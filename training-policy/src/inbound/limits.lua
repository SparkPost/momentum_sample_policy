module("inbound.limits", package.seeall);

require("msys.core");
require("msys.cidr");
require("msys.extended.ac");
require("msys.pbp");
require("inbound.library");

--[[
Two types of whitelists are supported, either from a datasource (such as a database 
or LDAP) or an RBLDNSD file.  The following common parameters are required:

type: either "datasource" or "rbldnsd"
name: name of the whitelist
refresh: an integer greater than or equal to 0
default_value: Must always be ""

Syntax for "datasource":
cachename: The name of a Datasource defined in ecelerity.conf
query: A query understood by the Datasource, which returns all CIDR blocks
       to whitelist, one row at a time.  Two columns must be returned, a
       value (which can be anything, even a static value) and the CIDR block.
cidr_column: The name of the column containing the CIDR block
value_column: The name of the column containing the value (the value is ignored
              for the purposes of the whitelist but something must be there)

Syntax for "rbldnsd"
source: Path to the rbldnsd source file on disk
record_type: Either "A" or "TXT"
]]

inbound.limits.conf = {
  whitelists = {
    good_guys = {
      type = "rbldnsd",
      refresh = 3600,
      source = "/var/tmp/good_guys.txt",
      record_type = "TXT",
      optimize_hosts = true,
      default_value = "",
      limits = {
        max_conn = 500,
        rcpt_ratelimit = 50000
      },
    },
  }, 
  default_limits = {
    max_conn = 1,
    rcpt_ratelimit = 50
  },
  -- Maximum number of concurrent connections error settings
  max_conn_code = 421,
  max_conn_reason = "4.7.1 - Connection refused - <%s> -  Too many concurrent connections",
  -- Maxiumum number of recipients per hour rate limit
  rcpt_rate_limit_code = 452,
  rcpt_rate_limit_reason = "Too many recipients received this hour.",
  -- DHA prevention rate limit
  invalid_rcpt_limit = 5,
  invalid_rcpt_limit_code = 452,
  invalid_rcpt_limit_reason = "Too many invalid recipients received this hour.",
  -- Message size limit
  message_size_limit = "30m",
  message_size_limit_code = 552,
  message_size_limit_reason = "Message too large; message rejected.",
  -- Global max connection limit
  global_max_conn = 20000,
  global_max_conn_code = 421,
  global_max_conn_reason = "4.7.1 - Connection refused - Too many concurrent connections",
};

local conf = inbound.limits.conf;

function active_for_phase(phase)
  if phase == "init" or phase == "accept" or 
     phase == "connect" or phase == "rcptto" or phase == "data" then
    return true;
  end
 
  return false;
end

function init()
  -- Define the whitelist CIDRDB entries
  for k, whitelist in pairs(conf.whitelists) do
    msys.cidr.define(k, whitelist);
  end

  -- Define the recipient rate limit audit series
  msys.audit_series.define("rcpt_valid", "cidr", 300, 12, {persist = true});
  msys.audit_series.define("rcpt_invalid", "cidr", 300, 12, {persist = true});

  return true; 
end

-- Called by the recipient validation and sending domain modules
--
-- Inputs:
-- key -- key to use for incrementing the audit series (string or 
--        accept construct user data)

function increment_invalid_recipient(ac)
  msys.audit_series.add("rcpt_invalid", {key = ac});
end

-- Increment the valid recipients audit series
--
-- Inputs:
-- key -- key to use for incrementing the audit series (string or 
--        accept construct user data)

function increment_valid_recipient(key)
  msys.audit_series.add("rcpt_valid", {key = ac});
end

-- Set the session limits to the provided table (only valid before the
-- connect phase limits check has been called)
--
-- Inputs:
-- self -- Connection-specific lua table (table)
-- t -- Limits to apply (table)

function set_limits(self, t)
  self.limits = t;
end

-- The Default Policy bits rely on the 'honor_whitelist' table to do the
-- whitelist checking, this function does the same thing but just for
-- a single whitelist

local whitelist_prefix = "dp_whitelist_";

-- Check whether the provided whitelist is active for this connection
-- Inputs:
-- vctx -- Momentum validation context (userdata)
-- list_name -- Whitelist name (string)
--
-- Outputs
-- Boolean -- true when whitelisted, false when not

local function check_whitelist(vctx, list_name)
  local whitelist = whitelist_prefix .. list_name;
  if vctx:exists(msys.core.VCTX_CONN, whitelist) == 1 or
     vctx:exists(msys.core.VCTX_MESS, whitelist) == 1 then
    return true;
  else
    return false;
  end
end

--
-- Apply the whitelists
-- Inputs:
-- ac -- Momentum accept construct (userdata)
-- vctx -- Momentum validation context (userdata)
-- limit -- Current limits previously defined (table)
--
-- Outputs:
-- table -- Limits to use (may be what was passed in if the limits didn't cahnge)

local function apply_whitelists_and_limits(ac, vctx, limit)
  local addr = inbound.library.ip_from_addr_and_port(ac.remote_addr);

  -- Then evaluate whitelists
  for k, v in pairs(conf.whitelists) do
    if check_whitelist(vctx, k) then
      limit = v.limits;
      break;
    end
  end

  return limit;
end

-- Inputs:
-- series -- Audit series to check (string)
-- limit -- Upper limit, above which the check fails (number)
-- vctx -- Momentum validation context (userdata)
-- ac -- Momentum accept construct (userdata)
--
-- Returns:
-- Boolean -- true when under the limit, false when over the limit

local function check_audit_series(series, limit, vctx, ac)
  -- NOTE: Assumes all series are 12 buckets
  local count = msys.audit_series.count(series, { key = ac, startv = 0, endv = 11 });
  if count > limit then
    return false;
  else
    return true;
  end
end

-- Setup the limits.
-- Inputs:
-- self -- Connection-specific Lua table
-- Outputs:
-- limits -- Lua table with the limits for this connection

local function setup_limits(self, ac, vctx)
  local limit = conf.default_limits;
  if self.limit then
    -- Something earlier told us some other defaults to use, do that
    limit = self.limit;
    -- Clear it out now
    self.limit = nil;
  end
  -- Connect phase rate limits.  First thing this does is evaluate the
  -- whitelists that may be set for this connection and set the rate
  -- limits appropriately in the validation context
  return apply_whitelists_and_limits(ac, vctx, limit);
end


-- Check function
-- Inputs:
-- self -- Connection-specific Lua table
-- phase -- Momentum SMTP phase (string)
-- ac -- Momentum accept construct (userdata)
-- vctx -- Momentum validation context (userdata)
-- msg -- Momentum ec_message (userdata)
-- str -- String (only for MAIL FROM or RCPT TO), (userdata, ec_string)
--
-- Outputs
-- continue -- True to continue validation, false for terminal action (boolean)
-- (Note that the following values are only meaningful if continue is false)
-- code -- SMTP code to return (number)
-- reason -- SMTP reason to return (string)
-- disconnect -- Whether or not to disconnect the connection (boolean)

function check(self, phase, ac, vctx, msg, str)
  local addr = inbound.library.ip_from_addr_and_port(ac.remote_addr);

  if phase == "accept" then
    -- Evaluate the whitelists
    for k, whitelist in pairs(conf.whitelists) do
      local whitelisted = msys.cidr.query(k);

      if whitelisted ~= "" then
        -- Whitelisted, set it in the context
        msys.pbp.set_whitelist(vctx, msys.core.VCTX_CONN, k, true);
      end
    end

    return true;
  elseif phase == "connect" then
    -- Start with defaults
    local limit = setup_limits(self, ac, vctx);
    -- Now we've got the limits.  Evaluate the connection limits, and 
    -- then set the rcpt rate limit for future use.

    local count = ac:pbp_inbound_session_count_service("SMTP", "/32");

    if count > limit.max_conn then
      return false, conf.max_conn_code, string.format(conf.max_conn_reason, addr), true;
    end

    local count = ac:pbp_inbound_session_count_service("SMTP", "/0");

    if count > conf.global_max_conn then
      return false, conf.global_max_conn_code, conf.global_max_conn_reason, true;
    end

    -- Set the recipient rate limit
    vctx:set(msys.core.VCTX_CONN, "rcpt_ratelimit", limit.rcpt_ratelimit);
  end

  -- Once the limits are established, in all cases enforce the rcpt rate
  -- limit as well as the rcpt invalid rate limit (DHA prevention)
  
  -- Check the recipient rate limit
  local rcpt_rate_limit = vctx:get(msys.core.VCTX_CONN, "rcpt_ratelimit");
  if not check_audit_series("rcpt_valid", tonumber(rcpt_rate_limit), vctx, ac) then
    return false, conf.rcpt_rate_limit_code, conf.rcpt_rate_limit_reason, true;
  end

  -- Check the invalid recipient/DHA limit
  if not check_audit_series("rcpt_invalid", conf.invalid_rcpt_limit, vctx, ac) then
    return false, conf.invalid_rcpt_limit_code, conf.invalid_rcpt_limit_reason, true;
  end

  -- Finally, enforce the message size limit for the data phase
  if phase == "data" then
    if msg:get_message_size() > msys.pbp.size_in_bytes(conf.message_size_limit) then
      return false, conf.message_size_limit_code, conf.message_size_limit_reason, false;
    end
  end

  return true;
end

-- vim:ts=2:sw=2:et

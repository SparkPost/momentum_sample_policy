module("inbound.rbl", package.seeall);

local counters = {};

require("msys.core");
require("msys.extended.ac");
require("msys.extended.vctx");
require("msys.cidr");
require("msys.pbp");
require("inbound.library");

-- Configuration of RBLs.  If another RBL is required, add it here.  Shouldn't
-- need to change the code.

--[[
Supports only RBLDNSD RBLs.

name: The name of the RBL, must be unique
code: Numeric SMTP response code to use for an RBL hit
reason: SMTP string to use for an RBL hit, %s is the RBL message
source: Path to the rbldnsd source file on disk
refresh: How often to reload the rbldnsd file

For all of the RBLs, you may define a 'process_result' function to override 
all processing of the result.  The function is defined like so:

inbound.rbl.conf = {
  rbls = {
    {
      ...
      ...
      process_result = function (ac, vctx, info)
          return false, 554, "RBL hit: " .. info;
        end,
    },
  }
};

The function is passed three parameters:

ac: The accept construct
vctx: The validation context
info: The result returned by the RBL.  Will be the first A or TXT record
      returned based on how the RBL was configured.

Its return value is the same as all policy modules in this strucure which
is:

Continue -- boolean about whether or not to continue processing
SMTP numeric code -- If Continue is false, this is the SMTP code to use
SMTP response string -- If Continue is false, this is the SMTP MDN
Disconnect -- Boolean indicating whether or not to disconnect
]]

inbound.rbl.conf = {
  honor_whitelist = { "good_guys" },
  rbls = {
    {
      check = true,
      type = "rbldnsd",
      name = "tmp_rbl",
      source = "/opt/msys/ecelerity/etc/rbl.txt",
      refresh = 3600,
      code = 554,
      reason = "Listed in the RBL",
    },
  }
};

local conf = inbound.rbl.conf

function active_for_phase(phase)
  if phase == "init" or phase == "accept" or phase == "connect" then
    return true;
  end

  return false;
end

function init()
  if conf.rbls ~= nil then
    for k, rbl in ipairs(conf.rbls) do
       if rbl.type == "rbldnsd" then
         msys.cidr.define(rbl.name, { type = "rbldnsd",
                                      source = rbl.source,
                                      value = rbl.record_type,
                                      refresh = rbl.refresh,
                                      interpolate = true });
      end
    end
  end
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
  local result;

  if msys.pbp.check_whitelist(vctx, conf.honor_whitelist) then
    -- Whitelisted, bail out early
    return true;
  end

  local addr = inbound.library.ip_from_addr_and_port(ac.remote_addr);
  for k, rbl in ipairs(conf.rbls) do
    -- rbl is each RBL defined above, so its check and whitelist members must
    -- be evaluated each time through the loop as it is different for each RBL
    if rbl.check then 
      if phase == "accept" and rbl.type == "rbldnsd" then
        result = msys.cidr.query(rbl.name, addr);
      elseif phase == "connect" and rbl.type == "dns" then
        local rip = inbound.library.reverse_ip(ac.remote_addr);

        local dns_result, err = msys.dnsLookup(rip .. "." .. rbl.base, 
                                               rbl.record_type or "A");

        if dns_result and #dns_result > 0 then
          result = dns_result[1];
        end
      end

      -- Result == "" and nil are functionally the same
      if result == "" then
        result = nil;
      end

      -- If the result wasn't nil, then the IP was in the RBL
      if result then
        if rbl.process_result ~= nil then
          local cont, code, reason, disconnect, stat = rbl.process_result(ac, vctx, result);

          if not cont then
            return cont, code, reason, disconnect, stat;
          end
        else
          return false, rbl.code, string.format(rbl.reason, result), true;
        end
      end
    end
  end
  return true;
end

-- vim:ts=2:sw=2:et


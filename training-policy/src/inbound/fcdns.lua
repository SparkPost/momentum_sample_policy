module("inbound.fcdns", package.seeall)
require("msys.core");
require("msys.pbp");
require("inbound.limits");

local mod = {}

inbound.fcdns.conf = {
  -- Limits to apply when FCDNS failed.  Note that the current behavior is to
  -- completely fail the connection if RDNS fails, so there are no limits
  -- for that case.
  fail_limits = {
    max_conn = 2,
    rcpt_ratelimit = 20,
  },
  -- Whitelists to honor, if a connection is any of these the FCDNS check
  -- is not performed.
  honor_whitelist = { 
    "good_guys" 
  },
  -- Reverse DNS failure code and message
  rdns_failure_code = 554,
  rdns_failure_message = "5.5.4 Relaying denied. IP name lookup failed for %s",
};

local conf = inbound.fcdns.conf;

function active_for_phase(phase)
  if phase == "connect" then
    return true;
  end

  return false;
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
  if not msys.pbp.check_whitelist(vctx, conf) then
    local addr = inbound.library.ip_from_addr_and_port(ac.remote_addr);
    -- The msys.pbp.fcdns_check() does both the reverse and forward lookups
    local success, rdns_error, fdns_error = msys.pbp.fcdns_check(ac, vctx);

    if success == false then
      local reverse_dns = vctx:get(msys.core.VCTX_CONN, "reverse_dns");
      if rdns_error ~= nil or reverse_dns == "" then
        if rdns_error == "NXDOMAIN" or 
           (rdns_error == nil and reverse_dns == "") then
          -- Reverse DNS failed
          if conf.rdns_failure_code ~= nil and conf.rdns_failure_message ~= nil then
            return false, 
                   conf.rdns_failure_code,
                   string.format(conf.rdns_failure_message, addr),
                   true;
          end
        else
          -- Temporary failure
          if conf.rdns_failure_code ~= nil then
            return false, 421, "Temporary resolution failure", true;
          end
        end
      else
        -- Reverse DNS succeeded, but the forward check failed
        local fcdns_status = vctx:get(msys.core.VCTX_CONN, "fcdns_status");
        if fcdns_status == 'false' then
          -- Poke these limits into our local data, which will get picked
          -- up by the limits module
          inbound.limits.set_limits(self, conf.fail_limits);
        end
      end
    end
  end
  return true;
end

-- vim:ts=2:sw=2:et


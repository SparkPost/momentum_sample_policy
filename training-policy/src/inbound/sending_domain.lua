module("inbound.sending_domain", package.seeall);
function active_for_phase(phase)
  if phase == "mailfrom" then
    return true;
  end
  return false;
end

function check(self, phase, ac, vctx, msg, str)
  local mailfrom = msg:mailfrom();

  if mailfrom ~= nil then
    local mailfrom_localpart, mailfrom_domain = string.match(mailfrom, "(.+)@(.+)");
    if mailfrom_domain ~= nil then
      local results, err = msys.dnsLookup(mailfrom_domain, "mx");
      if results == nil or #results == 0 then
        results, err = msys.dnsLookup(mailfrom_domain, "a");
      end
      if results == nil or #results == 0 then
        if err == "NXDOMAIN" then
          return false, 554, "Invalid sending domain", false;
        else
          return false, 451, "Temporary internal error", false;
        end
      end
    end
  end
  return true;
end

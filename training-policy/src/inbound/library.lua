module("inbound.library", package.seeall);
require("msys.core");

function ip_from_addr_and_port(sockaddr)
  local addr_and_port = tostring(sockaddr);
  local family = msys.core.ec_sockaddr_family(sockaddr);
  local ip;
  local sep;

  if family == msys.core.AF_INET then
    sep = ":";
  elseif family == msys.core.AF_INET6 then
    sep = "%.";
  end

  if sep == nil then
    return "0.0.0.0";
  end

  local port_index = string.find(addr_and_port, sep);

  if port_index ~= nil then
    ip = string.sub(addr_and_port, 1, port_index - 1);
  end

  return ip;
end

-- vim:ts=2:sw=2:et

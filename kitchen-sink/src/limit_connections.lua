require("msys.core")
 
require("msys.policyeditor")
 
require("msys.audit")
 
local mod = {};
 
 
 
function mod:validate_ehlo(str, accept, vctx)
 
  local ip, my_networks, current_limit;
  ip = msys.expandMacro("%{i}");
  print("From " .. ip .. " received EHLO " .. msys.expandMacro("%{vctx_conn:ehlo_domain}"));
  my_networks = msys.expandMacro("%{vctx_conn:my_networks}");
  current_limit = msys.expandMacro("%{vctx_conn:current_limit}");
  if my_networks != "yes" then
   local conn = msys.audit.connection("60,1")
    if conn > current_limit then
       print("EHLO : Too many concurrent connections from this client.");
       vctx:tarpit(10); -- time cost??
       vctx:disconnect(421, "Too many concurrent connections from this client.");
       return msys.core.VALIDATE_DONE;
    end
  end
  return msys.core.VALIDATE_CONT;
end
 
msys.registerModule("ehlo_phase", mod);

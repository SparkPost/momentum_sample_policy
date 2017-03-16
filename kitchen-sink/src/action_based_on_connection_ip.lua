require("msys.core");
require("msys.extended.vctx");
require("msys.audit");
 
local mod = {};
 
function mod:validate_connect(accept, vctx)
 local myipcount = msys.audit.inbound_session_count("/32", "SMTP");
 local max_con_per_ip = 2;
 --Various methods could be used to determine the value of some_ip
 local some_ip = "127.0.0.1";
 local this_ip = msys.expandMacro("%{spfv1:i}");
        if this_ip == some_ip then
         max_con_per_ip = 1;
        end
        print("IP: " .. this_ip .. "Sessions: " ..  myipcount);
        if myipcount > max_con_per_ip then
           vctx:disconnect(421, "Too many simultaneous connections from: " .. this_ip);
           return msys.core.VALIDATE_DONE;
         end
 return msys.core.VALIDATE_CONT;
end
 
msys.registerModule("connectionlimit", mod);

-- You will need 2 different scripts for this. First, an each_rcpt.lua 
-- Second set_binding.lua
local mod = {};
require("msys.core");require('msys.extended.message');
 
function mod:validate_data_spool_each_rcpt(msg, accept, vctx)  
    msg:context_set(msys.core.ECMESS_CTX_CONN, "FBL", "Mytestcontextvar");  
    return msys.core.VALIDATE_DONE;
end
 
msys.registerModule('validate_data_spool_each_rcpt', mod);

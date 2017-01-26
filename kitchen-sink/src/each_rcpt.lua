local mod = {};
require("msys.core");
require("msys.extended.message");
 
local mctx = msys.core.ECMESS_CTX_MESS;
 
function mod:validate_data_spool_each_rcpt(msg, accept, vctx)
 
   -- Create vctx based off X-Binding header
   local binding = msg:header( "X-Binding" )[1];
   if binding ~= nil then
      msg:context_set(mctx, "binding", binding);
   end
   msg:header("X-Binding","");
 
 return msys.core.VALIDATE_DONE;
 
end
 
 
msys.registerModule('validate_data_spool_each_rcpt', mod);

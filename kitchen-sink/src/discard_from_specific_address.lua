require("msys.core");
 
local mod = {};
 
function mod:validate_data(msg, acc, vctx)
   local myMsg = msg:mailfrom();
   if myMsg == "jdoe@example.com" then
     msg:discard ("550 5.7.0 discarded due to OOB responses");
   end;
  return msys.core.VALIDATE_DONE;
end;
 
msys.registerModule("data", mod);

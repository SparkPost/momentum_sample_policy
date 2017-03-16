require("msys.core");
require("msys.extended.message");
require('msys.extended.vctx');
require('msys.dumper');
 
local mod = {};
 
function mod:validate_data(msg, accept, vctx)
   local to = vctx:recipient_list();
   print ("Rcptto is currently set to",msys.dumper.Dumper(to));  --this prints the array but you could do anything you like.
   return msys.core.VALIDATE_CONT;
end
 
msys.registerModule("validate_data", mod);

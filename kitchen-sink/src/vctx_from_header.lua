local mod = {};
require("msys.core");
require("msys.extended.message");
  
local mctx = msys.core.ECMESS_CTX_MESS;
  
function mod:validate_data_spool_each_rcpt(msg, accept, vctx)
-- Create vctx based off a header
local hdr = msg:header( "Reply-To" )[1];
if hdr ~= nil then
msg:context_set(mctx, "rtheader", hdr);
end
return msys.core.VALIDATE_DONE;
end
  
msys.registerModule('setheader', mod);

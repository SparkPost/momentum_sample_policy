require("msys.core");
require("msys.extended.message");
require("msys.extended.vctx");
 
local mod = {};
 
 
function mod:validate_mailfrom(str, accept, vctx)
  local spfpass = vctx:get(msys.core.ECMESS_CTX_MESS, "spf_status");
     if spfpass == "fail" then
      --could also use vtcx:disconnect() if desired..
        vctx:set_code(550, "SPF HARD FAIL");
        return msys.core.VALIDATE_DONE;
     end
 return msys.core.VALIDATE_CONT;
end
 
msys.registerModule("spfreject", mod);

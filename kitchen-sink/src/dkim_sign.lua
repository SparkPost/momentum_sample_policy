require("msys.core");
require("msys.extended.message");
require("msys.validate.dkim");
 
local mod = {};
 
--[[ Set dkim key and domain based on x-header ]]--
function mod:core_final_validation(msg, accept, vctx)
  local options = {};
  -- this is a custom header inserted by the customer for controlling what domain to
sign with
 -- if not present, Momentum will sign with the implicit dkim key and domain name
 -- otherwise will change the base_domain accordingly.
 
local dkimdomain = msg:header("X-DkimDomain");
local existing_dkim = msg:header("DKIM-Signature");
 
    if ((dkimdomain[1] ~= "") and (dkimdomain[1] ~= nil)) then
        -- by default dkim is enabled and signing again will create two headers
        if ((existing_dkim[1] ~= "") and (existing_dkim[1])) then
            msg:header("DKIM-Signature","");
        end
        options["sign_condition"] = "can_relay";
        options["digest"] = "rsa-sha256";
        options["header_canon"] = "relaxed";
        options["body_canon"] = "relaxed";
        options["headerlist"] = "From:Subject:Date:To:MIME-Version?:Content-Type?";
        options["base_domain"]= dkimdomain[1];
        options["selector"] = "default";
        options["key"] = "/opt/msys/ecelerity/etc/conf/default/dkim/default_".. dkimdomain[1] ..".key"
     
        -- this is for the case when print is disabled
        -- msys.validate.dkim.sign(nil, nil, options);
        print("msys.validate.dkim.sign returns ", msys.validate.dkim.sign(nil, nil, options));
    else
        print(">>>>>>>>>>>>> No DKIM Set");
    end
return
msys.core.VALIDATE_CONT
end
 
msys.registerModule("policyDkim",mod);

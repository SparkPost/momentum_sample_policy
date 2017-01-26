require('msys.extended.message');
 
local mod = {};
function mod:validate_set_binding(msg)
 
    local from = msg:mailfrom();
    local localpart_str = msys.core.string_new();
    local domain_str = msys.core.string_new();
    msg:get_envelope2(msys.core.EC_MSG_ENV_FROM, localpart_str, domain_str);
    local domain = tostring(domain_str);
    localpart_str = nil;
    if msys.pcre.match(domain, "mydomain.com") then
        msg:binding("mydomain");
        return msys.core.VALIDATE_DONE;
    else
        return msys.core.VALIDATE_CONT;
    end;
end;
msys.registerModule("validate_set_binding", mod);

local mod = {};
require("msys.core");
require("msys.extended.message");
 
local mctx = msys.core.ECMESS_CTX_MESS;
function mod:validate_set_binding(msg, accept, vctx)
 
    local binding = msg:context_get(mctx, "binding");
 
    if binding ~= nil then
       local evalBind = msys.core.config_get_binding_id_from_name(binding);
       local evalBindingGrp = msys.core.config_get_binding_group_size(binding);
       if evalBind >= 0 then
          msg:binding(binding);
       elseif evalBindingGrp > 0 then
          msg:binding_group(binding);
       else       
          msg:binding("fallthrough binding"); -- this could also easily be msg:binding_group(default binding group) if you want a binding group instead.
       end
    else
       msg:binding("fallthrough binding"); -- this could also easily be msg:binding_group(default binding group) if you want a binding group instead.
    end
 
    return msys.core.VALIDATE_DONE;
 
end
 
msys.registerModule('validate_set_binding', mod);

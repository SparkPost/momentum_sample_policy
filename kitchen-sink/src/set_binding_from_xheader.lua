-- This sets a binding based on a custom X-header.
require("msys.extended.message")
require("msys.pcre")
 
local mod = {};
 
function mod:validate_set_binding(msg)
  local bindingGroup = msg:header("X-Group")
 
  if (#bindingGroup ~= 0) then
    msg:binding_group(bindingGroup[1])
  else
    local binding = msg:header("X-Binding");
    if (#binding ~= 0) then
      msg:binding(binding[1]);
    end
  end
  return msys.core.VALIDATE_CONT
end
 
msys.registerModule("setBinding", mod);

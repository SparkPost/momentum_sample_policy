local core = require('msys.core')
require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");

local mod = {};

function mod:validate_set_binding(msg)
  msg:binding("spe_relay_binding");
  local b = msg:context_get(core.VCTX_MESS, 'binding')
  print("XXXX STATE: validate_set_binding - " .. tostring(b))
  return msys.core.VALIDATE_CONT;
end


msys.registerModule("spe-relay", mod);

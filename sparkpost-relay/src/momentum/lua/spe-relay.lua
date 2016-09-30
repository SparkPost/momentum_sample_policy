local core = require('msys.core')
require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");

local mod = {};

function mod:validate_set_binding(msg)
  msg:binding("spe_relay_binding");
  local binding = msg:context_get(core.VCTX_MESS, 'binding')
  print("validate_set_binding - " .. tostring(binding))
  
  if tostring(getconf(binding, nil, 'outbound_smtp_auth_user')) ~= 'SMTP_Injection' then
    print('Message is being relayed through SparkPost')
  end

  return msys.core.VALIDATE_CONT;
end


function mod:outbound_smtp_auth_config(msg, ac, vctx)
   print('You should set the binding if using SparkPost Elite');
   -- msg:header('X-Binding', 'test')
end


function getconf(binding, domain, optname)
  if type(binding) == "number" then
    binding = msys.core.config_get_binding_name_from_id(binding);
  end
  if domain == nil then
    return msys.config("get", "binding", binding, optname);
  end
  return msys.config("get", "binding", binding, "domain", domain, optname);
end


msys.registerModule("spe-relay", mod);

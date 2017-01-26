--The following entry is strongly recommended in order to get the best results from this script
 
keep_message_dicts_in_memory = true
 
-- this scriptlet setting is required if you have no other scriptlet stanza.
-- scriptlet scriptlet {
--   script lua_logger {
--     source = "logger.lua"
--   }
-- }
 
 
logger.lua
 
require("msys.core");
local mod = {};
local context_variable = "last_transfail";
 
function mod:core_log_permanent_failure_v1(msg, domain, now, note, note_len)
  note = msg:get_code();
 
  if string.find(note, "^554 5%.4%.7 %[internal%] exceeded max") then
    local exists, new_note = msg:context_exists_and_get(msys.core.ECMESS_CTX_MESS,
                                                        context_variable);
    if exists == 1 and new_note then
      msg:set_code(554, "5.4.7 [internal] message timeout (last transfail: " ..
                   new_note .. ")");
    end
  end
end
 
function mod:core_log_transient_failure_v1(msg, domain, now, note, note_len)
  msg:context_set(msys.core.ECMESS_CTX_MESS, context_variable, msg:get_code());
end
 
msys.registerModule("lua_logger", mod);

-- Grabbing the remote message id on delivery (assuming that the remote machine 
-- gives one in the same line as the 250OK)
--

require("msys.extended.message");
require("msys.core");
 
local mod = {};
 
function mod:core_log_delivery_v1(msg, dr, now, note, notelen)
  print ("core_log_delivery_v1: Grabbing the remote message id on delivery");
  local reason = note
  if reason == nil or #reason == 0 then
    reason = msg:get_code();
  end
  local id = msg.id;
  print ("local messageid: ", id ," remote messageid: ", reason);
end
 
msys.registerModule("test", mod)

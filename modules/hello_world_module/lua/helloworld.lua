-----------------------------------
-- To use this add the following:
--
--    script "helloworld" {
--      source = "helloworld"
--    }
--
-- to the scriptlets tag in 
--     /opt/msys/ecelerity/etc/conf/default/ecelerity.conf
-----------------------------------

local core = require("msys.core");
local em = require("msys.extended.message");

local mod = {}

-- Momentum will call this hook whenever a delivery event should be logged.
-- see: https://support.messagesystems.com/docs/web-c-api/hooks.core.log_delivery_v1.php
function mod:core_log_delivery_v1(msg, dr, now, note, notelen)
  print ("hello_world[LUA]: core_log_delivery_v1 ");

  -- my_msg was set in the message context in the C module code
  local helloMsg = msg:context_get(msys.core.ECMESS_CTX_MESS, "my_msg");

  print("hello_world[LUA]: Our Message is: " .. tostring(helloMsg));
  
end


msys.registerModule('helloworld', mod);


require("msys.core");
require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");
local mod = {};
function mod:validate_data(str, accept, vctx)
  local mc = msys.core.accept_construct_get_message_construct(accept);
  local msg = mc.message;
  local rcptto = msg:rcptto();
    -- print    ("rcptto: ",rcptto);
 if (rcptto == "someemail@example.com") then vctx:add_recipient("bcced_email@example.com");
  print ("Added the additional recipient to the oob");
  end    local addrs = vctx:recipient_list();
  -- print ("Recipient list : ",msys.dumper.Dumper(addrs));
  return msys.core.VALIDATE_CONT;
end
msys.registerModule("blergh", mod);

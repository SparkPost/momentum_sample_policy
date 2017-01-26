-- Adding a recipient to all mail destined to a givien local part

require("msys.core");require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");
local mod = {};
function mod:validate_data(str, accept, vctx)
  local rcluser = msys.core.string_new();
  local rcdom= msys.core.string_new();
  local mc = msys.core.accept_construct_get_message_construct(accept);
  local msg = mc.message;
  msg:get_envelope2(msys.core.EC_MSG_ENV_TO, rcluser, rcdom);
  local myLocalpart = tostring(rcluser);
  myLocalpart = trim(myLocalpart);
  print ("RCUser :",myLocalpart,":");
  print ("RCDom : ",rcdom.buffer);
  if (myLocalpart == "bounce") then       vctx:add_recipient("bounce_review@your.tld");
    print ("Added the additional recipient to the oob");
  end    local addrs = vctx:recipient_list();
  print ("Recipient list : ",msys.dumper.Dumper(addrs));
  return msys.core.VALIDATE_CONT;
end
  
msys.registerModule("validate_data", mod);


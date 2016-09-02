local core = require("msys.core")
require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");

local mod = {};

function mod:core_post_msg_each_rcpt(msg, ac, vctx)
    print("XXXX SECOND: core_post_msg_each_rcpt " .. msg.recv_method)

    -- do not process internally generated messages
    if msg.recv_method == msys.core.P_INTERNAL then
      print("XXXX SECOND: " .. tostring(msg.id) .. " is an internally generated message")
      return
    end

    local secondaryAddress = "secondary@http-archive-gateway.local"
    -- 2 = ESMTP
    if msg.recv_method == 2 then 
        secondaryAddress = "esmtp@http-inbound-gateway.local"
    end

    local recipient = msg:rcptto();
    if recipient == secondaryAddress then
        print("XXXX SECOND:  Found", secondaryAddress)
        return
    end 

    print("XXXX SECOND: sending to ", secondaryAddress)
    local new_msg = msg:copy()
    new_msg:inject(msg:mailfrom(), secondaryAddress)

    return
end


msys.registerModule("secondary_delivery", mod);


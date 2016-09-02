local core = require("msys.core")
local message = require("msys.extended.message")
local smpp = require("msys.smpp")
local json = require("json")

local mod = {}

local function header(msg, field_name)
    local field_body = msg:header(field_name)
    if field_body[1] then
      return field_body[1]
    end
    return nil
end

--
-- create a message from a sms_submit response bound for the http-gateway
-- the message contains a X-SMS-ACK header which is a JSON object
-- this simplifies the http-gateway code so no parsing is needed
function mod:smpp_submit_response(msg, pdu)
    local id = msys.smpp.smpp_get_message_id_from_pdu(pdu)
 
    -- submit response don't have a 'From' or Source address
    -- so the JSON object doesn't have it either
    local data = json.new()
    data.type = 'sms-ack'
    data.from = msg:mailfrom()
    data['message-id'] = tostring(id)
    data['transmission-id'] = tostring(msg:context_get(core.ECMESS_CTX_MESS, "mo_transmission_id"))
    data.rcptto = tostring(msg:rcptto())
    data.date = header(msg, "Date")

    local headers = {}
    local text = json.encode(data)
    headers["X-SMS-ACK"] = tostring(text)

    -- If we need to send an ACK uncomment this: --
    --local ack = msys.core.ec_message_new(nil)
    --ack:build(headers, {}, {})  -- create an empty message, with just a header
    --ack:inject("mailer-daemon@localhost", "sms@http-sms-receiver-gateway.local")

    return smpp.SMPP_CONTINUE
end

msys.registerModule('sms2http', mod)





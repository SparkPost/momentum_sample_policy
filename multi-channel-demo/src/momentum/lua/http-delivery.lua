local db = require("msys.db")
local datasource = require("msys.datasource");
local core = require 'msys.core' 
local httpclnt = require 'msys.httpclnt'
local delivery = require 'msys.delivery'
local http = require 'msys.http_lua'
local json = require 'json' 

local CTXM = core.ECMESS_CTX_MESS

local mod = {}

local function header(msg, field_name)
    local field_body = msg:header(field_name)
    if field_body[1] then
      return field_body[1]
    end
    return nil
end

function mod:build_request(session)
    print("XXXX HTTP:  build request")

    local msg = delivery.ob_get_current_message(session.connh)
    print("msg : ", msg:text())

    local data = json.new()
    local smsData = json.new()

    -- a X-SMS-ACK message is a mail message generated in sms2http.lua
    -- it contains a json body that allows mapping of sms-ids to recipient/sender pairs
    -- the message is a MIME message as well
    if(header(msg, "X-SMS-ACK")) then
      data = json.decode(header(msg, "X-SMS-ACK"))
    else  
      data.type = "msg"
      data.from = msg:mailfrom() 
      data.date = header(msg, "Date")
      data.to = msg:context_get(CTXM, "SMS_Destination_Address")
      data.toEmail = header(msg, "To")
      data['message-id'] = header(msg, "Message-ID")
      data.subject = header(msg, 'Subject')
  
      local smsData = json.new()
      smsData.body = msg:text()
      data.msg = smsData
    end

    -- local json = '{"type":"sms", "from":"' .. msg:mailfrom() .. '", "date":"' .. tostring(date[1]) .. '",  "to":"' ..  toAddress .. '"}'
    local json_string = tostring(json.encode(data))
    print("XXXX HTTP: Sending: ", json_string)

    session:request_add_header("Accept", "appliation/json", 0);
    session:request_add_header("Content-Type", "application/json", 0);

    httpclnt.http_request_add_header(session, "Content-Length", #json_string, 1);
    httpclnt.http_request_set_body(session, json_string);

end

function mod:handle_response(session)
    print("XXXX HTTP:  handle_response")
    return httpclnt.HTTP_INTERNAL_DONE
end


http.registerModule('http-delivery', mod)


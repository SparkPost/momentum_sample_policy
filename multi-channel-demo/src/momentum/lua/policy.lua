
require("msys.core");
require("msys.db");
require("msys.pcre");
require("msys.dumper");
require("msys.extended.message");
require("msys.extended.message_routing");
require("msys.extended.ac");

local mod = {};

--[[ Modify these as necessesary for your demo ]]--
local sinkdomain = "54.69.70.202"
local safedomains = { "eu.sms.int", "usi.sms.int", "uso.sms.int", "validator.messagesystems.com", "messagesystems.com", "sparkpost.com", "yepher.com", "http-gateway.local", "http-sms-receiver-gateway.local", "http-inbound-gateway.local", "http-archive-gateway.local" }

--[[ each rcpt_to function ]]--
function mod:validate_data_spool_each_rcpt (msg, accept, vctx)
    return msys.core.VALIDATE_CONT;
end 


--[[ each MSG_GEN rcpt_to function ]]--
function mod:msg_gen_data_spool(msg)
    -- print ("XXXX POLICY: Using msg_gen_data_spool");
    return msys.core.VALIDATE_CONT;
end


--[[ Set Binding function ]]--
function mod:validate_set_binding(msg)
    local domain_str = msys.core.string_new();
    local localpart_str = msys.core.string_new();
    msg:get_envelope2(msys.core.EC_MSG_ENV_TO, localpart_str, domain_str);
    local mydomain = tostring(domain_str);
    local mylocalpart = tostring(localpart_str);
    local validdomain = "false"
    local hdr_JobID =  msg:header("X-JOB-ID")
    local hdr_IPInstance = msg:header("X-Ipinstance") 
    local hdr_Region = msg:header("X-Region")
    local bindingname = msg:header("X-Binding")

    if hdr_JobID[1] then 
        msg:context_set(msys.core.VCTX_MESS, "mo_campaign_id", hdr_JobID[1]);
    end

    if hdr_IPInstance[1] then 
        msg:context_set(msys.core.VCTX_MESS, "mo_IP_Instance", hdr_IPInstance[1])
    end

    if hdr_Region[1] then 
        msg:context_set(msys.core.VCTX_MESS, "mo_region", hdr_Region[1])
    end

    if bindingname[1] then 
        msg:context_set(msys.core.VCTX_MESS, "mo_binding", bindingname[1])
    end


    -- Test to see if the TO domain is in the safe list
    for i,v in ipairs(safedomains) do
        if v == mydomain then
            --  print ("XXXX POLICY: Routing to a valid domain: " .. mydomain);
            validdomain = "true"
            break
        end
    end

    if validdomain == "false" then
        --  print ("XXXX POLICY: Sending this to sink: " .. sinkdomain .. " / " .. mydomain);
        msg:routing_domain(sinkdomain);
    end

    if ( ( bindingname[1] ~= "" ) and (bindingname[1] ~= nil ) )  then
        local err = msg:binding(bindingname[1]);
    else 
        local err = msg:binding("generic");
    end


    -- print(msg:context_get(msys.core.ECMESS_CTX_MESS, 'mo_campaign_id'));
    return msys.core.VALIDATE_CONT;
end;

msys.registerModule("policy", mod);


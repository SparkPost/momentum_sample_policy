-- Relevant Ecelerity configuration elements for this example:
-- 13:51:38 /tmp/2025> config showrecurse binding default
-- suspend_delivery = true
-- 13:57:52 /tmp/2025> config showrecurse binding DNS
-- Bind_Address = 192.168.122.200
-- 13:57:58 /tmp/2025> config showrecurse binding SMARTHOST
-- Bind_Address = 192.168.122.200
-- 14:01:03 /tmp/2025> config showrecurse scriptlet "scriptlet"
-- script "smarthost" {
-- source = "lua.smarthost"
-- }
-- script "boot" {
-- source = "msys.boot"
-- }
-- 

require("msys.core");
require("msys.extended.message");
require("msys.extended.vctx");
require('msys.extended.message_routing');
local mod = {};
function mod:validate_data_spool_each_rcpt (msg, accept, vctx)
 local myroute = msg:routing_domain();
 local myrcptdomain = msg:context_get(msys.core.ECMESS_CTX_MESS, "rcptto_domain");
--Any logic available could be used to determine which messages should be routed to the "smart host"
--In this case the rcppto_domain is evalulated for a single domain
        if myrcptdomain == "smarthostdomain.tld" then
                msg:routing_domain("my.smart.host");
                msg:context_set(msys.core.ECMESS_CTX_MESS, "DNS_DOMAIN", "FALSE");
                msg:context_set(msys.core.ECMESS_CTX_MESS, "SMART_HOST", "TRUE");
        else
                 msg:context_set(msys.core.ECMESS_CTX_MESS, "DNS_DOMAIN", "TRUE");
        end
return msys.core.VALIDATE_CONT;
end
 
--We would like messages that are routed via DNS to go out to the DNS binding.
--We would like messages that are routed via the my.smart.host domain container to go out the SMARTHOST binding
--No messages should hit the default binding but if they do delivery has been suspendined for that binding.
function mod:validate_set_binding(msg)
 if (msg:context_get(msys.core.ECMESS_CTX_MESS, "DNS_DOMAIN"))  == "TRUE" then
        msg:binding("DNS");
 elseif (msg:context_get(msys.core.ECMESS_CTX_MESS, "SMART_HOST")) == "TRUE" then
        msg:binding("SMARTHOST");
 else 
        msg:binding("default");
 end
return msys.core.VALIDATE_CONT;
end
msys.registerModule("smarthost", mod);

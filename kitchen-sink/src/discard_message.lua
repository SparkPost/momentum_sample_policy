require("msys.core");
require("msys.extended.message");
require("msys.extended.message_routing");
 
local mod = {};
function mod:validate_rcptto(msg, str, accept, vctx)
    local recipient = msg:rcptto();
    local matches, errstr, errnum = msys.pcre.match(recipient, "(?P<localpart>[Lua Examples^@]+)@(?P<domain>[Lua Examples^>]+)")
    if (matches != nil) then
        domain = matches["domain"]
        if (domain == "yahoo.com") then
            msg:discard("QA: Discarding message before it can be sent");
            print ("QA: Dropping message to ", recipient);
            return msys.core.VALIDATE_DONE;
        end
    end
    print ("QA: Sending message to ", recipient);
    return msys.core.VALIDATE_CONT;
end
 
msys.registerModule("validate_rcptto", mod);

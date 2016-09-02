-- This is a basic suppression list implementation. It relies on datasource caching to improve performance but in a high volume
-- production system more advanced techniques like bloom fitlers should be used
--

local db = require("msys.db")
local ds = require("msys.datasource");
local core = require 'msys.core'
local ex = require("msys.extended.message");

local CTXM = core.ECMESS_CTX_MESS

local mod = {}

local function isSuppressed(address)
--    print("XXXX SUP: check suppression: ", address)
    local rowset, err = msys.db.query("preferencesdb", [[
        SELECT BULK FROM BLACKLIST WHERE
        ADDRESS = ? LIMIT 1]], { address }, {});

    if rowset != nil then
        local row;
        for row in rowset do
            if row.BULK == 1 then
                print("XXXX SUP: blocked: ", address,  row.BULK );
                return 1
            end
        end
    else
        -- print error to paniclog.ec
         print("XXXX SUP: error querying blacklist:", err);
    end
    print("XXXX SUP: allowed: ", address );
    return 0 
end

local function check_suppression_lists(msg) 
--    print("XXXX SUP: checking...");
    -- Fetch the recipient, canonicalize to lower case
    local rcptto = string.lower(msg:rcptto());
    if isSuppressed(rcptto) == 1 then
         -- XXX check the json result to decide if we want to suppress
         local reason = string.format("554 5.7.1 recipient address was suppressed due to customer policy")
         msg:discard(reason);
    end
end

function mod:core_post_msg_each_rcpt(msg, ac, vctx)
    -- ADD a check here to make sure we are processing outbound mail
    -- We don't want to do suppression checks on inbound mail (OOB, FBL)
    --if is_outbound(msg, vctx) then
--    print("XXXX SUP: entry...");
    check_suppression_lists(msg);

    --end
end

msys.registerModule('suppression_lists', mod)



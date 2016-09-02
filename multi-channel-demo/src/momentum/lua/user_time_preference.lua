--

local db = require("msys.db")
local ds = require("msys.datasource");
local core = require 'msys.core'
local ex = require("msys.extended.message");

local CTXM = core.ECMESS_CTX_MESS

local mod = {}

-----------------
-- currentSecond() returns a value between 0 and 86400 which represents now is the Nth second of the day
-----------------
local function currentSecond()
    local hours = tonumber(os.date("%H"))
    local minutes = tonumber(os.date("%M"))
    local seconds = tonumber(os.date("%S"))

    -- nil is sometimes getting returned from above so we define againg nil here
    if hours == nil then 
        hours = 0
    end

    if minutes == nil then
        minutes = 0
    end
  
    if seconds == nil then
        seconds = 0
    end

    local currentSecond = (hours * 3600) + (minutes * 60) + seconds
    print("XXXX USER: Current Second: " .. currentSecond)
    return currentSecond
end

-----------------
-- isQuietTime(userId, currentTime) Return
--    1 - is Quiet Time
--    0 - Not Quiet Time
-----------------
local function isQuietTime(userId, currentTime)
    -- print("XXXX QT: check Quiet Time for user " .. userId .. " at " .. currentTime)
    local rowset, err = msys.db.query("preferencesdb", "SELECT count(*) AS COUNT, NOTE FROM USER_PREF WHERE ID = ? AND QUIET_START <= ? AND QUIET_END >= ?", {userId, currentTime,  currentTime}, { } );

    if rowset != nil then
        local row;
        for row in rowset do
             if row.COUNT > 0 then
                 print("XXXX QT: QuietTime=" .. row.COUNT .. ", " .. row.NOTE)
             end
            return row.COUNT
        end
    else
        -- print error to paniclog.ec
         print("XXXX QT: error querying isQuietTime(" .. userId .. ", " .. currentTime .. ")", err);
    end
    return 0
end

-----------------
-- alternateAddress(userId, currentTime) Return
--    nil - no alternate address found
--    STRING - Alternate address to use
-----------------
local function alternateAddress(userId, currentTime)
    print("XXXX PRE: check Alt Address time for user " .. userId .. " at " .. currentTime)
    local rowset, err = msys.db.query("preferencesdb", "SELECT ADDRESS, NOTE FROM USER_ALT_ADDRESS WHERE USERID = ? AND START <= ? AND END >= ?", {userId, currentTime,  currentTime}, { } );
    if rowset != nil then
        local row;
        for row in rowset do
             if row.ADDRESS ~= nil then
                 print("XXXX PREF: Alt Address Found " .. row.ADDRESS .. ", " .. tostring(row.NOTE) )
                 return row.ADDRESS
             end
        end
    else
        -- print error to paniclog.ec
         print("XXXX PREF: error querying alternateAddress(" .. userId .. ", " .. currentTime .. ")", err);
    end
    
    return nil
end

function mod:core_post_msg_each_rcpt(msg, ac, vctx)
    local metadata = msg:context_get(CTXM, 'mo_rcpt_meta')
    print("XXXX USER: mo_rcpt_meta: ", tostring(metadata)) 

    -- TODO: non user specific quiet time processing. (Hope to not acutally do this to keep demo easier)

    local mobj, code, err = json.decode(tostring(metadata))
    if mobj then
        -- Check if transmission contains userId
        local userId = mobj.userId
        if userId == nil then
            -- No user info so skip user preference processing
            return
        end
        print("XXXX USER: UserId: " .. userId)

        -- Check if transmission overrides current time of day (seconds)
        local currentTime = currentSecond() 
        local timeOverride = mobj.timeOverride
        if timeOverride ~= nil then
            print("XXXX USER: Time override provided in transmission: " .. currentTime .. " changed to: " .. timeOverride)
            currentTime = timeOverride
        end
        print("XXXX USER: Time Reference: : " .. currentTime)

        -- Quiet time supercedes other user time based preferences
        if isQuietTime(userId, currentTime) == 1 then
             print("XXXX QT: discarding message due to quiet time ")
             local reason = string.format("554 5.7.1 recipient(" .. userId .. ") was suppressed due to user quiet time  policy")
             msg:discard(reason);
             return
        end

        -- User Alternate Address for Time of Day
        local alternateAddress = alternateAddress(userId, currentTime)
        if alternateAddress ~= nil then
             print("XXXX PREF: User has specified alternate address " .. alternateAddress)

             local new_msg = msg:copy()
             new_msg:inject(msg:mailfrom(), alternateAddress)

             -- Discard initial message since it is being routed to a new address
             local reason = string.format("554 5.7.1 recipient(" .. userId .. ") has specified alternate address " .. alternateAddress)
             msg:discard(reason);
             return
        end

        return
    end

    print("XXXX USER: No user in transmission.")
    return
end

msys.registerModule('er_time_preference', mod)



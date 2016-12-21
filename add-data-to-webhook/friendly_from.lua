require("msys.core")

local mod = {}

-- set mo_friendly_from if it exists so it is delivered in webhooks
function mod:core_pre_msg_each_rcpt(msg, ac)

  local from = msg:header("reply-to");
  if from ~= nil and from[1] ~= nil then
    debug.output('mo_friendly_from: ' .. tostring(from[1]))
    
    -- Writing context that start with "mo_" will be available in webhook events too
    msg:context_set(msys.core.ECMESS_CTX_MESS, "mo_friendly_from", tostring(from[1]))
  end
end

msys.registerModule("friendly_from", mod)

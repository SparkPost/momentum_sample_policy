require("msys.core");
require("msys.extended.vctx");
require("msys.extended.ac");

-- This is the list of policies to load, a Lua array
local policies = {
  "inbound.limits",
  "inbound.rbl",
  "inbound.fcdns",
};

-- NOTE: You should not usually need to modify anything below this line,
-- any policy work should be done in a separate policy module in the 
-- 'policies' array above.  The only exception is if there's some sort of 
-- unilateral action that you might want to take at the end of any given
-- phase, after all policies have executed.  One way to do that would be to
-- list such a policy last in the array above, as the policies are called
-- in order.  If that is not feasible, logic may be inserted into any of
-- the validate callouts, just before the 'return msys.core.VALIDATE_CONT' 
-- at the end, which will only be executed if all of the policy checks
-- passed successfully.  A use case for that may be incrementing a 
-- statistic or accreting log information in the event of a success (but
-- only in the event of a success).

local loaded_policies = {};

-- Load all of the policies into a local table that we can iterate for each
-- policy phase to see which ones we want to execute
for k, v in ipairs(policies) do
  table.insert(loaded_policies, require(v));
end;

local mod = {}

-- Init all the policies that have an init phase
function mod:init()
  for k, v in ipairs(loaded_policies) do
    if v.active_for_phase("init") then
      v.init();
    end
  end

  return true;
end

-- This is the root policy file, which is what plugs into the Momentum 
-- scriptlet module.  No actual policy is implemented here, that's done
-- in the subordinate modules.  Each policy defines the active_for_phase()
-- function that returns true if the policy should execute for the relevant
-- phase.  The check routine returns the following:
--
-- Continue -- boolean about whether or not to continue processing
-- SMTP numeric code -- If Continue is false, this is the SMTP code to use
-- SMTP response string -- If Continue is false, this is the SMTP MDN
-- Disconnect -- Boolean whether or not to disconnect the session
--
-- If Continue is true, processing proceeds.  If Continue is false, processing
-- stops and processing stops.
--
-- The wrapper function call_policy takes care of all of the conditional
-- logic around the return value of the policy itself

local function call_policy(self, phase, ac, vctx, msg, str)
  for k, v in ipairs(loaded_policies) do
    if v.active_for_phase(phase) then
      local continue, code, str, disconnect = v.check(self, phase, ac, 
                                                      vctx, msg, str);

      if not continue then
        -- The policy told us to stop
        vctx:set_code(code, str);
        if disconnect then
          -- The policy told us to disconnect
          vctx.disconnect = 1;
        end

        return false;
      end
    end
  end

  return true;
end

local function purge_self(self)
  for k, v in pairs(self) do
    self[k] = nil;
  end
end

-- accept phase
-- Inputs:
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:core_validate_accept(ac, vctx)
  -- Purge any lingering per-session state
  purge_self(self);

  if not call_policy(self, "accept", ac, vctx, nil, nil) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- Connect phase
-- Inputs:
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:validate_connect(ac, vctx)
  -- Purge any lingering per-session state
  purge_self(self);

  if not call_policy(self, "connect", ac, vctx, nil, nil) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- mailfrom phase
-- Inputs:
-- str -- userdata (ecstring) -- MAILFROM string, canonicalized
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:validate_mailfrom(str, ac, vctx)
  -- Fetch the message from the message construct.  It's available, but for
  -- legacy reasons it's not in the validate_mailfrom function prototype
  local msg = msys.core.accept_construct_get_message_construct(ac).message;

  if not call_policy(self, "mailfrom", ac, vctx, msg, str) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- rcptto phase
-- Inputs:
-- msg -- userdata -- Momentum ec_message
-- str -- userdata (ecstring) RCPTTO string, canonicalized
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:validate_rcptto(msg, str, ac, vctx)
  if not call_policy(self, "rcptto", ac, vctx, msg, str) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- Data phase
-- Inputs:
-- msg -- userdata -- Momentum ec_message
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:validate_data(msg, ac, vctx)
  if not call_policy(self, "data", ac, vctx, msg, str) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- Data_spool phase
-- Inputs:
-- msg -- userdata -- Momentum ec_message
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:validate_data_spool(msg, ac, vctx)
  if not call_policy(self, "spool", ac, vctx, msg, str) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- Data_spool_each_rcpt phase
-- Inputs:
-- msg -- userdata -- Momentum ec_message
-- ac -- userdata -- Momentum accept construct
-- vctx -- userdata -- Momentum validation context
-- 
-- Return:
-- Validation continue (either msys.core.VALIDATE_CONT or msys.core.VALIDATE_DONE

function mod:validate_data_spool_each_rcpt(msg, ac, vctx)
  if not call_policy(self, "each_rcpt", ac, vctx, msg, str) then
    return msys.core.VALIDATE_DONE;
  end

  return msys.core.VALIDATE_CONT;
end

-- dealloc
-- Called when a connection is closed; this is where we clean up our state
function mod:validate_dealloc()
  purge_self(self);
end

msys.registerModule("inbound_policy", mod);
-- vim:ts=2:sw=2:et

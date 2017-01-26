-- Getting info from the metadata in a REST call to the transmission api

local core = require('msys.core')
local extmsg = require("msys.extended.message")
 
local mod = {};
 
 
-- Make a local copy of the contexts to avoid doing two
-- hash lookups on every call. (HT:DG)
local MSG_CTX = core.ECMESS_CTX_CONN
local CONN_CTX = core.ECMESS_CTX_MESS
 
 
local function get_binding(msg)
  local binding;
  local metadata = msg:context_get(msys.core.ECMESS_CTX_MESS, "mo_rcpt_meta");
  if metadata and metadata ~= "" then
    local metadata_json = json.decode(metadata);
    if metadata_json then
      binding = metadata_json.binding;
    end
  end
  if not binding then
    local hdr = msg:header("X-Binding")
    if hdr ~= nil and hdr[1] ~= nil then
      binding = hdr[1];
    end
  end
  return binding;
end
 
 
function mod:msg_gen_data_spool(msg)
  local binding = get_binding(msg);
  msg:context_set(msys.core.ECMESS_CTX_CONN, "can_relay", "true")
  if binding then
      msg:context_set(msys.core.ECMESS_CTX_MESS, "binding_group", binding)
  end
  return msys.core.VALIDATE_CONT
end
 
 
function mod:validate_data_spool_each_rcpt(msg, accept, vctx)
  local binding = get_binding(msg);
  if binding then
      msg:context_set(msys.core.ECMESS_CTX_MESS, "binding_group", binding)
  end
  return msys.core.VALIDATE_CONT
end
 
 
function mod:validate_set_binding(msg)
  local e, binding = msg:context_exists_and_get(msys.core.ECMESS_CTX_MESS, "binding_group")
  if (e == 1) then
    msg:binding_group(binding)
end
  return msys.core.VALIDATE_CONT
end
msys.registerModule("policy", mod);


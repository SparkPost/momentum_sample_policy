-- transmission state logger

require("msys.core");
require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");

local mod = {};

-- SMTP Only
function mod:validate_ehlo(ehlo_string, ac, vctx)
    print("XXXX STATE: validate_ehlo");
    return msys.core.VALIDATE_CONT; 
end

-- SMTP Only
function mod:validate_mailfrom(str, ac, vctx)
   print("XXXX STATE: validate_mailfrom");
  return msys.core.VALIDATE_CONT;
end

-- SMTP Only
function mod:validate_connect(ac, vctx) 
    print("XXXX STATE:  validate_connect (new connection)"); 
    return msys.core.VALIDATE_CONT; 
end 

function mod:core_post_msg_each_rcpt(msg, ac, vctx)
    print("XXXX STATE: core_post_msg_each_rcpt");
    return msys.core.VALIDATE_CONT;
end

function mod:core_pre_mailq_message_requeue(msg, now)
    print("XXXX STATE: core_pre_mailq_message_requeue");
    return msys.core.VALIDATE_CONT;
end

-- SMTP Only
function mod:validate_rcptto(msg, str, ac, vctx)
    print("XXXX STATE: validate_rcptto"); 
    return msys.core.VALIDATE_CONT; 
end

function mod:validate_data(msg, accept, vctx)
    print("XXXX STATE: validate_data")
  return msys.core.VALIDATE_CONT
end

function mod:validate_data_spool(msg, ac, vctx)
    print("XXXX STATE: validate_data_spool")
    return msys.core.VALIDATE_CONT;
end

function mod:validate_data_spool_each_rcpt(msg, ac, vctx)
  print("XXXX STATE: validate_data_spool_each_rcpt")
  return msys.core.VALIDATE_CONT;
end

function mod:validate_rcptto_list(list, vctx)
    print("XXXX STATE: validate_rcptto_list");
    return msys.core.VALIDATE_CONT;
end

function mod:validate_rcptto_list_final(node, vctx)
  print("XXXX STATE: validate_rcptto_list_final")
  return msys.core.VALIDATE_CONT;
end

function mod:core_final_validation(msg, ac, vctx)
  print("XXXX STATE: core_final_validation")
  return msys.core.VALIDATE_CONT;
end

function mod:validate_set_binding(msg)
  print("XXXX STATE: validate_set_binding")
  return msys.core.VALIDATE_CONT;
end

function mod:core_post_msg_each_rcpt(msg, ac, vctx)
    print("XXXX STATE: core_post_msg_each_rcpt");
    return msys.core.VALIDATE_CONT; 
end

msys.registerModule("state_logger", mod);


require("msys.core")
require('msys.extended.message');
 
local mod = {};
 
function mod:validate_rcptto(msg, str, accept, vctx)
 
   local ctx = { ec_message = msg };
   local parms = {};
   local vars = {};
   local to = msg:rcptto();
   local parts, errstr, errnum = msys.pcre.split(to, "@");
   local todomain = parts[2];
 
-- ############################################### --
-- This part is relevant to the msg:build function --
-- ############################################### --
 
-- initiate tables
   local headers = {};
   local pparts = {};
   local attachments = {};
 
-- create a message container and define mailfrom and rcptto
   local imsg = msys.core.ec_message_new(now);
   local  imailfrom = "test@example.com";
   local  ircptto = "test2@example.com";
 
-- define the headers and message parts
   headers["To"] = "recipient@example.com";
   headers["From"] = "noreply@c1n1.example.net";
   headers["Subject"] = "This is a test of msg:build";
 
   pparts["text/plain; charset=utf8"] = "Momentum 3.1 rocks.";
   pparts["text/html"] = "<b>Hello World<b> this is a dynamic message.   \r\n\r\n . \r\n";
 
-- build and send
-- note the IF condition is only to limit testing and not required for msg:build
  if to == "test@example.com" then
     imsg:build(headers, pparts, attachments);
     imsg:inject(imailfrom, ircptto);
  end
 
  return msys.core.VALIDATE_CONT;
end
 
 
msys.registerModule("policy", mod);

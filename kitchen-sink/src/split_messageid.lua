-- Split a Message-ID  (or any header) to get the domain part (in this case, 
-- message-id contains 2 parts, 2nd part is the domain) and discard a messaege 
-- based on that domain (in this example: astramed-ms.ru)
--

require("msys.core");
require("msys.extended.message");
require("msys.pcre");
require("msys.dumper");
 
local mod = {};
function mod:validate_data(msg, acc, vctx)
local mid = msg:header('Message-ID');
local myHeader = (msys.dumper.Dumper(mid[1]));
 
 
-- print ("myHeader is:", myHeader);
 
 
local myParts = msys.pcre.split(myHeader,"@");
local myStringDomain=tostring(myParts[2]);
-- print ("MyParts is: ", myParts, "myStringDomain is: ", myStringDomain);
local myFinalDomain = string.sub(myStringDomain,1,14);
-- print ("myFinalDomain is: ", myFinalDomain);
 
 
if (myFinalDomain == "astramed-ms.ru") then
msg:discard ("550 5.7.0 discarded due to OOB responses");
end;
return msys.core.VALIDATE_DONE;
end;
 
msys.registerModule("data", mod);


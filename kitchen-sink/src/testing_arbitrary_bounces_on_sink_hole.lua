-- Enable easy adaptive/bounce testing on a sinkhole
-- If you deploy this on a sinkhole, you'll be able to generate arbitrary bounce replies
-- by adding them to an 'X-Adaptive' header to any message that will be relayed to that sinkhole
--

require("msys.dumper");
require("msys.extended.message");
require("msys.extended.vctx");
 
local mod = {};
 
function mod:validate_data_spool(msg, accept, vctx)
  local AD_header = msg:header("X-Adaptive");
  local AD_code;
 
  if (AD_header[1] != nil) then
    -- Strips out the code from the header (e.g matches '404' in '404 success not found')
    local matches, errstr, errnum = msys.pcre.match(AD_header[1], "^\\s*(?P<code>[2345]\\d{2})\\s")
    if (matches != nil) then
      -- take the code out of the header - momo will put it back later
      AD_code = matches["code"]
      AD_header[1] = msys.pcre.replace(AD_header[1], "^\\s*" .. AD_code .. "\\s?", "")
    else
      --sets an arbitrary default in case there was no code in the header
      AD_code = 550
    end
 
    print ("setting vctx code to:" .. AD_code .. " " .. AD_header[1]);
    vctx:set_code(AD_code, AD_header[1]);
    return msys.core.VALIDATE_DONE;
  end
 
end
 
msys.registerModule("magicSink", mod);

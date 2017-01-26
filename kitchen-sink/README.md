# Kitchen Sink Examples

This is a collection of LUA examples that demonstrates commonly asked coding questions.

## Helpful Code Snipets

### Log Line Numbers

To track the execution of your LUA script, in a manner analogous to C's `__LINE__` symbol.   The following can be inserted temporarily for debugging purposes pretty much anywhere, and then you can look for the output in Momentum's panic log.

``` print ("Reached Line #" .. debug.getinfo(1,'l').currentline) ```

### Replacing the Received header (to remove "ecelerity", or internal IPs, etc)

Requires there to be only one Received header in place. More info on matching [regex](http://www.lua.org/pil/20.3.html).

``` local myReceived = msg:header("Received");
local hostname = "New Hostname";
local address = "192.168.1.1"; --new IP address
local mtasoftware = "Name of MTA software";
local mytempReceived = string.gsub(myReceived[1],"127.0.0.1",address); --old ip address
local mytmpReceived = string.gsub(mytempReceived,"old[\-]hostname.smtp.com",hostname); --this old hostname matches against a regex
local mynewReceived = string.gsub(mytmpReceived,"[\(]ecelerity %d+.%d+.%d+.%d+ r[\(]%d+[\)][\)]", mtasoftware); --you can delete the mtasoftware variable above and replace mtasoftware in this line with double quotes to remove it entirely.
msg:header("Received",mynewReceived); --this inserts the new header line onto the bottom of the message header
local myReceived = msg:header("Received"); 
```

### IP Address that Message is From

Finding the ip address the message is from and the ip address is via (i.e. the listener ip). Please note that the general response is ip and port hence the split command.

```
local ip = tostring(msg.recv_from);
ip = msys.pcre.split(ip, ":");
print ("IP 1:"..ip[1]);
local ip1 = tostring(msg.recv_via);
ip1 = msys.pcre.split(ip1, ":");
print ("IP 2:"..ip1[1]);
```


### Check the `To` Domain

Check To: domain (in this case, gmail), just set list-unsubscribe (or any other header can be used) to nil.

```
local hdrTo = msg:header( "To" )[1];local i1;
i1 = string.find(hdrTo, "@gmail.com");
  
if i1 == nil then
msg:header("List-Unsubscribe","");
end
```

## Policy Samples

The following table briefly describe the examples found in `src` directory.

| Name | Description  |
|---|---|
| `action_based_on_connection_ip.lua` | Take action based on what the connecting IP is and how many sessions are in use by that IP  |
| `add_bcc_recipient.lua` | Adding a bcc recipient to a message |
| `add_recipient_based_on_localpart.lua` | Adding a recipient to all mail destined to a given local part  |
| `all_recipients_in_message.lua` | Log All recipients in a message |
| `check_spf.lua` | Check the SPF connection context variables set by the SPF module  |
| `custom_ad.lua` | Custom AD (Adaptive Deliver)  |
| `discard_from_specific_address.lua` | Discarding all messages from a specific address  |
| `discard_message.lua` | Example of discarding a message  |
| `dkim_sign.lua` | Examples of DKIM signing in LUA |
| `dynamically_create_new_message.lua` | Creating a complete mail using the `msg:build` functionality  |
| `each_rcpt.lua` | support file for `replicate_is_valid_binding_of_seive.lua`   |
| `friendly_from.lua` | Add additional information that will be available in webhook events |
| `hook_point_logger.lua`  | Policy that demonstrates common hook points [see](https://confluence.int.messagesystems.com/pages/viewpage.action?pageId=13434926)  |
| `limit_connections.lua` | Example for how to limit connections  |
| `log_reason_form_perm_fail.lua` | Log the most recent reason for an internal permfail  |
| `messageid_on_delivery.lua` | Grab the remote `message-id` on delivery _(assumes that the remote machine gives one in the same line as the 250OK_  |
| `meta_from_rest_transmission.lua` | Getting info from the metadata in a REST call to the transmission API  |
| `replicate_is_valid_binding_of_seive.lua` |Replicate the is valid binding behavior that is available in sieve |
| `route_to_smart_host.lua` | Route certain messages to a "smart host"  |
| `set_binding.lua` | support file for `replicate_is_valid_binding_of_seive.lua`  |
| `set_binding_by_domain.lua` | This sets a binding based on the message domain  |
| `set_binding_from_xheader.lua` | This sets a binding based on a custom X-header   |
| `split_messageid.lua` | Split a Message-ID (or any header) to get the domain part |
| `test_fbl_stanza.lua` | Test FBL stanza context variables using a Connection context variable |
| `testing_arbitrary_bounces_on_sink_hole.lua` |   |
| `vctx_from_header.lua` | Create `vctx` based off a header  |
| `write_msg_to_jlog.lua` | Writes message to Jlog  |



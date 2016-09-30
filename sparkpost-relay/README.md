# SparkPost Relay

Momentum can be configured to relay messages through a remote SMTP server. This project contains an example configuration and sample policy for routing messages through SparkPost.


## Work Around missing API definition

Momentum versions < 4.3.2.?13? need to do the following to enable outbound smtp

`vi /opt/msys/ecelerity/libexec/validate/outbound_smtp_auth.ecm`

File should contain:

```
[outbound_smtp_auth]
msys.provides:auto = config.Global.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Binding
msys.provides:auto = config.Global:Binding.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Binding.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Binding.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Binding.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Binding:Domain
msys.provides:auto = config.Global:Binding:Domain.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Binding:Domain.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Binding:Domain.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Binding:Domain.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Binding_Group
msys.provides:auto = config.Global:Binding_Group.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Binding_Group.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Binding_Group.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Binding_Group.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Binding_Group:Binding
msys.provides:auto = config.Global:Binding_Group:Binding.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Binding_Group:Binding.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Binding_Group:Binding.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Binding_Group:Binding.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Binding_Group:Binding:Domain
msys.provides:auto = config.Global:Binding_Group:Binding:Domain.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Binding_Group:Binding:Domain.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Binding_Group:Binding:Domain.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Binding_Group:Binding:Domain.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Binding_Group:Domain
msys.provides:auto = config.Global:Binding_Group:Domain.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Binding_Group:Domain.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Binding_Group:Domain.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Binding_Group:Domain.Outbound_SMTP_Auth_User
msys.provides:auto = config.Global:Domain
msys.provides:auto = config.Global:Domain.Outbound_SMTP_Auth_Key
msys.provides:auto = config.Global:Domain.Outbound_SMTP_Auth_Pass
msys.provides:auto = config.Global:Domain.Outbound_SMTP_Auth_Type
msys.provides:auto = config.Global:Domain.Outbound_SMTP_Auth_User
                                                                
```


## Visualizing Relay Messages

In some cases you would like to debug relayed messages on your local machine with out going through the foreign SMTP server. His is one way to accomplish that:

1. Get [fake SMTP server](https://nilhcem.github.io/FakeSMTP/)
2. Run server locally on port 2525 like this `java -jar fakeSMTP-2.0.jar -s -p 2525`
3. Reverse tunnel Momentum machine to local machine like this `ssh -R 2525:localhost:2525 root@talktalk1`
4. Configure a test binding that points at `fake SMTP` server

```
#######################################
## TESTING FAKE SMTP SERVER
########################################

domain "#fakesmtp" {
  routes = ( "smtp://127.0.0.1:2525" )

}

binding "fakesmtp" {
  gateway = "#fakesmtp"
  Outbound_SMTP_AUTH_Type = "LOGIN"
  Outbound_SMTP_AUTH_User = "fakesmtp"
  Outbound_SMTP_AUTH_Pass = "fakepassword"
}
```

5. Send a message to the fakesmtp binding and you will see the messages in the GUI

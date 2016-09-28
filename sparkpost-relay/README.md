# SparkPost Relay


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


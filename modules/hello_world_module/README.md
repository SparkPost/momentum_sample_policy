# Hello World Module

This is an introduction on how to build as simple as possible module for Momentum.

## Setup

To use this module Momentum will need to be configured to load the C and LUA modules.

### Build module and install

In the src directory run:

```
# Build module
# This creates the .so file and the .ecm file
`make`

# Install the module
`make install`
```

### Loading C Module

For Momentum to call your module you will need to add in `/opt/msys/ecelerity/etc/conf/default/ecelerity.conf` like this:

```
hello_world {  debug_level = DEBUG }
```


### Loading LUA Module


To enable `helloworld.lua` you will need to add the following to the `scriptlets` tag in `/opt/msys/ecelerity/etc/conf/default/ecelerity.conf`

```
script "helloworld" {
   source = "helloworld"
}
```

to the scriptlets tag in:
    `/opt/msys/ecelerity/etc/conf/default/ecelerity.conf`



## C Module Information

C modules are more easily read if you start from the bottom and work your way up.


### Register Callbacks

see also [1.3.1.2. The Module Infrastructure](https://support.messagesystems.com/docs/web-c-api/arch.primary.apis.php)

The module infrastructure is Momentum's entry point into an external module. The module infrastructure is only intended to be defined globally in this manner. As such, it is read-only thread-safe. The structure is called the generic module infrastructure, and it is usually defined at the bottom of a module source file as follows:

```
EC_MODULE_EXPORT
generic_module_infrastructure hello_world = {
    {
      EC_MODULE_INIT(EC_MODULE_TYPE_SINGLETON, 0),
      MODNAME,
      "Hellow World Demo 1",
      _EC_VER,
      NULL, /*module_control, function for control commands */
      NULL, /* module_conf, Deprecated, must be NULL */
      NULL, /* module_ext_conf, Deprecated, must be NULL */
      NULL, /* module_init, Deprecated, must be NULL */
      NULL, /* module_post_init, Deprecated, must be NULL */
      my_setup_config, /* module_config_setup, Must be defined */
      NULL, /* module_enable, Deprecated, must be NULL */
      NULL,  /* module_can_unload, Deprecated, must be NULL */
      my_ext_init /* module_ext_init, Must be defined */
    },
};

```

For now we ignore most of the fields and will only focus on the important ones for this demo.

`MODNAME` is string. It is the name of the module and is how it will be referenced in configuration as shown in [C Module Information](#C+Module+Information) above.

`my_setup_config` is the function that Momentum will call when configuring the module. See [`conf_setup`](#conf_setup) below.

`my_ext_init` is the function that will be called to initialize the module. See [`ext_intit`](#ext_init) below.


### ext_init

Called multiple times with different flags. Generally this is where you query configuration parameters for the module and cache them—which is far more efficient than doing it from the configuration system. The specifics of these functions are discussed in [Section 1.3.5, “Configuration API”](https://support.messagesystems.com/docs/web-c-api/arch.primary.apis.php#arch.configuration). In this module we only log a message that the function was called.

```
static int my_ext_init(generic_module_infrastructure *self,
                            ec_config_header *transaction,
                            string *output, int flags)
{
  ec_mod_debug(self, DDEBUG, MODNAME ": my_ext_init called with flag(%d)\n", flag);
  return 0;
}
```

This method will be discussed in more detail in more advanced modules.


### conf_setup

`conf_setup` is called the first time the module is loaded but only once for singleton modules, which is the only type of module that should generally be built. In this function, you must register configuration options that this module will expose. (For more about the configuration system see Section [1.3.5, “Configuration API”](https://support.messagesystems.com/docs/web-c-api/arch.primary.apis.php#arch.configuration).) Return 0 on success, -1 on any sort of failure.


```
static int my_setup_config(generic_module_infrastructure *self, int mode)
{
  /* Module pointer, for use in logging. */
  hello_world_self = self;

  ec_mod_debug(hello_world_self, DDEBUG, MODNAME ":my_setup_config\n");

  // Register to be called called before the MAIL FROM phase in the SMTP client.
  // https://support.messagesystems.com/docs/web-c-api/hooks.core.smtp_client_mailfrom_args.php
  register_core_smtp_client_mailfrom_args_hook_first(my_smtp_client_mailfrom_args, self);
  return 0;
}
```

This module registers the function `my_smtp_client_mailfrom_args` to be called when Momentum is in the  `MAIL FROM` phase in the SMTP client.

See [`register_core_smtp_client_mailfrom_args_hook_first`](https://support.messagesystems.com/docs/web-c-api/hooks.core.smtp_client_mailfrom_args.php) for more details about the MAILFROM phase.




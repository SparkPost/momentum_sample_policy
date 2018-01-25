/*
 * This is a simple example for how to make a basic module for Momentum
 * 
 * https://support.messagesystems.com/docs/web-momo4/module_config.php
 * 
 * To enable this module you will need to add the following to the file
 *    /opt/msys/ecelerity/etc/conf/default/ecelerity.conf
 * 
 * Add this line:
 *    hello_world {  debug_level = DEBUG }
 * 
 * 
 * 
 */
#ifndef SHARED_MODULE
#define SHARED_MODULE
#endif

#include "validate_module.h"
#include "ec_config.h"
#include "ec_message.h"
#include "ec_ssl.h"
#include "ec_types.h"
#include "hooks/core/smtp_client_mailfrom_args.h"
#include <stddef.h>
#include <debug_tools.h>

/*! Module name, used in logging. */
#define MODNAME "hello_world"

/*! Module pointer, for use in logging. */
static generic_module_infrastructure *hello_world_self = NULL;

static int my_smtp_client_mailfrom_args(void *closure, delivery_construct *dc, smtp_client_args *args)
{
  ec_mod_debug(hello_world_self, DDEBUG, MODNAME ":my_smtp_client_mailfrom_args\n");

  ec_message_context_set(dc->message, ECMESS_CTX_MESS, "my_msg", "hello world");
 
  return 0;
}

/*!
 * Configuration set-up hook for the module.
 * Set up data structures and register hooks.
 *
 * @param[in] self The module instance
 * @param[in] ignoreme Ignore me
 *
 * @return 0 (success)
 */
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

/*!
 * Module initialization hook
 *
 * @param[in] self The module instance
 * @param[in] transaction Configuration system transaction
 * @param[out] output String for notifying operator of errors
 * @param[in] flags Flags
 *
 * @return 0 (success)
 */
static int my_ext_init(generic_module_infrastructure *self,
                            ec_config_header *transaction,
                            string *output, int flags)
{
  ec_mod_debug(self, DDEBUG, MODNAME ":my_setup_config\n");
  return 0;
}

/* 
see https://support.messagesystems.com/docs/web-c-api/arch.primary.apis.php#arch.module.infrastructure
Structure is defined in shared_module.h as _shared_module_infrastructure_9
*/
EC_MODULE_EXPORT
generic_module_infrastructure hello_world = {
    {
      EC_MODULE_INIT(EC_MODULE_TYPE_SINGLETON, 0),
      MODNAME,
      "Hellow World Demo 1",
      /* Make module compatible with Momentum 3.x or 4.x */
#if _EC_MAJOR_VER > 3
      _EC_VER,
#endif
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

/* vim:ts=2:sw=2:et:
 */

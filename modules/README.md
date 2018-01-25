# Custom Modules

For a general overview of custom modules see [Primary Momentum APIs](https://support.messagesystems.com/docs/web-c-api/arch.primary.apis.php).

Momentum's module API is at the core of how it is extended. Without the module API, no extension to Momentum is possible. Modules within Momentum are defined in terms of a module infrastructure, which the configuration system learns of through a series of files called ‘.ecm’ files. The module infrastructure consists of a series of callbacks which are the entry points into the module from Momentum itself.


## Guides

| Example  | Description  |
|---|---|
| [`hello_world_module`](hello_world_module)  | This is as simple a module as possible to demonstrate basic concepts  |
|   |   |


## Development Setup

To build and test any of these modules you will need to setup the development environment.

1. You will need a functioning and licensed version of Momentum installed.
2. Install the development files (assumes you ran `setrepodir` already)
    `yum install -y --config momentum.repo --enablerepo momentum msys-ecelerity-devel`

That should be all you need to get going.


### Common Makefile targets

| Target  | Description  |
|---|---|
| none  | builds *.so and produces *.ecm  |
| clean  | removes *.so and *ecm in src directory  |
| install  | puts *.so and *.ecm into the proper Momentum directories  |
| run  | starts ecelerity (Momentum) in foreground for testing  |
| test  | runs unit tests  |


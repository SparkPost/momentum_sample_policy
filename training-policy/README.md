lua-policies
============

Example business policies, implemented in the Momentum Business Policy Framework.  

These Lua modules only work within the Momentum messaging server, and are provided by Message Systems as a way to help build your own custom policy.  Suggested changes or forks are encouraged.

These policies are loaded by loading the included policy.lua file into Momentum:

<pre>
scriptlet "scriptlet" {
  script "policy" {
    source = "policy"
  }
}
</pre>

And then adding your policy to this array in policy.lua:

<pre>
-- This is the list of policies to load, a Lua array
local policies = {
  "inbound.limits",
  "inbound.rbl",
  "inbound.fcdns",
};
</pre>

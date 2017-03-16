require('msys.adaptive')
local custom_rules = {
  ["harry.com"] = {
      responses = {
 
                             {
                                code = "^450 tempfail",
                                trigger = "5/1",
                                action = {"suspend", "4 hours"},
                                phase = "each_rcpt",
                             },
                            {
                                code = "^450 permfail",
                                trigger = "2/1",
                                action = {"suspend", "8 hours"},
                                phase = "each_rcpt",
                            },
                           {
                                code = "^451 Temporary fail 15% of messages",
                                trigger = "5/1",
                                action = {"suspend", "4 hours"},
                                phase = "connect",
                            },
                            {
                               code = "^421 4\\.7\\.0 \\[TS01\\] Messages from (?<IPADDRESS>\\d+\\.\\d+\\.\\d+\\.\\d+) temporarily deferred due to user complaints - 4\\.16\\.55\\.1",
                               trigger = "1",
                               action = {"transcode", "554 Dynamic block in place", "throttle" , "down" },
                               message = "This is a temporary situation and we are going to throttle down",
                               phase = "connect",
                          },
                  },
             },
         }
msys.adaptive.registerRules(custom_rules, "augment");

--[[
NOTE: This hasn't been tested yet, it's still a work in progress
]]

module("inbound.logger", package.seeall);
require("msys.core");
require("thread");

if not mutex then
  mutex = thread.mutex();
  registry = {};
end

-- name: Name of the logger
-- attributes: Lua array with the attributes
function register(name, path, attributes)
  mutex:lock();
  if not registry[name] then
    registry[name] = {};
    registry[name].name = name;
    registry[name].attributes = attributes;
    registry[name].path = path;
    registry[name].io = msys.core.io_wrapper_open("path", msys.core.O_CREAT|msys.core.O_APPEND);
  end
  mutex:unlock();

  return registry
end;

-- self -- Lua connection-specific table
-- logger -- Logger returned by register
-- attributes -- Lua table (key/value) for data to log
function log(self, logger, attributes)
  if not self.logger then
    self.logger = {};
  end

  if not self.logger[logger.name] then
    self.logger[logger.name] = {};
  end

  for k, v in pairs(attributes) do
    self.logger[logger.name][k] = v
  end

  -- See if we have all that we need
  local missing_some = false;

  for k, v in ipairs(logger.attributes) do
    if not self.logger[logger.name][v] then
      missing_some = true;
      break;
    end
  end

  tostring(msg.id)
  tostring(ac.conn_id);
  if not missing_some then
    local t = self.logger[logger.name];
    msys.runInPool("IO", function()
      local line = {};
      -- Good to log
      for k, v in pairs(t) do
        table.insert(line, string.format("%s: %s", k, v));
      end
      local s = table.concat(line);
        io:write(s, #s);
      end, true);
  end
end

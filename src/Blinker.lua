local Class = require('hump.class')
local Singleton = require('Singleton')

local Blinker = Class{}

function Blinker:init()
  self.time = 0
  self.period = 1
  self.periodPct = 0
end

function Blinker:setPeriod(xPeriod)
  self.period = xPeriod
end

function Blinker:update(dt)
  self.time = self.time + dt
  if self.time > self.period then
    self.time = self.time - self.period
  end
  self.periodPct = (self.time / self.period)
end

function Blinker:blink(...)
  local args = {...}
  local zeroBasedIndex = math.floor((#args) * self.periodPct)
  return args[zeroBasedIndex + 1]
end

return Singleton(Blinker)
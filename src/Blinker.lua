local Class = require('hump.class')

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
  self.periodPct = math.min((self.time / self.period), 1.0)
end

function Blinker:blink(...)
  local args = {...}
  local zeroBasedIndex = math.floor((#args) * self.periodPct) or 0
  return args[zeroBasedIndex + 1]
end

return Blinker
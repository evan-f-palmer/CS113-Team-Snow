local Class  = require('hump.class')
local Singleton = require('Singleton')

local Probability = Class {}

function Probability:init()
  math.randomseed(os.time())
  for i = 1, 10 do
    math.random()
  end
end

function Probability:of(xPercent)
  local X = math.random()
  return X <= xPercent
end

return Singleton(Probability)
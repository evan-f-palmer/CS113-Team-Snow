local Class = require('hump.class')

local PlayerGameData = Class{}

PlayerGameData.crystalScoreValue = 10

function PlayerGameData:init()
  self.health  = 0
  self.shields = 0
  self.score   = 0
  self.bombs   = 0
  self.time    = 0
  self.lives   = 0
end

function PlayerGameData:update(dt)
  self.time = self.time + dt
end

function PlayerGameData:pickupCrystal()
  self.score = self.score + PlayerGameData.crystalScoreValue
end

return PlayerGameData
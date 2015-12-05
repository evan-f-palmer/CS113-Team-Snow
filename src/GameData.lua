local Class = require('hump.class')
local SoundSystem  = require('SoundSystem')

local GameData = Class{}

GameData.sinistarKillValue = 20000
GameData.warriorKillValue = 500
GameData.workerKillValue = 300
GameData.crystalValue = 100
GameData.asteroidKillValue = 50

GameData.startingLives = 3
GameData.numberOfCrystalsToBuildSinistar = 100

function GameData:init()
  self.soundSystem = SoundSystem()
  self:reset()
end

function GameData:reset()
  self.lives   = GameData.startingLives
  self.health  = 0
  self.score   = 0
  self.bombs   = 0
  self.alertMessage = ""
  self.alertPriority = 0
  self.sinistarCrystals = 0
  self.lastLifeUpScore = 0
end

function GameData:updateAlertData(xAlertMachine)
  local primaryAlert = xAlertMachine:getPrimaryAlert()
  self.alertMessage = primaryAlert.message
  self.alertPriority = primaryAlert.priority
end

function GameData:isGameOver()
  return self.lives <= 0
end

function GameData:increaseScore(xAmount)
  self.score = self.score + xAmount
  if self.score - self.lastLifeUpScore >= 30000 then
    self.lastLifeUpScore = self.score
    self:incrementLives()
  end
end

function GameData:incrementLives()
  if self.lives < 3 then
    self.lives = self.lives + 1
    self.soundSystem:play("sound/sinibombExplosion.wav", 0.5)
  end
end

function GameData:decrementLives()
  self.lives = self.lives - 1
end

function GameData:shouldSinistarBeCompleted()
  return self.sinistarCrystals >= self.numberOfCrystalsToBuildSinistar
end

function GameData:incrementSinistarCrystals()
  self.sinistarCrystals = self.sinistarCrystals + 1
end

function GameData:resetSinistarCrystals()
  self.sinistarCrystals = 0
end

return GameData
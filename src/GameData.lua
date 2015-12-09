local Class = require('hump.class')
local SoundSystem  = require('SoundSystem')

local GameData = Class{}

GameData.sinistarKillValue = 20000
GameData.survivedSinistarForThreeMinutesValue = 10000
GameData.sinistarHitWithPlayerBulletValue = 10
GameData.sinistarHitWithSinibombValue = 200
GameData.sinistarHitWithSinibombBlastValue = 1

GameData.warriorKillValue = 500
GameData.workerKillValue = 300
GameData.crystalValue = 100
GameData.asteroidKillValue = 50

GameData.startingLives = 3
GameData.numberOfCrystalsToBuildSinistar = 70

function GameData:init()
  self.soundSystem = SoundSystem()
  self:free()
  self:reset()
end

function GameData:preserve()
  self.CAN_MODIFY = false
end

function GameData:free()
  self.CAN_MODIFY = true
end

function GameData:reset()
  if self.CAN_MODIFY then
    self.lives   = GameData.startingLives
    self.score   = 0
    self.alertMessage = ""
    self.alertPriority = 0
    self.sinistarCrystals = 0
    self.lastLifeUpScore = 0
    self.level = 1
    self.playerBombs = 0
  end
end

function GameData:updateAlertData(xAlertMachine)
  if self.CAN_MODIFY then
    local primaryAlert = xAlertMachine:getPrimaryAlert()
    self.alertMessage = primaryAlert.message
    self.alertPriority = primaryAlert.priority
  end
end

function GameData:isGameOver()
  return self.lives <= 0
end

function GameData:forceGameOver()
  if self.CAN_MODIFY then
    self.lives = 0
  end
end

function GameData:increaseScore(xAmount)
  if self.CAN_MODIFY then
    if not self:isGameOver() then
      self.score = self.score + xAmount
      if self.score - self.lastLifeUpScore >= 30000 then
        self.lastLifeUpScore = self.score
        self:incrementLives()
      end
    end
  end
end

function GameData:incrementLives()
  if self.CAN_MODIFY then
    if not self:isGameOver() then
      if self.lives < 3 then
        self.lives = self.lives + 1
        self.soundSystem:play("sound/sinibombExplosion.wav", 0.5)
      end
    end
  end
end

function GameData:decrementLives()
  if self.CAN_MODIFY then
    self.lives = self.lives - 1
  end
end

function GameData:shouldSinistarBeCompleted()
  return self.sinistarCrystals >= self.numberOfCrystalsToBuildSinistar
end

function GameData:getSinistarCompletionPercentage()
  return math.min(self.sinistarCrystals / self.numberOfCrystalsToBuildSinistar, 1.0)
end

function GameData:incrementSinistarCrystals()
  if self.CAN_MODIFY then
    self.sinistarCrystals = self.sinistarCrystals + 1
  end
end

function GameData:resetSinistarCrystals()
  if self.CAN_MODIFY then
    self.sinistarCrystals = 0
  end
end

function GameData:increaseLevel()
  if self.CAN_MODIFY then
    self.level = self.level + 1
  end
end

return GameData
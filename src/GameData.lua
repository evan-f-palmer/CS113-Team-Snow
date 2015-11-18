local Class = require('hump.class')

local GameData = Class{}

GameData.sinistarKillValue = 20000
GameData.warriorKillValue = 500
GameData.workerKillValue = 300
GameData.crystalValue = 100
GameData.asteroidKillValue = 50

GameData.secondaryWeaponWarmupTime = 2

GameData.startingLives = 3
GameData.startingHealth = 100
GameData.damageFromCollisionWithSinistar = 1000
GameData.damageFromCollisionWithWarriorBullet = 5
GameData.damageFromCollisionWithWorkerBullet = 1

GameData.bombAmmoFromCrystalPickup = 1

GameData.numberOfCrystalsToBuildSinistar = 35

GameData.worldCameraScale = 1

function GameData:init()
  self.lives   = GameData.startingLives
  self.health  = 0
  self.score   = 0
  self.bombs   = 0
  self.alertMessage = ""
  self.alertPriority = 0
  self.sinistarCrystals = 0
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
end

function GameData:incrementLives()
  self.lives = self.lives + 1
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
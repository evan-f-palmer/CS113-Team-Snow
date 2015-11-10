local Class = require('hump.class')

local PlayerGameData = Class{}

PlayerGameData.sinistarKillValue = 20000
PlayerGameData.warriorKillValue = 500
PlayerGameData.workerKillValue = 300
PlayerGameData.crystalValue = 100
PlayerGameData.asteroidKillValue = 50

PlayerGameData.secondaryWeaponWarmupTime = 2

PlayerGameData.startingLives = 3
PlayerGameData.startingHealth = 100
PlayerGameData.damageFromCollisionWithSinistar = 1000
PlayerGameData.damageFromCollisionWithWarriorBullet = 5
PlayerGameData.damageFromCollisionWithWorkerBullet = 1

PlayerGameData.bombAmmoFromCrystalPickup = 1


function PlayerGameData:init()
  self.lives   = PlayerGameData.startingLives
  self.health  = 0
  self.score   = 0
  self.bombs   = 0
  self.alertMessage = ""
  self.alertPriority = 0
end

function PlayerGameData:updateAlertData(xAlertMachine)
  local primaryAlert = xAlertMachine:getPrimaryAlert()
  self.alertMessage = primaryAlert.message
  self.alertPriority = primaryAlert.priority
end

function PlayerGameData:isGameOver()
  return self.lives <= 0
end

function PlayerGameData:increaseScore(xAmount)
  self.score = self.score + xAmount
end

function PlayerGameData:incrementLives()
  self.lives = self.lives + 1
end

function PlayerGameData:decrementLives()
  self.lives = self.lives - 1
end

return PlayerGameData
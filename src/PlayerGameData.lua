local Class = require('hump.class')

local PlayerGameData = Class{}

PlayerGameData.crystalScoreValue = 10
PlayerGameData.blindSpotRadius = 50
PlayerGameData.secondaryWeaponWarmupTime = 2

function PlayerGameData:init()
  self.health  = 0
  self.lives   = 0
  self.score   = 0
  self.bombs   = 3
  self.alertMessage = ""
  self.alertPriority = 0
end

function PlayerGameData:updateAlertData(xAlertMachine)
  local primaryAlert = xAlertMachine:getPrimaryAlert()
  self.alertMessage = primaryAlert.message
  self.alertPriority = primaryAlert.priority
end

function PlayerGameData:pickupCrystal()
  self.score = self.score + PlayerGameData.crystalScoreValue
end

return PlayerGameData
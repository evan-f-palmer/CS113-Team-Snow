local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')

local PRIMARY_FIRE_MESSAGE   = {message = "[Primary Fire]", lifespan = 0.5}
local SECONDARY_FIRE_MESSAGE = {message = "[Secondary Fire]", lifespan = 0.5}
local OUT_OF_SINIBOMBS_ALERT = {message = "[Out of Sinibombs]", lifespan = 1.5, priority = 2}

local Player = Class{}

function Player:init(playerInput, playerGameData)
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.playerInput = playerInput
  self.playerGameData = playerGameData
  self.maxSpeed = 450
  self.alertMachine = AlertMachine()
  self.secondaryWeaponWarmupTimer = 0
end

function Player:update(dt)
  self.secondaryWeaponWarmupTimer = self.secondaryWeaponWarmupTimer + dt

  if self.playerInput.primaryWeaponFire and self:canFirePrimaryWeapon() then
    self:firePrimaryWeapon()
  end
    
  if self.playerInput.secondaryWeaponFire and self:canFireSecondaryWeapon() then
    self:fireSecondaryWeapon()
  end

  self.dir = self.playerInput.directionVec
  
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)
  self.vel:scale_inplace(dt)
  
  self.loc:add_inplace(self.vel)
end

function Player:canFirePrimaryWeapon()
  --TODO
  return true 
end

function Player:canFireSecondaryWeapon()
  --TODO
  return (self.secondaryWeaponWarmupTimer >= self.playerGameData.secondaryWeaponWarmupTime)
end

function Player:firePrimaryWeapon()
  self.alertMachine:set(PRIMARY_FIRE_MESSAGE)
  --TODO
end

function Player:fireSecondaryWeapon()
  self.secondaryWeaponWarmupTimer = 0
  if (self.playerGameData.bombs > 0) then
    self.alertMachine:set(SECONDARY_FIRE_MESSAGE)
    self.playerGameData.bombs = self.playerGameData.bombs - 1
  else
    self.alertMachine:set(OUT_OF_SINIBOMBS_ALERT)
  end
  --TODO
end

return Player
local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')

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
  
  self.combat = Combat()
  self.combat:addCombatant("Player", {health = 100})
  self.combat:addWeapon("Player Primary", {damage = 50, ammo = math.huge, projectile = "Player Bullet", debounceTime = 0.1})
  self.combat:addWeapon("Player Secondary", {damage = 5000, ammo = 0, projectile = "Sinibomb", debounceTime = 1})  
end

function Player:update(dt)
  if self.playerInput.primaryWeaponFire and self.combat:canFire("Player Primary") then
    self.combat:fire("Player Primary", self.loc, self.dir)
    self.alertMachine:set(PRIMARY_FIRE_MESSAGE)  
  end
    
  if self.playerInput.secondaryWeaponFire and self.combat:canFire("Player Secondary") then
    self.combat:fire("Player Secondary", self.loc, self.dir)
    self.alertMachine:set(SECONDARY_FIRE_MESSAGE)
  end
  
  if self.playerInput.secondaryWeaponFire and self.combat:isOutOfAmmo("Player Secondary") then
    self.alertMachine:set(OUT_OF_SINIBOMBS_ALERT)
  end

  self.dir = self.playerInput.directionVec
  
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)
  self.vel:scale_inplace(dt)
  
  self.loc:add_inplace(self.vel)
  
  self.bombs = self.combat:getAmmo("Player Secondary")
  self.health = self.combat:getHealth("Player")
end

return Player
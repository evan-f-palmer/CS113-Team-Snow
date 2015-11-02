local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')

local PRIMARY_FIRE_MESSAGE   = {message = "[Primary Fire]", lifespan = 0.5}
local SECONDARY_FIRE_MESSAGE = {message = "[Secondary Fire]", lifespan = 0.5}
local OUT_OF_SINIBOMBS_ALERT = {message = "[Out of Sinibombs]", lifespan = 1.5, priority = 2}

local Player = Class{}
Player.ID = "Player"
Player.primaryWeaponID = "Player Primary"
Player.secondaryWeaponID = "Player Secondary"
Player.combatant = {health = 100}
Player.primaryWeapon = {damage = 50, ammo = math.huge, projectileID = "Player Bullet", debounceTime = 0.1}
Player.secondaryWeapon = {damage = 5000, ammo = 0, projectileID = "Sinibomb", debounceTime = 1}

function Player:init(playerInput, playerGameData)
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.playerInput = playerInput
  self.playerGameData = playerGameData
  self.maxSpeed = 450
  self.alertMachine = AlertMachine()
  
  self.combat = Combat()
  self.combat:addCombatant(Player.ID, Player.combatant)
  self.combat:addWeapon(Player.primaryWeaponID, Player.primaryWeapon)
  self.combat:addWeapon(Player.secondaryWeaponID, Player.secondaryWeapon)  
end

function Player:update(dt)
  if self.playerInput.primaryWeaponFire then
    self.combat:fire(Player.primaryWeaponID, self.loc, self.dir)
  end
    
  if self.playerInput.secondaryWeaponFire then
    self.combat:fire(Player.secondaryWeaponID, self.loc, self.dir)
  end
  
  if self.playerInput.secondaryWeaponFire and self.combat:isOutOfAmmo(Player.secondaryWeaponID) then
    self.alertMachine:set(OUT_OF_SINIBOMBS_ALERT)
  end

  self.dir = self.playerInput.directionVec
  
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)
  self.vel:scale_inplace(dt)
  
  self.loc:add_inplace(self.vel)
  
  self.bombs = self.combat:getAmmo(Player.secondaryWeaponID)
  self.health = self.combat:getHealth(Player.ID)
end

return Player
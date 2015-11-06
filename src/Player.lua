local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local Projectiles = require('Projectiles')

local PRIMARY_FIRE_MESSAGE   = {message = "[Primary Fire]", lifespan = 0.5}
local SECONDARY_FIRE_MESSAGE = {message = "[Secondary Fire]", lifespan = 0.5}
local OUT_OF_SINIBOMBS_ALERT = {message = "[Out of Sinibombs]", lifespan = 1.5, priority = 2}

local Player = Class{}
Player.type = "Player"

function Player:init(playerInput, playerGameData)
  self.playerInput = playerInput
  self.playerGameData = playerGameData
  
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.maxSpeed = 950
  self.radius = 10
  
  self.projectiles = Projectiles()
  self.projectiles:defProjectile("Player Bullet", {color = {0,220,150}, shouldRotate = true, speed = 800, lifespan = 3})
  self.projectiles:defProjectile("Sinibomb", {color = {180,50,0}, speed = 1500, lifespan = 3})  

  self.combat = Combat()
  self.combat:addCombatant("Player", {health = 100})
  self.combat:addWeapon("Player Primary", {ammo = math.huge, projectileID = "Player Bullet", debounceTime = 0.1})
  self.combat:addWeapon("Player Secondary", {ammo = 0, projectileID = "Sinibomb", debounceTime = 1, maxAmmo = 12})
  
  self.render = {
    image = love.graphics.newImage("assets/ship.png"),
    color = {255,255,255},
    shouldRotate = true,
  }
  
  self.alertMachine = AlertMachine()
end

function Player:update(dt)
  self.dir = self.playerInput.directionVec
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)

  if self.playerInput.primaryWeaponFire then
    self.combat:fire("Player Primary", self.loc, self.dir, self.vel)
  end
    
  if self.playerInput.secondaryWeaponFire then
    self.combat:fire("Player Secondary", self.loc, self.dir)
  end
  
  if self.playerInput.secondaryWeaponFire and self.combat:isOutOfAmmo("Player Secondary") then
    self.alertMachine:set(OUT_OF_SINIBOMBS_ALERT)
  end

  self.playerGameData.bombs = self.combat:getAmmo("Player Secondary")
  self.playerGameData.health = self.combat:getHealthPercent("Player")
end

function Player:onCollision(other)
  local type = other.type
  if type ~= "Capture Device" then
    self.alertMachine:set({message = (type .. " Here!"), lifespan = 1, priority = 4})
  end
  if type == "Enemy Bullet" then
    self.combat:attack("Player", 1)
  end
end

return Player
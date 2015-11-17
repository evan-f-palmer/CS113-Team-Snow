local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')

local PRIMARY_FIRE_MESSAGE   = {message = "[Primary Fire]", lifespan = 0.5}
local SECONDARY_FIRE_MESSAGE = {message = "[Secondary Fire]", lifespan = 0.5}
local OUT_OF_SINIBOMBS_ALERT = {message = "[Out of Sinibombs]", lifespan = 1.5, priority = 2}

local Player = Class{}
Player.type = "Player"

Player.variations = {
  {
    image = love.graphics.newImage("assets/ship.png"),
    color = {255,255,255},
    shouldRotate = true,
  },
}

function Player:init(gameData, playerInput)
  self.playerInput = playerInput
  self.gameData = gameData
  
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.maxSpeed = 2250
  self.radius = 70
  self.primaryFireOffset = 30
  
  self.id = "Player"
  
  self.combat = Combat()
  self.combat:addCombatant("Player", {health = self.gameData.startingHealth})
  self.combat:addWeapon("Player Primary R", {ammo = math.huge, projectileID = "Player Bullet", debounceTime = 0.1})
  self.combat:addWeapon("Player Primary L", {ammo = math.huge, projectileID = "Player Bullet", debounceTime = 0.1})
  self.combat:addWeapon("Player Secondary", {ammo = 0, projectileID = "Sinibomb", debounceTime = 1, maxAmmo = 12})
  
  self.render = self.variations[math.random(#self.variations)]
  
  self.alertMachine = AlertMachine()
  self.soundSystem = SoundSystem()
end

function Player:update(dt)
  self.dir = self.playerInput.directionVec
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)

  if self.playerInput.primaryWeaponFire then
    local offset = self.dir:perpendicular()
    offset = offset:normalize_inplace()
    offset = offset:scale_inplace(self.primaryFireOffset)
    self.combat:fire("Player Primary R", self.loc + offset, self.dir, self.vel)
    self.combat:fire("Player Primary L", self.loc - offset, self.dir, self.vel)
    self.soundSystem:play("sound/short.ogg")
  end
    
  if self.playerInput.secondaryWeaponFire then
    if self.combat:canFire("Player Secondary") then
      self.soundSystem:play("sound/laser.ogg")
    end
    self.combat:fire("Player Secondary", self.loc, self.dir)
  end
  
  if self.playerInput.secondaryWeaponFire and self.combat:isOutOfAmmo("Player Secondary") then
    self.alertMachine:set(OUT_OF_SINIBOMBS_ALERT)
    self.soundSystem:play("sound/marinealarm.ogg")
  end

  self.combat:heal(self.id, dt / 3)
  self.gameData.bombs = self.combat:getAmmo("Player Secondary")
  self.gameData.health = self.combat:getHealthPercent("Player")
  self.isDead = self.combat:isDead("Player")
end

function Player:onCollision(other)
  local type = other.type
  
  if type == "Warrior Bullet" then
    self.combat:attack("Player", self.gameData.damageFromCollisionWithWarriorBullet)
    other.isDead = true
  end
  
  if type == "Worker Bullet" then
    self.combat:attack("Player", self.gameData.damageFromCollisionWithWorkerBullet)
    other.isDead = true
  end
  
  if type == "Sinistar" then
    self.combat:attack("Player", self.gameData.damageFromCollisionWithSinistar)
  end
  
  if type == "Crystal" then
    self.gameData:increaseScore(self.gameData.crystalValue)
    self.combat:supplyAmmo("Player Secondary", self.gameData.bombAmmoFromCrystalPickup)
    --self.combat:heal(self.id, 1)
    other.isDead = true
  end
  
  if type == "Asteroid" then
    self.vel = -self.vel -- but controls vector just overrides it...
  end
end

function Player:respawn()
  self.combat:addCombatant("Player", {health = self.gameData.startingHealth})
  self.isDead = self.combat:isDead("Player")
end

return Player
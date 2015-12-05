local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')
local EntityParams = require('EntityParams')

local PRIMARY_FIRE_MESSAGE   = {message = "[Primary Fire]", lifespan = 0.5}
local SECONDARY_FIRE_MESSAGE = {message = "[Secondary Fire]", lifespan = 0.5}

local SCORE_MESSAGE          = {message = "+", lifespan = 0.75, priority = 1}
local LOW_HEALTH_ALERT       = {message = "[Shields Low]", lifespan = 0.5, priority = 2}
local CRITICAL_HEALTH_ALERT  = {message = "[Shields Critical]", lifespan = 0.5, priority = 3}
local OUT_OF_SINIBOMBS_ALERT = {message = "[Out of Sinibombs]", lifespan = 1.5, priority = 2}
local GOT_CRYSTAL_MESSAGE    = {message = "[Retrieved Crystal]", lifespan = 2, priority = 4}
local RESPAWN_MESSAGE        = {message = "[Invincible]", lifespan = 3, priority = 5}

local Player = Class{}
Player.type = "Player"
Player.maxSpeed = EntityParams.player.maxSpeed
Player.radius = EntityParams.player.radius
Player.primaryFireOffset = EntityParams.player.primaryFireOffset

Player.variations = {
  {
    image = love.graphics.newImage("assets/player.png"),
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
  self.id = "Player"
  
  self.combat = Combat()
  self.combat:addCombatant("Player", {health = EntityParams.player.health})
  self.combat:addWeapon("Player Primary R", {ammo = math.huge, projectileID = "Player Bullet", debounceTime = EntityParams.player.primaryFireDebounce})
  self.combat:addWeapon("Player Primary L", {ammo = math.huge, projectileID = "Player Bullet", debounceTime = EntityParams.player.primaryFireDebounce})
  self.combat:addWeapon("Player Secondary", {ammo = 0, projectileID = "Sinibomb", debounceTime = EntityParams.player.secondaryFireDebounce, maxAmmo = EntityParams.player.secondaryMaxAmmo})  
    
  self.render = self.variations[math.random(#self.variations)]
  
  self.alertMachine = AlertMachine()
  self.soundSystem = SoundSystem()
  self.previousScore = 0
  self.invincibilityTimer = 0
end

function Player:update(dt)
  self.dir = self.playerInput.directionVec
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)

  if self.playerInput.primaryWeaponFire and self.combat:canFire("Player Primary R") and self.combat:canFire("Player Primary L") then
    local offset = self.dir:perpendicular()
    offset = offset:normalize_inplace()
    offset = offset:scale_inplace(self.primaryFireOffset)
    self.combat:fire("Player Primary R", self.loc + offset, self.dir, self.vel)
    self.combat:fire("Player Primary L", self.loc - offset, self.dir, self.vel)
    self.soundSystem:play("sound/playerShot.wav", 0.5)
  end
    
  if self.playerInput.secondaryWeaponFire and self.combat:canFire("Player Secondary") then
    self.soundSystem:play("sound/bombFire.wav", 0.5)
    if self.vel.x == 0 and self.vel.y == 0 then
      self.combat:fire("Player Secondary", self.loc, self.dir)
    else
      self.combat:fire("Player Secondary", self.loc, -self.dir, self.vel)
    end
  end
  
  if self.playerInput.secondaryWeaponFire and self.combat:isOutOfAmmo("Player Secondary") then
    self.alertMachine:set(OUT_OF_SINIBOMBS_ALERT)
--    self.soundSystem:play("sound/marinealarm.ogg",0.25)
    self.soundSystem:play("sound/alarm.wav",0.5)
  end

  self.combat:heal(self.id, dt * EntityParams.player.healpersec)
  self.gameData.bombs = self.combat:getAmmo("Player Secondary")
  self.gameData.health = self.combat:getHealthPercent("Player")
  self.isDead = self.combat:isDead("Player")
  
  local score = self.gameData.score
  if score > self.previousScore then
    SCORE_MESSAGE.message = "+"..(score-self.previousScore)
    self.alertMachine:set(SCORE_MESSAGE)
  end 
  self.previousScore = score
  
  if self.gameData.health < 0.25 then
    self.alertMachine:set(CRITICAL_HEALTH_ALERT)    
  elseif self.gameData.health < 0.5 then
    self.alertMachine:set(LOW_HEALTH_ALERT)
  end
  
  if self.isDead then
    self.soundSystem:play("sound/explosion.wav", 0.5)
  end 
  
  if self.invincibilityTimer > 0 then
    self.invincibilityTimer = self.invincibilityTimer - dt
  end
end

function Player:damage(xAmount)
  if self.invincibilityTimer <= 0 then
    self.combat:attack("Player", xAmount)
  end
end

function Player:onCollision(other)
  local type = other.type
  
  if type == "Warrior Bullet" then
    self:damage(EntityParams.player.damageFrom.warriorBullet)
    other.isDead = true
  end
  
  if type == "Worker Bullet" then
    self:damage(EntityParams.player.damageFrom.workerBullet)
    other.isDead = true
  end
  
  if type == "Sinistar" then
    self:damage(EntityParams.player.damageFrom.sinistarCollision)
  end
  
  if type == "Crystal" then
    self.gameData:increaseScore(self.gameData.crystalValue)
    self.combat:supplyAmmo("Player Secondary", EntityParams.player.bombAmmoFromCrystalPickup)
    other.isDead = true
    self.soundSystem:play("sound/crystalPickup.wav", 0.2)
    self.alertMachine:set(GOT_CRYSTAL_MESSAGE)
  end
  
  if type == "Sinibomb Blast" then
    self:damage(EntityParams.player.damageFrom.sinibombBlast)
  end
end

function Player:respawn()
  self.invincibilityTimer = RESPAWN_MESSAGE.lifespan
  self.alertMachine:set(RESPAWN_MESSAGE)
  self.combat:addCombatant("Player", {health = EntityParams.player.health})
  self.isDead = self.combat:isDead("Player")
end

return Player

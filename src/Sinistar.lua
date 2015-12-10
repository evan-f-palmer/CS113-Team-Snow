local Class  = require('hump.class')
local Vector = require('hump.vector')
local Boid   = require('Boid')
local Heap   = require('Heap')
local Combat = require('Combat')
local EntityParams = require('EntityParams')
local SoundSystem = require('SoundSystem')
local Animator = require('Animator')
local AlertMachine = require('AlertMachine')
local Probability = require('Probability')
local AnimationDefinitions = require('AnimationDefinitions')

local Sinistar = Class{__includes = Boid}
Sinistar.type = "Sinistar"
Sinistar.MAX_SPEED = 40000
Sinistar.MAX_FORCE = 60000
Sinistar.radius    = EntityParams.sinistar.radius

local CHARGING_ALERT  = {message = "[Sinistar Charging]", lifespan = 0.1, priority = 1}
local WANDERING_ALERT = {message = "[Sinistar Wandering]", lifespan = 0.1, priority = 1}
local CHASING_ALERT   = {message = "[Sinistar in Pursuit]", lifespan = 0.1, priority = 1}

local SINISTAR_DEATH_MESSAGE = {message = "[Sinistar Destroyed]", lifespan = 3, priority = 6}

local animator = Animator()

Sinistar.render = {
  image = love.graphics.newImage("assets/sinistar/sinistarMouthOpen.png"),
  animation = animator:newAnimation("Sinistar", 3),
  color = {255,255,255},
  shouldRotate = false,
}

Sinistar.modeTimePeriods = {
  ["WANDER"] = EntityParams.sinistar.wanderingTime,
  ["CHARGE"] = EntityParams.sinistar.chargingTime,
  ["CHASE"]  = EntityParams.sinistar.chasingTime,
}

Sinistar.modeMaxSpeeds = {
  ["WANDER"] = Sinistar.MAX_SPEED * EntityParams.sinistar.maxWanderingSpeedScale,
  ["CHARGE"] = Sinistar.MAX_SPEED * EntityParams.sinistar.maxChargingSpeedScale,
  ["CHASE"]  = Sinistar.MAX_SPEED * EntityParams.sinistar.maxChasingSpeedScale,
}

Sinistar.modeMaxForces = {
  ["WANDER"] = Sinistar.MAX_FORCE * EntityParams.sinistar.maxWanderingForceScale,
  ["CHARGE"] = Sinistar.MAX_FORCE * EntityParams.sinistar.maxChargingForceScale,
  ["CHASE"]  = Sinistar.MAX_FORCE * EntityParams.sinistar.maxChasingForceScale,
}

Sinistar.sounds = {
  "sound/Beware_Coward.ogg",
  "sound/I_am_Sinistar.ogg",
  "sound/I_Hunger_Coward.ogg",
  "sound/I_Hunger.ogg",
  "sound/Run_Coward.ogg",
  "sound/Argh.ogg",
  "sound/Run_Run_Run.ogg"
}

Sinistar.soundTime = 5

function Sinistar:init(gameData, world)
  self.gameData = gameData
  self.world = world
  self.player = self.world.player
  
  Boid.init(self, Sinistar.MAX_SPEED, Sinistar.MAX_FORCE)
  self.render = Sinistar.render
  self.render.animation:start()
  self.id = "Sinistar"
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = EntityParams.sinistar.health})
  self.soundSystem = SoundSystem()  

  self.alertMachine = AlertMachine()
  self.probability = Probability()
  
  self.hasLivedForThreeMinutes = false
  self.aliveTime = 0
  self.soundTimer = Sinistar.soundTime
  self.slowTimer = 0

  self:setMode("WANDER")  
end

function Sinistar:setMode(xMode)
  self.mode = xMode
  local scale = 1
  if self.slowTimer > 0 then
    scale = 0.6
  elseif self.isFarAway then
    scale = 1.4
  end
  self.maxSpeed = Sinistar.modeMaxSpeeds[xMode] * scale
  self.maxForce = Sinistar.modeMaxForces[xMode] * scale
  self.timer = Sinistar.modeTimePeriods[xMode]
  self.isFarAway = false
end

Sinistar.maxDistanceFromPlayer = 100000

function Sinistar:update(dt)
  Boid.update(self, dt)
  self.player = self.world.player
  
  self.soundTimer = self.soundTimer - dt
  self.slowTimer = self.slowTimer   - dt
  
  local x, y = self.getRelativeLoc(self.player)
  local loc = Vector(self.loc.x + x, self.loc.y + y)
  
  if self.mode == "WANDER" then
    self.alertMachine:set(WANDERING_ALERT)
    self.acc = self:wander()
    
    if self.soundTimer <= 0 then
      self.soundSystem:play(Sinistar.sounds[math.random(#Sinistar.sounds)],0.5)
      self.soundTimer = Sinistar.soundTime
    end
    
    if self.loc:dist2(loc) > Sinistar.maxDistanceFromPlayer * Sinistar.maxDistanceFromPlayer then
      print("far away")
      self.loc = loc - self.loc
      self.loc:normalize_inplace()
      self.loc:scale_inplace(Sinistar.maxDistanceFromPlayer)
      self.loc:add_inplace(loc)
    end
    
  elseif self.mode == "CHASE" then
    self.alertMachine:set(CHASING_ALERT)
    self.acc = self:seek(loc)
    
    if self.soundTimer <= 0 then
      self.soundSystem:play(Sinistar.sounds[math.random(#Sinistar.sounds)],0.5)
      self.soundTimer = Sinistar.soundTime
    end
    
  elseif self.mode == "CHARGE" then
    self.alertMachine:set(CHARGING_ALERT)
    if self.soundTimer <= 0 then
      self.soundSystem:play(Sinistar.sounds[math.random(#Sinistar.sounds)],0.5)
      self.soundTimer = Sinistar.soundTime
    end
    
    if not self.charge then
      if self.probability:of(0.5) then
        self.charge = self:seek(loc)
      else
        self.charge = self:seek(loc)
      end
    end
    
    self.acc = self.charge:clone()
  end
  
  self.timer = self.timer - dt
  
  if self.timer < 0 then
    if self.mode == "WANDER" then
      self:setMode(self.probability:of(0.15) and "CHASE" or "CHARGE")
    elseif self.mode == "CHASE" then
      self:setMode(self.probability:of(0.30) and "CHARGE" or "CHASE")
    elseif self.mode == "CHARGE" then
      self.charge = nil
      self:setMode(self.probability:of(0.75) and "CHARGE" or "CHASE")
    end
  end
  
  local prevCheck = self.hasLivedForThreeMinutes
  self.aliveTime = self.aliveTime + dt
  self.hasLivedForThreeMinutes = (self.aliveTime >= 180)
  local hasLivedForExactlyThreeMinutes = (not prevCheck) and self.hasLivedForThreeMinutes
  if hasLivedForExactlyThreeMinutes then
    self.gameData:increaseScore(self.gameData.survivedSinistarForThreeMinutesValue)
  end
  
  self.isDead = self.combat:isDead(self.id)
end

function Sinistar:onDeath()
  self.alertMachine:set(SINISTAR_DEATH_MESSAGE)
  self.soundSystem:play("sound/explosion.wav", 0.5)    
  self.gameData:increaseScore(self.gameData.sinistarKillValue)
end

function Sinistar:damage(xAmount)
  self.combat:attack(self.id, xAmount)
end

function Sinistar:onCollision(other)
  local type = other.type
  
  if type == "Player Bullet" then
    self:damage(EntityParams.sinistar.damageFrom.playerBullet)
    self.gameData:increaseScore(self.gameData.sinistarHitWithPlayerBulletValue)
    other.isDead = true
  end
  
  if type == "Asteroid" or type == "Worker" or type == "Warrior" then
    other.isDead = true
  end
  
  if type == "Sinibomb" then
    self:damage(EntityParams.sinistar.damageFrom.sinibomb)
    self.gameData:increaseScore(self.gameData.sinistarHitWithSinibombValue)
    other.isDead = true
    self.slowTimer = 0.55
    self:setMode("WANDER")
  end
  
  if type == "Sinibomb Blast" then
    self:damage(EntityParams.sinistar.damageFrom.sinibombBlast)
    self.gameData:increaseScore(self.gameData.sinistarHitWithSinibombBlastValue)
    self.slowTimer = 0.55
    self:setMode("WANDER")
  end
end

return Sinistar
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

local Sinistar = Class{__includes = Boid}
Sinistar.type = "Sinistar"
Sinistar.MAX_SPEED = 40000  * EntityParams.sinistar.maxSpeedScale
Sinistar.MAX_FORCE = 60000 * EntityParams.sinistar.maxForceScale
Sinistar.radius    = EntityParams.sinistar.radius

local CHARGING_ALERT  = {message = "[CHARGING]",  lifespan = 0.1, priority = 4}
local WANDERING_ALERT = {message = "[WANDERING]", lifespan = 0.1, priority = 4}
local CHASING_ALERT   = {message = "[CHASING]",   lifespan = 0.1, priority = 4}

local ANIMATOR = Animator()

Sinistar.render = {
  image = love.graphics.newImage("assets/sinistar.png"),
  color = {255,255,255},
  shouldRotate = false,
}

Sinistar.modeTimePeriods = {
  ["WANDER"] = 1,
  ["CHARGE"] = 2,
  ["CHASE"]  = 0.5,
}

function Sinistar:init(gameData)
  self.gameData = gameData
  
  Boid.init(self, Sinistar.MAX_SPEED, Sinistar.MAX_FORCE)
  self.render = Sinistar.render
  
  self.id = "Sinistar"
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = EntityParams.sinistar.health})
  self.soundSystem = SoundSystem()  

  self:setMode("WANDER")
  
  self.alertMachine = AlertMachine()
  self.probability = Probability()
end

function Sinistar:setMode(xMode)
  self.mode = xMode
  self.timer = Sinistar.modeTimePeriods[xMode]
end

function Sinistar:update(dt)
  Boid.update(self, dt)
  
  if self.mode == "WANDER" then
    self.alertMachine:set(WANDERING_ALERT)
    self.acc = self:wander()
    self.acc:scale_inplace(1 / 4)
    
  elseif self.mode == "CHASE" then
    self.alertMachine:set(CHASING_ALERT)
    local x, y = self.getRelativeLoc(self.player)
    local loc = Vector(self.loc.x + x, self.loc.y + y)
    self.acc = self:pursue(loc, self.player.vel)
    
  elseif self.mode == "CHARGE" then
    self.alertMachine:set(CHARGING_ALERT)
    
    if not self.charge then
      local x, y = self.getRelativeLoc(self.player)
      local loc = Vector(self.loc.x + x, self.loc.y + y)
      if self.probability:of(0.5) then
        self.charge = self:seek(loc)
      else
        self.charge = self:pursue(loc, self.player.vel)
      end
    end
    
    self.acc = self.charge:clone()
  end
  
  self.timer = self.timer - dt
  
  if self.timer < 0 then
    if self.mode == "WANDER" then
      self:setMode(self.probability:of(0.1) and "CHASE" or "CHARGE")
    elseif self.mode == "CHASE" then
      self:setMode("WANDER")
    elseif self.mode == "CHARGE" then
      self.charge = nil
      self:setMode(self.probability:of(0.6) and "CHARGE" or "WANDER")
    end
  end
  
  self.isDead = self.combat:isDead(self.id)
  
  if self.isDead then
    self.soundSystem:play("sound/explosion.wav", 0.5)    
    if (self.lastCollision == "Player Bullet" or self.lastCollision == "Sinibomb" or self.lastCollision == "Sinibomb Blast") then
      self.gameData:increaseScore(self.gameData.sinistarKillValue)  
    end
  end
end

function Sinistar:damage(xAmount)
  self.combat:attack(self.id, xAmount)
end

function Sinistar:onCollision(other)
  local type = other.type

  if type == "Crystal" then
    other.isDead = true
  end
  
  if type == "Player Bullet" then
    self:damage(EntityParams.sinistar.damageFrom.playerBullet)
    other.isDead = true
  end
  
  if type == "Sinibomb" then
    self:damage(EntityParams.sinistar.damageFrom.sinibomb)
    other.isDead = true
  end
  
  if type == "Sinibomb Blast" then
    self:damage(EntityParams.sinistar.damageFrom.sinibombBlast)
  end
  
  self.lastCollision = type
end

return Sinistar
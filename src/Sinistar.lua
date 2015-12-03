local Class  = require('hump.class')
local Vector = require('hump.vector')
local Boid   = require('Boid')
local Heap   = require('Heap')
local Combat = require('Combat')
local EntityParams = require('EntityParams')
local SoundSystem = require('SoundSystem')
local Animator = require('Animator')

local Sinistar = Class{__includes = Boid}
Sinistar.count = 0
Sinistar.type = "Sinistar"
Sinistar.MAX_SPEED = 40000  * EntityParams.sinistar.maxSpeedScale
Sinistar.MAX_FORCE = 60000 * EntityParams.sinistar.maxForceScale
Sinistar.radius    = EntityParams.sinistar.radius

local ANIMATOR = Animator()

Sinistar.render = {
  image = love.graphics.newImage("assets/sinistar.png"),
  color = {255,255,255},
  shouldRotate = false,
}

Sinistar.chargeTime = 3
Sinistar.totalChargeTime = 1

function Sinistar:init(gameData)
  self.gameData = gameData
  
  Boid.init(self, Sinistar.MAX_SPEED, Sinistar.MAX_FORCE)
  self.render = Sinistar.render
  self.shouldFire = nil
  
  self.id = "Sinistar"
  Sinistar.count = Sinistar.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = EntityParams.sinistar.health})
  self.soundSystem = SoundSystem()  
  self.chargeTimer = Sinistar.chargeTime
  self.coolDownTimer = 0
end

function Sinistar:update(dt)
  Boid.update(self, dt)
  
  self.chargeTimer = self.chargeTimer - dt
  if (self.chargeTimer < 0) then
    self.chargeTimer = Sinistar.chargeTime
    local x, y = self.getRelativeLoc(self.player)
    local loc = Vector(x + self.loc.x, y + self.loc.y)
    self.charge = self:pursue(loc, self.player.vel)
    self.coolDownTimer = Sinistar.chargeTime - Sinistar.totalChargeTime
  end
  
  self.coolDownTimer = self.coolDownTimer - dt
  if self.coolDownTimer < 0 then
    self.charge = nil
  end
  
  if self.charge then
    self.acc = self.charge:clone()
  else
    self.acc = self:wander()
    self.acc:scale_inplace(1 / 4)
  end
  
  self.isDead = self.combat:isDead(self.id)
  
  if self.isDead then
    self.soundSystem:play("sound/explosion.wav", 0.5)    
    if (self.lastCollision == "Player Bullet" or self.lastCollision == "Sinibomb" or self.lastCollision == "Sinibomb Blast") then
      self.gameData:increaseScore(self.gameData.SinistarKillValue)  
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
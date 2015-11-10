local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')

local Asteroid = Class{}
Asteroid.type = "Asteroid"
Asteroid.count = 0

function Asteroid:init(xPlayerGameData)
  self.playerGameData = xPlayerGameData

  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.maxSpeed = 0
  self.radius = 80
  
  self.id = "Asteroid:" .. Asteroid.count
  Asteroid.count = Asteroid.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = 300})
  self.combat:addWeapon(self.id, {ammo = 6, projectileID = "Crystal", debounceTime = 2.25})
  
  self.render = {
    image = love.graphics.newImage("assets/worker.png"),
    color = {255,255,255},
    shouldRotate = true,
  }
  
  self.alertMachine = AlertMachine()
  self.soundSystem = SoundSystem()
  self.lastCollision = "None"
end

function Asteroid:update(dt)
  self.isDead = self.combat:isDead(self.id) or self.combat:isOutOfAmmo(self.id)
  if not self.isDead then
    self.combat:heal(self.id, 0.1)
  elseif self.lastCollision == "Player Bullet" or self.lastCollision == "Sinibomb" then
    self.playerGameData:increaseScore(self.playerGameData.asteroidKillValue)
  end
end

function Asteroid:fire()
  local offset = 20
  local dir = Vector():randomize_inplace()
  self.combat:fire(self.id, self.loc + (dir * offset), dir)
end

function Asteroid:attack(xAmount)
  self.combat:attack(self.id, xAmount)
end

function Asteroid:onCollision(other)
  local type = other.type
  
  if type == "Player Bullet" then
    if self.combat:canFire(self.id) then
      self:attack(2)
      self:fire()
    else
      self:attack(5)
      self:fire()
    end
    other.isDead = true
    self.lastCollision = type
  end
  if type == "Worker Bullet" then
    self:attack(1)
    self:fire()
    other.isDead = true
    self.lastCollision = type
  end
  if type == "Warrior Bullet" then
    self:attack(25)
    self:fire()
    other.isDead = true
    self.lastCollision = type
  end
  if type == "Sinibomb" then
    self:attack(1000)
    self:fire()
    other.isDead = true
    self.lastCollision = type
  end
end

return Asteroid
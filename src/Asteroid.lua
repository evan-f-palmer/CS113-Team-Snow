local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')

local Asteroid = Class{}
Asteroid.type = "Asteroid"
Asteroid.count = 0

function Asteroid:init()
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.maxSpeed = 0
  self.radius = 80
  
  self.id = "Asteroid:" .. Asteroid.count
  Asteroid.count = Asteroid.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = 100})
  self.combat:addWeapon(self.id, {ammo = 20, projectileID = "Crystal", debounceTime = 0.75})
  
  self.render = {
    image = love.graphics.newImage("assets/worker.png"),
    color = {255,255,255},
    shouldRotate = true,
  }
  
  self.alertMachine = AlertMachine()
  self.soundSystem = SoundSystem()
end

function Asteroid:update(dt)
  self.isDead = self.combat:isDead(self.id) or self.combat:isOutOfAmmo(self.id)
  if not self.isDead then
    self.combat:heal(self.id, 0.1)
  end
end

function Asteroid:onCollision(other)
  local type = other.type
  if type == "Player Bullet" then
    if self.combat:canFire(self.id) then
      self.combat:attack(self.id, 5)
    else
      self.combat:attack(self.id, 12)
    end
    other.isDead = true
  end
  if type == "Worker Bullet" then
    other.isDead = true
  end
  if type == "Warrior Bullet" then
    other.isDead = true
  end
  if type == "Sinibomb" then
    other.isDead = true
  end
end

return Asteroid
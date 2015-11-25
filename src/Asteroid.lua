local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')
local EntityParams = require('EntityParams')

local Asteroid = Class{}
Asteroid.type = "Asteroid"
Asteroid.count = 0

Asteroid.variations = {
  {
    image = love.graphics.newImage("assets/asteroid.png"),
    color = {165,165,165},
    shouldRotate = true,
  },
  {
    image = love.graphics.newImage("assets/asteroid.png"),
    color = {105,105,105},
    shouldRotate = true,
  },
  {
    image = love.graphics.newImage("assets/asteroid.png"),
    color = {143,127,121},
    shouldRotate = true,
  },
}

function Asteroid:init(gameData)
  self.gameData = gameData

  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.maxSpeed = 0
  self.radius = EntityParams.asteroid.radius
  
  self.id = "Asteroid:" .. Asteroid.count
  Asteroid.count = Asteroid.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = EntityParams.asteroid.health})
  self.combat:addWeapon(self.id, {ammo = EntityParams.asteroid.crystals, projectileID = "Crystal", debounceTime = EntityParams.asteroid.crystalDebounce})
  
  self.render = self.variations[math.random(#self.variations)]
  
  self.alertMachine = AlertMachine()
  self.soundSystem = SoundSystem()
  self.lastCollision = "None"
end

function Asteroid:update(dt)
  self.combat:heal(self.id, dt * 3)
  self.isDead = self.combat:isDead(self.id) or self.combat:isOutOfAmmo(self.id)
  
  if self.isDead and (self.lastCollision == "Player Bullet" or self.lastCollision == "Sinibomb" or self.lastCollision == "Sinibomb Blast") then
    self.gameData:increaseScore(self.gameData.asteroidKillValue)
  end
end

function Asteroid:fire()
  local offset = EntityParams.asteroid.fireOffset
  local dir = Vector():randomize_inplace()
  self.combat:fire(self.id, self.loc + (dir * offset), dir)
end

function Asteroid:damage(xAmount)
  self.combat:attack(self.id, xAmount)
end

function Asteroid:onCollision(other)
  local type = other.type
  
  if type == "Player Bullet" then
    if self.combat:canFire(self.id) then
      self:damage(EntityParams.asteroid.damageFrom.playerBullet)
      self:fire()
    else
      self:damage(EntityParams.asteroid.excessiveDamageFrom.playerBullet)
      self:fire()
    end
    other.isDead = true
  end
  if type == "Worker Bullet" then
    self:damage(EntityParams.asteroid.damageFrom.workerBullet)
    self:fire()
    other.isDead = true
  end
  if type == "Warrior Bullet" then
    self:damage(EntityParams.asteroid.damageFrom.warriorBullet)
    self:fire()
    other.isDead = true
  end
  if type == "Sinibomb" then
    self:damage(EntityParams.asteroid.damageFrom.sinibomb)
    other.isDead = true
  end
  
  if type == "Sinibomb Blast" then
    self:damage(EntityParams.asteroid.damageFrom.sinibombBlast)
  end
  
  self.lastCollision = type
end

return Asteroid
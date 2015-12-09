local Class  = require('hump.class')
local Vector = require('hump.vector')
local AlertMachine = require('AlertMachine')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')
local EntityParams = require('EntityParams')
local Probability = require('Probability')
local Projectiles  = require('Projectiles')

local Asteroid = Class{}
Asteroid.type = "Asteroid"
Asteroid.count = 0
Asteroid.probability = Probability()

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
  {
    image = love.graphics.newImage("assets/asteroid2.png"),
    color = {165,165,165},
    shouldRotate = true,
  },
  {
    image = love.graphics.newImage("assets/asteroid2.png"),
    color = {105,105,105},
    shouldRotate = true,
  },
  {
    image = love.graphics.newImage("assets/asteroid2.png"),
    color = {143,127,121},
    shouldRotate = true,
  },
}

local projectiles = Projectiles()
local asteroidFragCount = 1
for _, obj in pairs(Asteroid.variations) do
  projectiles:define("AsteroidFrag" .. asteroidFragCount , {
    shouldRotate = true, 
    image = love.graphics.newImage("assets/asteroidFrag1.png"), 
    color = obj.color, 
    speed = EntityParams.asteroidFrag.speed, 
    lifespan = EntityParams.asteroidFrag.lifespan, 
    radius = EntityParams.asteroidFrag.radius
  })
  projectiles:define("AsteroidFrag" .. (asteroidFragCount + #Asteroid.variations) , {
    shouldRotate = true, 
    image = love.graphics.newImage("assets/asteroidFrag2.png"), 
    color = obj.color, 
    speed = EntityParams.asteroidFrag.speed, 
    lifespan = EntityParams.asteroidFrag.lifespan,
    radius = EntityParams.asteroidFrag.radius
  })
  asteroidFragCount = asteroidFragCount + 1
end

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
  self.combat:recharge(self.id)
  
  local variation = math.random(#self.variations)
  self.render = self.variations[variation]
  self.combat:addWeapon(self.id .. 1, {ammo = 5, projectileID = "AsteroidFrag" .. (variation), debounceTime = 0})
  self.combat:addWeapon(self.id .. 2, {ammo = 5, projectileID = "AsteroidFrag" .. (variation + #self.variations), debounceTime = 0})
  
  self.alertMachine = AlertMachine()
  self.soundSystem = SoundSystem()
  self.wasPlayerCausedCollision = false
end

function Asteroid:update(dt)
  self.combat:heal(self.id, dt + dt + dt)
  self.isDead = self.combat:isDead(self.id) or self.combat:isOutOfAmmo(self.id)
end

function Asteroid:onDeath()
  if self.wasPlayerCausedCollision then
    self.gameData:increaseScore(self.gameData.asteroidKillValue)
  end
  
  local offset = EntityParams.asteroid.fireOffset
  for i = 1, (3 + math.random(5)) do
    local dir = Vector():randomize_inplace()
    if self.probability:of(0.5) then
      self.combat:fire(self.id .. 1, self.loc + (dir * offset), dir)
    else
      self.combat:fire(self.id .. 2, self.loc + (dir * offset), dir)
    end
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
      if self.probability:of(EntityParams.asteroid.crystalProductionProbabilityFor.playerBullet) then
        self:fire()
      end
    else
      self:damage(EntityParams.asteroid.excessiveDamageFrom.playerBullet)
      if self.probability:of(EntityParams.asteroid.excessiveDamageCrystalProductionProbabilityFor.playerBullet) then
        self:fire()
      end
    end
    other.isDead = true
    self.wasPlayerCausedCollision = true
  end

  if type == "Sinibomb" then
    self:damage(EntityParams.asteroid.damageFrom.sinibomb)
    other.isDead = true
    self.wasPlayerCausedCollision = true
  end
  
  if type == "Sinibomb Blast" then
    self:damage(EntityParams.asteroid.damageFrom.sinibombBlast)
    self.wasPlayerCausedCollision = true
  end
  
  if type == "Worker Bullet" then
    self:damage(EntityParams.asteroid.damageFrom.workerBullet)
    if self.probability:of(EntityParams.asteroid.crystalProductionProbabilityFor.workerBullet) then
      self:fire()
    end
    other.isDead = true
    self.wasPlayerCausedCollision = false
  end
  
  if type == "Sinistar" then
    self:damage(EntityParams.asteroid.damageFrom.sinistar)
  end
end

return Asteroid
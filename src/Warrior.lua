local Class  = require('hump.class')
local Vector = require('hump.vector')
local Boid   = require('Boid')
local Heap   = require('Heap')
local Combat = require('Combat')
local EntityParams = require('EntityParams')
local SoundSystem = require('SoundSystem')
local Animator = require('Animator')

local Warrior = Class{__includes = Boid}
Warrior.count = 0
Warrior.type = "Warrior"
Warrior.MAX_SPEED = 20000  * EntityParams.warrior.maxSpeedScale
Warrior.MAX_FORCE = 100000 * EntityParams.warrior.maxForceScale
Warrior.sightRadius = EntityParams.warrior.sightRadius
Warrior.radius = EntityParams.warrior.radius
Warrior.maxDistanceFromFlock = EntityParams.warrior.maxDistanceFromFlock
Warrior.minDistance2 = math.pow(EntityParams.warrior.closestProximity, 2)

local ANIMATOR = Animator()

Warrior.render = {
  color = {255,255,255},
  shouldRotate = false,
}

function Warrior:init(gameData)
  self.gameData = gameData

  Boid.init(self, Warrior.MAX_SPEED, Warrior.MAX_FORCE)
  self.currentTarget  = nil
  self.previousTarget = nil
  self.render = Warrior.render
  self.shouldFire = nil
  
  self.id = "Warrior:" .. Warrior.count
  Warrior.count = Warrior.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = EntityParams.warrior.health})
  self.combat:addWeapon(self.id, {ammo = math.huge, projectileID = "Warrior Bullet", debounceTime = EntityParams.warrior.fireDebounce})
  self.soundSystem = SoundSystem()  
  
  self.render.animation = ANIMATOR:newAnimation("WarriorLights", (2)) -- (1/2) is the fps. fps > 1 works too.
  self.render.animation.start() -- you must tell it to start when you want it to start
end

function Warrior:setFlock(xFlock)
  self.flock = xFlock
end

function Warrior:update(dt)
  Boid.update(self, dt)
  
  if self.currentTarget  then 
    local angle = self:pursue(self.currentTarget)
    self.combat:fire(self.id, self.loc, angle, self.vel)
  end
  
  self.isDead = self.combat:isDead(self.id)
  
  if self.isDead and (self.lastCollision == "Player Bullet" or self.lastCollision == "Sinibomb" or self.lastCollision == "Sinibomb Blast") then
    self.gameData:increaseScore(self.gameData.warriorKillValue)
    self.soundSystem:play("sound/explosion.wav", 0.5)    
  end
end

function Warrior:damage(xAmount)
  self.combat:attack(self.id, xAmount)
end

function Warrior:onCollision(other)
  local type = other.type

  if type == "Crystal" then
    self.gameData:incrementSinistarCrystals()    
    other.isDead = true
  end
  
  if type == "Player Bullet" then
    self:damage(EntityParams.warrior.damageFrom.playerBullet)
    other.isDead = true
  end
  
  if type == "Sinibomb" then
    self:damage(EntityParams.warrior.damageFrom.sinibomb)
    other.isDead = true
  end
  
  if type == "Sinibomb Blast" then
    self:damage(EntityParams.warrior.damageFrom.sinibombBlast)
  end
  
  if type == "Asteroid" then
    self.vel = -self.vel -- but controls vector just overrides it...
  end
  
  self.lastCollision = type
end

function Warrior:updateAI()
  local target, asteroids = self:pickTarget()
  self:updateSteering(target, asteroids)
  self:updateFiring(target)
  self:setTarget(target)
end

function Warrior:pickTarget()
  local player
  local asteroids        = Heap(self:makeAsteroidPriority())

  for _, neighbor in pairs(self.getNeighbors(Warrior.sightRadius)) do
    if neighbor.type     == "Asteroid" then
      asteroids:add(neighbor)
    elseif neighbor.type == "Player" then
      player = neighbor
    end    
  end
  
  return player, asteroids
end

function Warrior:updateSteering(target, asteroids)
  local steer = Vector(0, 0)
  
  steer:add_inplace(self:wander())
  
  -- Avoid Asteroids
  for _, asteroid in pairs(asteroids.data) do
    tmp = self:flee(asteroid.loc)
    tmp:scale_inplace(1 / self.loc:dist2(asteroid.loc)) -- Use inverse square 
    steer:add_inplace(tmp)
  end
  
  self.acc = steer
end

function Warrior:updateFiring(target)
  if target == nil then
    self.shouldFire = nil
  else
    self.shouldFire = true
  end
end

function Warrior:makeAsteroidPriority()  
  return function(a1, a2)
    local dis2A1 = self.loc:dist2(a1.loc)
    local dis2A2 = self.loc:dist2(a2.loc)
    
    -- Asteroid health should also be considered
    
    return dis2A1 < dis2A2
  end
end

function Warrior:setTarget(newTarget)
  self.previousTarget = self.currentTarget
  self.currentTarget = newTarget
end

return Warrior
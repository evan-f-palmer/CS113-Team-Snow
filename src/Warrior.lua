local Class  = require('hump.class')
local Vector = require('hump.vector')
local Boid   = require('Boid')
local Heap   = require('Heap')
local Combat = require('Combat')

local Warrior = Class{__includes = Boid}

Warrior.MAX_SPEED = 20000
Warrior.MAX_FORCE = 100000
Warrior.type = "Warrior"
Warrior.count = 0
Warrior.sightRadius = 2000

Warrior.render = {
  image = love.graphics.newImage("assets/warrior.png"),
  color = {255,255,255},
  shouldRotate = false,
}

function Warrior:init(xPlayerGameData)
  self.playerGameData = xPlayerGameData

  Boid.init(self, Warrior.MAX_SPEED, Warrior.MAX_FORCE)
  self.currentTarget  = nil
  self.previousTarget = nil
  self.render = Warrior.render
  self.minDistance2 = math.pow(300, 2)
  self.shouldFire = nil
  self.maxDistanceFromFlock = 1000
  self.radius = 70
  
  self.id = "Warrior:" .. Warrior.count
  Warrior.count = Warrior.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = 60})
  self.combat:addWeapon(self.id .. " Weapon", {ammo = math.huge, projectileID = "Warrior Bullet", debounceTime = 3})
end

function Warrior:setFlock(xFlock)
  self.flock = xFlock
end

function Warrior:update(dt)
--  print(self.id, self.loc)
  Boid.update(self, dt)
  
  if self.currentTarget  then 
    local angle = self:pursue(self.currentTarget)
    self.combat:fire(self.id .. " Weapon", self.loc, angle, self.vel)
  end
  
  self.isDead = self.combat:isDead(self.id)
  
  if self.isDead and (self.lastCollision == "Player Bullet" or self.lastCollision == "Sinibomb") then
    self.playerGameData:increaseScore(self.playerGameData.warriorKillValue)
  end
end

function Warrior:onCollision(other)
  local type = other.type

  if type == "Crystal" then
    -- Collect crystal here
    
    other.isDead = true
  end
  
  if type == "Player Bullet" then
    self.combat:attack(self.id, 10)
    other.isDead = true
  end
  
  if type == "Sinibomb" then
    self.combat:attack(self.id, 1000)
    other.isDead = true
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
  
  local isTooFarFromFlock = self.flock.avgLoc:dist2(self.loc) > self.maxDistanceFromFlock
  -- Move towards target
  local tmp
  if isTooFarFromFlock and target and self.loc:dist2(target.loc) > self.minDistance2 then
    tmp = self:seek(target.loc)
  elseif isTooFarFromFlock then
    tmp = self:seek(self.flock.avgLoc)
  else 
    tmp = self:wander()
  end
  
  steer:add_inplace(tmp)
  
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
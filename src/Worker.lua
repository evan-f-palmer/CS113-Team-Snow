local Class  = require('hump.class')
local Vector = require('hump.vector')
local Boid   = require('Boid')
local Heap   = require('Heap')
local Combat = require('Combat')

local Worker = Class{__includes = Boid}

Worker.MAX_SPEED = 20000
Worker.MAX_FORCE = 100000
Worker.type = "Worker"
Worker.count = 0
Worker.sightRadius = 2000

Worker.render = {
  image = love.graphics.newImage("assets/worker.png"),
  color = {255,255,255},
  shouldRotate = false,
}

function Worker:init()
  Boid.init(self, Worker.MAX_SPEED, Worker.MAX_FORCE)
  self.currentTarget  = nil
  self.previousTarget = nil
  self.render = Worker.render
  self.minDistance2 = math.pow(300, 2)
  self.shouldFire = nil
  self.radius = 70
  
  self.id = "Worker:" .. Worker.count
  Worker.count = Worker.count + 1
  self.combat = Combat()
  self.combat:addCombatant(self.id, {health = 60})
  self.combat:addWeapon(self.id .. " Weapon", {ammo = math.huge, projectileID = "Worker Bullet", debounceTime = 5.6})
end

function Worker:setFlock(xFlock)
  self.flock = xFlock
end

function Worker:update(dt)
--  print(self.id, self.loc)
  Boid.update(self, dt)
  
  if self.currentTarget and self.shouldFire then 
    if self.currentTarget.type == "Player" then
      local angle = self:pursue(self.currentTarget)
      self.combat:fire(self.id .. " Weapon", self.loc, angle, self.vel)
    else
      -- Need more logic here for asteroid mining
      local angle = self:seek(self.currentTarget.loc)
      self.combat:fire(self.id .. " Weapon", self.loc, angle, self.vel)
    end
  end
  
  self.isDead = self.combat:isDead(self.id)
end

function Worker:onCollision(other)
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
end

function Worker:updateAI()
  local target, asteroids = self:pickTarget()
  self:updateSteering(target, asteroids)
  self:updateFiring(target)
  self:setTarget(target)
end

function Worker:pickTarget()
  local player
  local asteroids        = Heap(self:makeAsteroidPriority())
  local crystals         = Heap(self:makeCrystalPriority())
  local alliesTargets    = {}
  local numberOfWarriors = 0

  for _, neighbor in pairs(self.getNeighbors(Worker.sightRadius)) do
    if neighbor.type     == "Asteroid" then
      asteroids:add(neighbor)
    elseif neighbor.type == "Player" then
      player = neighbor
    elseif neighbor.type == "Worker" and neighbor.id ~= self.id then
      self:addAllyTarget(alliesTargets, neighbor.currentTarget)
    elseif neighbor.type == "Warrior" then
      self:addAllyTarget(alliesTargets, neighbor.currentTarget)
      numberOfWarriors = numberOfWarriors + 1
    elseif neighbor.type == "Crystal" then
      crystals:add(neighbor)
    end    
  end
  
  local target = self:determinMainTarget(player, asteroids, crystals, alliesTargets, numberOfWarriors)
  
  return target, asteroids
end

function Worker:updateSteering(target, asteroids)
  local steer = Vector(0, 0)
  
  -- Move towards target
  local tmp
  if target and (target.type == "Crystal" or self.loc:dist2(target.loc) > self.minDistance2) then
    tmp = self:seek(target.loc)
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

function Worker:updateFiring(target)
  if target == nil or target.type == "Crystal" then
    self.shouldFire = nil
  elseif target.type == "Asteroid" then
    self.shouldFire = "steady"
  elseif target.type == "Player" then
    self.shouldFire = "fast"
  end
end

function Worker:makeAsteroidPriority()  
  return function(a1, a2)
    local dis2A1 = self.loc:dist2(a1.loc)
    local dis2A2 = self.loc:dist2(a2.loc)
    
    -- Asteroid health should also be considered
    
    return dis2A1 < dis2A2
  end
end

function Worker:makeCrystalPriority()
  return function(c1, c2)
    return self.loc:dist2(c1.loc) < self.loc:dist2(c2.loc)
  end
end

function Worker:determinMainTarget(player, asteroids, crystals, alliesTargets, numberOfWarriors)
  while crystals:size() > 0 do
    if not alliesTargets[crystals:peek()] or alliesTargets[crystals:peek()] <= 2 then
      return crystals:peek()
    end
    crystals:remove()
  end
   
  if numberOfWarriors == 0 and player then
    if not alliesTargets[player] or alliesTargets[player] <= 1 then
      return player
    end
  end
  
  while asteroids:size() > 0 do
    if not alliesTargets[asteroids:peek()] or alliesTargets[asteroids:peek()] <= 3 then
      return asteroids:peek()
    end
    asteroids:remove()
  end  
end

function Worker:setTarget(newTarget)
  self.previousTarget = self.currentTarget
  self.currentTarget = newTarget
end

function Worker:addAllyTarget(alliesTargets, target)
  if target then
    if not alliesTargets[target] then
      alliesTargets[target] = 1
    else
      alliesTargets[target] = alliesTargets[target] + 1
    end
  end
end

return Worker
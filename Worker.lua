local Class = require('hump.class')
local Boid = require('Boid')
local Heap = require('Heap')

local Worker = Class{__includes = Boid}

Worker.MAX_SPEED = 10
Worker.MAX_FORCE = 10
Worker.ID = "Worker"

function Worker:init(loc)
  Boid.init(self, loc, Worker.MAX_SPEED, Worker.MAX_FORCE)
  self.currentTarget  = nil
  self.previousTarget = nil
end

function Worker:update(dt)
  Boid.update(self, dt)
end

function Worker:onCollision()

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
    local dis2C1 = self.loc:dist2(c1.loc)
    local dis2C2 = self.loc:dist2(c2.loc)
        
    return dis2C1 < dis2C2
  end
end

function Worker:updateAI()
  local player
  local asteroids        = Heap(self:makeAsteroidPriority())
  local crystals         = Heap(self:makeCrystalPriority())
  local alliesTargets    = {}
  local numberOfWarriors = 0
  
  for _, neighbor in pairs(self:getNeightbors()) do
    if neighbor.ID     == "Asteroid" then
      asteroids:add(neighbor)
    elseif neighbor.ID == "Player" then
      player = neighbor
    elseif neighbor.ID == "Worker" then
      self:addAllyTarget(alliesTargets, neighbor.previousTarget)
    elseif neighbor.ID == "Warrior" then
      self:addAllyTarget(alliesTargets, neighbor.previousTarget)
      numberOfWarriors = numberOfWarriors + 1
    elseif neighbor.ID == "Crystal" then
      crystals:add(neighbor)
    end    
  end
  
  local target = self.currentTarget
  if not self:isCurrentTargetStillValid() then
    target = self:determinMainTarget(player, asteroids, crystals, alliesTargets, numberOfWarriors)
  end
  
  
end

function Worker:isCurrentTargetStillValid()
  return false
end

function Worker:determinMainTarget(player, asteroids, crystals, alliesTargets, numberOfWarriors)
  while crystals:size() > 0 do
    if not alliesTargets[crystals:peek()] then
      return crystals:peek()
    end
    crystals:remove()
  end
   
  if numberOfWarriors == 0 and player then
    if alliesTargets[player] <= 2 then
      return player
    end
  end
  
  while asteroids:size() > 0 do
    if alliesTargets[asteroids:peek()] <= 2 then
      return asteroids:peek()
    end
    asteroids:remove()
  end
  
  -- Wander until we find something
  
end

function Worker:setTarget(newTarget)
  self.previousTarget = self.currentTarget
  self.currentTarget = newTarget
end

function Worker:addAllyTarget(alliesTargets, target)
  if not alliesTargets[target] then
    alliesTargets[target] = 1
  else
    alliesTargets[target] = alliesTargets[target] + 1
  end
end

return Worker
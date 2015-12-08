local Class  = require('hump.class')
local Vector = require('hump.vector')

local Flock = Class {}

function Flock:init(boids, maxSeparation, separationScale, cohesionScale)
  self.boids = boids
  self.maxSeparation2 = maxSeparation * maxSeparation
  self.separationScale = separationScale
  self.cohesionScale = cohesionScale
  self.avgAcc = Vector(0, 0)
  self.avgLoc = Vector(0, 0)
  self.missingTypes = {}
  self.respawnStep = nil
  self.recalcTimer = 0.5
end

function Flock:update(dt)
  self.recalcTimer = self.recalcTimer - dt
  if self.recalcTimer <= 0 then
    self:calcAvgs()
    self:separation()
    self:cohesion()
  --  self:alignment()
    self.recalcTimer = 0.5
  end
end

function Flock:addBoid(boid)
  self.boids[boid.id] = boid
end

function Flock:removeBoid(boid)
  self.boids[boid.id] = nil
  self.missingTypes[#self.missingTypes + 1] = boid.type
end

function Flock:claimRespawn()
  return table.remove(self.missingTypes)
end

function Flock:calcAvgs()
  self.avgAcc = Vector(0, 0)
  self.avgLoc = Vector(0, 0)
  local mainLocBoid = self.boids[1]
  self.mainLocBoid = mainLocBoid
  self.avgAcc:add_inplace(mainLocBoid.acc)
  self.avgLoc:add_inplace(mainLocBoid.loc)
  
  for i = 2, #self.boids do
    local boid = self.boids[i]
    local x, y = mainLocBoid.getRelativeLoc(boid)
    local loc = Vector(mainLocBoid.loc.x + x, mainLocBoid.loc.y + y)
    self.avgAcc:add_inplace(boid.acc)
    self.avgLoc:add_inplace(loc)
  end
  
  self.avgAcc:scale_inplace(1 / #self.boids)
  self.avgLoc:scale_inplace(1 / #self.boids)
  
  self.sd = Vector(0, 0)
  local diff = self.avgLoc - mainLocBoid.loc
  self.sd:add_inplace(diff * diff)
  for i = 2, #self.boids do
    local boid = self.boids[i]
    local x, y = mainLocBoid.getRelativeLoc(boid)
    local loc = Vector(mainLocBoid.loc.x + x, mainLocBoid.loc.y + y)
    diff = self.avgLoc - loc
    self.sd:add_inplace(diff * diff)
  end
  self.sd:scale_inplace(1 / #self.boids)
  
  self.twoSD    = self.avgLoc + (2 * self.sd)
  self.negTwoSD = self.avgLoc - (2 * self.sd)
end

function Flock:getLoc(boid)
  local x, y = self.mainLocBoid.getRelativeLoc(boid)
  return Vector(self.mainLocBoid.loc.x + x, self.mainLocBoid.loc.y + y)
end

function Flock:separation()
  for i = 1, #self.boids do
    for j = i + 1, #self.boids  do
      local boid1 = self.boids[i] 
      local boid2 = self.boids[j]
      local dist2 = boid1.loc.dist2(boid1.loc, boid2.loc)
      
      if dist2 > self.maxSeparation2 then
        local separationForce = boid1:flee(boid2.loc)
        separationForce:scale_inplace(1 / dist2)
        separationForce:scale_inplace(self.separationScale)
        
        boid1.acc:add_inplace(separationForce)
        
        separationForce:scale_inplace(-1)
        boid2.acc:add_inplace(separationForce)        
      end
    end
  end
end

function Flock:cohesion()
  for _, boid in ipairs(self.boids) do
    local cohesionForce = boid:seek(self.avgLoc)
    cohesionForce:scale_inplace(self.cohesionScale)
    local loc = self:getLoc(boid)
    if loc.x < self.negTwoSD.x or loc.y < self.negTwoSD.y or loc.x > self.twoSD.x or loc.y > self.twoSD.y then
      cohesionForce:scale_inplace(100000000)      
    else
      cohesionForce:scale_inplace(self.cohesionScale)  
    end
    boid.acc:add_inplace(cohesionForce)
    
  end
end

--function Flock:alignment()
--  for _, boid in ipairs(self.boids) do
--    local angle = Vector.angleTo(boid.acc, self.avgAcc)
--    if(angle < self.maxForceCorrection) then
--      boid.acc = self.avgAcc
--    else 
--      
--    end
--  end
--end

return Flock
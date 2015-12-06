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
end

function Flock:update(dt)
  self:calcAvgs()
  self:separation()
  self:cohesion()
--  self:alignment()
  if self.respawnStep and (#self.missingTypes > 0) then
    self:respawnStep(dt)
  end
end

function Flock:addBoid(boid)
  self.boids[boid.id] = boid
end

function Flock:removeBoid(boid)
  self.boids[boid.id] = nil
  self.missingTypes[#self.missingTypes + 1] = boid.type
end

function Flock:calcAvgs()
  self.avgAcc = Vector(0, 0)
  self.avgLoc = Vector(0, 0)
  
  for _, boid in ipairs(self.boids) do
    self.avgAcc:add_inplace(boid.acc)
    self.avgLoc:add_inplace(boid.loc)
  end
  
  self.avgAcc:scale_inplace(1 / #self.boids)
  self.avgLoc:scale_inplace(1 / #self.boids)
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
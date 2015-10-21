local Class  = require ('hump.class')
local Vector = require('hump.vector')

local Boid = Class {}

function Boid:init(loc, maxSpeed, maxForce) 
  self.loc = loc or Vector(0,0)
  self.maxSpeed = maxSpeed
  self.maxForce = maxForce
  self.vel = Vector(0,0)
  self.acc = Vector(0,0)
  self.wanderTheta = 0.0
end

function Boid:update(dt)  
  self.acc:trim_inplace(self.maxForce)
  self.acc:scale_inplace(dt)
  self.vel:add_inplace(self.acc)
  
  self.vel:trim_inplace(self.maxSpeed)
  self.vel:scale_inplace(dt)  
  self.loc:add_inplace(self.vel)
  
  self.acc:scale_inplace(0)
end

function Boid:flee(target) 
  local steer
  local desired = self.loc - target 
  
  if desired:len2() > 0 then
    desired:normalize_inplace()
    desired:scale_inplace(self.maxSpeed)    
    steer = desired - self.vel
  else
    steer = Vector(0, 0)
  end
  
  return steer
end

function Boid:seek(target) 
  local steer
  local desired = target - self.loc
  
  if desired:len2() > 0 then
    desired:normalize_inplace()
    desired:scale_inplace(self.maxSpeed)    
    steer = desired - self.vel
  else
    steer = Vector(0, 0)
  end
  
  return steer
end

function Boid:arrive(target, damping) 
  local steer
  local desired = target - self.loc
  local desiredMagnitude = desired:len2()
  
  if desiredMagnitude > 0 then
    desired:normalize_inplace()
      
    if desiredMagnitude < damping then 
      local dampSpeed = self.maxSpeed * (desiredMagnitude / damping)
      desired:scale_inplace(dampSpeed) 
    else
      desired:scale_inplace(self.maxSpeed)
    end
    
    steer = desired - self.vel
  else
    steer = Vector(0, 0)
  end
  
  return steer
end

function Boid:pursue(movingTarget)  
  return self:seek(movingTarget.loc + movingTarget.vel)
end

function Boid:evade(movingTarget)  
  return self:flee(movingTarget.loc + movingTarget.vel)
end

return Boid
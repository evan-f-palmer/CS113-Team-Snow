local Class  = require ('hump.class')
local Vector = require('hump.vector')

local Boid = Class {}

function Boid:init(maxSpeed, maxForce) 
  self.loc = Vector(0,0)
  self.maxSpeed = maxSpeed
  self.maxForce = maxForce
  self.vel = Vector(0,0)
  self.acc = Vector(0,0)
  self.wanderTheta = 0.0
  self.angleChange = 0.4
  self.wanderAngle = 0
  self.circleDistance = 30
  self.circleRadius = 10
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

function Boid:wander()
  local circleCenter = self.vel:normalized()
  circleCenter:scale_inplace(self.circleDistance)
  
  local displacement = Vector(0, -1)
  displacement:scale_inplace(self.circleRadius);
  
  displacement:setAngle_inplace(self.wanderAngle)
  
  self.wanderAngle = self.wanderAngle + (math.random() * self.angleChange - self.angleChange * 0.5);
  
  local wanderSteer = circleCenter + displacement
  wanderSteer:normalize_inplace()
  wanderSteer:scale_inplace(self.maxSpeed)
  return wanderSteer - self.vel
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

function Boid:pursue(loc, vel)  
  return self:seek(loc + vel)
end

function Boid:evade(movingTarget)  
  return self:flee(movingTarget.loc + movingTarget.vel)
end

return Boid
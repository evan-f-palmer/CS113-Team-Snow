local Class  = require('hump.class')
local Singleton = require('Singleton')
local CollisionSystem = require('CollisionSystem')
local Vector = require('hump.vector')

local Projectiles = Class{}
Projectiles.MAX = 100

Projectiles.DEFAULT_LIFESPAN = 10
Projectiles.DEFAULT_RADIUS = 1
Projectiles.DEFAULT_SPEED = 1000
Projectiles.DEFAULT_ON_COLLISION = function(other)
  -- self v other logic
end

Projectiles.DEFAULT_DEF = {
  lifetime = Projectiles.DEFAULT_LIFETIME,
  radius = Projectiles.DEFAULT_RADIUS,
  speed = Projectiles.DEFAULT_SPEED,
  onCollision = Projectiles.DEFAULT_ON_COLLISION
}

function Projectiles:init()
  self.projectileDefs = {}
  self.collider = CollisionSystem()
end

function Projectiles:update(dt)  
  self:limit()  
  for i = #self, 1, -1 do
    local projectile = self[i]
    projectile.time = projectile.time + dt    
    if projectile.time >= projectile.lifespan then
      self:remove(i)
    end
  end 
end

function Projectiles:limit()
  while #self > Projectiles.MAX do
    self:remove(1)
  end
end

function Projectiles:remove(i)
  local obj = table.remove(self, i)
  self.collider:removeObject(obj)
end

function Projectiles:defProjectile(xProjectileType, xDef)
  xDef.lifespan = xDef.lifespan or Projectiles.DEFAULT_LIFESPAN
  xDef.speed = xDef.speed or Projectiles.DEFAULT_SPEED  
  xDef.onCollision = xDef.onCollision or Projectiles.DEFAULT_ON_COLLISION
  xDef.radius = xDef.radius or Projectiles.DEFAULT_RADIUS
  self.projectileDefs[xProjectileType] = xDef
end

local function createProjectileVelocity(xSpeed, xDirection, xMomentum)
  local vel = xDirection:clone()
  vel = vel:normalize_inplace()
  vel = vel:scale_inplace(xSpeed)
  if xMomentum then vel = vel + xMomentum end
  return vel
end

function Projectiles:addProjectile(xProjectileType, xPosition, xDirection, xMomentum)
  local projectileDef = self.projectileDefs[xProjectileType] or Projectiles.DEFAULT_DEF
  local projectile = {time = 0, lifespan = projectileDef.lifespan, type = xProjectileType, render = projectileDef,}
  projectile.loc = xPosition
  projectile.dir = xDirection
  projectile.vel = createProjectileVelocity(projectileDef.speed, xDirection, xMomentum)  
  projectile.onCollision = projectileDef.onCollision
  table.insert(self, projectile)
  self.collider:createCollisionObject(projectile, projectileDef.radius)
end

return Singleton(Projectiles)
local Class  = require('hump.class')
local Singleton = require('Singleton')
local CollisionSystem = require('CollisionSystem')

local Projectiles = Class{}
Projectiles.MAX = 100
Projectiles.DEFAULT_LIFETIME = 10
Projectiles.DEFAULT_DEF = {lifetime = Projectiles.DEFAULT_LIFETIME}
Projectiles.DEFAULT_RADIUS = 1

function Projectiles:init()
  self.projectileDefs = {}
  self.collider = CollisionSystem()
end

function Projectiles:update(dt)  
  self:limit()  
  
  for i = #self, 1, -1 do
    local projectile = self[i]
    projectile.time = projectile.time + dt
    projectile.dist = projectile.dist + 0
    
    -- TODO --
    
    if projectile.time >= projectile.def.lifetime then
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

function Projectiles:defProjectile(xProjectileID, xDef)
  xDef.lifetime = xDef.lifetime or Projectiles.DEFAULT_LIFETIME
  xDef.onCollision = xDef.onCollision or (function(neighbor, dx, dy) end) -- onCollision body, self v. neighbor logic
  xDef.radius = xDef.radius or Projectiles.DEFAULT_RADIUS
  xDef.color = xDef.color or Projectiles.DEFAULT_COLOR -- todo move?
  self.projectileDefs[xProjectileID] = xDef
end

function Projectiles:addProjectile(xProjectileID, xPosition, xDirection)
  local projectileDef = self.projectileDefs[xProjectileID] or Projectiles.DEFAULT_DEF
  local projectile = {def = projectileDef, loc = xPosition, dir = xDirection, id = xProjectileID, time = 0, dist = 0}
  table.insert(self, projectile)
  projectile.onCollision = projectileDef.onCollision
  
  -- TODO move
  projectile.color = projectileDef.color
  projectile.image = projectileDef.image
  projectile.shouldRotate = projectileDef.shouldRotate
  -- TODO move
  
  self.collider:createCollisionObject(projectile, projectileDef.radius)
end

return Singleton(Projectiles)
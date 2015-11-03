local Class  = require('hump.class')
local Singleton = require('Singleton')

local Projectiles = Class{}
Projectiles.MAX = 100
Projectiles.DEFAULT_LIFETIME = 10
Projectiles.DEFAULT_DEF = {lifetime = Projectiles.DEFAULT_LIFETIME}

function Projectiles:init()
  self.projectileDefs = {}
end

function Projectiles:update(dt)
  local toKill = {}
  
  self:limit()  
  
  for i, projectile in ipairs(self) do
    projectile.time = projectile.time + dt
    projectile.dist = projectile.dist + 0
    
    -- TODO -- 
    
    if projectile.time >= projectile.def.lifetime then
      table.insert(toKill, i)
    end
  end
  
  while #toKill > 0 do
    local indexToRemove = table.remove(toKill)
    table.remove(self, indexToRemove)
  end
end

function Projectiles:limit()
  while #self > Projectiles.MAX do
    table.remove(self, 1)
  end
end

function Projectiles:defProjectile(xProjectileID, xDef)
  xDef.lifetime = xDef.lifetime or Projectiles.DEFAULT_LIFETIME
  self.projectileDefs[xProjectileID] = xDef
end

function Projectiles:addProjectile(xProjectileID, xPosition, xDirection)
  local projectileDef = self.projectileDefs[xProjectileID] or Projectiles.DEFAULT_DEF
  local projectile = {def = projectileDef, pos = xPosition, dir = xDirection, id = xProjectileID, time = 0, dist = 0}
  table.insert(self, projectile)
end

return Singleton(Projectiles)
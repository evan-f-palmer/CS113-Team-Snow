local Class  = require('hump.class')
local Singleton = require('Singleton')

local Projectiles = Class{}
Projectiles.MAX = 100

function Projectiles:init()
  self.projectileDefs = {}
end

function Projectiles:update(dt)
  self:limit()
  for i, projectile in ipairs(self) do
    -- TODO  
  end
end

function Projectiles:limit()
  while #self > Projectiles.MAX do
    table.remove(self, 1)
  end
end

function Projectiles:defProjectile(xProjectileID, xDefs)
  self.projectileDefs[xProjectileID] = xDefs
end

function Projectiles:addProjectile(xProjectileID, xPosition, xDirection)
  local projectileDef = self.projectileDefs[xProjectileID]
  table.insert(self, {def = projectileDef, pos = xPosition, dir = xDirection, id = xProjectileID})
end

return Singleton(Projectiles)
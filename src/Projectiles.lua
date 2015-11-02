local Class  = require('hump.class')
local Singleton = require('Singleton')

local Projectiles = Class{}
Projectiles.MAX  = 100

function Projectiles:init()
  self.projectileDefs = {}
end

function Projectiles:update(dt)
  while #self > Projectiles.MAX do
    table.remove(self, 1)
  end

  for i, projectile in ipairs(self) do
    
  end
  -- TODO
end

function Projectiles:defProjectile(xProjectileID, xDefs)
  self.projectileDefs[xProjectileID] = xDefs
end

function Projectiles:addProjectile(xProjectileID, xPosition, xDirection)
  print("added")
  local projectileDef = self.projectileDefs[xProjectileID]
  table.insert(self, {def = projectileDef, pos = xPosition, dir = xDirection, id = xProjectileID})
end

return Singleton(Projectiles)
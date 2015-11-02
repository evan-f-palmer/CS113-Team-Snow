local Class  = require('hump.class')
local Singleton = require('Singleton')

local ProjectileFactory = Class{}

function ProjectileFactory:init()
  self.projectileDefs = {}
  self.projectiles = {}
end

function ProjectileFactory:update(dt)
  -- TODO
end

function ProjectileFactory:defProjectile(xProjectileID, xDefs)
  self.projectileDefs[xProjectileID] = xDefs
end

function ProjectileFactory:addProjectile(xProjectileID, xPosition, xVelocity)
  local projectileDef = self.projectileDefs[xProjectileID]
  table.insert(self.projectiles, {def = projectileDef, pos = xPosition, vel = xVelocity})
end

return Singleton(ProjectileFactory)
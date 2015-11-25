local Class  = require('hump.class')
local Vector = require('hump.vector')
local Bodies = require("Bodies")

local Projectiles = Class{__includes = Bodies}
Projectiles.MAX = 300

Projectiles.DEFAULT_LIFESPAN = 10
Projectiles.DEFAULT_RADIUS = 1
Projectiles.DEFAULT_SPEED = 1000

Projectiles.DEFAULT_DEF = {
  lifespan = Projectiles.DEFAULT_LIFESPAN,
  radius = Projectiles.DEFAULT_RADIUS,
  speed = Projectiles.DEFAULT_SPEED,
}

Projectiles.DEFS = {}

function Projectiles:init()
  Bodies.init(self)
end

function Projectiles:update(dt)  
  self:limit()  
  for i = #self, 1, -1 do
    local projectile = self[i]
    projectile.time = projectile.time + dt
    projectile.isDead = projectile.isDead or (projectile.time >= projectile.lifespan) or (projectile.externalControl and projectile.externalControl.isDead)
    if projectile.isDead then
      self:remove(i)
    end
  end 
end

function Projectiles:limit()
  while #self > Projectiles.MAX do
    self:remove(1)
  end
end

function Projectiles:define(xProjectileType, xDef)
  xDef.lifespan = xDef.lifespan or Projectiles.DEFAULT_LIFESPAN
  xDef.speed = xDef.speed or Projectiles.DEFAULT_SPEED
  xDef.radius = xDef.radius or Projectiles.DEFAULT_RADIUS
  self.DEFS[xProjectileType] = xDef
end

local function createProjectileVelocity(xSpeed, xDirection, xMomentum)
  local vel = xDirection:clone()
  vel = vel:normalize_inplace()
  vel = vel:scale_inplace(xSpeed)
  if xMomentum then vel = vel + xMomentum end
  return vel
end

function Projectiles:add(xProjectileType, xPosition, xDirection, xMomentum, xExternalControl)
  local projectileDef = self.DEFS[xProjectileType] or Projectiles.DEFAULT_DEF
  local projectile = {time = 0, lifespan = projectileDef.lifespan, type = xProjectileType, render = projectileDef, onDeath = projectileDef.onDeath, externalControl = xExternalControl}
  projectile.loc = xPosition
  projectile.dir = xDirection
  projectile.vel = createProjectileVelocity(projectileDef.speed, xDirection, xMomentum)
  projectile.radius = projectileDef.radius
  projectile.onCollision = projectileDef.onCollision
  table.insert(self, projectile)
  self.collider:createCollisionObject(projectile, projectileDef.radius)
end

return Projectiles
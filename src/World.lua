local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')

local World = Class{}

function World:init(playerInput, playerGameData, projectiles)
  self.collider = CollisionSystem()
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  self.projectiles = projectiles
  self.bodies = {} -- Asteroids and Enemies?
  
  self.collider:createCollisionObject(self.player, self.player.radius)
end

local function updateObjects(objects, dt)
  for i = #objects, 1, -1 do
    local object = objects[i]
    object:update(dt)
    if object:isDead() then 
      table.remove(objects, i) 
    end  
  end 
end

function World:update(dt)
  self.player:update(dt)
  self.projectiles:update(dt)
  self:moveAllWorldObjects(dt)
  self.collider:update()
end

local function move(xBody, dt)
  local vel = (xBody.vel) * (dt) 
  xBody.loc:add_inplace(vel) 
end

function World:moveAllWorldObjects(dt)
  move(self.player, dt)
  for i, projectile in ipairs(self.projectiles) do
    move(projectile, dt)
  end
  for k, body in pairs(self.bodies) do
    move(body, dt)
  end
end

return World
local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')

local World = Class{}

function World:init(playerInput, playerGameData, projectiles)
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  self.projectiles = projectiles
  
  self.collider       = CollisionSystem()
 
  self.playerBullets  = {}
  self.enemyBullets   = {}
  self.workers        = {}
  self.warriors       = {}
  
  self.collider:createCollisionObject(self.player, 3)
end

function World:update(dt)
  self.player:update(dt)
  self.projectiles:update(dt)
  
  local function updateObjects(objects, dt)
    for i = #objects, 1, -1 do
      local object = objects[i]
      object:update(dt)
      if object:isDead() then 
        table.remove(objects, i) 
      end  
    end 
  end
  
  updateObjects(self.playerBullets)
  updateObjects(self.enemyBullets)
  updateObjects(self.workers)
  updateObjects(self.warriors)
  
  self.collider:update()
  
end

return World
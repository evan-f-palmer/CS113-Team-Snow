local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')

local World = Class{}

function World:init(playerInput, playerGameData, projectiles)
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  self.projectiles = projectiles
  
  self.collider = CollisionSystem()
 
  self.workers = {}
  self.warriors = {}
  
  self.collider:createCollisionObject(self.player, 3)
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
  
  updateObjects(self.workers)
  updateObjects(self.warriors)
  
  self.collider:update()
end

return World
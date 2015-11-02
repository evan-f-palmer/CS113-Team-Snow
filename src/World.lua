local Class  = require('hump.class')
local Player = require('Player')

local World = Class{}

function World:init(playerInput, playerGameData, projectiles)
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  self.projectiles = projectiles
  
end

function World:update(dt)
  self.player:update(dt)
  self.projectiles:update(dt)
  
end

return World
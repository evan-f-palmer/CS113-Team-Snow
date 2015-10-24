local Class  = require('hump.class')
local Player = require('Player')

local World = Class{}

function World:init(playerInput, playerGameData)
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  
end

function World:update(dt)
  self.player:update(dt)
  
  
end

return World
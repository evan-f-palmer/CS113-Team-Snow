local Class          = require('hump.class')
local World          = require('World')
local PlayerInput    = require('PlayerInput')
local PlayerGameData = require('PlayerGameData')
local Renderer       = require('Renderer')
local HUD            = require('HUD')

local Game = Class{}

function Game:init()
  self.playerInput    = PlayerInput()
  self.playerGameData = PlayerGameData()
  self.world          = World(self.playerInput, self.playerGameData)
  self.hud            = HUD()
  self.renderer       = Renderer()
end

function Game:update(dt)
  self.playerInput:update(dt)
  self.world:update(dt)
  self.playerGameData:update(dt)
end

function Game:isGameOver()
  return self.playerGameData.lives == 0
end

function Game:draw()
  love.graphics.setBackgroundColor(0,0,0,0)
  
  self.renderer:draw(self.world)
  self.hud:draw(self.playerGameData)
end

return Game
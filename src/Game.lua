local Class          = require('hump.class')
local World          = require('World')
local PlayerInput    = require('PlayerInput')
local PlayerGameData = require('PlayerGameData')
local Renderer       = require('Renderer')
local HUD            = require('HUD')
local AlertMachine   = require('AlertMachine')

local Game = Class{}

function Game:init()
  self.alertMachine   = AlertMachine()
  self.playerGameData = PlayerGameData()
  self.playerInput    = PlayerInput(self.playerGameData)
  self.world          = World(self.playerInput, self.playerGameData)
  self.hud            = HUD()
  self.renderer       = Renderer()
  
  self.alertMachine:set({message = "Hello World", lifespan = 5})
  self.alertMachine:set({message = "High Priority Message", lifespan = 3, priority = 2})
  self.alertMachine:set({message = "Higher Priority Message", lifespan = 1, priority = 3})
end

function Game:update(dt)
  self.alertMachine:update(dt)
  self.playerInput:update(dt)
  self.world:update(dt)
  self.playerGameData:updateAlertData(self.alertMachine)
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
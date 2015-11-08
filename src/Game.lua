local Class          = require('hump.class')
local World          = require('World')
local PlayerInput    = require('PlayerInput')
local PlayerGameData = require('PlayerGameData')
local Renderer       = require('Renderer')
local HUD            = require('HUD')
local AlertMachine   = require('AlertMachine')
local Projectiles    = require('Projectiles')
local Combat         = require('Combat')

local Game = Class{}

function Game:init()
  self.projectiles    = Projectiles()
  self.playerGameData = PlayerGameData()
  self.playerInput    = PlayerInput()
  self.world          = World(self.playerInput, self.playerGameData, self.projectiles)
  self.hud            = HUD()
  self.renderer       = Renderer()
  self.alertMachine   = AlertMachine()
  self.combat         = Combat()
  
  self.alertMachine:set({message = "Hello World!", lifespan = 3})
end

function Game:update(dt)
  self.playerInput:update(dt)
  self.alertMachine:update(dt)
  self.combat:update(dt)
  self.world:update(dt)
  self.playerGameData:updateAlertData(self.alertMachine)
  self.hud:update(dt)
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
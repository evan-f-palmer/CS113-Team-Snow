local Class       = require('hump.class')
local Player      = require('Player')
local PlayerInput = require('PlayerInput')
local Renderer    = require('Renderer')
local HUD         = require('HUD')

local Game = Class{}

local player
local playerInput
local renderer
local hud

function Game:init()
  playerInput = PlayerInput()
  player      = Player(playerInput)
  hud         = HUD()
  renderer    = Renderer()
end

function Game:update(dt)
  playerInput:update(dt)
  player:update(dt)
  
  hud:update()
end

function Game:draw()
  love.graphics.setBackgroundColor(0,0,0,0)
  
  -- Draw Player
  love.graphics.setColor(255,0,0)
  love.graphics.circle("fill", player.loc.x, player.loc.y, 10, 50)
  
  renderer:draw()
  
  hud:draw()
end

return Game
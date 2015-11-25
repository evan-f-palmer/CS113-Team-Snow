local game
local isGamePaused
local current

function love.load(arg)
  if arg[#arg] == '-debug' then require('mobdebug').start() end
  io.stdout:setvbuf('no')
  love.window.setTitle(" ")
  love.window.setFullscreen(true, 'desktop')
  
  local Game = require('Game')
  game = Game()
  
--  local GameMenu = require('GameMenu')
--  local ClickButton = { onHover = function(self) return false end, onClick = function(self) return true end, }
--  local HoverButton = { onHover = function(self) return true end, onClick = function(self) return false end, }
--  local width, height = love.graphics.getDimensions()
--  local credits  = GameMenu {}
--  local settings = GameMenu {}
--  local scores   = GameMenu {}
--  
--  local buttonR = height/16
--  local mainMenu = GameMenu {
--    contexts = {
--      ["Play"] = game, ["Settings"] = settings, ["Credits"] = credits, ["High Scores"] = scores,
--    },
--    layout = {
--      ["Play"]        = {x = width*(4/16),  y = height*(3/4), r = buttonR},
--      ["Settings"]    = {x = width*(7/16),  y = height*(3/4), r = buttonR},
--      ["Credits"]     = {x = width*(9/16),  y = height*(3/4), r = buttonR},
--      ["High Scores"] = {x = width*(12/16), y = height*(3/4), r = buttonR},
--    },
--    buttons = {
--      ["Play"] = ClickButton, ["Settings"] = ClickButton, ["Credits"] = ClickButton, ["High Scores"] = HoverButton,
--    },
--  }
  
--  current = mainMenu
  current = game
end

function love.update(dt)
  current = current:update(dt)
  isGamePaused = game.isPaused
end

function love.draw()
  current:draw()  
end
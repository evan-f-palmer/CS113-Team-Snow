local game

function love.load(arg)
  if arg[#arg] == '-debug' then require('mobdebug').start() end
  io.stdout:setvbuf('no')
  love.window.setTitle(" ")
  love.window.setFullscreen(true, 'desktop')
  local Game = require('Game')
  game = Game()
end

local isGamePaused
function love.update(dt)  
  game:update(dt)
  isGamePaused = game.isPaused
end

function love.draw()
  game:draw()  
end
local Game = require('Game')

local game

function love.load(arg)
  if arg[#arg] == '-debug' then require('mobdebug').start() end
  io.stdout:setvbuf('no')
  
  game = Game()
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()  
end
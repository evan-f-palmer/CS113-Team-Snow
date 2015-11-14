local Game = require('Game')

local game

function love.load(arg)
  if arg[#arg] == '-debug' then require('mobdebug').start() end
  io.stdout:setvbuf('no')

  game = Game()
end

local isPaused = false
local step = false
local time = 0
function love.update(dt)
  time = time + dt
  if love.keyboard.isDown("q") and time > 0.1 then
    time = 0
    isPaused = not isPaused
  end
  
  if love.keyboard.isDown("w") and time > 0.1 then
    step = true
  end
  
  if not isPaused or step then
    step = false
    game:update(dt)
  end
end

function love.draw()
  game:draw()  
end
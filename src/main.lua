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
  
  local DrawCommon = require('DrawCommon')
  local graphics = DrawCommon()
  
  local startScreen = {}
  startScreen.update = function(self)
    if love.mouse.isDown('l') or love.mouse.isDown('r') then
      return game
    else
      return startScreen
    end
  end
  
  local logo = love.graphics.newImage("assets/screens/logo.JPG")
  startScreen.draw = function(self)
    local width, height = love.graphics.getDimensions()
    
    love.graphics.setColor(255,0,0)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    love.graphics.setColor(255,255,255)
    graphics:drawFullscreen(logo)
    
    love.graphics.setColor(255,255,255)
    graphics:centeredText("Click Mouse to Start", width*(1/2), height*(3/4))
    local x, y = width*(1/2)-width*(1/8), height*(3/4)-height*(1/32)
    love.graphics.rectangle("line", x, y, width*(1/4), 1)
  end
  
  current = startScreen
end

function love.update(dt)
  current = current:update(dt)
  isGamePaused = game.isPaused
end

function love.draw()
  current:draw()  
end
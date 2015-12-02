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
  
  local LoadingScreen = require('LoadingScreen')
  local startScreen = LoadingScreen()
  startScreen:setLoader(function()
    if love.mouse.isDown('l') or love.mouse.isDown('r') then
      return game
    else
      return startScreen
    end
  end)
  startScreen:setDrawer(function()
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(255,0,0)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255,255,255)
    graphics:centeredText("Click to Start", width/2, height/2)
  end)
  
  current = startScreen
end

function love.update(dt)
  current = current:update(dt)
  isGamePaused = game.isPaused
end

function love.draw()
  current:draw()  
end
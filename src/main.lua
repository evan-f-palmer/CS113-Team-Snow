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
  
  local scoresScreen = require("ScoresScreen")
  scoresScreen.transition = game
  
  local startScreen = require("StartScreen")
  startScreen.transition = scoresScreen
  
  game.scores = scoresScreen
  
  current = startScreen
end

function love.update(dt)
  isGamePaused = game.isPaused
  local previous = current
  current = current:update(dt)
  if current ~= previous then
    current:load()
  end
end

function love.draw()
  current:draw()  
end
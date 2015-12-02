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
  
  local pausedScreen = require("PausedScreen")
  pausedScreen.transition = game
  
  local deathScreen = require("DeathScreen")
  deathScreen.transition = game
  
  local gameOverScreen = require("GameOverScreen")
  gameOverScreen.transition = scoresScreen
  
  game.scoresScreen = scoresScreen
  game.pausedScreen = pausedScreen
  game.deathScreen = deathScreen
  game.gameOverScreen = gameOverScreen
  gameOverScreen.game = game
  deathScreen.game = game
  
  current = startScreen --gameOverScreen
  current:load()
end

function love.update(dt)
  if love.keyboard.isDown('escape') then
    love.event.quit()
  end

  isGamePaused = game.isPaused
  local previous = current
  current = current:update(dt)
  if current ~= previous then
    previous:unload()
    current:load()
  end
end

function love.draw()
  current:draw()  
end
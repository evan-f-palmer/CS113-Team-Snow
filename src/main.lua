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
  
  local scoresScreen = require("ScoresScreen")
  local startScreen = require("StartScreen")
  local pausedScreen = require("PausedScreen")
  local deathScreen = require("DeathScreen")
  local gameOverScreen = require("GameOverScreen")
  
  game.scoresScreen = scoresScreen
  game.pausedScreen = pausedScreen
  game.deathScreen = deathScreen
  game.gameOverScreen = gameOverScreen
  
  scoresScreen.transition = game
  startScreen.transition = game  
  pausedScreen.transition = game
  deathScreen.transition = game
  gameOverScreen.transition = scoresScreen
  
  gameOverScreen.game = game
  deathScreen.game = game
  pausedScreen.game = game
  
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
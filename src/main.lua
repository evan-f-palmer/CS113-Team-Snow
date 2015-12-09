local game
local isGamePaused
local current

function love.load(arg)
  if arg[#arg] == '-debug' then require('mobdebug').start() end
  io.stdout:setvbuf('no')
  love.window.setTitle(" ")
  love.window.setFullscreen(true, 'desktop')
  love.window.setIcon(love.image.newImageData("assets/sinistar/sinistarMouthOpen.png")) 
  love.window.setTitle("Infinistar")
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
  
  startScreen.transition = game  
  scoresScreen.transition = game
  scoresScreen.esc = startScreen
  pausedScreen.transition = game
  pausedScreen.esc = scoresScreen
  deathScreen.transition = game
  deathScreen.esc = deathScreen
  gameOverScreen.transition = scoresScreen
  gameOverScreen.esc = gameOverScreen
  
  gameOverScreen.game = game
  deathScreen.game = game
  pausedScreen.game = game
  
  current = startScreen --gameOverScreen
  current:load()
end

function love.update(dt)
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
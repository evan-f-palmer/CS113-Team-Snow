local Class        = require('hump.class')
local World        = require('World')
local PlayerInput  = require('EntityIOController')
local GameData     = require('GameData')
local Renderer     = require('Renderer')
local HUD          = require('HUD')
local AlertMachine = require('AlertMachine')
local Projectiles  = require('Projectiles')
local Combat       = require('Combat')
local SoundSystem  = require('SoundSystem')
local GameIOController = require('GameIOController')
local EntityParams = require('EntityParams')
local Animator = require('Animator')

local Game = Class{}
Game.levelNicknames = {"Alphabet Soup", "Spots", "Highways"}
Game.levels = {"testing2.lua", "spots.lua", "highways.lua"}

function Game:init()  
  if not love.graphics.isSupported("canvas", "npot", "subtractive", "multicanvas") then
    love.window.showMessageBox("Sorry", "You do not meet the minimum system requirements to play this game.\nOpenGL 2.1+ or DirectX 9.0c+ required", 'info', true)
    love.event.quit()
  end
  
  if not love.graphics.isSupported("shader") then
    love.window.showMessageBox("", "Shaders not supported", 'info', true)
  end
  
  require('AnimationDefinitions')
  require('ProjectileDefinitions')
  
  self:start()
end

function Game:start()
  self.isPaused = false
  self.step = false

  self.projectiles    = Projectiles()
  self.data           = GameData()
  self.playerInput    = PlayerInput()
  self.world          = World(self.playerInput, self.data, self.projectiles)
  self.hud            = HUD()
  self.renderer       = Renderer()
  self.alertMachine   = AlertMachine()
  self.combat         = Combat()
  self.combat:setProjectiles(self.projectiles)
  self.soundSystem = SoundSystem()
  self.animator = Animator()
  self.projectiles = Projectiles()  
  self.gameInput = GameIOController(self)
  
  self.previousLives = self.data.lives
  
  self.world:setPlayerSpawnAtOrigin()
  self:newGameLoadLevel()
end

function Game:loadLevel()
  local levelFileName = Game.levels[((self.data.level-1) % (#Game.levels)) + 1]  
  local levelNickname = Game.levelNicknames[((self.data.level-1) % (#Game.levels)) + 1]  
  self.data:preserve()
  self.isLoading = true
  local levelFilePath = "src/levels/" .. levelFileName
  self.world:loadLevel(levelFilePath)
  self.isLoading = false
  self.data:free()
  self.data:resetSinistarCrystals()
  self.alertMachine:set({message = levelNickname, lifespan = 5})
  
  self:update(0)
  local player = self.world:getByID("Player")
  self.renderer:follow(player)
  self.hud:setActor(player)
end

function Game:newGameLoadLevel()  
  self.data:reset()
  self:loadLevel()
  self.alertMachine:clear()
  local levelNickname = Game.levelNicknames[((self.data.level-1) % (#Game.levels)) + 1]  
  self.alertMachine:set({message = levelNickname, lifespan = 3})
end

function Game:load()
  self.transition = self
  self.data:free()
  if self.data:isGameOver() then
    self.world:setPlayerSpawnAtOrigin()
    self:newGameLoadLevel()
  end
end

function Game:unload()
  self.data:preserve()
  self.renderer:follow()
  self.hud:setActor()
end

function Game:update(dt)
  self.gameInput:update(dt)
  
  if (not self.isPaused) or self.step then
    self.step = false
    self.sinistarWasAliveLastStep = not self.combat:isDead("Sinistar")
    
    self.playerInput:update(dt)
    self.alertMachine:update(dt)    
    self.combat:update(dt)
    self.world:update(dt) 
    self.data:updateAlertData(self.alertMachine)
    self.hud:update(dt)
    
    if self.combat:isDead("Sinistar") and self.sinistarWasAliveLastStep then
      self.data:increaseLevel()
      self:loadLevel()
    end
    
    if self.data:isGameOver() then
      self.data:preserve()
      self.world:unload()
      self.data:free()
      self.transition = self.gameOverScreen
    elseif self.data.lives < self.previousLives then
      self.transition = self.deathScreen
    end
  end
  
  self.animator:update(dt)
  
  self.previousLives = self.data.lives
  
  return self.transition
end

function Game:draw()
  if not self.isLoading then
    self:rendererRecovery()
    self.renderer:draw(self.world)
    self.hud:draw(self.data)
  end
end

function Game:rendererRecovery()
  if not self.renderer:isFollowing() then
    local player = self.world:getByID("Player")
    self.renderer:follow(player)
    self.hud:setActor(player)
  end
end

return Game
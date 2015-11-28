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

function Game:init()
  require('AnimationDefinitions')
  require('ProjectileDefinitions')

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
  
  --self.soundSystem:playMusic("music/TheFatRat-Dancing-Naked.mp3")
  self.soundSystem:playMusic("music/Closet_Face_128.ogg", 0.3)

  local levelFileName = "src/levels/testing2.lua"
  self.world:loadLevel(levelFileName)
  self.alertMachine:set({message = levelFileName, lifespan = 3})
  
  if not love.graphics.isSupported("canvas", "npot", "subtractive", "multicanvas") then
    love.window.showMessageBox("Sorry", "You do not meet the minimum system requirements to play this game.\nOpenGL 2.1+ or DirectX 9.0c+ required", 'info', true)
    love.event.quit()
  end
  
  if not love.graphics.isSupported("shader") then
    love.window.showMessageBox("", "Shaders not supported", 'info', true)
  end
end

function Game:update(dt)
  self.gameInput:update(dt)
  
  if (not self.isPaused) or self.step then
    self.step = false
    
    self.playerInput:update(dt)
    self.alertMachine:update(dt)
    self.combat:update(dt)
    self.world:update(dt)
    if self.data:isGameOver() then
      self.alertMachine:set({message = "Game Over", lifespan = 3})
    end
    self.data:updateAlertData(self.alertMachine)
    self.hud:update(dt)
  end
  
  self.animator:update(dt)
  
  return self
end

function Game:draw()
--  love.graphics.setBackgroundColor(1,1,1,0)
  
  self.renderer:draw(self.world)
  self.hud:draw(self.data)
end

return Game
local Class = require('hump.class')
local Vector = require('hump.vector')
local Combat = require("Combat")
local SoundSystem = require('SoundSystem')

local LEFT_MOUSE_BUTTON = 'l'
local RIGHT_MOUSE_BUTTON = 'r'

local COMBAT = Combat()

local GameIOController = Class{}
GameIOController.inputAmplifier = 100

function GameIOController:init(game)
  self.game = game
  self.soundSystem = SoundSystem()
  self.debounceTimer = {}
end

local AlertMachine = require('AlertMachine')
local alertMachine = AlertMachine()
local ALERT_TEST = {message = "ALERT TEST", lifespan = 0.1, priority = 1}
local MEDIUM_PRIORITY_ALERT = {message = "Medium Priority Alert", lifespan = 0.1, priority = 2}
local HIGH_PRIORITY_ALERT = {message = "High Priority Alert", lifespan = 0.1, priority = 3}
local INFO_MESSAGE = {message = "", lifespan = 0.5, priority = 1}

function GameIOController:update(dt)
  self:updateDebounce(dt)
  
  if self:isDown('d') then self:press('d')
    self.game.data:increaseLevel()
    self.game:loadLevel()
  end
  
  if self:isDown('a') then self:press('a')
    local toView = "Player"    
    if self.game.renderer:isFollowing("Player") then
      toView = "Sinistar"
    else
      toView = "Player"
    end
    local obj = self.game.world:getByID(toView)
    self.game.renderer:follow(obj)
    self.game.hud:setActor(obj)
  end
  
  if love.keyboard.isDown("p") then
    self.game.transition = self.game.pausedScreen
  end
  
  if love.keyboard.isDown("v") then
    INFO_MESSAGE.message = "Sinistar Crystals: " .. self.game.data.sinistarCrystals
    alertMachine:set(INFO_MESSAGE)
    self.game.data:incrementSinistarCrystals()
  elseif love.keyboard.isDown("c") then
    INFO_MESSAGE.message = "Sinistar Crystals: " .. self.game.data.sinistarCrystals
    alertMachine:set(INFO_MESSAGE)
  end
  
  if love.keyboard.isDown("-") then
    COMBAT:attack("Player", 1)
  end
  
  if love.keyboard.isDown("=") then
    COMBAT:heal("Player", 1)
  end
  
  if love.keyboard.isDown("x") then
    COMBAT:attack("Sinistar", 1)
  end
  
  if self:isDown("b") then self:press('b')
    COMBAT:supplyAmmo("Player Secondary", 1)
  end
  
  if love.keyboard.isDown("s") then
    self.game.data:increaseScore(100)
  end
  
  if self:isDown('l') then self:press('l')
    self.game.data:incrementLives()
  end
  
  if self:isDown('q') then self:press('q')
    self.game.isPaused = not self.game.isPaused
  end
  
  if self:isDown('w') then self:press('w')
    self.game.step = true
  end
  
  if love.keyboard.isDown('1') then
    ALERT_TEST.priority = 1
    alertMachine:set(ALERT_TEST)
  end
  if love.keyboard.isDown('2') then 
    ALERT_TEST.priority = 2
    alertMachine:set(ALERT_TEST)
  end
  if love.keyboard.isDown('3') then 
    ALERT_TEST.priority = 3
    alertMachine:set(ALERT_TEST)
  end
  if love.keyboard.isDown('4') then 
    ALERT_TEST.priority = 4
    alertMachine:set(ALERT_TEST)
  end
  if love.keyboard.isDown('5') then 
    ALERT_TEST.priority = 5
    alertMachine:set(ALERT_TEST)
  end
  if love.keyboard.isDown('6') then 
    ALERT_TEST.priority = 6
    alertMachine:set(ALERT_TEST)
  end
end

function GameIOController:isDown(key)
  return love.keyboard.isDown(key) and self:isDebounceComplete(key)
end

function GameIOController:isDebounceComplete(key)
  return (self.debounceTimer[key] or 0) <= 0
end

function GameIOController:press(key)
  self.debounceTimer[key] = 0.1
end

function GameIOController:updateDebounce(dt)
  for k,v in pairs(self.debounceTimer) do
    self.debounceTimer[k] = v - dt
  end
end

return GameIOController

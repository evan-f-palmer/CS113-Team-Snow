local Class = require('hump.class')
local Vector = require('hump.vector')
local Combat = require("Combat")
local InputParams = require("InputParams")
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
local BRIEF_MESSAGE = { message = "", lifespan = 0.1, priority = 4 }
local MEDIUM_PRIORITY_ALERT = {message = "Medium Priority Alert", lifespan = 0.1, priority = 2}
local HIGH_PRIORITY_ALERT = {message = "High Priority Alert", lifespan = 0.1, priority = 3}
local INFO_MESSAGE = { message = "", lifespan = 0.5, priority = 4}

function GameIOController:update(dt)
  self:updateDebounce(dt)
  
  if love.keyboard.isDown("h") then
    alertMachine:set(HIGH_PRIORITY_ALERT)
    self.soundSystem:play("sound/arcadealarm.ogg")
  end
  
  if love.keyboard.isDown("m") then
    alertMachine:set(MEDIUM_PRIORITY_ALERT)
    self.soundSystem:play("sound/marinealarm.ogg")
  end
  
  if love.keyboard.isDown("a") then
    COMBAT:attack("Player", 1)
  end
  
  if love.keyboard.isDown("s") then
    COMBAT:heal("Player", 1)
  end
  
  if love.keyboard.isDown("p") then
    self.soundSystem:pause("music/TheFatRat-Dancing-Naked.mp3")
  end
  
  if love.keyboard.isDown("r") then
    self.soundSystem:resume("music/TheFatRat-Dancing-Naked.mp3")
  end
  
  if love.keyboard.isDown("l") then
    self.soundSystem:loop("sound/short.ogg")
  end
  
  if love.keyboard.isDown('k') then
    self.soundSystem:stop("sound/short.ogg")
  end
  
  if love.keyboard.isDown("c") then
    INFO_MESSAGE.message = "Sinistar Crystals: " .. self.game.data.sinistarCrystals
    alertMachine:set(INFO_MESSAGE)
  end
  
  if self:isDown("b") then self:press('b')
    COMBAT:supplyAmmo("Player Secondary", 1)
  end
  
  if self:isDown('q') then self:press('q')
    self.game.isPaused = not self.game.isPaused
  end
  
  if self:isDown('w') then self:press('w')
    self.game.step = true
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
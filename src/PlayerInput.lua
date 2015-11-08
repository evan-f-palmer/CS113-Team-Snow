local Class = require('hump.class')
local Vector = require('hump.vector')
local Combat = require("Combat")
local PlayerInputParams = require("PlayerInputParams")
local SoundSystem = require('SoundSystem')

local LEFT_MOUSE_BUTTON = 'l'
local RIGHT_MOUSE_BUTTON = 'r'

local COMBAT = Combat()

local PlayerInput = Class{}
PlayerInput.inputAmplifier = 100

function PlayerInput:init()
  self.movementVec = Vector(0, 0)
  self.directionVec = Vector(0, 0)
  self.primaryWeaponFire  = false
  self.secondaryWeaponFire = false
  self.soundSystem = SoundSystem()
end

function PlayerInput:update(dt)
  self.primaryWeaponFire   = love.keyboard.isDown("f") or love.keyboard.isDown("j") or love.mouse.isDown(LEFT_MOUSE_BUTTON)
  self.secondaryWeaponFire = love.keyboard.isDown(" ") or love.mouse.isDown(RIGHT_MOUSE_BUTTON)
  
  local x, y, minR
  
  x, y = self:getMouseOffsetRelativeToCenter(PlayerInputParams.directionalJoystick)
  self.directionVec.y = y
  self.directionVec.x = x
  
  x, y = self:getMouseOffsetRelativeToCenter(PlayerInputParams.movementJoystick)
  minR = PlayerInputParams.movementJoystick.minR
  if (y*y) + (x*x) >= (minR*minR) then
    self.movementVec.y = y
    self.movementVec.x = x
    self.movementVec:scale_inplace(PlayerInput.inputAmplifier)
  else
    self.movementVec.y = 0
    self.movementVec.x = 0
  end
  
  self:debugStuff()
end

function PlayerInput:getMouseOffsetRelativeToCenter(xJoystick)
  local centerX, centerY = xJoystick.x, xJoystick.y
  local mouseX, mouseY = love.mouse.getPosition()
  return -(centerX - mouseX), -(centerY - mouseY)
end

local AlertMachine = require('AlertMachine')
local alertMachine = AlertMachine()
local BRIEF_MESSAGE = { message = "", lifespan = 0.1, priority = 4 }
local MEDIUM_PRIORITY_ALERT = {message = "Medium Priority Alert", lifespan = 0.1, priority = 2}
local HIGH_PRIORITY_ALERT = {message = "High Priority Alert", lifespan = 0.1, priority = 3}

function PlayerInput:debugStuff()
  if love.keyboard.isDown("d") then
    BRIEF_MESSAGE.message = "DIRECTION: " .. self.directionVec.x .. ", " .. self.directionVec.y
    alertMachine:set(BRIEF_MESSAGE)
  end
  if love.keyboard.isDown("v") then
    BRIEF_MESSAGE.message = "VELOCITY: " .. self.movementVec.x .. ", " .. self.movementVec.y
    alertMachine:set(BRIEF_MESSAGE)
  end
  if love.keyboard.isDown("h") then
    alertMachine:set(HIGH_PRIORITY_ALERT)
    self.soundSystem:play("sound/arcadealarm.ogg")
  end
  if love.keyboard.isDown("m") then
    alertMachine:set(MEDIUM_PRIORITY_ALERT)
    self.soundSystem:play("sound/marinealarm.ogg")
  end
  
  if love.keyboard.isDown("b") then
    COMBAT:supplyAmmo("Player Secondary", 1)
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
end

return PlayerInput
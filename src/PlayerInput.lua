local Class = require('hump.class')
local Vector = require('hump.vector')

local LEFT_MOUSE_BUTTON = 'l'
local RIGHT_MOUSE_BUTTON = 'r'

local PlayerInput = Class{}
PlayerInput.inputAmplifier = 100

function PlayerInput:init(xPlayerGameData)
  self.movementVec = Vector(0, 0)
  self.directionVec = Vector(0, 0)
  self.primaryWeaponFire  = false
  self.secondaryWeaponFire = false
  self.blindSpotRadius = xPlayerGameData.blindSpotRadius
end

local function getMouseOffsetRelativeToCenter()
  local width, height = love.graphics.getDimensions()
  local centerX, centerY = width/2, height/2
  local mouseX, mouseY = love.mouse.getPosition()
  return -(centerX - mouseX), -(centerY - mouseY)
end

function PlayerInput:update(dt)
  self.primaryWeaponFire   = love.keyboard.isDown("f") or love.keyboard.isDown("j") or love.mouse.isDown(LEFT_MOUSE_BUTTON)
  self.secondaryWeaponFire = love.keyboard.isDown(" ") or love.mouse.isDown(RIGHT_MOUSE_BUTTON)
  
  local x, y = getMouseOffsetRelativeToCenter()

  self.directionVec.y = y
  self.directionVec.x = x

  if (y*y) + (x*x) >= (self.blindSpotRadius*self.blindSpotRadius) then
    self.movementVec.y = y
    self.movementVec.x = x
    self.movementVec:scale_inplace(PlayerInput.inputAmplifier)
  else
    self.movementVec.y = 0
    self.movementVec.x = 0
  end
  
  self:debugStuff()
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
  end
  if love.keyboard.isDown("m") then
    alertMachine:set(MEDIUM_PRIORITY_ALERT)
  end
end

return PlayerInput
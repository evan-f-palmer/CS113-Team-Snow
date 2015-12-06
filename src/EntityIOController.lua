local Class = require('hump.class')
local Vector = require('hump.vector')
local InputDeviceLayout = require("InputDeviceLayout")
local ViewportParams = require("ViewportParams")

local EntityIOController = Class{}
EntityIOController.inputAmplifier = (1750 / ViewportParams.r) * (7/4) -- (Player speed / Viewport radius) * (Magic throttle constant)

function EntityIOController:init()
  self.movementVec = Vector(0, 0)
  self.directionVec = Vector(0, 0)
  self.primaryWeaponFire  = false
  self.secondaryWeaponFire = false
end

local LEFT_MOUSE_BUTTON = 'l'
local RIGHT_MOUSE_BUTTON = 'r'
function EntityIOController:update(dt)
  self.primaryWeaponFire   = love.keyboard.isDown("f") or love.keyboard.isDown("j") or love.mouse.isDown(LEFT_MOUSE_BUTTON)
  self.secondaryWeaponFire = love.keyboard.isDown(" ") or love.mouse.isDown(RIGHT_MOUSE_BUTTON)
  self:handleJoystick(InputDeviceLayout.directionalJoystick, self.directionVec)
  self:handleJoystick(InputDeviceLayout.movementJoystick, self.movementVec)  
end

function EntityIOController:handleJoystick(xJoystick, xVector)
  local x, y = self:getMouseOffsetRelativeToCenter(xJoystick)
  local minR = xJoystick.minR
  if (y*y) + (x*x) >= (minR*minR) then
    xVector.y = y
    xVector.x = x
    xVector:scale_inplace(EntityIOController.inputAmplifier)
  else
    xVector.y = 0
    xVector.x = 0
  end
end

function EntityIOController:getMouseOffsetRelativeToCenter(xJoystick)
  local centerX, centerY = xJoystick.x, xJoystick.y
  local mouseX, mouseY = love.mouse.getPosition()
  return -(centerX - mouseX), -(centerY - mouseY)
end

return EntityIOController
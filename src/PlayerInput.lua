local Class = require('hump.class')
local Vector = require('hump.vector')

local PlayerInput = Class{}

PlayerInput.leftMouseButton  = 1
PlayerInput.rightMouseButton = 2

PlayerInput.inputAmplifier = 100

PlayerInput.blindSpotRadius = 50

function PlayerInput:init()
  self.movementVec = Vector(0, 0)
  self.primaryWeaponFire  = false
  self.secondaryWeaponFire = false
end

local function getMouseOffsetRelativeToCenter()
  local width, height = love.graphics.getDimensions()
  local centerX, centerY = width/2, height/2
  local mouseX, mouseY = love.mouse.getPosition()
  return centerX - mouseX, centerY - mouseY
end

function PlayerInput:update(dt)
  self.primaryWeaponFire   = love.keyboard.isDown("f") or love.keyboard.isDown("j") or love.mouse.isDown(PlayerInput.leftMouseButton)
  self.secondaryWeaponFire = love.keyboard.isDown(" ") or love.mouse.isDown(PlayerInput.rightMouseButton)
  
  local x, y = getMouseOffsetRelativeToCenter()

  if math.abs(y) >= self.blindSpotRadius then
    self.movementVec.y = -y
  else
    self.movementVec.y = 0
  end
  
  if math.abs(x) >= self.blindSpotRadius then
    self.movementVec.x = -x
  else
    self.movementVec.x = 0
  end
  
  self.movementVec:scale_inplace(PlayerInput.inputAmplifier)
end

return PlayerInput
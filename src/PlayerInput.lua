local Class = require('hump.class')
local Vector = require('hump.vector')

local PlayerInput = Class{}

PlayerInput.leftMouseButton  = 1
PlayerInput.rightMouseButton = 2

PlayerInput.inputAmplifier = 100

function PlayerInput:init()
  self.movementVec = Vector(0, 0)
  self.primaryWeaponFire  = false
  self.secondaryWeaponFire = false
end

function PlayerInput:update(dt)
  self.primaryWeaponFire   = love.keyboard.isDown("f") or love.keyboard.isDown("j") or love.mouse.isDown(PlayerInput.leftMouseButton)
  self.secondaryWeaponFire = love.keyboard.isDown(" ") or love.mouse.isDown(PlayerInput.rightMouseButton)
  
  local x, y = love.mouse.getPosition()
  
  -- Replace with mouse
  if love.keyboard.isDown("w") then
    self.movementVec.y = -1
  elseif love.keyboard.isDown("s") then
    self.movementVec.y = 1
  else
    self.movementVec.y = 0
  end
  
  if love.keyboard.isDown("a") then
    self.movementVec.x = -1
  elseif love.keyboard.isDown("d") then
    self.movementVec.x = 1
  else 
    self.movementVec.x = 0
  end
  
  self.movementVec:scale_inplace(PlayerInput.inputAmplifier)
end

return PlayerInput
local Class  = require('hump.class')
local Camera = require('hump.camera')

local HUD = Class {}

function HUD:init()
  self.camera = Camera()

  self.background = love.graphics.newImage("assets/hud.png")
end

function HUD:draw(xPlayerGameData)
  self.camera:attach()
  
  love.graphics.setColor(255,255,255)
  
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
  local zeroRotation = 0
  
  local width  = screenWidth / self.background:getWidth()
  local height = screenHeight / self.background:getHeight()
  
  love.graphics.draw(self.background, 0, 0, zeroRotation, width, height) 

  self.camera:detach()
end

return HUD
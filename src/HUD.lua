local Class  = require('hump.class')
local Camera = require('hump.camera')

local ALERT_PRIORITY_COLORS = {
  [0] = {255,255,255,225},
  [1] = {255,255,255,225},
  [2] = {255,255,0,225},
  [3] = {255,0,0,225},
}
local CONTROL_CIRCLE_COLOR = {0,200,200,200}

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
  
  local rotation = 0
  local width  = screenWidth / self.background:getWidth()
  local height = screenHeight / self.background:getHeight()
  
  love.graphics.draw(self.background, 0, 0, rotation, width, height) 

  -- THIS SHOWS US WHERE THE MOUSE CONTROLS ARE INACTIVE FOR PROPULSION, (but still active for rotation)
  love.graphics.setColor(unpack(CONTROL_CIRCLE_COLOR))
  love.graphics.circle("line", screenWidth/2, screenHeight/2, xPlayerGameData.blindSpotRadius, 50)

  self:drawAlertMessage(xPlayerGameData)

  self.camera:detach()
end

function HUD:drawAlertMessage(xPlayerGameData)
  local color = self:getAlertColor(xPlayerGameData.alertPriority)
  love.graphics.setColor(unpack(color))
  love.graphics.print(xPlayerGameData.alertMessage, love.graphics.getWidth() * (2/5), love.graphics.getHeight() * (4/5))
end

function HUD:getAlertColor(xPriority)
  return ALERT_PRIORITY_COLORS[xPriority] or ALERT_PRIORITY_COLORS[0]
end

return HUD
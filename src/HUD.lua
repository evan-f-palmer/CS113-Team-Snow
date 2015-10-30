local Class  = require('hump.class')
local Camera = require('hump.camera')
local Blinker = require('Blinker')

local ALERT_DIM_COLOR = {150,150,150,200}

local ALERT_PRIORITY_COLORS = {
  [0] = {{255,255,255,225},},
  [1] = {{255,255,255,225},},
  [2] = {{255,255,0,225}, ALERT_DIM_COLOR,},
  [3] = {{255,0,0,225}, ALERT_DIM_COLOR, {255,0,0,225}, ALERT_DIM_COLOR,},
}

local HUD_COLORS = {
  {0,200,200,200},
  {0,200,210,195},{0,200,220,190},{0,200,230,195},{0,208,240,200},{0,215,250,190},{0,224,240,185},
  {0,230,230,180},
  {0,240,224,185},{0,250,215,190},{0,240,208,200},{0,230,200,195},{0,220,200,190},{0,210,200,195},
}

local HUD = Class {}

function HUD:init()
  self.camera = Camera()
  self.background = love.graphics.newImage("assets/hud.png")
  self.blinker = Blinker()
  self.blinker:setPeriod(1)
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
  local HUDcolor = self:getHeadsUpDisplayColor()
  love.graphics.setColor(unpack(HUDcolor))
  love.graphics.circle("line", screenWidth/2, screenHeight/2, xPlayerGameData.blindSpotRadius, 50)

  self:drawAlertMessage(xPlayerGameData)

  self.camera:detach()
end

function HUD:getHeadsUpDisplayColor()
  return self.blinker:blink(unpack(HUD_COLORS))
end

function HUD:drawAlertMessage(xPlayerGameData)
  local color = self:getAlertColor(xPlayerGameData.alertPriority)
  love.graphics.setColor(unpack(color))
  love.graphics.print(xPlayerGameData.alertMessage, love.graphics.getWidth() * (2/5), love.graphics.getHeight() * (4/5))
end

function HUD:getAlertColor(xPriority)
  local priorityColors = ALERT_PRIORITY_COLORS[xPriority] or ALERT_PRIORITY_COLORS[0]
  local alertColor = self.blinker:blink(unpack(priorityColors))
  return alertColor
end

return HUD
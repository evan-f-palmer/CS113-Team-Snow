local Class  = require('hump.class')
local Camera = require('hump.camera')
local Blinker = require('Blinker')
local DrawCommon = require('DrawCommon')
local AlertMachine = require('AlertMachine')

local ALERT_DIM_COLOR = {150,150,150,200}

local ALERT_PRIORITY_COLORS = {
  [0] = {{255,255,255,225},}, -- DEFAULT
  [1] = {{255,255,255,225},}, -- STANDARD MESSAGE
  [2] = {{255,255,0,225}, ALERT_DIM_COLOR,}, -- MEDIUM PRIORITY
  [3] = {{255,0,0,225}, ALERT_DIM_COLOR, {255,0,0,225}, ALERT_DIM_COLOR,}, -- HIGH PRIORITY
  [4] = {{160,185,225,225},}, -- FOR DEBUG MESSAGES
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
  self.blinker = Blinker()
  self.GU = DrawCommon()
  self.alertMachine = AlertMachine()

  self.background = love.graphics.newImage("assets/hud.png")
end

function HUD:draw(xPlayerGameData)
  self.camera:attach()
  
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()    
  local width  = screenWidth / self.background:getWidth()
  local height = screenHeight / self.background:getHeight()
  local rotation = 0
  
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.background, 0, 0, rotation, width, height) 

  local HUDcolor = self:getHeadsUpDisplayColor()
  love.graphics.setColor(unpack(HUDcolor))
  
  self.GU:drawDebugInfo(xPlayerGameData, screenWidth/2, screenHeight/2 + xPlayerGameData.blindSpotRadius)
  love.graphics.circle("line", screenWidth/2, screenHeight/2, xPlayerGameData.blindSpotRadius, 50)

  local primaryAlert = self.alertMachine:getPrimaryAlert()
  self:drawAlertMessage(primaryAlert, love.graphics.getWidth() * (2/5), love.graphics.getHeight() * (4/5))
  --self:drawAlerts()

  self.camera:detach()
end

function HUD:getHeadsUpDisplayColor()
  return self.blinker:blink(unpack(HUD_COLORS))
end

function HUD:drawAlerts()
  local alerts = self.alertMachine.alertsInOrder
  local x, y = love.graphics.getWidth() * (2/5), love.graphics.getHeight() * (4/5)
  local yOff = self.GU.FONT_SIZE
  for i, alert in ipairs(alerts) do
    self:drawAlertMessage(alert, x, y)
    y = y - yOff
  end
end

function HUD:drawAlertMessage(xAlert, x, y)
  local color = self:getAlertColor(xAlert.priority)
  love.graphics.setColor(unpack(color))
  love.graphics.print(xAlert.message, x, y)
end

function HUD:getAlertColor(xPriority)
  local priorityColors = ALERT_PRIORITY_COLORS[xPriority] or ALERT_PRIORITY_COLORS[0]
  local alertColor = self.blinker:blink(unpack(priorityColors))
  return alertColor
end

return HUD
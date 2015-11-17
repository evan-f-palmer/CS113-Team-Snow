local Class  = require('hump.class')
local Camera = require('hump.camera')
local Blinker = require('Blinker')
local DrawCommon = require('DrawCommon')
local AlertMachine = require('AlertMachine')
local InputParams = require("InputParams")

local ALERT_DIM_COLOR = {150,150,150,200}

local ALERT_PRIORITY_COLORS = {
  [0] = {{255,255,255,225},}, -- DEFAULT
  [1] = {{255,255,255,225},}, -- STANDARD MESSAGE
  [2] = {{255,255,0,225}, ALERT_DIM_COLOR,}, -- MEDIUM PRIORITY
  [3] = {{255,0,0,225}, ALERT_DIM_COLOR, {255,0,0,225}, ALERT_DIM_COLOR,}, -- HIGH PRIORITY
  [4] = {{160,185,225,225},}, -- FOR DEBUG MESSAGES
}

local HUD_COLORS = {
  {0,200,200,125},
  {0,200,210,120},{0,200,220,115},{0,200,230,120},{0,208,240,125},{0,215,250,115},{0,224,240,110},
  {0,230,230,105},
  {0,240,224,110},{0,250,215,115},{0,240,208,100},{0,230,200,120},{0,220,200,115},{0,210,200,120},
}

local HEALTH_BAR_COLORS = {
  {255,0,0,125},
  {255,255,0,125},
  {30,200,70,125},
  {30,200,70,125},
  {30,200,70,125},
}

local HUD = Class {}

HUD.RADAR_DRAW_ORDERING = {"Asteroid", "Crystal", "Worker", "Warrior", "Sinistar"}
HUD.RADAR_COLORS = {
  ["Asteroid"] = {50, 255, 120, 120},
  ["Crystal"] = {50, 120, 255, 140},
  ["Worker"] = {255, 50, 50, 180},
  ["Warrior"] = {255, 50, 50, 180},
  ["Sinistar"] = {180, 170, 40, 220},
}

function HUD:init()
  self.camera = Camera()
  self.blinker = Blinker()
  self.blinker:setPeriod(1)
  self.GU = DrawCommon()
  self.alertMachine = AlertMachine()
  
  self.bloomShader = love.graphics.newShader("shaders/bloom.glsl")
  self.background = love.graphics.newImage("assets/hud.png")
  
  self.textOffset = self.GU.FONT_SIZE * (2)
  self.layout = {
    lives = { x = love.graphics.getWidth() * (1/5), y = love.graphics.getHeight() * (11/12) },
    bombs = { x = love.graphics.getWidth() * (4/5), y = love.graphics.getHeight() * (11/12) },
    score = { x = love.graphics.getWidth() * (1/2), y = love.graphics.getHeight() * (1/12) },
    health = { x = love.graphics.getWidth() * (3/10), y = love.graphics.getHeight() * (11/12) - (self.GU.FONT_SIZE/2), 
               w = love.graphics.getWidth() * (4/10), h = (self.GU.FONT_SIZE)},
    alert = { x = love.graphics.getWidth() * (1/2), y = love.graphics.getHeight() * (5/6)}
  }
  
  self.radarCanvas = love.graphics.newCanvas()
end

function HUD:update(dt)
  self.blinker:update(dt)
end

function HUD:draw(gameData)
  self.camera:attach()
  
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()    
  local width  = screenWidth / self.background:getWidth()
  local height = screenHeight / self.background:getHeight()
  local rotation = 0
 
  --love.graphics.draw(self.background, 0, 0, rotation, width, height) 
  --love.graphics.setShader(self.bloomShader)
  
  local x, y, minR = InputParams.movementJoystick.x, InputParams.movementJoystick.y, InputParams.movementJoystick.minR

  love.graphics.setColor(255,255,255)
  love.graphics.circle("line", x, y, 300)
    
  self:drawHealthBar(gameData.health)

  local HUDcolor = self:getHeadsUpDisplayColor()
  love.graphics.setColor(HUDcolor[1], HUDcolor[2], HUDcolor[3], HUDcolor[4])

  love.graphics.circle("line", x, y, minR)
  x, y, minR = InputParams.directionalJoystick.x, InputParams.directionalJoystick.y, InputParams.directionalJoystick.minR
  love.graphics.circle("line", x, y, minR)

  love.graphics.circle("fill", self.layout.lives.x, self.layout.lives.y, self.GU.FONT_SIZE, 30)
  love.graphics.circle("fill", self.layout.bombs.x, self.layout.bombs.y, self.GU.FONT_SIZE, 30)  
  
  love.graphics.setColor(255,255,255)
  self.GU:centeredText(gameData.lives, self.layout.lives.x, self.layout.lives.y)
  self.GU:centeredText("LIVES", self.layout.lives.x, self.layout.lives.y + self.textOffset)  
  self.GU:centeredText(math.floor(gameData.health * 100)..'%', self.layout.health.x + self.layout.health.w/2, self.layout.health.y + self.layout.health.h/2)
  self.GU:centeredText(gameData.bombs, self.layout.bombs.x, self.layout.bombs.y)
  self.GU:centeredText("BOMBS", self.layout.bombs.x, self.layout.bombs.y + self.textOffset)
  self.GU:centeredText(gameData.score, self.layout.score.x, self.layout.score.y)
  self.GU:centeredText("SCORE", self.layout.score.x, self.layout.score.y - self.textOffset)

  local primaryAlert = self.alertMachine:getPrimaryAlert()
  self:drawAlertMessage(primaryAlert, self.layout.alert.x, self.layout.alert.y)

  self:drawRadar(gameData, x, y)
  
  love.graphics.setShader()
  self.camera:detach()
end

function HUD:getHeadsUpDisplayColor()
  return self.blinker:blink(unpack(HUD_COLORS))
end

function HUD:drawAlertMessage(xAlert, x, y)
  local color = self:getAlertColor(xAlert.priority)
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  self.GU:centeredText(xAlert.message, x, y)
end

function HUD:getAlertColor(xPriority)
  local priorityColors = ALERT_PRIORITY_COLORS[xPriority] or ALERT_PRIORITY_COLORS[0]
  local alertColor = self.blinker:blink(unpack(priorityColors))
  return alertColor
end

function HUD:drawHealthBar(xHealthPercent)
  local color = self:getHealthBarColor(xHealthPercent)
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  love.graphics.rectangle("fill", self.layout.health.x, self.layout.health.y, self.layout.health.w * xHealthPercent, self.layout.health.h)
end

function HUD:getHealthBarColor(xHealthPercent)
  local zeroBasedIndex = math.floor((#HEALTH_BAR_COLORS-1) * xHealthPercent)  
  local index = zeroBasedIndex + 1    
  local color = HEALTH_BAR_COLORS[index] or HEALTH_BAR_COLORS[0]
  return color
end

function HUD:drawRadar(gameData, x, y)
  self.radarCanvas:clear()
  love.graphics.setCanvas(self.radarCanvas)
  local players = gameData.forRadar["Player"] or {}
  local player = players[1]
  if player then 
    for i = 1, (#self.RADAR_DRAW_ORDERING) do
      local typeToDraw = self.RADAR_DRAW_ORDERING[i]
      local layerObjects = gameData.forRadar[typeToDraw] or {}
      local color = self.RADAR_COLORS[typeToDraw]
      love.graphics.setColor(color[1], color[2], color[3], color[4])
      for k, object in pairs(layerObjects) do
        local distSqr = math.pow(object.loc.x - player.loc.x, 2) + math.pow(object.loc.y - player.loc.y, 2)
        if distSqr > ((300*5)*(300*5)) then -- if object is outside of viewing region
          local angle = math.atan2(object.loc.y - player.loc.y, object.loc.x - player.loc.x)
          local dist = math.sqrt(distSqr)
          local width = (math.pi/15) / (dist/2000) 
          local angle1, angle2 = angle - width/2, angle + width/2
          love.graphics.arc("fill", x, y, 295, angle1, angle2, 8)
        end
      end
    end
  end
  love.graphics.setBlendMode('subtractive')
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", x, y, 285, 50)
  love.graphics.setBlendMode('alpha')
  love.graphics.setCanvas()
  love.graphics.draw(self.radarCanvas, 0, 0)
end

return HUD
local Class  = require('hump.class')
local Camera = require('hump.camera')
local Blinker = require('Blinker')
local DrawCommon = require('DrawCommon')
local AlertMachine = require('AlertMachine')
local PlayerInputParams = require("PlayerInputParams")

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
end

function HUD:update(dt)
  self.blinker:update(dt)
end

function HUD:draw(xPlayerGameData)
  self.camera:attach()
  
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()    
  local width  = screenWidth / self.background:getWidth()
  local height = screenHeight / self.background:getHeight()
  local rotation = 0
  
  local x, y, minR = PlayerInputParams.movementJoystick.x, PlayerInputParams.movementJoystick.y, PlayerInputParams.movementJoystick.minR
  
  love.graphics.setColor(255,255,255)
  love.graphics.circle("line", x, y, 300)

  --love.graphics.draw(self.background, 0, 0, rotation, width, height) 
  --love.graphics.setShader(self.bloomShader)
  
  self:drawHealthBar(xPlayerGameData.health)

  local HUDcolor = self:getHeadsUpDisplayColor()
  love.graphics.setColor(HUDcolor[1], HUDcolor[2], HUDcolor[3], HUDcolor[4])

  love.graphics.circle("line", x, y, minR, 50)
  love.graphics.circle("fill", self.layout.lives.x, self.layout.lives.y, self.GU.FONT_SIZE, 30)
  love.graphics.circle("fill", self.layout.bombs.x, self.layout.bombs.y, self.GU.FONT_SIZE, 30)  
  
  love.graphics.setColor(255,255,255)
  self.GU:centeredText(xPlayerGameData.lives, self.layout.lives.x, self.layout.lives.y)
  self.GU:centeredText("LIVES", self.layout.lives.x, self.layout.lives.y + self.textOffset)  
  self.GU:centeredText((xPlayerGameData.health * 100)..'%', self.layout.health.x + self.layout.health.w/2, self.layout.health.y + self.layout.health.h/2)
  self.GU:centeredText(xPlayerGameData.bombs, self.layout.bombs.x, self.layout.bombs.y)
  self.GU:centeredText("BOMBS", self.layout.bombs.x, self.layout.bombs.y + self.textOffset)
  self.GU:centeredText(xPlayerGameData.score, self.layout.score.x, self.layout.score.y)
  self.GU:centeredText("SCORE", self.layout.score.x, self.layout.score.y - self.textOffset)

  local primaryAlert = self.alertMachine:getPrimaryAlert()
  self:drawAlertMessage(primaryAlert, self.layout.alert.x, self.layout.alert.y)

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

return HUD
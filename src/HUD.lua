local Class  = require('hump.class')
local Camera = require('hump.camera')
local Blinker = require('Blinker')
local DrawCommon = require('DrawCommon')
local AlertMachine = require('AlertMachine')
local InputDeviceLayout = require("InputDeviceLayout")
local ViewportParams = require("ViewportParams")
local FontParams = require("FontParams")
local HUDLayout = require("HUDLayout")
local RendererParams = require("RendererParams")

local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE

local function SOLID(xColor)
  return {xColor[1], xColor[2], xColor[3], 255}
end
local function DIM(xColor)
  return {xColor[1]/2, xColor[2]/2, xColor[3]/2, 255}
end

local GRAY = DIM(WHITE)

local ALERT_PRIORITY_COLORS = {
  [0] = {SOLID(WHITE), DIM(WHITE)}, -- DEFAULT
  [1] = {SOLID(WHITE), DIM(WHITE)}, -- STANDARD MESSAGE
  [2] = {SOLID(YELLOW), DIM(YELLOW),}, -- MEDIUM PRIORITY
  [3] = {SOLID(RED), DIM(RED), SOLID(RED), DIM(RED),}, -- HIGH PRIORITY
  [4] = {SOLID(BLUE), DIM(BLUE)}, -- FOR DEBUG MESSAGES
  [5] = {SOLID(GREEN), DIM(GREEN)}, -- Player Respawn Invincibility
}

local HUD_COLORS = {
  {50,200,200,125},
  {50,200,210,120},{50,200,220,115},{50,200,230,120},{50,208,240,125},{50,215,250,115},{50,224,240,110},
  {50,230,230,105},
  {50,240,224,110},{50,250,215,115},{50,240,208,100},{50,230,200,120},{50,220,200,115},{50,210,200,120},
}

local HEALTH_BAR_COLORS = { RED, YELLOW, GREEN, GREEN, GREEN}

local HUD = Class {}
HUD.background = love.graphics.newImage("assets/screens/HUD1.JPG")

HUD.RADAR_DRAW_ORDERING = {"Asteroid", "Crystal", "Worker", "Warrior", "Sinistar"}
HUD.RADAR_COLORS = {["Asteroid"] = GREEN, ["Crystal"] = BLUE, ["Worker"] = RED, ["Warrior"] = RED, ["Sinistar"] = YELLOW,}

function HUD:init()
  self.camera = Camera()
  self.blinker = Blinker()
  self.blinker:setPeriod(1)
  self.GU = DrawCommon()
  self.alertMachine = AlertMachine()
  
  --self.bloomShader = love.graphics.newShader("shaders/bloom.glsl")
  
  self.textOffset = FontParams.FONT_SIZE * (2)
  self.layout = HUDLayout
  
  self.radarCanvas = love.graphics.newCanvas()
  local radarRadius = self.layout.viewport.r - 5
  self.radarDrawData = {x = 0, y = 0, radius = radarRadius, cutoutRadius = radarRadius - 10, minimumDistance = radarRadius, segmentSize = (math.pi/15), distanceTaperDivisor = 2000}

  self.imageCanvas = love.graphics.newCanvas()
end

function HUD:update(dt)
  self.blinker:update(dt)
end

function HUD:draw(gameData)
  self.camera:attach()
  
  self.radarDrawData.minimumDistance = self.radarDrawData.radius / RendererParams.cameraScale
  
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()    
  local rotation = 0
 
  local primaryAlert = self.alertMachine:getPrimaryAlert()
 
  -- IMAGE CANVAS, DRAWING HUD FOREGROUND IMAGE WITH A CUTOUT
  self.imageCanvas:clear()
  love.graphics.setCanvas(self.imageCanvas)
  self.GU:drawFullscreen(self.background)
  love.graphics.setBlendMode('subtractive')
  love.graphics.setColor(255,255,255)
  local width, height = love.graphics.getDimensions()
  love.graphics.circle("fill", width/2, height/2, ViewportParams.r, 50)
  love.graphics.setBlendMode('alpha')
  -- GO BACK TO MAIN CANVAS
  love.graphics.setCanvas()
  
  local color = self:getAlertColor(primaryAlert.priority)
  if primaryAlert.priority < 2 then
    love.graphics.setColor(GRAY[1], GRAY[2], GRAY[3])
  else
    love.graphics.setColor(color[1], color[2], color[3])
  end
  self.GU:drawFullscreen(self.imageCanvas)
  -- END HUD FOREGROUND IMAGE
  
--  love.graphics.setShader(self.bloomShader)

  love.graphics.setColor(unpack(WHITE))
  love.graphics.circle("line", self.layout.viewport.x, self.layout.viewport.y, self.layout.viewport.r)
    
  local HUDcolor = self:getHeadsUpDisplayColor()
  love.graphics.setColor(HUDcolor[1], HUDcolor[2], HUDcolor[3], HUDcolor[4])

  love.graphics.setShader(self.bloomShader)
  local x, y, minR = InputDeviceLayout.movementJoystick.x, InputDeviceLayout.movementJoystick.y, InputDeviceLayout.movementJoystick.minR
  love.graphics.circle("line", x, y, minR)
  x, y, minR = InputDeviceLayout.directionalJoystick.x, InputDeviceLayout.directionalJoystick.y, InputDeviceLayout.directionalJoystick.minR
  love.graphics.circle("line", x, y, minR)

  love.graphics.circle("line", self.layout.lives.x, self.layout.lives.y, self.GU.FONT_SIZE, 30)
  love.graphics.circle("line", self.layout.bombs.x, self.layout.bombs.y, self.GU.FONT_SIZE, 30)  
  love.graphics.setShader()
  
  self.radarDrawData.x = x
  self.radarDrawData.y = y
  self:drawRadar(gameData.forRadar, self.radarDrawData)  
  self:drawHealthBar(gameData.health)
    
  love.graphics.setColor(unpack(WHITE))
  self.GU:centeredText(gameData.lives, self.layout.lives.x, self.layout.lives.y)
  self.GU:centeredText("LIVES", self.layout.lives.x, self.layout.lives.y + self.textOffset)  
  self.GU:centeredText(math.floor(gameData.health * 100)..'%', self.layout.health.x + self.layout.health.w/2, self.layout.health.y + self.layout.health.h/2)
  self.GU:centeredText(gameData.bombs, self.layout.bombs.x, self.layout.bombs.y)
  self.GU:centeredText("BOMBS", self.layout.bombs.x, self.layout.bombs.y + self.textOffset)
  self.GU:centeredText(gameData.score, self.layout.score.x, self.layout.score.y)
  self.GU:centeredText("SCORE", self.layout.score.x, self.layout.score.y - self.textOffset)
    
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
  if xAlert.priority < 2 then
    love.graphics.setColor(unpack(GRAY))
  end
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

function HUD:drawRadar(toDisplayOnRadarByType, draw)
  -- USE RADAR CANVAS
  self.radarCanvas:clear()
  love.graphics.setCanvas(self.radarCanvas)
  
  -- EXTRACT PLAYER
  local players = toDisplayOnRadarByType["Player"] or {}
  local player = players[1]
  
  -- IF PLAYER EXISTS, DRAW BODIES RELATIVE TO PLAYER ON RADAR
  if player then 
    local playerloc = player.loc
    for i = 1, (#self.RADAR_DRAW_ORDERING) do
      local typeToDraw = self.RADAR_DRAW_ORDERING[i]
      local layerObjects = toDisplayOnRadarByType[typeToDraw] or {}
      local color = self.RADAR_COLORS[typeToDraw]
      love.graphics.setColor(color[1], color[2], color[3], color[4])
      for k, object in pairs(layerObjects) do
        local tx, ty = player.getRelativeLoc(object)
        local distSqr = (tx*tx) + (ty*ty)
        if distSqr >= (draw.minimumDistance * draw.minimumDistance) then
          local angle = math.atan2(ty, tx)
          local dist = math.sqrt(distSqr)
          local segmentWidth = draw.segmentSize / (dist/draw.distanceTaperDivisor) 
          local angle1, angle2 = angle - segmentWidth/2, angle + segmentWidth/2
          love.graphics.arc("fill", draw.x, draw.y, draw.radius, angle1, angle2, 3)
        end
      end
    end
  end
  -- CUTOUT
  love.graphics.setBlendMode('subtractive')
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", draw.x, draw.y, draw.cutoutRadius, 50)
  love.graphics.setBlendMode('alpha')
  -- GO BACK TO MAIN CANVAS
  love.graphics.setCanvas()
  love.graphics.draw(self.radarCanvas, 0, 0)
end

return HUD
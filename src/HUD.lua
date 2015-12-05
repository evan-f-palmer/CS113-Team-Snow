local Class  = require('hump.class')
local Camera = require('hump.camera')
local DrawCommon = require('DrawCommon')
local AlertMachine = require('AlertMachine')
local InputDeviceLayout = require("InputDeviceLayout")
local ViewportParams = require("ViewportParams")
local FontParams = require("FontParams")
local HUDLayout = require("HUDLayout")
local RendererParams = require("RendererParams")
local Combat = require('Combat')
local Colorer = require('Colorer')
local Palette = require('Palette')

local HUD = Class {}
HUD.background = love.graphics.newImage("assets/screens/HUD1.JPG")
HUD.life = love.graphics.newImage("assets/player.png")
HUD.RADAR_DRAW_ORDERING = {"Asteroid", "Crystal", "Worker", "Warrior", "Sinistar", "Sinistar Construction", "Player"}

function HUD:init()
  self.camera = Camera()
  self.GU = DrawCommon()
  self.alertMachine = AlertMachine()
  self.combat = Combat()
  self.colorer = Colorer()
  
  self.textOffset = FontParams.FONT_SIZE * (15/8)
  self.layout = HUDLayout
  
  self.radarCanvas = love.graphics.newCanvas()
  local radarRadius = self.layout.viewport.r - 5
  self.radarDrawData = {x = 0, y = 0, radius = radarRadius, cutoutRadius = radarRadius - 10, minimumDistance = radarRadius, segmentSize = (math.pi/15), distanceTaperDivisor = 2000}

  self.imageCanvas = love.graphics.newCanvas()
end

function HUD:update(dt)
  self.colorer:update(dt)
end

function HUD:setActor(xActor)
  self.actor = xActor
end

function HUD:drawPorthole()
  love.graphics.setColor(unpack(Palette.WHITE))
  love.graphics.circle("line", self.layout.viewport.x, self.layout.viewport.y, self.layout.viewport.r)
end

function HUD:draw(gameData)
  self.camera:attach()
  
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()    
  local rotation = 0
 
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

  local color = self.colorer:getCurrentAlertColor()
  love.graphics.setColor(color[1], color[2], color[3])
  self.GU:drawFullscreen(self.imageCanvas)
  -- END HUD FOREGROUND IMAGE
  
  love.graphics.setColor(unpack(Palette.WHITE))
  love.graphics.circle("line", self.layout.viewport.x, self.layout.viewport.y, self.layout.viewport.r)
    
  local HUDcolor = self.colorer:getHeadsUpDisplayColor()
  love.graphics.setColor(HUDcolor[1], HUDcolor[2], HUDcolor[3], HUDcolor[4])

  love.graphics.setShader(self.bloomShader)
  local x, y, minR = InputDeviceLayout.movementJoystick.x, InputDeviceLayout.movementJoystick.y, InputDeviceLayout.movementJoystick.minR
  love.graphics.circle("line", x, y, minR)
  x, y, minR = InputDeviceLayout.directionalJoystick.x, InputDeviceLayout.directionalJoystick.y, InputDeviceLayout.directionalJoystick.minR
  love.graphics.circle("line", x, y, minR)
  
  if self.actor then
    self:drawActorInfo(gameData)
  end

  self.camera:detach()
end

-- private
function HUD:drawActorInfo(gameData)
  self.radarDrawData.minimumDistance = self.radarDrawData.radius / RendererParams.cameraScale
  self.radarDrawData.x = ViewportParams.x
  self.radarDrawData.y = ViewportParams.y
  self:drawRadar(gameData.forRadar, self.radarDrawData)
  
  local actorID = self.actor.id
  local health = self.combat:getHealthPercent(actorID)
  self:drawHealthBar(health)

  local healthx100 = math.floor(health * 100)
  local healthString = healthx100 .. '%'
  if healthx100 == 0 and health > 0 then
    healthString = '<1%'
  end

  love.graphics.setColor(unpack(Palette.WHITE))  
  self.GU:centeredText(healthString, self.layout.health.x + self.layout.health.w/2, self.layout.health.y + self.layout.health.h/2)  
  
  if actorID == "Player" then
    self:drawPlayerInfo(gameData) 
  end
  
  local primaryAlert = self.alertMachine:getPrimaryAlert()
  self:drawAlertMessage(primaryAlert, self.layout.alert.x, self.layout.alert.y)
end

-- private
function HUD:drawPlayerInfo(gameData)
  love.graphics.setColor(unpack(Palette.WHITE))
  local x, y = self.layout.lives.x, self.layout.lives.y
  local scale = 0.15
  for i = 1, gameData.lives do
    self.GU:BEGIN_SCALE(x, y, scale)
    self.GU:drawRotatedImage(self.life, x, y, 0)
    self.GU:END()
    x = x + self.life:getWidth() * scale * (3/2)
  end

  local HUDcolor = self.colorer:getHeadsUpDisplayColor()
  love.graphics.setColor(HUDcolor[1], HUDcolor[2], HUDcolor[3], HUDcolor[4])
  love.graphics.circle("line", self.layout.bombs.x, self.layout.bombs.y, self.GU.FONT_SIZE, 30)  
  love.graphics.setColor(unpack(Palette.WHITE))
  local bombs  = self.combat:getAmmo("Player Secondary")
  self.GU:centeredText(bombs, self.layout.bombs.x, self.layout.bombs.y)
  self.GU:centeredText("BOMBS", self.layout.bombs.x, self.layout.bombs.y + self.textOffset)
  
  love.graphics.setColor(unpack(Palette.WHITE))
  self.GU:centeredText(gameData.score, self.layout.score.x, self.layout.score.y)
  self.GU:centeredText("SCORE", self.layout.score.x, self.layout.score.y - self.textOffset)
end

-- private
function HUD:drawAlertMessage(xAlert, x, y)
  local color = self.colorer:getAlertColor(xAlert.priority)
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  self.GU:centeredText(xAlert.message, x, y)
  if xAlert.priority < 2 then
    love.graphics.setColor(unpack(Palette.GRAY))
  end
end

-- private
function HUD:drawHealthBar(xHealthPercent)
  local color = self.colorer:getHealthBarColor(xHealthPercent)
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  love.graphics.rectangle("fill", self.layout.health.x, self.layout.health.y, self.layout.health.w * xHealthPercent, self.layout.health.h)
end

-- private
function HUD:drawRadar(toDisplayOnRadarByType, draw)

  -- USE RADAR CANVAS
  self.radarCanvas:clear()
  love.graphics.setCanvas(self.radarCanvas)
  
  -- IF ACTOR SET, DRAW BODIES RELATIVE TO ACTOR ON RADAR
  if self.actor then 
    for i = 1, (#self.RADAR_DRAW_ORDERING) do
      local typeToDraw = self.RADAR_DRAW_ORDERING[i]
      local layerObjects = toDisplayOnRadarByType[typeToDraw] or {}
      local color = self.colorer:getRadarColor(typeToDraw)
      love.graphics.setColor(color[1], color[2], color[3], color[4])
      for k, object in pairs(layerObjects) do
        local tx, ty = self.actor.getRelativeLoc(object)
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
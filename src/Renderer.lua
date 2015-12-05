local Class  = require('hump.class')
local Camera = require('hump.camera')
local DrawCommon = require('DrawCommon')
local InputDeviceLayout = require("InputDeviceLayout")
local CollisionSystem = require('CollisionSystem')
local Combat = require('Combat')
local ViewportParams = require("ViewportParams")
local RendererParams = require("RendererParams")
local Colorer = require('Colorer')

local Renderer = Class {}
Renderer.background = love.graphics.newImage("assets/screens/HUD1.JPG")

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = RendererParams.cameraScale
  self.camera:lookAt(0, 0)  
  self.GU = DrawCommon()
  self.collider = CollisionSystem()
  self.combat = Combat()
  self.colorer = Colorer()
    
  self.captureRadius = RendererParams.captureRadius / (self.camera.scale)
  self.radarRadius = RendererParams.radarRadius / (self.camera.scale)
  self.drawScale = RendererParams.drawScale
  
  self.DEFAULT_COLOR = {255,255,255}
  self.TEXT_Y_OFFSET = 2 * self.GU.FONT_SIZE
  self.DEBUG_TEXT_COLOR = {80, 80, 200}
  
  self.DRAW_ORDERING = {"Worker Bullet", "Player Bullet", "Asteroid", "Crystal", "Sinistar Construction", "Sinistar", "Warrior Bullet", "Sinibomb", "Worker", "Player", "Warrior", "Sinibomb Blast"}
end

function Renderer:follow(xBody)
  self.toFollow = xBody
end

function Renderer:isFollowing()
  return self.toFollow
end

function Renderer:draw(xWorld)
  local color = self.colorer:getCurrentAlertColor()
  love.graphics.setColor(color[1], color[2], color[3])

  self.GU:drawFullscreen(self.background)
  love.graphics.setScissor(ViewportParams.x - ViewportParams.r, ViewportParams.y - ViewportParams.r, ViewportParams.r*2, ViewportParams.r*2)
  
  if self.toFollow then
    local actor = self.toFollow
    local actorX, actorY = actor.loc.x, actor.loc.y
    local actorAngle = self.GU:getAngle(actor.dir)
    local inCDView = actor.getNeighbors(self.captureRadius)
    local inViewByType = self:getObjectsInViewByType(inCDView)
    local inRDView = actor.getNeighbors(self.radarRadius)
    local inRadarViewByType = self:getObjectsInViewByType(inRDView)  
    xWorld.gameData.forRadar = inRadarViewByType

    self.camera:lookAt(actorX, actorY)
    self.camera:attach()  
    
    -- TEMP --
    local worldW, worldH = xWorld.width, xWorld.height
    local worldXT, worldYT = worldW / 2, worldH / 2
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("line", -worldXT, -worldYT, worldW, worldH)
    love.graphics.setColor(255, 120, 0)
    love.graphics.line(0, worldYT, worldXT, 0)
    love.graphics.line(0, worldYT, -worldXT, 0)
    love.graphics.line(0, -worldYT, worldXT, 0)
    love.graphics.line(0, -worldYT, -worldXT, 0)
    -- END TEMP --
    
    for i = 1, #self.DRAW_ORDERING do
      local layerToDraw = self.DRAW_ORDERING[i]
      local layerObjects = inViewByType[layerToDraw] or {}
      
      for j = 1, #layerObjects do
        local obj = layerObjects[j]
        local tx, ty = actor.getRelativeLoc(obj)
        local x, y = (actorX + tx), (actorY + ty)
        
        local image = obj.render.image 
        if obj.render.animation then
          image = obj.render.animation.image
        end
        
        if image then
          local color = obj.render.color or self.DEFAULT_COLOR
          love.graphics.setColor(color[1], color[2], color[3], color[4])
          local angle = 0
          if obj.render.shouldRotate then
            angle = self.GU:getAngle(obj.dir)
          end
  
          self.GU:BEGIN_SCALE(x, y, self.drawScale[layerToDraw])
          self.GU:drawRotatedImage(image, x, y, angle)
          self.GU:END()
  
  --        if obj.radius then
  --          love.graphics.circle("line", x, y, obj.radius)
  --        end
        end
    
  --      local inverseCameraScale = 1/self.camera.scale
  --      love.graphics.setColor(self.DEBUG_TEXT_COLOR[1], self.DEBUG_TEXT_COLOR[2], self.DEBUG_TEXT_COLOR[3], self.DEBUG_TEXT_COLOR[4])
  --      self.GU:BEGIN_SCALE(x, y, inverseCameraScale)
  --        self.GU:centeredText(obj.type .. "\n" .. math.floor(self.combat:getHealthPercent(obj.id) * 100) .. '%' .. "\n" .. math.floor(x) .. ", " .. math.floor(y), x, y + self.TEXT_Y_OFFSET)
  --      self.GU:END()     
      end
    end
    
    self.camera:detach()
  end
  -- END FOLLOW
  love.graphics.setScissor()
end

function Renderer:getObjectsInViewByType(xInView)
  local byType = {}
  for k, obj in pairs(xInView) do
    local type = obj.type
    if not byType[type] then byType[type] = {} end
    table.insert(byType[type], obj)
  end
  return byType
end

return Renderer
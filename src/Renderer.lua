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
  
  self.DRAW_ORDERING = {"Worker Bullet", "Sinistar Construction", "Player Bullet", "Asteroid", "AsteroidFrag", "Crystal", "Sinistar", "Warrior Bullet", "Sinibomb", "Worker", "Player Thrust", "Player", "Warrior", "Sinibomb Blast"}
end

function Renderer:follow(xBody)
  self.toFollow = xBody
end

function Renderer:isFollowing(xID)
  local following = self.toFollow
  if xID then
    following = following and (self.toFollow.id == xID)
  end
  return following
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
    local inViewByType = {}
    if actor.getNeighbors then
      local inCDView = actor.getNeighbors(self.captureRadius)
      inViewByType = self:getObjectsInViewByType(inCDView)
      local inRDView = actor.getNeighbors(self.radarRadius)
      local inRadarViewByType = self:getObjectsInViewByType(inRDView)  
      xWorld.gameData.forRadar = inRadarViewByType
    end

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
          
          --if layerToDraw == 'Sinistar' or layerToDraw == 'Asteroid' then
            local healthPct = self.combat:getHealthPercent(obj.id)
            if healthPct < 1.0 then
              -- DRAW A HEALTH BAR FOR THE ENTITY
              local w, h = image:getWidth() * self.drawScale[layerToDraw], image:getHeight() * self.drawScale[layerToDraw]
              local color = self.colorer:getHealthBarColor(healthPct)
              love.graphics.setColor(color[1], color[2], color[3], color[4])
              love.graphics.rectangle("fill", x - w/2, y + h/2, w * healthPct, 20)
            end
          --end
        end
        
--        if obj.radius then
--          love.graphics.circle("line", x, y, obj.radius)
--        end
    
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
    if type:find("AsteroidFrag") then
      type = "AsteroidFrag"
    end

    if not byType[type] then byType[type] = {} end
    table.insert(byType[type], obj)
  end
  return byType
end

return Renderer
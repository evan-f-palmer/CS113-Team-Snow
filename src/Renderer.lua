local Class  = require('hump.class')
local Camera = require('hump.camera')
local DrawCommon = require('DrawCommon')
local InputDeviceLayout = require("InputDeviceLayout")
local CollisionSystem = require('CollisionSystem')
local Combat = require('Combat')
local ViewportParams = require("ViewportParams")
local RendererParams = require("RendererParams")

local Renderer = Class {}

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = RendererParams.cameraScale
  self.camera:lookAt(0, 0)  
  self.GU = DrawCommon()
  self.collider = CollisionSystem()
  self.combat = Combat()
  
  self.captureRadius = RendererParams.captureRadius / (self.camera.scale)
  self.radarRadius = RendererParams.radarRadius / (self.camera.scale)
  
  self.DEFAULT_COLOR = {255,255,255}
  self.TEXT_Y_OFFSET = 2 * self.GU.FONT_SIZE
  self.TEXT_COLOR = {80, 80, 200}
  
  self.DRAW_ORDERING = {"Asteroid", "Worker Bullet", "Player Bullet", "Warrior Bullet", "Crystal", "Sinistar", "Sinibomb", "Worker", "Warrior", "Player", "Sinibomb Blast"}
end

function Renderer:draw(xWorld)
  local player = xWorld.player
  local playerX, playerY = player.loc.x, player.loc.y
  local playerAngle = self.GU:getAngle(player.dir)
  local movementJoystickMinR = InputDeviceLayout.movementJoystick.minR
  local projectiles = xWorld.projectiles
  local inverseCameraScale = 1/self.camera.scale
  
  local inCDView = player.getNeighbors(self.captureRadius)
  local inViewByType = self:getObjectsInViewByType(inCDView)
  local inRDView = player.getNeighbors(self.radarRadius)
  local inRadarViewByType = self:getObjectsInViewByType(inRDView)  
  xWorld.gameData.forRadar = inRadarViewByType 
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerX, playerY)
  self.camera:attach()  
  love.graphics.setScissor(ViewportParams.x - ViewportParams.r, ViewportParams.y - ViewportParams.r, ViewportParams.r*2, ViewportParams.r*2)
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
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
  
  love.graphics.setColor(255,255,255)
  self.GU:BEGIN_SCALE(0, 0, inverseCameraScale)
    self.GU:centeredText("ORIGIN", 0, self.TEXT_Y_OFFSET)
  self.GU:END()
  
  for i = 1, #self.DRAW_ORDERING do
    local layerToDraw = self.DRAW_ORDERING[i]
    local layerObjects = inViewByType[layerToDraw] or {}
    
    for j = 1, #layerObjects do
      local obj = layerObjects[j]
      local tx, ty = player.getRelativeLoc(obj)
      local x, y = (player.loc.x + tx), (player.loc.y + ty)
      
      if obj.render.image then
        local color = obj.render.color or self.DEFAULT_COLOR
        love.graphics.setColor(color[1], color[2], color[3], color[4])
        local angle = 0
        if obj.render.shouldRotate then
          angle = self.GU:getAngle(obj.dir)
        end
        
        local image = obj.render.image 
        if obj.render.animation then
          image = obj.render.animation.image
        end
        
        self.GU:drawRotatedImage(image, x, y, angle)
        if obj.radius then
          love.graphics.circle("line", x, y, obj.radius)
        end
      end
  
--      love.graphics.setColor(self.TEXT_COLOR[1], self.TEXT_COLOR[2], self.TEXT_COLOR[3], self.TEXT_COLOR[4])
--      self.GU:BEGIN_SCALE(x, y, inverseCameraScale)
--        self.GU:centeredText(obj.type .. "\n" .. math.floor(self.combat:getHealthPercent(obj.id) * 100) .. '%' .. "\n" .. math.floor(x) .. ", " .. math.floor(y), x, y + self.TEXT_Y_OFFSET)
--      self.GU:END()      
    end
  end
  
  love.graphics.setScissor()
  self.camera:detach()  
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
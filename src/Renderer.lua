local Class  = require('hump.class')
local Camera = require('hump.camera')
local DrawCommon = require('DrawCommon')
local InputParams = require("InputParams")
local CollisionSystem = require('CollisionSystem')
local Combat = require('Combat')
local ViewportParams = require("ViewportParams")

local Renderer = Class {}

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = (1/4)
  self.camera:lookAt(0, 0)  
  self.GU = DrawCommon()
  self.collider = CollisionSystem()
  self.combat = Combat()
  
  self.captureDeviceRadius = (ViewportParams.r + 50) / (self.camera.scale)
  self.radarDeviceRadius = (ViewportParams.r * 3) / (self.camera.scale)
  
  self.DEFAULT_COLOR = {255,255,255}
  self.TEXT_Y_OFFSET = 2 * self.GU.FONT_SIZE
  self.TEXT_COLOR = {80, 80, 200}
  
  self.DRAW_ORDERING = {"Asteroid", "Worker Bullet", "Player Bullet", "Warrior Bullet", "Crystal", "Sinistar", "Sinibomb", "Worker", "Warrior", "Player"}
end

function Renderer:draw(xWorld)
  local playerX, playerY = xWorld.player.loc.x, xWorld.player.loc.y
  local playerAngle = self.GU:getAngle(xWorld.player.dir)
  local movementJoystickMinR = InputParams.movementJoystick.minR
  local projectiles = xWorld.projectiles
  local inverseCameraScale = 1/self.camera.scale
  
  local inCDView = xWorld.player.getRelativeNeighbors(self.captureDeviceRadius)
  local inViewByType = self:getObjectsInViewByType(inCDView)
  local inRDView = xWorld.player.getRelativeNeighbors(self.radarDeviceRadius)
  local inRadarViewByType = self:getObjectsInViewByType(inRDView)
  
  xWorld.gameData.worldCameraScale = self.camera.scale
  xWorld.gameData.forRadar = inRadarViewByType 
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerX, playerY)
  self.camera:attach()  
  love.graphics.setScissor(ViewportParams.x - ViewportParams.r, ViewportParams.y - ViewportParams.r, ViewportParams.r*2, ViewportParams.r*2)
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
  love.graphics.rectangle("line", -7200, -7200, 14400, 14400)
  
  love.graphics.setColor(255,255,255)
  self.GU:BEGIN_SCALE({x = 0, y = 0}, inverseCameraScale)
    self.GU:centeredText("ORIGIN", 0, self.TEXT_Y_OFFSET)
  self.GU:END()
  
  for i = 1, #self.DRAW_ORDERING do
    local layerToDraw = self.DRAW_ORDERING[i]
    local layerObjects = inViewByType[layerToDraw] or {}
    
    for j = 1, #layerObjects do
      local obj = layerObjects[j]
      local dir = obj.obj.dir
      local radius = obj.obj.radius
      local id = obj.obj.id
      local type = obj.obj.type
      local loc = obj.obj.loc
      local objRender = obj.obj.render
      local image = objRender.image
      if image then
        local color = objRender.color or self.DEFAULT_COLOR
        love.graphics.setColor(color[1], color[2], color[3], color[4])
        local angle = 0
        if objRender.shouldRotate then
          angle = self.GU:getAngle(dir)
        end   
        self.GU:drawRotatedImage(image, obj.x, obj.y, angle)
        if radius then
          love.graphics.circle("line", obj.x, obj.y, radius)
        end
      end
  
      love.graphics.setColor(self.TEXT_COLOR[1], self.TEXT_COLOR[2], self.TEXT_COLOR[3], self.TEXT_COLOR[4])
      self.GU:BEGIN_SCALE(loc, inverseCameraScale)
        self.GU:centeredText(type .. "\n" .. math.floor(self.combat:getHealthPercent(id) * 100) .. '%' .. "\n" .. math.floor(obj.x) .. ", " .. math.floor(obj.y), obj.x, obj.y + self.TEXT_Y_OFFSET)
      self.GU:END()      
    end
  end
  
  love.graphics.setScissor()
  self.camera:detach()  
end

function Renderer:getObjectsInViewByType(xInView)
  local byType = {}
  for k, obj in pairs(xInView) do
    local type = obj.type or obj.obj.type
    if not byType[type] then byType[type] = {} end
    table.insert(byType[type], obj)
  end
  return byType
end

return Renderer
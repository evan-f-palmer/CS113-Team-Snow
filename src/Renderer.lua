local Class  = require('hump.class')
local Camera = require('hump.camera')
local DrawCommon = require('DrawCommon')
local InputParams = require("InputParams")
local CollisionSystem = require('CollisionSystem')
local Combat = require('Combat')

local Renderer = Class {}

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = 1 / 5
  self.camera:lookAt(0, 0)  
  self.GU = DrawCommon()
  self.collider = CollisionSystem()
  self.combat = Combat()
  
  self.viewRadius = 300
  
  self.captureDevice = {
    loc = {x = 0, y = 0},
    radius = 350 * (1/self.camera.scale),
    type = "Capture Device",
  }
  self.collider:createCollisionObject(self.captureDevice, self.captureDevice.radius)

  self.radarDevice = {
    loc = {x = 0, y = 0},
    radius = 600 * (1/self.camera.scale),
    type = "Radar Device",
  }
  self.collider:createCollisionObject(self.radarDevice, self.radarDevice.radius)

  
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
  
  self.captureDevice.loc = xWorld.player.loc
  self.captureDevice.inView = xWorld.collider:getCollisions(self.captureDevice)
  local inViewByType = self:getObjectsInViewByType(self.captureDevice.inView)
  
  self.radarDevice.loc = xWorld.player.loc
  self.radarDevice.inView = xWorld.collider:getCollisions(self.radarDevice)
  local inRadarViewByType = self:getObjectsInViewByType(self.radarDevice.inView)
  
  xWorld.gameData.forRadar = inRadarViewByType 
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerX, playerY)
  self.camera:attach()  

  local centerX = love.window.getWidth()/2
  local centerY = love.window.getHeight()/2
  love.graphics.setScissor(centerX - self.viewRadius, centerY - self.viewRadius, self.viewRadius*2, self.viewRadius*2)
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  love.graphics.setColor(255,255,255)
  self.GU:BEGIN_SCALE({x = 0, y = 0}, inverseCameraScale)
    self.GU:centeredText("ORIGIN", 0, self.TEXT_Y_OFFSET)
  self.GU:END()
  
  for i = 1, #self.DRAW_ORDERING do
    local layerToDraw = self.DRAW_ORDERING[i]
    local layerObjects = inViewByType[layerToDraw] or {}
    
    for j = 1, #layerObjects do
      local obj = layerObjects[j]
      local objRender = obj.render
      local image = objRender.image
      if image then
        local color = objRender.color or self.DEFAULT_COLOR
        love.graphics.setColor(color[1], color[2], color[3], color[4])
        local angle = 0
        if objRender.shouldRotate then
          angle = self.GU:getAngle(obj.dir)
        end   
        self.GU:drawRotatedImage(image, obj.loc.x, obj.loc.y, angle)
        if obj.radius then
          love.graphics.circle("line", obj.loc.x, obj.loc.y, obj.radius)
        end
      end
  
      love.graphics.setColor(self.TEXT_COLOR[1], self.TEXT_COLOR[2], self.TEXT_COLOR[3], self.TEXT_COLOR[4])
      self.GU:BEGIN_SCALE(obj.loc, inverseCameraScale)
        self.GU:centeredText(obj.type .. "\n" .. math.floor(self.combat:getHealthPercent(obj.id) * 100) .. '%' .. "\n" .. math.floor(obj.loc.x) .. ", " .. math.floor(obj.loc.y), obj.loc.x, obj.loc.y + self.TEXT_Y_OFFSET)
      self.GU:END()      
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
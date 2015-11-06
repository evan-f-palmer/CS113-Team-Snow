local Class  = require('hump.class')
local Camera = require('hump.camera')
local DrawCommon = require('DrawCommon')
local PlayerInputParams = require("PlayerInputParams")
local CollisionSystem = require('CollisionSystem')

local Renderer = Class {}

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = 1 / 5
  self.camera:lookAt(0, 0)  
  self.GU = DrawCommon()
  self.collider = CollisionSystem()
  
  self.captureDevice = {
    loc = {x = 0, y = 0},
    radius = 300 * (1/self.camera.scale),
    type = "Capture Device",
  }
  self.collider:createCollisionObject(self.captureDevice, self.captureDevice.radius)
  
  self.DEFAULT_COLOR = {255,255,255}
  self.DEFAULT_IMAGE = love.graphics.newImage("assets/worker.png")
end

function Renderer:draw(xWorld)
  local playerX, playerY = xWorld.player.loc.x, xWorld.player.loc.y
  local playerAngle = self.GU:getAngle(xWorld.player.dir)
  local movementJoystickMinR = PlayerInputParams.movementJoystick.minR
  local projectiles = xWorld.projectiles
  
  self.captureDevice.loc = xWorld.player.loc
  self.captureDevice.inView = xWorld.collider:getCollisions(self.captureDevice)
  -- can sort self.captureDevice.inView by object "types" (EX: can insert into layers by type)
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerX, playerY)
  self.camera:attach()
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
  for i = 1, #self.captureDevice.inView do
    local obj = self.captureDevice.inView[i]
    local objRender = obj.render
    local color = objRender.color or self.DEFAULT_COLOR
    love.graphics.setColor(unpack(color))
    local image = objRender.image or self.DEFAULT_IMAGE 
    local angle = 0
    if objRender.shouldRotate then
      angle = self.GU:getAngle(obj.dir)
    end   
    self.GU:drawRotatedImage(image, obj.loc.x, obj.loc.y, angle)  
  end
    
  self.GU:BEGIN_SCREENSPACE(self.camera)    
    love.graphics.setColor(80, 80, 200)
    self.GU:centeredText("ORIGIN", 0, 0)    
    for i = 1, #self.captureDevice.inView do
      local obj = self.captureDevice.inView[i]
      self.GU:centeredText(obj.type, obj.loc.x, obj.loc.y)       
    end
  self.GU:END()
    
  self.camera:detach()  
end

return Renderer
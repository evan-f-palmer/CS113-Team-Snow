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
  self.TEXT_Y_OFFSET = 2 * self.GU.FONT_SIZE
  self.TEXT_COLOR = {80, 80, 200}
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
  
  local inverseCameraScale = 1/self.camera.scale
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  love.graphics.setColor(255,255,255)
  self.GU:BEGIN_SCALE({x = 0, y = 0}, inverseCameraScale)
    self.GU:centeredText("ORIGIN", 0, self.TEXT_Y_OFFSET)
  self.GU:END()
  
  for i = 1, #self.captureDevice.inView do
    local obj = self.captureDevice.inView[i]
    local objRender = obj.render
    local image = objRender.image
    if image then
      local color = objRender.color or self.DEFAULT_COLOR
      love.graphics.setColor(unpack(color))
      local angle = 0
      if objRender.shouldRotate then
        angle = self.GU:getAngle(obj.dir)
      end   
      self.GU:drawRotatedImage(image, obj.loc.x, obj.loc.y, angle)
    end

    love.graphics.setColor(self.TEXT_COLOR[1], self.TEXT_COLOR[2], self.TEXT_COLOR[3], self.TEXT_COLOR[4])
    self.GU:BEGIN_SCALE(obj.loc, inverseCameraScale)
      self.GU:centeredText(obj.type, obj.loc.x, obj.loc.y + self.TEXT_Y_OFFSET)
    self.GU:END()
  end
    
  self.camera:detach()  
end

return Renderer
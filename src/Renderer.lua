local Class  = require('hump.class')
local Camera = require('hump.camera')
local Vector = require('hump.vector')
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
    onCollision = function(self, objInView, dx, dy)
      -- I CAN INSERT IN SOME ORDER, S.T. THERE IS A LAYERING (Ex: I can insert into different layers)
      table.insert(self.inView, objInView)
    end,
    inView = {},
    radius = 300 * (1/self.camera.scale),
  }
  self.collider:createCollisionObject(self.captureDevice, self.captureDevice.radius)
  
  self.DEFAULT_IMAGE = love.graphics.newImage("assets/worker.png")
end

function Renderer:draw(xWorld)
  local playerX, playerY = xWorld.player.loc.x, xWorld.player.loc.y
  local playerAngle = self.GU:getAngle(xWorld.player.dir)
  local movementJoystickMinR = PlayerInputParams.movementJoystick.minR
  local projectiles = xWorld.projectiles
  
  self.captureDevice.loc = xWorld.player.loc
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerX, playerY)
  self.camera:attach()
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
  for i = 1, #self.captureDevice.inView do
    local obj = self.captureDevice.inView[i]
    local angle = 0
    if obj.shouldRotate then
      angle = self.GU:getAngle(obj.dir)
    end
    local color = obj.color or {255, 255, 255}
    local image = obj.image or self.DEFAULT_IMAGE
    love.graphics.setColor(unpack(color))
    self.GU:drawRotatedImage(image, obj.loc.x, obj.loc.y, angle)
  end
    
  self.GU:BEGIN_SCREENSPACE(self.camera)    
    love.graphics.setColor(255, 255, 255) 
    self.GU:centeredText("ORIGIN", 0, 0)
    
    love.graphics.setColor(80, 80, 200)
    for i, projectile in ipairs(projectiles) do
      self.GU:centeredText(projectile.id, projectile.loc.x, projectile.loc.y)      
    end
  self.GU:END()
  
  self.captureDevice.inView = {}
  
  self.camera:detach()  
end

function Renderer:drawPlayerDebugInfo(xPlayer, xLoc, yLoc)
  local info = {}
  info["LOC"] = '['.. math.floor(xPlayer.loc.x) .. ', ' .. math.floor(xPlayer.loc.y) .. ']'
  self.GU:drawDebugInfo(info, xLoc, yLoc)
end

return Renderer
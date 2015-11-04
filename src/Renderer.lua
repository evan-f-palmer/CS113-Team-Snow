local Class  = require('hump.class')
local Camera = require('hump.camera')
local Vector = require('hump.vector')
local DrawCommon = require('DrawCommon')
local PlayerInputParams = require("PlayerInputParams")

local Renderer = Class {}

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = 1 / 5
  self.camera:lookAt(0, 0)  
  self.GU = DrawCommon()
  
  self.playerShip = love.graphics.newImage("assets/ship.png")
end

function Renderer:draw(xWorld)
  local playerX, playerY = xWorld.player.loc.x, xWorld.player.loc.y
  local playerAngle = self.GU:getAngle(xWorld.player.dir)
  local movementJoystickMinR = PlayerInputParams.movementJoystick.minR
  local projectiles = xWorld.projectiles
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerX, playerY)
  self.camera:attach()
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
  love.graphics.setColor(80, 80, 200)
  for i, projectile in ipairs(projectiles) do
    local angle = self.GU:getAngle(projectile.dir)
    self.GU:drawRotatedImage(self.playerShip, projectile.pos.x, projectile.pos.y, angle) 
  end
  
    -- THE PLAYER
  love.graphics.setColor(255,255,255)
  self.GU:drawRotatedImage(self.playerShip, playerX, playerY, playerAngle)
  
  self.GU:BEGIN_SCREENSPACE(self.camera)
    love.graphics.setColor(255, 255, 0)
    --self:drawPlayerDebugInfo(xWorld.player, playerX + movementJoystickMinR, playerY)
    
    love.graphics.setColor(255, 255, 255) 
    self.GU:centeredText("ORIGIN", 0, 0)
    
    love.graphics.setColor(80, 80, 200)
    for i, projectile in ipairs(projectiles) do
      self.GU:centeredText(projectile.id, projectile.pos.x, projectile.pos.y)      
    end
  self.GU:END()
  
  self.camera:detach()  
end

function Renderer:drawPlayerDebugInfo(xPlayer, xLoc, yLoc)
  local info = {}
  info["LOC"] = '['.. math.floor(xPlayer.loc.x) .. ', ' .. math.floor(xPlayer.loc.y) .. ']'
  self.GU:drawDebugInfo(info, xLoc, yLoc)
end

return Renderer
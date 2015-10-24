local Class  = require('hump.class')
local Camera = require('hump.camera')
local Vector = require('hump.vector')

local Renderer = Class {}
local FONT_FILE = nil
local FONT_SIZE = 12

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = 1 / 10
  self.camera:lookAt(0, 0)  
  
  self.playerShip = love.graphics.newImage("assets/ship.png")
  
  self.font = love.graphics.newFont(FONT_FILE, FONT_SIZE)
  love.graphics.setFont(self.font)
end

local UP_VECTOR = Vector(0, 1)
local function getAngle(xVec)
  return math.pi - UP_VECTOR:angleTo(xVec)
end

function Renderer:draw(xWorld)
  local playerX, playerY = xWorld.player.loc.x, xWorld.player.loc.y
  local playerCenterX, playerCenterY = (playerX + self.playerShip:getWidth() / 2), (playerY + self.playerShip:getHeight() / 2)
  local playerAngle = getAngle(xWorld.player.dir)
  local blindSpotRadius = xWorld.player.playerInput.blindSpotRadius
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerCenterX, playerCenterY)
  self.camera:attach()
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
  -- THE PLAYER
  love.graphics.setColor(255,255,255)
  self:drawRotatedImage(self.playerShip, playerX, playerY, playerAngle)
  
  self:BEGIN_SCREENSPACE()
    -- THIS SHOWS US WHERE THE MOUSE CONTROLS ARE INACTIVE FOR PROPULSION, (but still active for rotation)
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("line", playerCenterX, playerCenterY, blindSpotRadius, 50)
    
    love.graphics.setColor(255, 255, 0)
    self:drawPlayerDebugInfo(xWorld.player, playerCenterX + blindSpotRadius, playerCenterY)
    
    --self:drawDebugInfo(xWorld.player.playerGameData, playerCenterX, playerCenterY + blindSpotRadius)
  self:END()
  
  self.camera:detach()  
end

function Renderer:drawRotatedImage(image, x, y, angle)  
  local centerX = x + image:getWidth()/2
  local centerY = y + image:getHeight()/2
  self:BEGIN_ROTATE_ABOUT_POINT_AT_ANGLE(centerX, centerY, angle)
    love.graphics.draw(image, x, y)
  self:END()
end

function Renderer:drawPlayerDebugInfo(xPlayer, xLoc, yLoc)
  local info = {}
  info["LOC"] = '['.. math.floor(xPlayer.loc.x) .. ', ' .. math.floor(xPlayer.loc.y) .. ']'
  info["VEL"] = '['.. math.floor(xPlayer.vel.x) .. ', ' .. math.floor(xPlayer.vel.y) .. ']'  
  info["[PRIMARY FIRE]"] = xPlayer.playerInput.primaryWeaponFire
  info["[SECONDARY FIRE]"] = xPlayer.playerInput.secondaryWeaponFire
  self:drawDebugInfo(info, xLoc, yLoc)
end

function Renderer:drawDebugInfo(xInfo, xLoc, yLoc)
  local yOffset = (FONT_SIZE)
  for key, infoData in pairs(xInfo) do
    if infoData then
      if type(infoData) == 'boolean' then
        love.graphics.print(key, xLoc, yLoc)
      else
        local toPrint = key .. ':' .. infoData
        love.graphics.print(toPrint, xLoc, yLoc)
      end
      yLoc = yLoc + yOffset
    end
  end
end

function Renderer:BEGIN_SCREENSPACE()
  love.graphics.push()
  love.graphics.translate(self.camera.x, self.camera.y)
  love.graphics.scale(1 / self.camera.scale, 1 / self.camera.scale)
  love.graphics.translate(-self.camera.x, -self.camera.y)
end

function Renderer:BEGIN_ROTATE_ABOUT_POINT_AT_ANGLE(centerX, centerY, angle)
  love.graphics.push()
  love.graphics.translate(centerX, centerY)
  love.graphics.rotate(angle)
  love.graphics.translate(-centerX, -centerY)
end

function Renderer:END()
  love.graphics.pop()
end

return Renderer
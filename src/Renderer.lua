local Class  = require('hump.class')
local Camera = require('hump.camera')
local Vector = require('hump.vector')

local UP_VECTOR = Vector(0, 1)
local function getAngle(xVec)
  return math.pi - UP_VECTOR:angleTo(xVec)
end

local Renderer = Class {}

function Renderer:init()
  self.camera = Camera()
  self.camera.scale = 1 / 10
  self.camera:lookAt(0, 0)  
  
  self.playerShip = love.graphics.newImage("assets/ship.png")
end

local function rotateAboutPointAtAngle(centerX, centerY, angle)
  love.graphics.translate(centerX, centerY)
  love.graphics.rotate(angle)
  love.graphics.translate(-centerX, -centerY)
end

local function drawRotatedImage(image, x, y, angle)  
  local centerX = x + image:getWidth()/2
  local centerY = y + image:getHeight()/2
  love.graphics.push()
  rotateAboutPointAtAngle(centerX, centerY, angle)
  love.graphics.draw(image, x, y)
  love.graphics.pop()
end

function Renderer:draw(xWorld)
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
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
  drawRotatedImage(self.playerShip, playerX, playerY, playerAngle)
  
  self:BEGIN_SCREENSPACE()
    -- THIS SHOWS US WHERE THE MOUSE CONTROLS ARE INACTIVE FOR PROPULSION, (but still active for rotation)
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("line", playerCenterX, playerCenterY, blindSpotRadius, 50)
    
    love.graphics.setColor(255, 255, 0)
    self:drawPlayerDebugInfo(xWorld.player, playerCenterX + blindSpotRadius, playerCenterY)
  self:END_SCREENSPACE()
  
  self.camera:detach()  
end

function Renderer:drawPlayerDebugInfo(xPlayer, xLoc, yLoc)
  local info = {}
  
  local loc = 'LOC:['.. math.floor(xPlayer.loc.x) .. ', ' .. math.floor(xPlayer.loc.y) .. ']'
  table.insert(info, loc)
  local vel = 'VEL:['.. math.floor(xPlayer.vel.x) .. ', ' .. math.floor(xPlayer.vel.y) .. ']'  
  table.insert(info, vel)
  
  if xPlayer.playerInput.primaryWeaponFire then
    table.insert(info, '[PRIMARY   FIRE]')
  end
  
  if xPlayer.playerInput.secondaryWeaponFire then
    table.insert(info, '[SECONDARY FIRE]')
  end
  
  self:drawDebugInfo(info, xLoc, yLoc, 10)
end

function Renderer:drawDebugInfo(xInfo, xLoc, yLoc, yOffset)
  for k, infoString in pairs(xInfo) do
    love.graphics.print(infoString, xLoc, yLoc)
    yLoc = yLoc + yOffset
  end
end

function Renderer:BEGIN_SCREENSPACE()
  love.graphics.push()
  love.graphics.translate(self.camera.x, self.camera.y)
  love.graphics.scale(1 / self.camera.scale, 1 / self.camera.scale)
  love.graphics.translate(-self.camera.x, -self.camera.y)
end

function Renderer:END_SCREENSPACE()
  love.graphics.pop()
end

return Renderer
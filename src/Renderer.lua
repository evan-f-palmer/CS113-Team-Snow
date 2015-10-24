local Class  = require('hump.class')
local Camera = require('hump.camera')
local Vector = require('hump.vector')

local UP_VECTOR = Vector(0, 1)
local function getAngle(xVec)
  return math.pi - UP_VECTOR:angleTo(xVec)
end

local Renderer = Class {}

function Renderer:init(world)
  self.camera = Camera()
  self.world = world
  self.camera.scale = 1 / 5
  
  self.playerShip = love.graphics.newImage("assets/ship.png")

  self.camera:lookAt(0, 0)  
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

function Renderer:draw()
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
  local playerX, playerY = self.world.player.loc.x, self.world.player.loc.y
  local playerCenterX, playerCenterY = (playerX + self.playerShip:getWidth() / 2), (playerY + self.playerShip:getHeight() / 2)
  local playerAngle = getAngle(self.world.player.dir)
  
  -- ALWAYS LOOK AT THE PLAYER
  self.camera:lookAt(playerCenterX, playerCenterY)
  self.camera:attach()
  
  -- THE PLAYER
  love.graphics.setColor(255,255,255)
  drawRotatedImage(self.playerShip, playerX, playerY, playerAngle)
  
--  -- THIS SHOWS US WHERE THE MOUSE CONTROLS ARE INACTIVE FOR PROPULSION (but it implemented as a rectangle, so it doesn't)
  love.graphics.setColor(0, 255, 0)
  local blindSpotRadius = self.world.player.playerInput.blindSpotRadius
  love.graphics.push()
  love.graphics.translate(playerCenterX, playerCenterY)
  love.graphics.scale(1 / self.camera.scale, 1 / self.camera.scale)
  love.graphics.translate(-playerCenterX, -playerCenterY)
  love.graphics.circle("line", playerCenterX, playerCenterY, blindSpotRadius, 50)
  love.graphics.pop()
  
  -- SOME INFO THAT FOLLOWS THE PLAYER
  love.graphics.setColor(255, 255, 0)
  local loc = 'LOC:['.. math.floor(self.world.player.loc.x) .. ', ' .. math.floor(self.world.player.loc.y) .. ']'
  love.graphics.print(loc, playerCenterX + 50, playerCenterY + 50, 0, 5, 5)
  local vel = 'VEL:['.. math.floor(self.world.player.vel.x) .. ', ' .. math.floor(self.world.player.vel.y) .. ']'
  love.graphics.print(vel, playerCenterX + 50, playerCenterY + 100, 0, 5, 5)
  
  -- THE ORIGIN
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 30, 20)
  
  self.camera:detach()  
end

return Renderer
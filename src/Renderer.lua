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
  self.camera.scale = 1 / 3
  
  self.playerShip = love.graphics.newImage("assets/ship.png")

  self.camera:lookAt(0, 0)  
end

local function rotateAboutPointAtAngle(centerX, centerY, angle)
  love.graphics.translate(centerX, centerY)
  love.graphics.rotate(angle)
  love.graphics.translate(-centerX, -centerY)
end

function Renderer:draw()
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
  local playerX, playerY = self.world.player.loc.x, self.world.player.loc.y
  local playerCenterX, playerCenterY = (playerX + self.playerShip:getWidth() / 2), (playerY + self.playerShip:getHeight() / 2)
  local playerAngle = getAngle(self.world.player.vel)
  
  self.camera:lookAt(playerCenterX, playerCenterY)
  self.camera:attach()
  
  love.graphics.setColor(255,255,255)
  love.graphics.push()
  rotateAboutPointAtAngle(playerCenterX, playerCenterY, playerAngle)
  love.graphics.draw(self.playerShip, playerX, playerY)
  --love.graphics.rectangle("line", playerX, playerY, self.playerShip:getWidth(), self.playerShip:getHeight())
  love.graphics.pop()
  
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 10, 50)
  
  love.graphics.setColor(255, 255, 0)
  local loc = 'LOC:['.. math.floor(self.world.player.loc.x) .. ', ' .. math.floor(self.world.player.loc.y) .. ']'
  love.graphics.print(loc, 50, 50, 0, 5, 5)
  local vel = 'VEL:['.. math.floor(self.world.player.vel.x) .. ', ' .. math.floor(self.world.player.vel.y) .. ']'
  love.graphics.print(vel, 50, 100, 0, 5, 5)
  
  self.camera:detach()  
end

return Renderer
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

function Renderer:drawOnCenter(image, rotation)
  love.graphics.push()
  love.graphics.rotate(rotation)
  love.graphics.translate(-image:getWidth() / 2, -image:getHeight() / 2)
  love.graphics.draw(image, 0, 0)  
  love.graphics.pop()  
end

function Renderer:draw()
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
  self.camera:attach()
  
  love.graphics.setColor(255,255,255)
  
  local playerVel = self.world.player.vel
  local playerAngle = getAngle(playerVel)

  self:drawOnCenter(self.playerShip, playerAngle)
  
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", 0, 0, 10, 50)
  
  local loc = 'LOC:['.. math.floor(self.world.player.loc.x) .. ', ' .. math.floor(self.world.player.loc.y) .. ']'
  love.graphics.print(loc, 50, 50, 0, 5, 5)
  local vel = 'VEL:['.. math.floor(self.world.player.vel.x) .. ', ' .. math.floor(self.world.player.vel.y) .. ']'
  love.graphics.print(vel, 50, 100, 0, 5, 5)
  
  self.camera:detach()  
end

return Renderer
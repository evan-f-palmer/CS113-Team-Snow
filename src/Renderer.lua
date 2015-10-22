local Class  = require('hump.class')
local Camera = require('hump.camera')


local Renderer = Class {}

function Renderer:init(world)
  self.camera = Camera()
  self.world = world
  self.camera.scale = 1 / 10
  
  self.playerShip = love.graphics.newImage("assets/ship.png")

  self.camera:lookAt(0, 0)  
end

function Renderer:drawOnCenter(image, loc, rotation)
  love.graphics.push()
  love.graphics.translate(0, 0)
  love.graphics.rotate(rotation)
  love.graphics.translate(loc.x - image:getWidth() / 2, loc.y - image:getHeight() / 2)
  
  love.graphics.draw(image,0, 0)
  love.graphics.pop()  
end

function Renderer:draw()
  local screenWidth  = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
  local playerLoc = self.world.player.loc

  self.camera:attach()
  
  love.graphics.setColor(255,255,255)
  

  
  love.graphics.setColor(255,255,255)
  
  self:drawOnCenter(self.playerShip, playerLoc,0)
  
  love.graphics.setColor(255,0,0)
  love.graphics.circle("fill",playerLoc.x, playerLoc.y, 10, 50)
  
  self.camera:detach()  
  
end

return Renderer
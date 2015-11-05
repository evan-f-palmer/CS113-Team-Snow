local Class  = require('hump.class')
local HC     = require 'HardonCollider'
local Singleton = require('Singleton')

local CollisionSystem = Class {}

local MainObject = 'main'

--[[
The metaObject passed in needs a loc with an x and y
and needs an onCollision(metaObject, dx, dy) for collisions

It will inject a getNeighbors function that returns the metaObjects
that are neighboring this object
--]]

function CollisionSystem:init()
  self.hc = HC(100)
  self.collisionObjects = {}
end

function CollisionSystem:createCollisionObject(metaObject, radius)
  local collisionObject = {}
  collisionObject[MainObject] = self.hc:circle(metaObject.loc.x, metaObject.loc.y, radius)
  collisionObject[MainObject].metaObject = metaObject
  
  -- Create More objects here
  -- Need more logic for wrapping world
  
  self.collisionObjects[metaObject] = collisionObject
  
  -- Inject getNeighbots
  metaObject['getNeighbors'] = function()
    local neighbors = {}
    for _, neighbor in pairs(self:getNeighbors(metaObject)) do
      neighbors[#neighbors + 1] = neighbor.metaObject
    end
    return neighbors
  end
end

function CollisionSystem:update()
  for metaObject, collisionObject in pairs(self.collisionObjects) do
  
    if self:hasMoved(collisionObject, metaObject.loc) then
      self:moveCollisionObject(collisionObject, metaObject.loc)
    end
    self:updateCollisions(collisionObject)
  end
end

function CollisionSystem:hasMoved(collisionObject, location)
  local centerX, centerY = collisionObject[MainObject]:center()
  return centerX ~= location.x or centerY ~= location.y
end

function CollisionSystem:moveCollisionObject(collisionObject, newLoc)
  collisionObject[MainObject]:moveTo(newLoc.x, newLoc.y)
  -- More logic to update other shapes
  
end

function CollisionSystem:updateCollisions(collisionObject)
  for _, neighbor in pairs(self.hc:neighbors(collisionObject[MainObject])) do
    local collides, dx, dy = collisionObject[MainObject]:collidesWith(neighbor)
    if collides then
      collisionObject[MainObject].metaObject:onCollision(neighbor.metaObject, dx, dy)
      neighbor.metaObject:onCollision(collisionObject[MainObject].metaObject, dx, dy)
    end
  end
end

function CollisionSystem:removeObject(metaObject)
  for _, shape in pairs(self.objects[metaObject]) do
    self.hc.remove(shape)
  end
  self.objects[metaObject] = nil
end

function CollisionSystem:getNeighbors(metaObject)
  return self.hc.neighbors(self.collisionObjects[metaObject][MainObject])
end

return Singleton(CollisionSystem)
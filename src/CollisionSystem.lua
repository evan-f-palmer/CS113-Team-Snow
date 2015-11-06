local Class  = require('hump.class')
local HC     = require 'HardonCollider'
local Singleton = require('Singleton')

local CollisionSystem = Class {}

local MainObject = 'main'

local EMPTY_FUNCTION = function() end
--[[
The metaObject passed in needs a loc with an x and y
and needs an onCollision(metaObject) for collisions

It will inject a getNeighbors function that returns the metaObjects
that are neighboring this object
--]]

function CollisionSystem:init()
  self.hc = HC(100)
  self.collisionObjects = {}
end

function CollisionSystem:createCollisionObject(metaObject, radius)
  local collisionObject = {}
  metaObject.onCollision = metaObject.onCollision or EMPTY_FUNCTION
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
      self:updateCollisions(collisionObject)
    end
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
      collisionObject[MainObject].metaObject:onCollision(neighbor.metaObject)
      neighbor.metaObject:onCollision(collisionObject[MainObject].metaObject)   
    end
  end
end

function CollisionSystem:removeObject(metaObject)
  for _, shape in pairs(self.collisionObjects[metaObject]) do
    self.hc:remove(shape)
  end
  self.collisionObjects[metaObject] = nil
end

function CollisionSystem:getNeighbors(metaObject)
  return self.hc:neighbors(self.collisionObjects[metaObject][MainObject])
end

function CollisionSystem:getCollisions(metaObject)
  local collisions = {}
  for object, collision in pairs(self.hc:collisions(self.collisionObjects[metaObject][MainObject])) do
    if collision then
      collisions[#collisions + 1] = object.metaObject
    end
  end

  return collisions
end

return Singleton(CollisionSystem)
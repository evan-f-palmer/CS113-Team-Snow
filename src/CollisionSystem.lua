local Class  = require('hump.class')
local HC     = require 'HardonCollider'
local Singleton = require('Singleton')

local CollisionSystem = Class {}

local MainObject = 'main'
local TwinObject = 'twin'

local EMPTY_FUNCTION = function() end
local HC_SCALE = 100
local closerToOriginComparitor
--[[
The metaObject passed in needs a loc with an x and y
and needs an onCollision(metaObject) for collisions

It will inject a getNeighbors function that returns the metaObjects
that are neighboring this object
--]]

function CollisionSystem:init()
  self.hc = HC(HC_SCALE)
  self.collisionObjects = {}
  self.width, self.height = HC_SCALE, HC_SCALE
  self.xTranslate, self.yTranslate = HC_SCALE / 2, HC_SCALE / 2 
  self:setWidth(HC_SCALE)
  self:setHeight(HC_SCALE)
end

function CollisionSystem:setWidth(xWidth)
  self.xScale = (HC_SCALE / xWidth)
  self.invxScale = 1 / self.xScale
  
  self.xTranslate = xWidth/2 -- ZZZ
end

function CollisionSystem:setHeight(xHeight)
  self.yScale = (HC_SCALE / xHeight)
  self.invyScale = 1 / self.yScale
  
  self.yTranslate = xHeight/2 -- ZZZ
end

function CollisionSystem:createCollisionObject(metaObject, radius)
  local collisionObject = {}
  self.collisionObjects[metaObject] = collisionObject
  local scaledRadius = self:toColliderRadius(radius)  
  metaObject.onCollision = metaObject.onCollision or EMPTY_FUNCTION
  collisionObject[MainObject] = self.hc:circle(0, 0, scaledRadius)
  collisionObject[MainObject].metaObject = metaObject
  collisionObject[TwinObject] = self.hc:circle(0, 0, scaledRadius)
  collisionObject[TwinObject].metaObject = metaObject
  self:moveCollisionObject(collisionObject, metaObject.loc)
  self:worldWrap(metaObject)

  metaObject['getNeighbors'] = function(sightRadius)
    local neighbors = {}    
    local mx, my = collisionObject[MainObject]:center()
    for neighbor, _ in pairs(self.hc:circleCollisions(mx, my, sightRadius)) do
      neighbors[#neighbors + 1] = neighbor.metaObject
    end
    return neighbors
  end

  metaObject['getRelativeNeighbors'] = function(sightRadius)  
    local neighbors = {}    
    local mx, my = collisionObject[MainObject]:center()
    local tx, ty = collisionObject[TwinObject]:center()
    
    for neighbor, _ in pairs(self.hc:circleCollisions(mx, my, sightRadius)) do
      local nx, ny = self:toWorldCoordinate(neighbor:center())
      neighbors[#neighbors + 1] = {x = nx, y = ny, obj = neighbor.metaObject}
    end
    
    for neighbor, _ in pairs(self.hc:circleCollisions(tx, ty, sightRadius)) do
      local nx, ny = self:toWorldCoordinate(self:getTwinLoc(neighbor:center()))
      neighbors[#neighbors + 1] = {x = nx, y = ny, obj = neighbor.metaObject}
    end
    
    return neighbors
  end
end

function CollisionSystem:update()
  for metaObject, collisionObject in pairs(self.collisionObjects) do
    if self:hasMoved(collisionObject, metaObject.loc) then
      self:moveCollisionObject(collisionObject, metaObject.loc)
      self:updateCollisions(collisionObject)
      self:worldWrap(metaObject)
    end
  end
end

function CollisionSystem:hasMoved(collisionObject, location)
  local centerX, centerY = collisionObject[MainObject]:center()
  return centerX ~= location.x or centerY ~= location.y
end

function CollisionSystem:moveCollisionObject(collisionObject, newLoc)
  local cX, cY = self:toColliderCoordinate(newLoc.x, newLoc.y)
  local twinX, twinY = self:getTwinLoc(cX, cY)
  
  collisionObject[MainObject]:moveTo(cX, cY)
  collisionObject[TwinObject]:moveTo(twinX, twinY)
  
  local newMain, newTwin = closerToOriginComparitor(collisionObject[MainObject], collisionObject[TwinObject])
  collisionObject[MainObject], collisionObject[TwinObject] = newMain, newTwin  
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
  metaObject.getNeighbors = nil
  self.collisionObjects[metaObject] = nil
end

function CollisionSystem:isHandling(metaObject)
  return self.collisionObjects[metaObject] ~= nil
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

function CollisionSystem:toColliderRadius(r)
  return r -- ZZZ
  --return r * math.max(self.xScale, self.yScale)
end

function CollisionSystem:toColliderCoordinate(x, y)
  return x,y -- ZZZ
  --return x * self.xScale, y * self.yScale
end

function CollisionSystem:toWorldCoordinate(x, y)
  return x,y -- ZZZ
  --return x * self.invxScale, y * self.invyScale
end

function CollisionSystem:getTwinLoc(x, y)
  if x < 0 then
    x = x + self.xTranslate
  else
    x = x - self.xTranslate
  end
  if y < 0 then
    y = y + self.yTranslate
  else
    y = y - self.yTranslate
  end
  return x, y
end

function closerToOriginComparitor(A, B)
  local Ax, Ay = A:center()
  local Bx, By = B:center()
  local AdistSqr = (Ax)*(Ax) + (Ay)*(Ay)
  local BdistSqr = (Bx)*(Bx) + (By)*(By)
  if AdistSqr < BdistSqr then
    return A, B
  else
    return B, A
  end
end

function CollisionSystem:worldWrap(metaObject)
  local collisionObject = self.collisionObjects[metaObject]
  metaObject.loc.x, metaObject.loc.y = self:toWorldCoordinate(collisionObject[MainObject]:center())
end

return Singleton(CollisionSystem)
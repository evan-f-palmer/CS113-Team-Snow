local Class  = require('hump.class')
local HC     = require 'HardonCollider'
local Singleton = require('Singleton')

local CollisionSystem = Class {}

local MainObject = 'main'
local TwinObject = 'twin'
local EMPTY_FUNCTION = function() end
local HC_SCALE = 100

function CollisionSystem:init()
  self.hc = HC(HC_SCALE)
  self.collisionObjects = {}
  self:setWidth(HC_SCALE)
  self:setHeight(HC_SCALE)
end

function CollisionSystem:setWidth(xWidth)
  self.width = xWidth
  self.xTranslate = xWidth/2
end

function CollisionSystem:setHeight(xHeight)
  self.height = xHeight
  self.yTranslate = xHeight/2
end

function CollisionSystem:createCollisionObject(metaObject, radius)
  local collisionObject = {}
  self.collisionObjects[metaObject] = collisionObject
  metaObject.loc = metaObject.loc or {x = 0, y = 0} 
  metaObject.onCollision = metaObject.onCollision or EMPTY_FUNCTION
  collisionObject[MainObject] = self.hc:circle(0, 0, radius)
  collisionObject[MainObject].metaObject = metaObject
  collisionObject[TwinObject] = self.hc:circle(0, 0, radius)
  collisionObject[TwinObject].metaObject = metaObject
  self:moveCollisionObject(collisionObject, metaObject.loc)
  self:worldWrap(metaObject)

  metaObject['getNeighbors'] = function(sightRadius)
    local neighbors = {}    
    local mx, my = collisionObject[MainObject]:center()
    local tx, ty = collisionObject[TwinObject]:center()
    for neighbor, _ in pairs(self.hc:circleCollisions(tx, ty, sightRadius)) do
      neighbors[neighbor] = neighbor.metaObject
    end
    for neighbor, _ in pairs(self.hc:circleCollisions(mx, my, sightRadius)) do
      neighbors[neighbor] = neighbor.metaObject
    end
    return neighbors
  end
  
  metaObject['getRelativeLoc'] = function(ofObject)
    local mx, my = collisionObject[MainObject]:center() -- Relative Origin
    local otherCollisionObject = self.collisionObjects[ofObject]
    local ox, oy = otherCollisionObject[MainObject]:center()        
    local x, y = (ox - mx), (oy - my) -- Relative space
    x, y = self:getClosestTranslationToOrigin(x, y)
    return x, y
  end
end

function CollisionSystem:removeObject(metaObject)
  if self:isHandling(metaObject) then
    for _, shape in pairs(self.collisionObjects[metaObject]) do
      self.hc:remove(shape)
    end
    metaObject.getNeighbors = nil
    self.collisionObjects[metaObject] = nil
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

-- private
function CollisionSystem:isHandling(metaObject)
  return self.collisionObjects[metaObject] ~= nil
end

-- private
function CollisionSystem:hasMoved(collisionObject, location)
  local centerX, centerY = collisionObject[MainObject]:center()
  return centerX ~= location.x or centerY ~= location.y
end

-- private
local function closerToOriginComparitor(A, B)
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

function CollisionSystem:moveCollisionObject(collisionObject, newLoc)
  local cX, cY = newLoc.x, newLoc.y
  local twinX, twinY = self:getTwinLoc(cX, cY)
  
  collisionObject[MainObject]:moveTo(cX, cY)
  collisionObject[TwinObject]:moveTo(twinX, twinY)
  
  local newMain, newTwin = closerToOriginComparitor(collisionObject[MainObject], collisionObject[TwinObject])
  collisionObject[MainObject], collisionObject[TwinObject] = newMain, newTwin  
end

-- private
function CollisionSystem:updateCollisions(collisionObject)
  for _, neighbor in pairs(self.hc:neighbors(collisionObject[MainObject])) do
    local collides, dx, dy = collisionObject[MainObject]:collidesWith(neighbor)
    if collides then
      collisionObject[MainObject].metaObject:onCollision(neighbor.metaObject)
      neighbor.metaObject:onCollision(collisionObject[MainObject].metaObject)   
    end
  end
end

-- private
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

-- private
function CollisionSystem:worldWrap(metaObject)
  metaObject.loc.x, metaObject.loc.y = self.collisionObjects[metaObject][MainObject]:center()
end

-- private
function CollisionSystem:closestPairToOrigin(...)
  local points = {...}
  local closestX, closestY
  local minDistanceSqr = math.huge
  for i = 1, #points, 2 do
    local x, y = points[i], points[i+1]
    local distSqr = (x*x) + (y*y)
    if distSqr < minDistanceSqr then
      minDistanceSqr = distSqr
      closestX, closestY = x, y
    end
  end
  return closestX, closestY
end

-- private
function CollisionSystem:getClosestTranslationToOrigin(x, y)    
    x, y = self:closestPairToOrigin(
      x,                   y,
      x,                   y + self.height, 
      x - self.xTranslate, y + self.yTranslate,
      x + self.xTranslate, y + self.yTranslate, 
      x,                   y - self.height,
      x,                   y + self.yTranslate,
      x,                   y - self.yTranslate,
      x + self.width,      y, 
      x + self.xTranslate, y - self.yTranslate,
      x - self.xTranslate, y - self.yTranslate,
      x - self.width,      y,
      x - self.xTranslate, y,
      x + self.xTranslate, y
    )
    return x, y
end

return Singleton(CollisionSystem)
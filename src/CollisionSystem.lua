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
  self.width, self.height = HC_SCALE, HC_SCALE
  self.xTranslate, self.yTranslate = HC_SCALE / 2, HC_SCALE / 2 
  self:setWidth(HC_SCALE)
  self:setHeight(HC_SCALE)
end

function CollisionSystem:setWidth(xWidth)
  self.xScale = (HC_SCALE / xWidth)
  self.invxScale = 1 / self.xScale
  
  self.xTranslate = xWidth/2 -- ZZZ
  self.width = xWidth -- ZZZ
end

function CollisionSystem:setHeight(xHeight)
  self.yScale = (HC_SCALE / xHeight)
  self.invyScale = 1 / self.yScale
  
  self.yTranslate = xHeight/2 -- ZZZ
  self.height = xHeight -- ZZZ
end

function CollisionSystem:createCollisionObject(metaObject, radius)
  local collisionObject = {}
  self.collisionObjects[metaObject] = collisionObject
  local scaledRadius = self:toColliderRadius(radius) 
  metaObject.loc = metaObject.loc or {x = 0, y = 0} 
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
    x, y = self:toWorldCoordinate(x, y)
    return x, y
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
  local cX, cY = self:toColliderCoordinate(newLoc.x, newLoc.y)
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
function CollisionSystem:toColliderRadius(r)
  return r -- ZZZ
  --return r * math.max(self.xScale, self.yScale)
end

-- private
function CollisionSystem:toColliderCoordinate(x, y)
  return x,y -- ZZZ
  --return x * self.xScale, y * self.yScale
end

-- private
function CollisionSystem:toWorldCoordinate(x, y)
  return x,y -- ZZZ
  --return x * self.invxScale, y * self.invyScale
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
  local collisionObject = self.collisionObjects[metaObject]
  metaObject.loc.x, metaObject.loc.y = self:toWorldCoordinate(collisionObject[MainObject]:center())
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
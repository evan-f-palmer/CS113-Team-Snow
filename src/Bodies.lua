local Class  = require('hump.class')

local Bodies = Class{}

Bodies.DEFAULT_RADIUS = 1
Bodies.DEFAULT_ON_COLLISION = function(other) end

function Bodies:init()

end

function Bodies:setCollider(xCollider)
  self.collider = xCollider
end

function Bodies:update(dt)  
  for i = #self, 1, -1 do
    local body = self[i]
    if body.update then
      body:update(dt)
    end
    if body.isDead then
      self:remove(i)
    end
  end
end

function Bodies:add(xBody)
  xBody.radius = xBody.radius or Bodies.DEFAULT_RADIUS
  xBody.onCollision = xBody.onCollision or Bodies.DEFAULT_ON_COLLISION
  table.insert(self, xBody)
  self.collider:createCollisionObject(xBody, xBody.radius)
end

function Bodies:remove(i)
  local obj = table.remove(self, i)
  self.collider:removeObject(obj)
end

function Bodies:clear()
  while #self > 0 do
    self:remove(#self)
  end
end

function Bodies:foreachdo(xFunc, ...)
  for i, body in ipairs(self) do
    xFunc(body, ...)
  end
end

return Bodies
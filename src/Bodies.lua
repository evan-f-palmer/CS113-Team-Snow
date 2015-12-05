local Class  = require('hump.class')

local Bodies = Class{}

Bodies.DEFAULT_RADIUS = 1

function Bodies:init()
  self.ids = {}
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
    if body.updateAI then
      body:updateAI()
    end
    if body.isDead then
      self:remove(i)
    end
  end
end

function Bodies:getByID(id)
  return self.ids[id]
end

function Bodies:add(xBody)
  if xBody.id and self.ids[xBody.id] then
    print('Body with ID already exists:', xBody.id)
  else
    if xBody.id then
      self.ids[xBody.id] = xBody
    end
    xBody.radius = xBody.radius or Bodies.DEFAULT_RADIUS
    table.insert(self, xBody)
    self.collider:createCollisionObject(xBody, xBody.radius)
  end
end

function Bodies:remove(i)
  local obj = table.remove(self, i)
  self.collider:removeObject(obj)
  if obj.onDeath then 
    obj:onDeath() 
  end
  if obj.id then 
    self.ids[obj.id] = nil
  end
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
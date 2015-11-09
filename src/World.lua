local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')
local Bodies = require('Bodies')

local World = Class{}

function World:init(playerInput, playerGameData, projectiles)
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  self.projectiles = projectiles
  self.bodies = Bodies() -- Asteroids and Enemies?
  self.collider = CollisionSystem()
  self.projectiles:setCollider(self.collider)
  self.bodies:setCollider(self.collider)  
  
  self.playerInput = playerInput
  self.playerGameData = playerGameData
  
  self.collider:createCollisionObject(self.player, self.player.radius)
end

local function updateObjects(objects, dt)
  for i = #objects, 1, -1 do
    local object = objects[i]
    object:update(dt)
    if object:isDead() then 
      table.remove(objects, i) 
    end  
  end 
end

function World:loadLevel(xLevelFileName)
  local level = dofile(xLevelFileName)
  local layers = level.layers
  for k, layer in pairs(layers) do
    local name = layer.name or "X"
    local properties = layer.properties
    local objects = layer.objects
    layers[name] = {properties = properties, objects = objects}
  end
  
  self:unload()
  
  for k, obj in pairs(layers["Spawn"].objects) do
    local type, x, y = obj.type, obj.x, obj.y
    x = x * 3
    y = y * 3
    if type == "Player" then
      self.player.loc.x = x
      self.player.loc.y = y
    end
  end
  
  local body = Player(self.playerInput, self.playerGameData)
  body.loc.x = self.player.loc.x - 200
  body.loc.y = self.player.loc.y
  self.bodies:add(body)
  
  local B = Player(self.playerInput, self.playerGameData)
  B.loc.x = self.player.loc.x + 200
  B.loc.y = self.player.loc.y
  self.bodies:add(B)
end

function World:unload()
  self.projectiles:clear()
  self.bodies:clear()
end

function World:update(dt)
  self:updateAllWorldObjects(dt)
  self:moveAllWorldObjects(dt)
  self.collider:update()
end

function World:updateAllWorldObjects(dt)
  self.player:update(dt)
  self.projectiles:update(dt)
  self.bodies:update(dt)
end

local function move(xBody, dt)
  local vel = (xBody.vel) * (dt) 
  xBody.loc:add_inplace(vel) 
end

function World:moveAllWorldObjects(dt)
  move(self.player, dt)
  for i, projectile in ipairs(self.projectiles) do
    move(projectile, dt)
  end
  for i, body in ipairs(self.bodies) do
    move(body, dt)
  end
end

return World
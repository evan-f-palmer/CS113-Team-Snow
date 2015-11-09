local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')
local Bodies = require('Bodies')

local World = Class{}
World.make = {
  Warrior  = require('Player'),
  Worker   = require('Player'),
  Asteroid = require('Player'),
  Sinistar = require('Player'),
}
World.levelScale = 3

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

function World:makeBody(type, x, y)
  local class = self.make[type]
  local obj = class(self.playerInput, self.playerGameData)
  obj.loc.x = x
  obj.loc.y = y
  self.bodies:add(obj)
  return obj
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
    x = x * World.levelScale
    y = y * World.levelScale
    if type == "Player" then
      self.player.loc.x = x
      self.player.loc.y = y
    else
      self:makeBody(type, x, y)
    end
  end
end

function World:unload()
  self.projectiles:clear()
  self.bodies:clear()
end

--local function updateObjects(objects, dt)
--  for i = #objects, 1, -1 do
--    local object = objects[i]
--    object:update(dt)
--    if object:isDead() then 
--      table.remove(objects, i) 
--    end  
--  end 
--end

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
  self.projectiles:foreachdo(move, dt)
  self.bodies:foreachdo(move, dt)
end

return World
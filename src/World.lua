local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')
local Bodies = require('Bodies')

local World = Class{}
World.make = {
  Warrior  = require('Player'), -- temporary placeholder
  Worker   = require('Player'), -- temporary placeholder
  Asteroid = require('Player'), -- temporary placeholder
  Sinistar = require('Player'), -- temporary placeholder
}
World.levelScale = 3

function World:init(playerInput, playerGameData, projectiles)
  self.player = Player(playerInput, playerGameData)
  self.playerGameData = playerGameData
  self.projectiles = projectiles
  self.bodies = Bodies()
  self.collider = CollisionSystem()
  self.projectiles:setCollider(self.collider)
  self.bodies:setCollider(self.collider)  
  
  self.playerInput = playerInput -- temporary
  self.playerGameData = playerGameData -- temporary
  
  self.collider:createCollisionObject(self.player, self.player.radius)
end

function World:loadLevel(xLevelFileName)
  local level = dofile(xLevelFileName)
  local layers = self:getLayers(level)  
  self:unload()
  self:spawnAllFrom(layers["Spawn"])
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
  self.projectiles:foreachdo(move, dt)
  self.bodies:foreachdo(move, dt)
end

function World:makeBody(type, x, y, ...)
  local class = self.make[type]
  local obj = class(...)
  obj.loc.x = x
  obj.loc.y = y
  self.bodies:add(obj)
  return obj
end

function World:getLayers(xLevel)
  local layers = xLevel.layers
  for i, layer in ipairs(layers) do
    local name = layer.name
    local properties = layer.properties
    local objects = layer.objects
    layers[name] = {properties = properties, objects = objects}
  end
  return layers
end

function World:spawnAllFrom(xSpawnLayer)
  for k, obj in pairs(xSpawnLayer.objects) do
    local type, x, y = obj.type, (obj.x * World.levelScale), (obj.y * World.levelScale)
    if type == "Player" then
      self.player.loc.x = x
      self.player.loc.y = y
    else
      self:makeBody(type, x, y, self.playerInput, self.playerGameData) -- playerInput and playerGameData args are temporary
    end
  end
end

return World
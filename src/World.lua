local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')
local Bodies = require('Bodies')

local World = Class{}
World.make = {
  Warrior  = require('Warrior'), -- temporary placeholder
  Worker   = require('Worker'), -- temporary placeholder
  Asteroid = require('Asteroid'), -- temporary placeholder
  Sinistar = require('Asteroid'), -- temporary placeholder
  Flock    = require('Flock'),
}
World.levelScale = 20

function World:init(playerInput, gameData, projectiles)
  self.player = Player(gameData, playerInput)
  self.player.spawn = {x = 0, y = 0}
  self.gameData = gameData
  self.projectiles = projectiles
  self.bodies = Bodies()
  self.collider = CollisionSystem()
  self.projectiles:setCollider(self.collider)
  self.bodies:setCollider(self.collider)  
  self.flocks = {}
  
  self.playerInput = playerInput -- temporary
  
  self.collider:createCollisionObject(self.player, self.player.radius)
end

function World:aitestcode()
  self.flocks[1] = World.make["Flock"]({}, 1/100, 50, 1/10)
end

function World:respawnPlayer()
  self.player.loc.x = self.player.spawn.x
  self.player.loc.y = self.player.spawn.y
  if self.player.isDead then
    self.gameData:decrementLives()
    self.player:respawn()
  end
end

function World:loadLevel(xLevelFileName)
  local level = dofile(xLevelFileName)
  local layers = self:getLayers(level)  
  self:unload()
  self:aitestcode()
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
  if self.player.isDead then
    self:respawnPlayer()
  end
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
  if type == "Warrior" then
      obj:setFlock(self.flocks[1])
      self.flocks[1]:addBoid(obj)
  end
  return obj
end

function World:makeProjectile(type, loc, dir)
  self.projectiles:add(type, loc, dir)
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
      self.player.spawn.x = x
      self.player.spawn.y = y      
      self:respawnPlayer()
    else
      self:makeBody(type, x, y, self.gameData, self.playerInput) -- playerInput and gameData args are temporary
    end
  end
end

return World
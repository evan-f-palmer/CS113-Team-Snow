local Class  = require('hump.class')
local Player = require('Player')
local CollisionSystem = require('CollisionSystem')
local Bodies = require('Bodies')

local World = Class{}
World.make = {
  Warrior  = require('Warrior'),
  Worker   = require('Worker'),
  Asteroid = require('Asteroid'),
  Sinistar = require('Asteroid'), -- temporary placeholder
  Flock    = require('Flock'),
}
World.levelScale = 15

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

end

function World:respawnPlayer()
  self.player.loc.x = self.player.spawn.x
  self.player.loc.y = self.player.spawn.y
  if self.player.isDead then
    self.gameData:decrementLives()
    self.player:respawn()
  end
  self.collider:createCollisionObject(self.player, self.player.radius)
end

function World:loadLevel(xLevelFileName)
  local level = dofile(xLevelFileName)  
  local layers = self:getLayers(level)  
  self:unload()
    
  self.width = level.width * level.tilewidth
  self.height = level.height * level.tileheight
  self.collider:setWidth(self.width * World.levelScale)
  self.collider:setHeight(self.height * World.levelScale)
  
  self:spawnAllFromAsType(layers["Asteroid"], "Asteroid")
  self:spawnSquads(layers["Squad"])
  self:respawnPlayer()
end

function World:unload()
  self.projectiles:clear()
  self.bodies:clear()
  if self.collider:isHandling(self.player) then
    self.collider:removeObject(self.player)
  end
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

function World:translateX(x)
  return (x - (self.width/2)) * World.levelScale
end

function World:translateY(y)
  return (y - (self.height/2)) * World.levelScale
end

function World:spawnAllFromAsType(xSpawnLayer, xType)
  for k, obj in pairs(xSpawnLayer.objects) do
    local x, y = self:translateX(obj.x), self:translateY(obj.y)
    local body = self:makeBody(xType, x, y, self.gameData)
  end
end

function World:spawnSquads(xSquadLayer)  
  for k, obj in pairs(xSquadLayer.objects) do
    local flock = World.make["Flock"]({}, 1/100, 50, 1/10)
    
    local numWorkers = obj.properties["Workers"] or 0
    for i = 1, numWorkers do
      local x, y = self:translateX(obj.x + i), self:translateY(obj.y + i)
      local body = self:makeBody("Worker", x, y, self.gameData)
      body:setFlock(flock)
      flock:addBoid(body)
    end
    
    local numWarriors = obj.properties["Warriors"] or 0
    for i = 1, numWarriors do
      local x, y = self:translateX(obj.x + i), self:translateY(obj.y + i)
      local body = self:makeBody("Warrior", x, y, self.gameData)
      body:setFlock(flock)
      flock:addBoid(body)
    end
    table.insert(self.flocks, flock)
  end
end

return World
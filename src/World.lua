local Class  = require('hump.class')
local CollisionSystem = require('CollisionSystem')
local Bodies = require('Bodies')
local SoundSystem = require('SoundSystem')

local World = Class{}
World.make = {
  Player   = require('Player'),
  Warrior  = require('Warrior'),
  Worker   = require('Worker'),
  Asteroid = require('Asteroid'),
  Sinistar = require('Sinistar'),
  Flock    = require('Flock'),
  SinistarConstruction = require('SinistarConstruction'),
  Explosion = require('Explosion')
}
World.levelScale = 15
World.collider = CollisionSystem()
World.DEFAULT_GET_NEIGHBORS = function() return {} end
World.DEAFULT_RESPAWN_TIME = 5.0

function World:init(playerInput, gameData, projectiles)
  self.gameData = gameData
  self.projectiles = projectiles
  self.bodies = Bodies()
  self.projectiles:setCollider(self.collider)
  self.bodies:setCollider(self.collider)  
  self.playerInput = playerInput
  self.flocks = {}
  self.bodyAdditionQueue = {}
  self.playerX = 0
  self.playerY = 0
  self.soundSystem = SoundSystem()
end

function World:setPlayerSpawnAtOrigin()
  self.playerX = 0
  self.playerY = 0
end

function World:loadLevel(xLevelFileName)
  local level = dofile(xLevelFileName)  
  local layers = self:getLayers(level)  
  self:unload()
    
  self.width = (level.width * level.tilewidth * World.levelScale)
  self.height = (level.height * level.tileheight * World.levelScale)
  self.collider:setWidth(self.width)
  self.collider:setHeight(self.height)
  
  self.flocks = {}
  self.bodyAdditionQueue = {}
  
  self:spawnAllFromAsType(layers["Asteroid"], "Asteroid")
  self:spawnSquads(layers["Squad"])
  self:spawnPlayer()
  self.sinstar =  self:makeBody("SinistarConstruction", 0, 1000, self.gameData, self)
  self.soundSystem:playMusic("music/Closet_Face_128.ogg", 0.3)
  
  self:createRequestedBodies()
end

function World:unload()
  self.projectiles:clear()
  self.bodies:clear()
end

function World:update(dt)
  self:createRequestedBodies()
  self:respawnFlocks(dt)
  self:updateAllWorldObjects(dt)  
  self:moveAllWorldObjects(dt)
  self.collider:update()
  if self.player then
    self.playerX = self.player.loc.x
    self.playerY = self.player.loc.y
  end
end

function World:spawnPlayer()
  self.player = self:makeBody("Player", self.playerX, self.playerY, self.gameData, self.playerInput, self)
end

function World:makeBody(type, x, y, ...)
  local class = self.make[type]
  local obj = class(...)
  obj.loc.x = x
  obj.loc.y = y
  obj.getNeighbors = self.DEFAULT_GET_NEIGHBORS
  self:requestBody(obj)
  return obj
end

function World:makeProjectile(type, loc, dir)
  self.projectiles:add(type, loc, dir)
end

function World:getByID(id)
  return self.bodies:getByID(id)
end

function World:respawnFlocks(dt)
  for k, flock in pairs(self.flocks) do
    if flock.respawnStep and (#flock.missingTypes > 0) then
      flock:respawnStep(dt)
    end
  end
end

-- private
function World:requestBody(xBody)
  table.insert(self.bodyAdditionQueue, xBody)
end

-- private
function World:createRequestedBodies()
  while #self.bodyAdditionQueue > 0 do
    local bodyToAdd = table.remove(self.bodyAdditionQueue)
    self.bodies:add(bodyToAdd)
  end
end

-- private
function World:updateAllWorldObjects(dt)
  self.projectiles:update(dt)
  self.bodies:update(dt)
end

-- private
local function move(xBody, dt)
  local vel = (xBody.vel) * (dt)
  xBody.loc:add_inplace(vel)
end

-- private
function World:moveAllWorldObjects(dt)
  self.projectiles:foreachdo(move, dt)
  self.bodies:foreachdo(move, dt)
end

-- private
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

-- private
function World:translateX(x)
  return (x - (self.width/World.levelScale/2)) * World.levelScale
end

-- private
function World:translateY(y)
  return (y - (self.height/World.levelScale/2)) * World.levelScale
end

-- private
function World:spawnAllFromAsType(xSpawnLayer, xType)
  for k, obj in pairs(xSpawnLayer.objects) do
    local x, y = self:translateX(obj.x), self:translateY(obj.y)
    local body = self:makeBody(xType, x, y, self.gameData, self)
  end
end

-- private
function World:spawnSquads(xSquadLayer)  
  for k, obj in pairs(xSquadLayer.objects) do
    local flock = World.make["Flock"]({}, 100, 5, 1/10)
    
    local numWorkers = obj.properties["Workers"] or 0
    for i = 1, numWorkers do
      local x, y = self:translateX(obj.x), self:translateY(obj.y)
      local body = self:makeBody("Worker", x, y, self.gameData, self)
      body:setFlock(flock)
      flock:addBoid(body)
    end
    
    local numWarriors = obj.properties["Warriors"] or 0
    for i = 1, numWarriors do
      local x, y = self:translateX(obj.x), self:translateY(obj.y)
      local body = self:makeBody("Warrior", x, y, self.gameData, self)
      body:setFlock(flock)
      flock:addBoid(body)
    end
    
    local respawnTime = tonumber(obj.properties["Respawn Period"]) or World.DEAFULT_RESPAWN_TIME
    
    local respawnTimer = 0
    flock.respawnStep = function(flock, dt)
      respawnTimer = respawnTimer + dt
      if respawnTimer >= respawnTime then
        local type = flock:claimRespawn()
        local body = self:makeBody(type, obj.x, obj.y, self.gameData, self)
        body:setFlock(flock)
        flock:addBoid(body)
        respawnTimer = 0
      end
    end
    
    table.insert(self.flocks, flock)
  end
end

return World
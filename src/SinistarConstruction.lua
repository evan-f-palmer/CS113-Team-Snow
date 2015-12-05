local Class  = require('hump.class')
local Vector = require('hump.vector')
local Boid   = require('Boid')
local Heap   = require('Heap')
local Combat = require('Combat')
local EntityParams = require('EntityParams')
local SoundSystem = require('SoundSystem')
local Animator = require('Animator')
local AlertMachine = require('AlertMachine')
local Probability = require('Probability')
local Sinistar = require('Sinistar')

local SinistarConstruction = Class{__includes = Boid}
SinistarConstruction.type = "Sinistar Construction"
SinistarConstruction.radius = EntityParams.sinistar.radius

local HALF_WAY_COMPLETED_ALERT  = {message = "[Sinistar Construction Half Complete]", lifespan = 3, priority = 1}
local ALMOST_COMPLETED_ALERT  = {message = "[Sinistar Construction Almost Complete]", lifespan = 3, priority = 2}
local COMPLETED_ALERT = {message = "[Sinistar Construction Completed]", lifespan = 3, priority = 3}

local ANIMATOR = Animator()

SinistarConstruction.render = {
  image = love.graphics.newImage("assets/sinistar.png"),
  color = {50,200,200},
  shouldRotate = false,
}

function SinistarConstruction:init(gameData, world)
  self.gameData = gameData
  self.world = world
  
  Boid.init(self, 1, 1)
  self.render = SinistarConstruction.render
  
  self.id = "Sinistar Construction"

  self.soundSystem = SoundSystem()  
  self.alertMachine = AlertMachine()
  self.hasAlertedHalfWay = false
  self.hasAlertedAlmostComplete = false
end

function SinistarConstruction:update(dt)
  Boid.update(self, dt)
  self.isDead = false
  
  if self.gameData:getSinistarCompletionPercentage() >= 0.5 and not self.hasAlertedHalfWay then
    self.alertMachine:set(HALF_WAY_COMPLETED_ALERT)
    self.hasAlertedHalfWay = true
  elseif self.gameData:getSinistarCompletionPercentage() >= 0.85 and not self.hasAlertedAlmostComplete then
    self.alertMachine:set(ALMOST_COMPLETED_ALERT)
    self.hasAlertedAlmostComplete = true
  elseif self.gameData:shouldSinistarBeCompleted() then
    self.alertMachine:set(COMPLETED_ALERT)
    self.isDead = true
  end
end

function SinistarConstruction:onDeath()
  self.world:makeBody("Sinistar", self.loc.x, self.loc.y, self.gameData, self.world)
end

function SinistarConstruction:onCollision(other)
  local type = other.type
  
  if type == "Worker Bullet" then
    other.isDead = true
  end
  
  if type == "Player Bullet" then
    other.isDead = true
  end
  
  if type == "Sinibomb" then
    other.isDead = true
  end

  if type == "Crystal" then
    self.gameData:incrementSinistarCrystals()
    other.isDead = true
  end
end

return SinistarConstruction
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

SinistarConstruction.images = {
  love.graphics.newImage("assets/sinistar/sinistar1.png"),
  love.graphics.newImage("assets/sinistar/sinistar2.png"),
  love.graphics.newImage("assets/sinistar/sinistar3.png"),
  love.graphics.newImage("assets/sinistar/sinistar4.png"),
  love.graphics.newImage("assets/sinistar/sinistar5.png"),
  love.graphics.newImage("assets/sinistar/sinistar6.png"),
  love.graphics.newImage("assets/sinistar/sinistar7.png"),
  love.graphics.newImage("assets/sinistar/sinistar8.png"),
}

SinistarConstruction.render = {
  image = SinistarConstruction.images[1],
  color = {127,127,127,127},
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
  local p = self.gameData:getSinistarCompletionPercentage()
  if p < 0.20 then
    self.render.image = SinistarConstruction.images[1]
  elseif p >= 0.20 and p < 0.37  then
    self.render.image = SinistarConstruction.images[2]
  elseif p >= 0.37 and p < 0.5 then
    self.render.image = SinistarConstruction.images[3]
  elseif p >= 0.5 and p < 0.62 then
    self.alertMachine:set(HALF_WAY_COMPLETED_ALERT)
    self.render.image = SinistarConstruction.images[4]
    self.hasAlertedHalfWay = true
  elseif p >= 0.62 and p < 0.75 then
    self.render.image = SinistarConstruction.images[5]
  elseif p >= 0.75 and p < 0.85 then
    self.render.image = SinistarConstruction.images[6]  
  elseif p >= 0.85 and p < 0.9 then
    self.alertMachine:set(ALMOST_COMPLETED_ALERT)
    self.hasAlertedAlmostComplete = true
    self.render.image = SinistarConstruction.images[7]  
  elseif p >= 0.90 and p < 1.00 then
    self.render.image = SinistarConstruction.images[8]
  elseif self.gameData:shouldSinistarBeCompleted() then
    self.alertMachine:set(COMPLETED_ALERT)
    self.soundSystem:play("sound/Beware_I_Live.ogg",0.5)
    self.soundSystem:playMusic("music/You_Can_Not_Believe_It.ogg", 0.7)
    self.isDead = true
  end
end

function SinistarConstruction:onDeath()
  self.world.sinistar = self.world:makeBody("Sinistar", self.loc.x, self.loc.y, self.gameData, self.world)
end

function SinistarConstruction:onCollision(other)
  local type = other.type
  
  if type == "Worker Bullet" then
    other.isDead = true
  end

  if type == "Crystal" then
    self.gameData:incrementSinistarCrystals()
    other.isDead = true
  end
end

return SinistarConstruction
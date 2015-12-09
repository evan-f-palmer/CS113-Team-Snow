local Class  = require('hump.class')
local Vector = require('hump.vector')
local SoundSystem = require('SoundSystem')
local Animator = require('Animator')
local animator = Animator()
local soundSystem = SoundSystem()
local Explosion = Class{}

function Explosion:init(name)
  self.ttl = 0.9
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.type = name
  self.render = {
    animation = animator:newAnimation("Explosion", (self.ttl + 0.1) * 4),
  }
  soundSystem:play("sound/explosion.wav", 0.5)    
  
  self.render.animation:start()
end

function Explosion:update(dt)
  self.ttl = self.ttl - dt
  
  if self.ttl <= 0 then
    self.isDead = true
  end
end

return Explosion
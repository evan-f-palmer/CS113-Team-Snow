local Class  = require('hump.class')
local Singleton = require('Singleton')

local Animator = Class {}
local PLAYING = "Playing"
local PAUSED = "Paused"

function Animator:init()
  self.definitions = {}
  self.animationPrivate = {}
  self.animationInstances = 0
end

function Animator:define(id, frames)
  self.definitions[id] = frames
end

-- Returns an animation which has functions {"start", "stop", "reset", "delete", "isAnimating", "runtime"} and member variable "image"
function Animator:newAnimation(definitionID, fps)
  local animation = {}
  animation.image = nil

  local private = {
    fps = fps,
    definition = self.definitions[definitionID],
    animation = animation,
    state = PAUSED,
    timer = 0,
  }
  
  local instanceID = self:newID()
  self.animationPrivate[instanceID] = private
  self:updateFrame(private)

  animation.delete = function() self.animationPrivate[instanceID] = nil; end
  animation.start = function() private.state = PLAYING; end
  animation.stop  = function() private.state = PAUSED; end
  animation.reset = function() private.timer = 0; end  
  animation.isAnimating = function() return (private.state == PLAYING); end
  animation.runtime = function() return private.timer; end
 
  return animation
end

function Animator:update(dt)
  for instanceID, private in pairs(self.animationPrivate) do
    if private and (private.state == PLAYING) then
      self:updateFrame(private)
      private.timer = (private.timer + dt)
    end
  end
end

-- private
function Animator:updateFrame(animationPrivate)
  local zeroBasedFrameNumber = math.floor(animationPrivate.timer / (1/animationPrivate.fps)) -- avoids division by zero
  local definition = animationPrivate.definition
  local frameNumber = (zeroBasedFrameNumber % #definition) + 1
  animationPrivate.animation.image = definition[frameNumber]
end

-- private
function Animator:newID()
  local instanceID = self.animationInstances
  self.animationInstances = self.animationInstances + 1
  return instanceID
end

return Singleton(Animator)
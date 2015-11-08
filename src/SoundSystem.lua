local Class = require('hump.class')
local Singleton = require('Singleton')

local SoundSystem = Class{}

function SoundSystem:init()
  self.musicSources = {}
  self.soundSources = {}
  self.status = {}
end

function SoundSystem:play(xSoundFileName)
  if not self.soundSources[xSoundFileName] then
    self:load(xSoundFileName)
  end
  local src = self.soundSources[xSoundFileName]
  love.audio.play(src)
  self.status[xSoundFileName] = "Playing"
end

function SoundSystem:playMusic(xMusicFileName)
  if not self.musicSources[xMusicFileName] then
    self:loadMusic(xMusicFileName)
  end
  local src = self.musicSources[xMusicFileName]
  love.audio.play(src)
  self.status[xMusicFileName] = "Playing"
end

function SoundSystem:getStateOf(xFileName)
  if not self.status[xFileName] then return "None" end
  local src = self.musicSources[xFileName] or self.soundSources[xFileName]
  if src:isStopped() then self.status[xFileName] = "Stopped" end
  return self.status[xFileName]
end

function SoundSystem:load(xSoundFileName)
  local sound = love.audio.newSource(xSoundFileName, "static")
  self.soundSources[xSoundFileName] = sound
end

function SoundSystem:loadMusic(xMusicFileName)
  local music = love.audio.newSource(xMusicFileName, "stream")
  self.musicSources[xMusicFileName] = music
end

function SoundSystem:pause(xFileName)
  if self.status[xFileName] == "Playing" then
    local src = self.musicSources[xFileName] or self.soundSources[xFileName]
    love.audio.pause(src)
    self.status[xFileName] = "Paused"
  end
end

function SoundSystem:resume(xFileName)
  if self.status[xFileName] == "Paused" then
    local src = self.musicSources[xFileName] or self.soundSources[xFileName]
    love.audio.resume(src)
    self.status[xFileName] = "Playing"
  end
end

function SoundSystem:rewind(xFileName)
  local src = self.musicSources[xFileName] or self.soundSources[xFileName]
  love.audio.rewind(src)
end

function SoundSystem:stop(xFileName)
  if self.status[xFileName] == "Playing" then
    local src = self.musicSources[xFileName] or self.soundSources[xFileName]
    love.audio.stop(src)
    self.status[xFileName] = "Stopped"
  end
end

function SoundSystem:loop(xFileName)
  local src = self.musicSources[xFileName] or self.soundSources[xFileName]
  src:setLooping(true)
end

return Singleton(SoundSystem)
local Class        = require('hump.class')
local SoundSystem  = require('SoundSystem')

local GameMenu = Class{}

local musicFile = "music/TheFatRat-Dancing-Naked.mp3"

function GameMenu:init()
  self.isOpen = false

  self.soundSystem = SoundSystem()
  self.soundSystem:loadMusic(musicFile)
  self.soundSystem:loop(musicFile)
end

function GameMenu:open()
  self.isOpen = true
  self.soundSystem:playMusic(musicFile)
end

function GameMenu:close()
  self.isOpen = false
  self.soundSystem:stop(musicFile)
end

function GameMenu:update(dt)  
  if self.isOpen then

  end
end

function GameMenu:draw()
  love.graphics.setBackgroundColor(0,0,0,0)
  love.window.showMessageBox("HEY", "Press X to quit", 'info', true)  
  
  --love.graphics.setColor(255, 255, 255)
  --love.graphics.rectangle('fill',0,0,love.window.getWidth(),love.window.getHeight())
end

return Game
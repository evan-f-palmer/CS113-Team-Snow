local Class        = require('hump.class')
local SoundSystem  = require('SoundSystem')

local GameMenu = Class{}
GameMenu.defaultMusicFile = "music/TheFatRat-Dancing-Naked.mp3"

function GameMenu:init(xDef)
  self.contexts  = xDef.contexts
  self.layout    = xDef.layout
  self.buttons   = xDef.buttons
  self.musicFile = xDef.musicFile or self.defaultMusicFile
  
  self.soundSystem = SoundSystem()
  self.soundSystem:loadMusic(self.musicFile)
  self.soundSystem:loop(self.musicFile)
end

function GameMenu:onOpen()
  self.soundSystem:playMusic(self.musicFile)
  -- load buttons and cursor collision bodies
end

function GameMenu:onClose()
  self.soundSystem:stop(self.musicFile)
  -- unload buttons and cursor collision bodies
end

function GameMenu:update(dt)  
  local selection
  local newContext
  
  -- choose "selection" via button logic here
  
  if selection then
    self:onClose()
    newContext = self.contexts[selection]
    if newContext.onOpen then
      newContext:onOpen()
    end
  end
  
  return newContext or self
end

function GameMenu:draw()
  love.graphics.setBackgroundColor(0,0,0,0)
-- draw buttons and cursor  
end

return GameMenu
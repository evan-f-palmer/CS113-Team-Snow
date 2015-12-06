local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()
local Blinker = require('Blinker')
local blinker = Blinker()
local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE, GRAY = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE, Palette.GRAY
local DIMWHITE = {WHITE[1], WHITE[2], WHITE[3], 127}
local DIMGRAY = {GRAY[1], GRAY[2], GRAY[3], 127}
local SOLIDWHITE = {WHITE[1], WHITE[2], WHITE[3], 255}
local SOLIDGRAY = {GRAY[1], GRAY[2], GRAY[3], 255}
local HUDLayout = require("HUDLayout")
local FontParams = require('FontParams')

local GameOverScreen = {}
GameOverScreen.lifetime = 0
GameOverScreen.layout = HUDLayout

function GameOverScreen:load()
  self.background = love.graphics.newImage("assets/screens/HUD1.JPG")
  self.lifetime = 0
  self.currentKey = ' '
  self.username = ''
end

function GameOverScreen:unload()
  self.background = nil
end

function GameOverScreen:update(dt)
  blinker:update(dt)
  self.lifetime = self.lifetime + dt
  if (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    if self.currentKey == 'OK' and (#self.username > 0) then
      local f = assert(io.open('src/scores/history', 'a'))
      f:write('{name = \'' .. self.username .. '\', score = ' .. self.game.data.score .. '}, ')
      f:close()
      return self.transition
    else
      if self.currentKey == 'DEL' then
        self.username = self.username:sub(1, #self.username-1)
      elseif self.currentKey ~= 'OK' then
        self.username = self.username .. self.currentKey
      end
      self.lifetime = 0
      return GameOverScreen
    end
  else
    return GameOverScreen
  end
end

function GameOverScreen:draw()
  local width, height = love.graphics.getDimensions()
  
  love.graphics.setColor(255,255,255)
  graphics:drawFullscreen(self.background)
 
  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("Game Over", width*(1/2), height*(1/16))
  local x, y = width*(1/2)-width*(1/8), height*(3/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)  
 
  graphics:centeredText("Score:" , width*(13/32), height*(4/32))
  graphics:centeredText("" .. self.game.data.score , width*(19/32), height*(4/32))
  
  love.graphics.setColor(WHITE[1], WHITE[2], WHITE[3], WHITE[4])  
  x, y = width*(1/2)-width*(1/8), height*(30/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
  local color = blinker:blink(WHITE, DIMWHITE)
  love.graphics.setColor(color[1],color[2],color[3],color[4])
  local message = (#self.username > 0) and "Click OK to Accept Name" or "Click Wheel to Enter Name"
  graphics:centeredText(message, width*(1/2), height*(31/32))
    
  self:drawKeyboardPalette()
  
  love.graphics.setColor(RED[1],RED[2],RED[3],RED[4])
  graphics:centeredText(self.currentKey, width*(1/2), height*(1/2) - FontParams.FONT_SIZE)
  love.graphics.setColor(BLUE[1],BLUE[2],BLUE[3],BLUE[4])
  graphics:centeredText(self.username, width*(1/2), height*(1/2))
end

local keysorder = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 
  '!', '?', '#', ' ', 
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 
  'DEL', 'OK',
}
local keyoffset = -FontParams.FONT_SIZE
local selectorOffset = FontParams.FONT_SIZE/2
local viewportscale = (11/16)
local centerCircleScale = (37/64)
local backgroundTrimColor = DIMWHITE
local textColor       = WHITE
local selectorColor   = RED
local foregroundColor = SOLIDWHITE
function GameOverScreen:drawKeyboardPalette()
  local sectorlength = math.pi / (#keysorder)
  local tx, ty = self:getMouseOffsetRelativeToCenter(self.layout.viewport.x, self.layout.viewport.y)
  local mouseAngle = math.atan2(ty, tx)
  local selectedIndex = math.floor((mouseAngle-(sectorlength)+math.pi)/(2*math.pi) * (#keysorder)) - math.floor(#keysorder/2)
  selectedIndex = selectedIndex % (#keysorder) + 1
  local selectedKey = keysorder[selectedIndex]
  
  self.currentKey = selectedKey
  
  local angle1, angle2 = mouseAngle - sectorlength, mouseAngle + sectorlength
  love.graphics.setColor(unpack(selectorColor))
  love.graphics.arc("fill", self.layout.viewport.x, self.layout.viewport.y, self.layout.viewport.r * viewportscale + selectorOffset, angle1, angle2, 3)  
  
  for i, key in ipairs(keysorder) do
    local angle = (2*math.pi) * (i/(#keysorder))
    local angle1, angle2 = angle - sectorlength, angle + sectorlength
        
    love.graphics.setColor(backgroundTrimColor[1], backgroundTrimColor[2], backgroundTrimColor[3], backgroundTrimColor[4])
    love.graphics.arc("line", self.layout.viewport.x, self.layout.viewport.y, self.layout.viewport.r * viewportscale, angle1, angle2, 3)
    
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4])
    graphics:centeredText(key, self.layout.viewport.x + math.cos(angle)*(self.layout.viewport.r * viewportscale + keyoffset),
                               self.layout.viewport.y + math.sin(angle)*(self.layout.viewport.r * viewportscale + keyoffset))
  end
  
  love.graphics.setColor(unpack(foregroundColor))
  love.graphics.circle("fill", self.layout.viewport.x, self.layout.viewport.y, self.layout.viewport.r * centerCircleScale)
end

function GameOverScreen:getMouseOffsetRelativeToCenter(x, y)
  local centerX, centerY = x, y
  local mouseX, mouseY = love.mouse.getPosition()
  return -(centerX - mouseX), -(centerY - mouseY)
end

return GameOverScreen
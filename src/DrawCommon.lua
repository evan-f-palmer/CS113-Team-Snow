local Class  = require('hump.class')
local Vector = require('hump.vector')
local Blinker = require('Blinker')
local Singleton = require('Singleton')

local DrawCommon = Class {}

DrawCommon.UP_VECTOR = Vector(0, 1)
DrawCommon.FONT_FILE = nil
DrawCommon.FONT_SIZE = 12

function DrawCommon:init()
  self.blinker = Blinker()
  self.blinker:setPeriod(1)  
  
  self.font = love.graphics.newFont(DrawCommon.FONT_FILE, DrawCommon.FONT_SIZE)
  love.graphics.setFont(self.font)
end

function DrawCommon:drawRotatedImage(image, x, y, angle)  
  local centerX = x + image:getWidth()/2
  local centerY = y + image:getHeight()/2
  self:BEGIN_ROTATE_ABOUT_POINT_AT_ANGLE(centerX, centerY, angle)
    love.graphics.draw(image, x, y)
  self:END()
end

function DrawCommon:BEGIN_SCREENSPACE(xCamera)
  love.graphics.push()
  love.graphics.translate(xCamera.x, xCamera.y)
  love.graphics.scale(1 / xCamera.scale, 1 / xCamera.scale)
  love.graphics.translate(-xCamera.x, -xCamera.y)
end

function DrawCommon:BEGIN_ROTATE_ABOUT_POINT_AT_ANGLE(centerX, centerY, angle)
  love.graphics.push()
  love.graphics.translate(centerX, centerY)
  love.graphics.rotate(angle)
  love.graphics.translate(-centerX, -centerY)
end

function DrawCommon:END()
  love.graphics.pop()
end

function DrawCommon:getAngle(xVec)
  return math.pi - DrawCommon.UP_VECTOR:angleTo(xVec)
end

function DrawCommon:drawDebugInfo(xInfo, xLoc, yLoc)
  local yOffset = (DrawCommon.FONT_SIZE)
  for key, infoData in pairs(xInfo) do
    if infoData then
      if type(infoData) == 'boolean' then
        love.graphics.print(key, xLoc, yLoc)
      else
        local toPrint = key .. ':' .. tostring(infoData)
        love.graphics.print(toPrint, xLoc, yLoc)
      end
      yLoc = yLoc + yOffset
    end
  end
end

return Singleton(DrawCommon)
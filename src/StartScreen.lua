local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()
local Blinker = require('Blinker')
local blinker = Blinker()
local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE
local DIMWHITE = {WHITE[1], WHITE[2], WHITE[3], 127}

local StartScreen = {}
StartScreen.lifetime = 0

function StartScreen:load()
  self.logo = love.graphics.newImage("assets/screens/logo.JPG")
  self.lifetime = 0
end

function StartScreen:unload()
  self.logo = nil
end

function StartScreen:update(dt)
  blinker:update(dt)
  self.lifetime = self.lifetime + dt
  if (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    return self.transition
  else
    return StartScreen
  end
end

function StartScreen:draw()
  local width, height = love.graphics.getDimensions()

  love.graphics.setColor(255,255,255)
  graphics:drawFullscreen(self.logo)

  love.graphics.setColor(WHITE[1], WHITE[2], WHITE[3], WHITE[4])  
  local x, y = width*(1/2)-width*(1/8), height*(3/4)-height*(1/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
  local color = blinker:blink(WHITE, DIMWHITE)
  love.graphics.setColor(color[1],color[2],color[3],color[4])
  graphics:centeredText("Click Mouse to Start", width*(1/2), height*(3/4))
end

return StartScreen
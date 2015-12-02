local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()
local Blinker = require('Blinker')
local blinker = Blinker()
local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE
local DIMWHITE = {WHITE[1], WHITE[2], WHITE[3], 127}

local ScoresScreen = {}
ScoresScreen.lifetime = 0

function ScoresScreen:load()
  self.background = love.graphics.newImage("assets/screens/HUD1.JPG")
  self.lifetime = 0
end

function ScoresScreen:unload()
  self.background = nil
end

function ScoresScreen:update(dt)
  blinker:update(dt)
  self.lifetime = self.lifetime + dt
  if (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    return self.transition
  else
    return ScoresScreen
  end
end

function ScoresScreen:draw()
  local width, height = love.graphics.getDimensions()
  
  love.graphics.setColor(unpack(DIMWHITE))
  graphics:drawFullscreen(self.background)

  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("Game Paused", width*(1/2), height*(5/16))
  local x, y = width*(1/2)-width*(1/8), height*(11/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)  
  
  love.graphics.setColor(WHITE[1], WHITE[2], WHITE[3], WHITE[4])  
  x, y = width*(1/2)-width*(1/8), height*(21/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
  local color = blinker:blink(WHITE, DIMWHITE)
  love.graphics.setColor(color[1],color[2],color[3],color[4])
  graphics:centeredText("Click Mouse to Resume", width*(1/2), height*(11/16))
  
  love.graphics.setColor(255,255,255)
  self.game.hud:drawPartial(self.game.data)
end

return ScoresScreen
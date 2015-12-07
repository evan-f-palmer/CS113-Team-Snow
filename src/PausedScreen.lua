local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()
local Blinker = require('Blinker')
local blinker = Blinker()
local Palette = require('Palette')
local Colorer = require('Colorer')
local colorer = Colorer()

local WHITE = Palette.WHITE
local DIMWHITE = {WHITE[1], WHITE[2], WHITE[3], 127}

local PausedScreen = {}
PausedScreen.lifetime = 0

function PausedScreen:load()
  self.background = love.graphics.newImage("assets/screens/HUD1.JPG")
  self.lifetime = 0
  self.game.hud:setActor(self.game.world:getByID("Player"))
end

function PausedScreen:unload()
  self.background = nil
  self.game.hud:setActor(nil)
end

function PausedScreen:update(dt)
  blinker:update(dt)
  self.lifetime = self.lifetime + dt

  if love.keyboard.isDown('escape') and self.lifetime > 0.25 then    
    return self.esc
  elseif (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    return self.transition
  else
    return PausedScreen
  end
end

function PausedScreen:draw()
  local width, height = love.graphics.getDimensions()
  
  local color = colorer:getCurrentAlertColor()
  love.graphics.setColor(color[1], color[2], color[3])
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
  self.game.hud:draw(self.game.data)
end

return PausedScreen
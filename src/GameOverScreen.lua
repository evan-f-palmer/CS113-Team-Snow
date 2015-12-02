local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()

local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE

local GameOverScreen = {}
GameOverScreen.lifetime = 0

function GameOverScreen:load()
  self.background = love.graphics.newImage("assets/screens/face.JPG")
  self.lifetime = 0
end

function GameOverScreen:unload()
  self.background = nil
end

function GameOverScreen:update(dt)
  self.lifetime = self.lifetime + dt
  if (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    return self.transition
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
 
  graphics:centeredText("Score:" , width*(13/32), height*(5/32))
  graphics:centeredText("" .. self.game.data.score , width*(19/32), height*(5/32))
 
  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("Click Mouse to Enter High Score", width*(1/2), height*(31/32))
  x, y = width*(1/2)-width*(1/8), height*(30/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
end

return GameOverScreen
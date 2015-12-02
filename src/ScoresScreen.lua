local background = love.graphics.newImage("assets/screens/fancy.JPG")
local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()

local ScoresScreen = {}
ScoresScreen.lifetime = 0

function ScoresScreen:update(dt)
  self.lifetime = self.lifetime + dt
  if (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    self.lifetime = 0
    return self.transition
  else
    return ScoresScreen
  end
end

function ScoresScreen:draw()
  local width, height = love.graphics.getDimensions()
  
  love.graphics.setColor(255,255,255)
  graphics:drawFullscreen(background)
  
  love.graphics.setColor(255,255,255)
  
  graphics:centeredText("High Scores", width*(1/2), height*(1/16))
  local x, y = width*(1/2)-width*(1/8), height*(3/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
  
  graphics:centeredText("Click Mouse to Play", width*(1/2), height*(31/32))
  x, y = width*(1/2)-width*(1/8), height*(30/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
end

return ScoresScreen
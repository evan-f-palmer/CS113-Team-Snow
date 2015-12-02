local logo = love.graphics.newImage("assets/screens/logo.JPG")
local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()

local StartScreen = {}
StartScreen.lifetime = 0

function StartScreen:update(dt)
  self.lifetime = self.lifetime + dt
  if (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    self.lifetime = 0
    return self.transition
  else
    return StartScreen
  end
end

function StartScreen:draw()
  local width, height = love.graphics.getDimensions()

  love.graphics.setColor(255,255,255)
  graphics:drawFullscreen(logo)
  
  love.graphics.setColor(255,255,255)
  graphics:centeredText("Click Mouse to Start", width*(1/2), height*(3/4))
  local x, y = width*(1/2)-width*(1/8), height*(3/4)-height*(1/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
end

return StartScreen
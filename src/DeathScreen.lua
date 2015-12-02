local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()

local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE

local DeathScreen = {}
DeathScreen.lifetime = 0
DeathScreen.maxLifetime = 3

function DeathScreen:load()
  self.background = love.graphics.newImage("assets/screens/face.JPG")
  self.lifetime = 0
end

function DeathScreen:unload()
  self.background = nil
end

function DeathScreen:update(dt)
  self.lifetime = self.lifetime + dt
  if (self.lifetime > self.maxLifetime) or ((love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25) then
    return self.transition
  else
    return DeathScreen
  end
end

function DeathScreen:draw()
  local width, height = love.graphics.getDimensions()
  
  love.graphics.setColor(255,255,255,128)
  graphics:drawFullscreen(self.background)

  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("Dead", width*(1/2), height*(1/16))
  local x, y = width*(1/2)-width*(1/8), height*(3/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1) 
   
  graphics:centeredText("Lives:" , width*(13/32), height*(6/32))
  graphics:centeredText("" .. self.game.data.lives , width*(19/32), height*(6/32))
  graphics:centeredText("Score:" , width*(13/32), height*(9/32))
  graphics:centeredText("" .. self.game.data.score , width*(19/32), height*(9/32))  
   
  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("Respawning in " .. math.floor(self.maxLifetime - self.lifetime) .. " seconds", width*(1/2), height*(12/32))
  x, y = width*(1/2)-width*(1/8), height*(13/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1) 
end

return DeathScreen
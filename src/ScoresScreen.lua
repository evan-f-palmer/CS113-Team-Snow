local background = love.graphics.newImage("assets/screens/fancy.JPG")
local DrawCommon = require('DrawCommon')
local graphics = DrawCommon()

local Palette = require('Palette')
local RED, BLUE, GREEN, YELLOW, WHITE = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE

local ScoresScreen = {}
ScoresScreen.lifetime = 0

function ScoresScreen:load()
  local readscores = {
    {name = "Example", score = 0}, 
    {name = "Bob", score = 1000}, 
    {name = "Steve", score = 2000}, 
    {name = "Yeep", score = 0}, 
    {name = "Yarp", score = 0}, 
  }
  
  self.scores = {}
  local size = #readscores 
  if size > 10 then size = 10 end
  
  for i = 1, size do
    local highest = {name = "", score = 0, index = 1}
    for j, entry in ipairs(readscores) do
      if entry.score >= highest.score then
        highest = entry
        highest.index = j
      end
    end
    self.scores[i] = highest
    table.remove(readscores, highest.index)
  end
end

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
 
  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("Click Mouse to Play", width*(1/2), height*(31/32))
  local x, y = width*(1/2)-width*(1/8), height*(30/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)

  love.graphics.setColor(WHITE[1],WHITE[2],WHITE[3],WHITE[4])
  graphics:centeredText("High Scores", width*(1/2), height*(1/16))
  x, y = width*(1/2)-width*(1/8), height*(3/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)  
  self:drawScores()
  
  love.graphics.setColor(BLUE[1],BLUE[2],BLUE[3],BLUE[4])
  graphics:centeredText("High Scores", width*(1/2), height*(1/16))
  x, y = width*(1/2)-width*(1/8), height*(3/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)  
  self:drawScores()
end

function ScoresScreen:drawScores()
  local width, height = love.graphics.getDimensions()
  local y = height*(2/16)
  for i, entry in ipairs(self.scores) do
    local name, score = entry.name, entry.score
    graphics:centeredText(name, width*(13/32), y)
    graphics:centeredText(score, width*(19/32), y)
    y = y + height*(1/16)
  end
end

return ScoresScreen
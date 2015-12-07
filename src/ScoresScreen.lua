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
  self.background = love.graphics.newImage("assets/screens/fancy.JPG")
  self.lifetime = 0

  local f = assert(io.open('src/scores/history', 'r'))
  local filestring = f:read('*all')
  f:close()

  filestring = 'return {' .. filestring .. '}'
  local readscores = loadstring(filestring)()
  
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

function ScoresScreen:unload()
  self.background = nil
end

function ScoresScreen:update(dt)
  blinker:update(dt)
  self.lifetime = self.lifetime + dt
  
  if love.keyboard.isDown('escape') and self.lifetime > 0.25 then    
    return self.esc
  elseif (love.mouse.isDown('l') or love.mouse.isDown('r')) and self.lifetime > 0.25 then
    return self.transition
  else
    return ScoresScreen
  end
end

function ScoresScreen:draw()
  local width, height = love.graphics.getDimensions()
  
  love.graphics.setColor(255,255,255)
  graphics:drawFullscreen(self.background)
 
  love.graphics.setColor(WHITE[1], WHITE[2], WHITE[3], WHITE[4])  
  local x, y = width*(1/2)-width*(1/8), height*(30/32)
  love.graphics.rectangle("line", x, y, width*(1/4), 1)
  local color = blinker:blink(WHITE, DIMWHITE)
  love.graphics.setColor(color[1],color[2],color[3],color[4])
  graphics:centeredText("Click Mouse to Play", width*(1/2), height*(31/32))
 
  love.graphics.push()
  love.graphics.translate(width*(3/16), 0)

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
  
  love.graphics.pop()
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
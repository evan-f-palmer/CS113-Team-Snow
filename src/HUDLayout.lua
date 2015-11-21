local ViewportParams = require("ViewportParams")
local FontParams = require("FontParams")

local width, height = love.graphics.getDimensions()
local fontSize = FontParams.FONT_SIZE

return {
  lives  = { x = width * (1/5),  y = height * (11/12) },
  bombs  = { x = width * (4/5),  y = height * (11/12) },
  score  = { x = width * (1/2),  y = height * (1/12)  },
  health = { x = width * (3/10), y = height * (11/12) - (fontSize/2), w = width * (4/10), h = (fontSize)},
  alert  = { x = width * (1/2),  y = height * (5/6)   },
  viewport = ViewportParams,
}
local ViewportParams = require("ViewportParams")
local FontParams = require("FontParams")

local width, height = love.graphics.getDimensions()
local fontSize = FontParams.FONT_SIZE

return {
  lives  = { x = width * (8/40),  y = height * (43/48) },
  bombs  = { x = width * (31/40),  y = height * (42/48) },
  score  = { x = width * (1/2),  y = height * (1/12)  },
  health = { x = width * (3/10), y = height * (41/48) - (fontSize/2), w = width * (4/10), h = (fontSize)},
  alert  = { x = width * (1/2),  y = height * (38/48)   },
  viewport = ViewportParams,
}
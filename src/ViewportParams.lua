local width, height = love.graphics.getDimensions()

return {
  x = width * (1/2), 
  y = height * (1/2), 
  r = width * (1/4)
}
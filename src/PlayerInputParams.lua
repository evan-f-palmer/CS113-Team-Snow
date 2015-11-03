local width, height = love.graphics.getDimensions()

return {
  directionalJoystick = {
    x = width/2,
    y = height/2,
    minR = 0,
    maxR = math.huge,
  },
  movementJoystick = {
    x = width/2,
    y = height/2,
    minR = 50,
    maxR = math.huge,
  },
}
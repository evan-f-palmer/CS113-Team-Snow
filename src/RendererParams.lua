local ViewportParams = require("ViewportParams")

return {
  captureRadius = (ViewportParams.r + 50),
  radarRadius   = (ViewportParams.r * 3),
  cameraScale   = (1/3),
}
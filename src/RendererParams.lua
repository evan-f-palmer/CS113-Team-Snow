local ViewportParams = require("ViewportParams")

return {
  captureRadius = (ViewportParams.r + 50),
  radarRadius   = (ViewportParams.r * 3),
  cameraScale   = (11/48), --5/48 to see what the hell is going on with all the AI at once
  drawScale = {
    ["Worker Bullet"] = 1.3, 
    ["Player Bullet"] = 1.3, 
    ["Warrior Bullet"] = 2, 
    ["Asteroid"] = 1.4, 
    ["Crystal"] = 0.5, 
    ["Sinistar"] = 0.4,
    ["Sinistar Construction"] = 0.4,
    ["Sinibomb"] = 1.8, 
    ["Worker"] = 1.4, 
    ["Warrior"] = 3.0, 
    ["Player"] = 1.2, 
    ["Sinibomb Blast"] = 5,
  },
}
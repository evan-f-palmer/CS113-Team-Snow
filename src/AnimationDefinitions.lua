local Animator = require('Animator')

local animator = Animator()

animator:define("Sinibomb Explosion", {
  love.graphics.newImage("assets/explosion/explosion1.png"), 
  love.graphics.newImage("assets/explosion/explosion2.png"), 
  love.graphics.newImage("assets/explosion/explosion3.png")
})

animator:define("Explosion", {
  love.graphics.newImage("assets/explosion/explosion2frame1.png"), 
  love.graphics.newImage("assets/explosion/explosion2frame2.png"), 
  love.graphics.newImage("assets/explosion/explosion2frame3.png"), 
  love.graphics.newImage("assets/explosion/explosion2frame4.png"),   
})

local nolights = love.graphics.newImage("assets/warrior/warrior1.png")
animator:define("WarriorLights", {
  nolights, nolights, nolights, nolights, nolights, nolights,
  love.graphics.newImage("assets/warrior/warrior2.png"),
  love.graphics.newImage("assets/warrior/warrior3.png"),
  love.graphics.newImage("assets/warrior/warrior4.png"),
  love.graphics.newImage("assets/warrior/warrior5.png"),
  love.graphics.newImage("assets/warrior/warrior6.png"),
  love.graphics.newImage("assets/warrior/warrior7.png"),
  love.graphics.newImage("assets/warrior/warrior8.png"),
})

animator:define("Sinistar", {
  love.graphics.newImage("assets/sinistar/sinistarMouthOpen.png"),
  love.graphics.newImage("assets/sinistar/sinistarMouthClosed.png"),
})


local EntityParams = require('EntityParams')
local Projectiles  = require('Projectiles')
local Animator = require('Animator')
local Combat = require('Combat')
local SoundSystem = require('SoundSystem')

local combat = Combat()
combat:addWeapon("Sinibomb Detonator", {ammo = math.huge, projectileID = "Sinibomb Blast", debounceTime = 0})

local soundSystem = SoundSystem()
local sinibombDeath = function(sinibomb)
  combat:fire("Sinibomb Detonator", sinibomb.loc, sinibomb.dir)
  soundSystem:play("sound/sinibombExplosion.wav", 1)
end
local sinibombCollision = function(sinibomb, other)
  if other.type == "Sinibomb Blast" then
    sinibomb.isDead = true
  end
end

local animator = Animator()
local sinibombBlastAnimation = animator:newAnimation("Sinibomb Explosion", 3)
sinibombBlastAnimation.start()
  
local projectiles = Projectiles()
projectiles:define("Player Bullet", {
  shouldRotate = true, 
  image = love.graphics.newImage("assets/projectiles/projectile1.png"), 
  color = {0,180,50}, 
  speed = EntityParams.playerBullet.speed, 
  lifespan = EntityParams.playerBullet.lifespan, 
  radius = EntityParams.playerBullet.radius
})
projectiles:define("Sinibomb", {
  shouldRotate = true, 
  image = love.graphics.newImage("assets/projectiles/projectile4.png"), 
  speed = EntityParams.sinibomb.speed, 
  lifespan = EntityParams.sinibomb.lifespan, 
  radius = EntityParams.sinibomb.radius, 
  onDeath = sinibombDeath, 
  onCollision = sinibombCollision
})
projectiles:define("Sinibomb Blast", {
  shouldRotate = false, 
  animation = sinibombBlastAnimation, 
  speed = EntityParams.sinibombBlast.speed, 
  lifespan = EntityParams.sinibombBlast.lifespan, 
  radius = EntityParams.sinibombBlast.radius
})
projectiles:define("Worker Bullet", {
  shouldRotate = true, 
  image = love.graphics.newImage("assets/projectiles/projectile3.png"), 
  color = {195,145,40}, 
  speed = EntityParams.workerBullet.speed, 
  lifespan = EntityParams.workerBullet.lifespan, 
  radius = EntityParams.workerBullet.radius
}) 
projectiles:define("Warrior Bullet", {
  shouldRotate = true, 
  image = love.graphics.newImage("assets/projectiles/projectile6.png"), 
  color = {200,100,0}, 
  speed = EntityParams.warriorBullet.speed, 
  lifespan = EntityParams.warriorBullet.lifespan, 
  radius = EntityParams.warriorBullet.radius
})
projectiles:define("Crystal", {
  shouldRotate = true, 
  image = love.graphics.newImage("assets/crystal.png"), 
  speed = EntityParams.crystal.speed, 
  lifespan = EntityParams.crystal.lifespan, 
  radius = EntityParams.crystal.radius
}) 

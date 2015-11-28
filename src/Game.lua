local Class        = require('hump.class')
local World        = require('World')
local PlayerInput  = require('EntityIOController')
local GameData     = require('GameData')
local Renderer     = require('Renderer')
local HUD          = require('HUD')
local AlertMachine = require('AlertMachine')
local Projectiles  = require('Projectiles')
local Combat       = require('Combat')
local SoundSystem  = require('SoundSystem')
local GameIOController = require('GameIOController')
local EntityParams = require('EntityParams')
local Animator = require('Animator')

local Game = Class{}

function Game:init()
  self.isPaused = false
  self.step = false

  self.projectiles    = Projectiles()
  self.data           = GameData()
  self.playerInput    = PlayerInput()
  self.world          = World(self.playerInput, self.data, self.projectiles)
  self.hud            = HUD()
  self.renderer       = Renderer()
  self.alertMachine   = AlertMachine()
  self.combat         = Combat()
  self.combat:setProjectiles(self.projectiles)
  self.soundSystem = SoundSystem()
  self.animator = Animator()
  
  self.gameInput = GameIOController(self)
  
  --self.soundSystem:playMusic("music/TheFatRat-Dancing-Naked.mp3")
  self.soundSystem:playMusic("music/Closet_Face_128.ogg", 0.3)
  
  self.projectiles = Projectiles()
  
  self.combat:addWeapon("Sinibomb Detonator", {ammo = math.huge, projectileID = "Sinibomb Blast", debounceTime = 0})
  local sinibombDeath = function(sinibomb)
    self.combat:fire("Sinibomb Detonator", sinibomb.loc, sinibomb.dir)
    self.soundSystem:play("sound/sinibombExplosion.wav", 1)
  end
  local sinibombCollision = function(sinibomb, other)
    if other.type == "Sinibomb Blast" then
      sinibomb.isDead = true
    end
  end
  
  self.animator:define("Sinibomb Explosion", {love.graphics.newImage("assets/explosion/explosion1.png"), love.graphics.newImage("assets/explosion/explosion2.png"), love.graphics.newImage("assets/explosion/explosion3.png")})
  local sinibombBlastAnimation = self.animator:newAnimation("Sinibomb Explosion", 3)
  sinibombBlastAnimation.start()
  
  self.projectiles:define("Player Bullet", {shouldRotate = true, image = love.graphics.newImage("assets/projectiles/projectile1.png"), color = {0,180,50}, speed = EntityParams.playerBullet.speed, lifespan = EntityParams.playerBullet.lifespan, radius = EntityParams.playerBullet.radius})
  self.projectiles:define("Sinibomb", {shouldRotate = true, image = love.graphics.newImage("assets/projectiles/projectile4.png"), color = {255,255,255}, speed = EntityParams.sinibomb.speed, lifespan = EntityParams.sinibomb.lifespan, radius = EntityParams.sinibomb.radius, onDeath = sinibombDeath, onCollision = sinibombCollision})
  self.projectiles:define("Sinibomb Blast", {shouldRotate = false, animation = sinibombBlastAnimation, color = {255,255,255}, speed = EntityParams.sinibombBlast.speed, lifespan = EntityParams.sinibombBlast.lifespan, radius = EntityParams.sinibombBlast.radius})
  self.projectiles:define("Worker Bullet", {shouldRotate = true, image = love.graphics.newImage("assets/projectiles/projectile3.png"), color = {195,145,40}, speed = EntityParams.workerBullet.speed, lifespan = EntityParams.workerBullet.lifespan, radius = EntityParams.workerBullet.radius}) 
  self.projectiles:define("Warrior Bullet", {shouldRotate = true, image = love.graphics.newImage("assets/projectiles/projectile6.png"), color = {200,100,0}, speed = EntityParams.warriorBullet.speed, lifespan = EntityParams.warriorBullet.lifespan, radius = EntityParams.warriorBullet.radius})
  self.projectiles:define("Crystal", {shouldRotate = true, image = love.graphics.newImage("assets/crystal.png"), color = {50,120,220}, speed = EntityParams.crystal.speed, lifespan = EntityParams.crystal.lifespan, radius = EntityParams.crystal.radius}) 
  
  local levelFileName = "src/levels/testing2.lua"
  self.world:loadLevel(levelFileName)
  self.alertMachine:set({message = levelFileName, lifespan = 3})
  
  if not love.graphics.isSupported("canvas", "npot", "subtractive", "multicanvas") then
    love.window.showMessageBox("Sorry", "You do not meet the minimum system requirements to play this game.\nOpenGL 2.1+ or DirectX 9.0c+ required", 'info', true)
    love.event.quit()
  end
  
  if not love.graphics.isSupported("shader") then
    love.window.showMessageBox("", "Shaders not supported", 'info', true)
  end
end

function Game:update(dt)
  self.gameInput:update(dt)
  
  if (not self.isPaused) or self.step then
    self.step = false
    
    self.playerInput:update(dt)
    self.alertMachine:update(dt)
    self.combat:update(dt)
    self.world:update(dt)
    if self.data:isGameOver() then
      self.alertMachine:set({message = "Game Over", lifespan = 3})
    end
    self.data:updateAlertData(self.alertMachine)
    self.hud:update(dt)
  end
  
  self.animator:update(dt)
  
  return self
end

function Game:draw()
--  love.graphics.setBackgroundColor(1,1,1,0)
  
  self.renderer:draw(self.world)
  self.hud:draw(self.data)
end

return Game
local Class        = require('hump.class')
local World        = require('World')
local PlayerInput  = require('PlayerInput')
local GameData     = require('GameData')
local Renderer     = require('Renderer')
local HUD          = require('HUD')
local AlertMachine = require('AlertMachine')
local Projectiles  = require('Projectiles')
local Combat       = require('Combat')
local SoundSystem  = require('SoundSystem')

local Game = Class{}

function Game:init()
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
  
  self.alertMachine:set({message = "Hello World!", lifespan = 3})
 -- self.soundSystem:playMusic("music/TheFatRat-Dancing-Naked.mp3")
  
  self.projectiles = Projectiles()
  self.projectiles:define("Player Bullet", {shouldRotate = true, image = love.graphics.newImage("assets/temp/redLaserRay.png"), color = {0,180,50}, speed = 4200, lifespan = 5})
  self.projectiles:define("Sinibomb", {shouldRotate = true, image = love.graphics.newImage("assets/temp/redLaserRay.png"), color = {180,50,0}, speed = 5600, lifespan = 8, radius = 25})
  self.projectiles:define("Worker Bullet", {shouldRotate = true, image = love.graphics.newImage("assets/temp/redLaserRay.png"), color = {115,115,0}, speed = 3200, lifespan = 3}) 
  self.projectiles:define("Warrior Bullet", {shouldRotate = true, image = love.graphics.newImage("assets/temp/redLaserRay.png"), color = {200,100,0}, speed = 4600, lifespan = 5})
  self.projectiles:define("Crystal", {shouldRotate = true, image = love.graphics.newImage("assets/temp/redLaserRay.png"), color = {200,200,200}, speed = 180, lifespan = 13, radius = 30}) 
  
  self.world:loadLevel("src/levels/1.lua")
end

function Game:update(dt)
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

function Game:draw()
  love.graphics.setBackgroundColor(0,0,0,0)
  
  self.renderer:draw(self.world)
  self.hud:draw(self.data)
end

return Game
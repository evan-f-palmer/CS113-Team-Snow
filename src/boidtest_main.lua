local Vector = require('hump.vector')
local Boid = require('boid')
local Flock = require('flock')

local boids
local flock
local radius = 20
local segments = 6

local maxSpeed = 100
local maxForce = 10

local numBoids = 53

local maxSeparation = 1 / 10
local separationScale = 1000
local cohesionScale = 1 / 10

function love.load(arg)
  if arg[#arg] == '-debug' then require('mobdebug').start() end
  io.stdout:setvbuf('no')
  --love.window.setFullscreen(false)
  
  boids = {}
  
  for i = 1, numBoids do
    local min = 0
    local max = 500
    boids[i] = Boid(Vector(love.math.random( min, max), love.math.random( min, max )), maxSpeed, maxForce)
  end
  
  flock = Flock(boids, maxSeparation, separationScale, cohesionScale)
end

local function renderBoids()
  for _, boid in ipairs(boids) do
    love.graphics.circle("fill", boid.loc.x, boid.loc.y, radius, segments)
  end
end

local function updateBoidsAcc()
  local mouse = Vector(love.mouse.getPosition())
  for _, boid in ipairs(boids) do
    boid.acc = boid:seek(mouse)
  end
end

local function updateBoids(dt)
  for _, boid in ipairs(boids) do
    boid:update(dt)
  end
end
  
function love.update(dt)
  updateBoidsAcc()
  flock:update()
  updateBoids(dt)
end

function love.draw()
  love.graphics.setBackgroundColor(255,0,255,0)
  
  love.graphics.setColor(255,255,0)
  renderBoids()
  
  -- Draw mouse
  love.graphics.setColor(0,255,255)
  local x, y = love.mouse.getPosition()
  love.graphics.circle("fill", x, y, radius, segments)
  
  love.graphics.setColor(255,255,255)
end

function love.keypressed(key) 

end
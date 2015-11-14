local Class   = require("hump.class")
local Worker  = require("Worker")
local Warrior = require("Warrior")
local Flock   = require("Flock")

local Squad = Class{}

Squad.maxSeparation = 1 / 100
Squad.separationScale = 500
Squad.cohesionScale = 1 / 10

function Squad:init(numWorkers, numWarriors)
  self.boids   = {}
  
  for i = 1, numWorkers do
    self.boids[#self.boids + 1] = Worker()
  end
  
   for i = 1, numWarriors do
    self.boids[#self.boids + 1] = Warrior(self)
  end

  self.flock = Flock(self.boids, Squad.maxSeparation, Squad.separationScale, Squad.cohesionScale)
end

function Squad:update(dt)
  for _, boid in pairs(self.boids) do
    boid:update(dt)
  end
end

function Squad:moveTo(x, y)
  for _, boid in self.boids do
    boid.loc.x = x
    boid.loc.y = y
  end
end

function Squad:updateAI()
  for _, boid in pairs(self.boids) do
    boid:updateAI()
  end
  self.flock:update()
end

return Squad
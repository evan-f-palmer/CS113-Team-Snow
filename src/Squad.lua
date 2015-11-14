local Class  = require("hump.class")
local Worker = require("Worker")
local Flock  = require("Flock")

local Squad = Class{}

Squad.maxSeparation = 1 / 1
Squad.separationScale = 10000
Squad.cohesionScale = 1 / 10

function Squad:init(numWorkers, numWariors, loc)
  self.boids   = {}
  
  for i = 1, numWorkers do
    self.boids[#self.boids + 1] = Worker(loc)
  end

  self.flock = Flock(self.boids, Squad.maxSeparation, Squad.separationScale, Squad.cohesionScale)
end

function Squad:update(dt)
  for _, boid in pairs(self.boids) do
    boid:update(dt)
  end
end

function Squad:updateAI()
  for _, boid in pairs(self.boids) do
    boid:updateAI()
  end
  self.flock:update()
end

return Squad
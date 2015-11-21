
return {
  player = {
    health = 100,
    maxSpeed = 1500,
    radius = 70,
    primaryFireOffset = 30,
    primaryFireDebounce = 0.1,
    secondaryFireDebounce = 1,
    secondaryMaxAmmo = 12,
    damageFrom = {
      sinistarCollision = 100,
      warriorBullet = 5,
      workerBullet = 1,
    },
    bombAmmoFromCrystalPickup = 1,
    healpersec = (1/3),
  },
  worker = {
    health = 40,
    radius = 70,
    sightRadius = 2000,
    maxSpeedScale = 0.9,
    maxForceScale = 1,
    fireDebounce = 5.6,
    closestProximity = 400,
    damageFrom = {
      playerBullet = 10,
      sinibomb = 10,
    }
  },
  warrior = {  
    health = 60,  
    radius = 70,
    primaryFireOffset = 20,
    sightRadius = 2000,
    maxSpeedScale = 0.5,
    maxForceScale = 1,
    maxDistanceFromFlock = 1000,
    fireDebounce = 3,
    closestProximity = 800,
    damageFrom = {
      playerBullet = 10,
      sinibomb = 10,
    }
  },
  playerBullet = {
    speed = 2200, lifespan = 3, radius = 4,
  },
  sinibomb = {
    speed = 100, lifespan = 5, radius = 25,
  },
  workerBullet = {
    speed = 1200, lifespan = 2, radius = 5,
  },
  warriorBullet = {
    speed = 1800, lifespan = 3, radius = 5,
  },
  crystal = {
    speed = 180, lifespan = 8, radius = 30,
  },
}
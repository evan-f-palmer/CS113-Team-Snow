
return {
  player = {
    health = 100,
    maxSpeed = 1750,
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
    maxSpeedScale = 1,
    maxForceScale = 1,
    fireDebounce = 5.6,
    closestProximity = 350,
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
    maxSpeedScale = 1,
    maxForceScale = 1,
    maxDistanceFromFlock = 1000,
    fireDebounce = 3,
    closestProximity = 700,
    damageFrom = {
      playerBullet = 10,
      sinibomb = 10,
    }
  },
}
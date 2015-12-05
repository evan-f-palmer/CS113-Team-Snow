
return {
  player = {
    health = 100,
    maxSpeed = 1750,
    radius = 65,
    primaryFireOffset = 30,
    primaryFireDebounce = 0.18,
    secondaryFireDebounce = 1,
    secondaryMaxAmmo = 20,
    damageFrom = {
      sinistarCollision = 100,
      warriorBullet = 10,
      workerBullet = 2.5,
      sinibombBlast = 0.1,
    },
    bombAmmoFromCrystalPickup = 1,
    healpersec = (1/3),
  },
  worker = {
    health = 80,
    radius = 80,
    sightRadius = 2000,
    maxSpeedScale = 1.95,
    maxForceScale = 1,
    fireDebounce = 0.7,
    closestProximity = 400,
    damageFrom = {
      playerBullet = 5,
      sinibomb = 15,
      sinibombBlast = 1000,
    }
  },
  warrior = {  
    health = 120,  
    radius = 120, -- 180 should fit width
    primaryFireOffset = 20,
    sightRadius = 1000,
    maxSpeedScale = 1.55,
    maxForceScale = 1.85,
    maxDistanceFromFlock = 20,
    fireDebounce = 1.5,
    closestProximity = 1000,
    damageFrom = {
      playerBullet = 5,
      sinibomb = 15,
      sinibombBlast = 1000,
    }
  },
  asteroid = {
    health = 180,
    radius = 120,
    crystals = 6,
    crystalDebounce = 2.25,
    fireOffset = 20,
    damageFrom = {
      playerBullet = 2,
      workerBullet = 1,
      warriorBullet = 0,
      sinibomb = 15,
      sinibombBlast = 1000,
    },
    crystalProductionProbabilityFor = {
      playerBullet = 0.08,
      workerBullet = 0.1,
      warriorBullet = 0,
    },
    excessiveDamageFrom = {
      playerBullet = 5,
    },
    excessiveDamageCrystalProductionProbabilityFor = {
      playerBullet = 0.5,
    }
  },
  sinistar = {
    health = 100,
    radius = 500,
    maxSpeedScale = 1.25,
    maxForceScale = 2,
    damageFrom = {
      playerBullet = 0,
      sinibomb = 10,
      sinibombBlast = 0,
    }
  },
  playerBullet = {
    speed = 2500, lifespan = 1.75, radius = 4,
  },
  sinibomb = {
    speed = 650, lifespan = 1.5, radius = 40,
  },
  sinibombBlast = {
    speed = 1, lifespan = 1, radius = 300,
  },
  workerBullet = {
    speed = 1300, lifespan = 2, radius = 5,
  },
  warriorBullet = {
    speed = 2200, lifespan = 3, radius = 5,
  },
  crystal = {
    speed = 180, lifespan = 8, radius = 45,
  },
}

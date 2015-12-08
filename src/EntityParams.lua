
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
      warriorBullet = 7.5,
      workerBullet = 2,
      sinibombBlast = 0.1,
    },
    bombAmmoFromCrystalPickup = 1,
    healpersec = (1/3),
    crystalPickupHealth = 1.5,
  },
  worker = {
    health = 25,
    radius = 80,
    sightRadius = 2000,
    maxSpeedScale = 1.6,
    maxForceScale = 0.5,
    fireDebounce = 0.7,
    closestProximity = 700,
    damageFrom = {
      playerBullet = 5,
      sinibomb = 15,
      sinibombBlast = 1000,
    },
    crystalPickupHealthToSinistar = 0.01,
  },
  warrior = {  
    health = 70,  
    radius = 120,
    sightRadius = 1300,
    maxSpeedScale = 1.40,
    maxForceScale = 0.65,
    maxDistanceFromFlock = 600,
    fireDebounce = 1.2,
    closestProximity = 1100,
    damageFrom = {
      playerBullet = 5,
      sinibomb = 15,
      sinibombBlast = 1000,
    }
  },
  asteroid = {
    health = 120,
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
      playerBullet = 0.3,
    }
  },
  sinistar = {
    health = 1000,
    radius = 230,
    damageFrom = {
      playerBullet = 0.0,
      sinibomb = 5,
      sinibombBlast = 1,
    },

    maxWanderingSpeedScale = 0.35,
    maxChargingSpeedScale = 1.4,
    maxChasingSpeedScale = 0.8,
    
    maxWanderingForceScale = 1.0,
    maxChargingForceScale = 1.2,
    maxChasingForceScale = 1.4,
    
    wanderingTime = 3.75,
    chargingTime = 1.5,
    chasingTime = 1.25,
  },
  playerBullet = {
    speed = 2775, lifespan = 1.55, radius = 4,
  },
  sinibomb = {
    speed = 700, lifespan = 1.5, radius = 40,
  },
  sinibombBlast = {
    speed = 1, lifespan = 1, radius = 300,
  },
  workerBullet = {
    speed = 2075, lifespan = 2, radius = 5,
  },
  warriorBullet = {
    speed = 2525, lifespan = 3, radius = 5,
  },
  crystal = {
    speed = 180, lifespan = 8, radius = 45,
  },
  asteroidFrag = {
    speed = 180, lifespan = 2, radius = 45,
  },
  explosion = {
    speed = 0, lifespan = 3, radius = 0.1,
  },
}

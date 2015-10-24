local Class  = require('hump.class')
local Vector = require('hump.vector')

local Player = Class{}

function Player:init(playerInput, playerGameData)
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.dir = Vector(0, 0)
  self.playerInput = playerInput
  self.playerGameData = playerGameData
  self.maxSpeed = 450
end

function Player:update(dt)
  if self.playerInput.primaryWeaponFire and self.canFirePrimaryWeapon() then
    self:firePrimaryWeapon()
  end
  
  if self.playerInput.secondaryWeaponFire and self.canFireSecondaryWeapon() then
    self:fireSecondaryWeapon()
  end

  self.dir = self.playerInput.directionVec
  
  self.vel = self.playerInput.movementVec
  self.vel:trim_inplace(self.maxSpeed)
  self.vel:scale_inplace(dt)
  
  self.loc:add_inplace(self.vel)
end

function Player:canFirePrimaryWeapon()
  return true --TODO
end

function Player:canFireSecondaryWeapon()
  return true --TODO
end

function Player:firePrimaryWeapon()
  print("Firing Primary Weapon")
  --TODO
end

function Player:fireSecondaryWeapon()
  if self.playerGameData.bombs > 0 then
    self.playerGameData.bombs = self.playerGameData.bombs - 1
    print("Firing Secondary Weapon")
  else
    print("No Secondary Weapon Remaining")
  end
  --TODO
end

return Player
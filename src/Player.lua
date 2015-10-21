local Class  = require('hump.class')
local Vector = require('hump.vector')

local Player = Class{}

function Player:init(playerInput)
  self.loc = Vector(0, 0)
  self.vel = Vector(0, 0)
  self.playerInput = playerInput
  self.maxSpeed = 100
end

function Player:update(dt)
  if self.playerInput.primaryWeaponFire and self.canFirePrimaryWeapon() then
    self:firePrimaryWeapon()
  end
  
  if self.playerInput.secondaryWeaponFire and self.canFireSecondaryWeapon() then
    self:fireSecondaryWeapon()
  end

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
  print("Firing Secondary Weapon")
  --TODO
end

return Player
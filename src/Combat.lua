local Class = require('hump.class')
local Singleton = require('Singleton')
local Projectiles = require('Projectiles')

local Combat = Class{}
Combat.DEFAULT_HEALTH = 100
Combat.DEFAULT_DAMAGE = 50
Combat.DEFAULT_AMMO = math.huge
Combat.DEFAULT_WEAPON_DEBOUNCE = 0
Combat.ONE_HUNDRED_PERCENT = 1
Combat.DEFAULT_PROJECTILE_ID = "Default Projectile"
Combat.ACTION_DISPATCH = {}
Combat.PROJECTILES = Projectiles()

function Combat:init()
  self.combatants = {}  
  self.weapons = {}
  self.actions = {}
end

function Combat:update(dt)
  while #self.actions > 0 do
    local action = table.remove(self.actions, 1)
    Combat.ACTION_DISPATCH[action.type](action)
  end
  
  self:chargeAllWeapons(dt)
end

function Combat:addCombatant(xCombatantID, xCombatantData)
  local combatant = xCombatantData or {}
  combatant.health = combatant.health or Combat.DEFAULT_HEALTH
  combatant.maxHealth = combatant.health
  self.combatants[xCombatantID] = combatant
end

function Combat:addWeapon(xWeaponID, xWeaponData)
  local weapon = xWeaponData or {}
  weapon.damage = weapon.damage or Combat.DEFAULT_DAMAGE
  weapon.ammo = weapon.ammo or Combat.DEFAULT_AMMO
  weapon.maxAmmo = weapon.maxAmmo or weapon.ammo
  weapon.debounceTime = weapon.debounceTime or Combat.DEFAULT_WEAPON_DEBOUNCE
  weapon.timer = 0
  weapon.projectileID = weapon.projectileID or Combat.DEFAULT_PROJECTILE_ID
  self.weapons[xWeaponID] = weapon
end

function Combat:attack(xDefenderCombatantID, xDamage)
  if not self:isDead(xDefenderCombatantID) then
    local combatant = self.combatants[xDefenderCombatantID]
    table.insert(self.actions, {type = "ATTACK", combatant = combatant, damage = xDamage})
  end
end

function Combat:heal(xHealingCombatantID, xAmount)
  if not self:isDead(xHealingCombatantID) then
    local combatant = self.combatants[xHealingCombatantID]
    table.insert(self.actions, {type = "HEAL", combatant = combatant, amount = xAmount})
  end
end

function Combat:fire(xWeaponID, xPosition, xDirection)
  if self:canFire(xWeaponID) then
    local weapon = self.weapons[xWeaponID]
    table.insert(self.actions, {type = "FIRE", weapon = weapon, pos = xPosition:clone(), dir = xDirection:clone()})
  end
end

function Combat:supplyAmmo(xToSupplyWeaponID, xAmount)
  local weapon = self.weapons[xToSupplyWeaponID]
  if weapon then
    table.insert(self.actions, {type = "SUPPLY_AMMO", weapon = weapon, amount = xAmount})
  end
end

function Combat:getHealth(xCombatantID)
  local combatant = self.combatants[xCombatantID] or {health = 0}
  return combatant.health
end

function Combat:getHealthPercent(xCombatantID)
  local combatant = self.combatants[xCombatantID] or {health = 0, maxHealth = Combat.DEFAULT_HEALTH}
  return (combatant.health / combatant.maxHealth)
end

function Combat:isDead(xCombatantID)
  return self:getHealth(xCombatantID) <= 0
end

function Combat:getAmmo(xWeaponID)
  local weapon = self.weapons[xWeaponID] or {ammo = 0}
  return weapon.ammo
end

function Combat:getAmmoPercent(xWeaponID)
  local weapon = self.weapons[xWeaponID] or {ammo = 0, maxAmmo = Combat.DEFAULT_AMMO}
  return (weapon.ammo / weapon.maxAmmo)
end

function Combat:isOutOfAmmo(xWeaponID)
  return self:getAmmo(xWeaponID) <= 0
end

function Combat:getRechargePercent(xWeaponID)
  local weapon = self.weapons[xWeaponID] or {timer = 0, debounceTime = Combat.DEFAULT_WEAPON_DEBOUNCE}
  return math.min((weapon.timer / weapon.debounceTime), Combat.ONE_HUNDRED_PERCENT)
end

function Combat:canFire(xWeaponID)
  return not self:isOutOfAmmo(xWeaponID) and self:getRechargePercent(xWeaponID) >= Combat.ONE_HUNDRED_PERCENT
end

function Combat:chargeAllWeapons(dt)
  for k, weapon in pairs(self.weapons) do
    weapon.timer = weapon.timer + dt
  end
end

Combat.ACTION_DISPATCH["FIRE"] = function(xFire)
  local newAmmo = xFire.weapon.ammo - 1
  xFire.weapon.ammo = newAmmo
  xFire.weapon.timer = 0
  Combat.PROJECTILES:addProjectile(xFire.weapon.projectileID, xFire.pos, xFire.dir)
end

Combat.ACTION_DISPATCH["ATTACK"] = function(xAttack)
  local newHealth = xAttack.combatant.health - xAttack.damage
  xAttack.combatant.health = math.max(newHealth, 0)
end

Combat.ACTION_DISPATCH["HEAL"] = function(xHeal)
  local newHealth = xHeal.combatant.health + xHeal.amount
  xHeal.combatant.health = math.min(newHealth, xHeal.combatant.maxHealth)
end

Combat.ACTION_DISPATCH["SUPPLY_AMMO"] = function(xSupplyAmmo)
  local newAmmo = xSupplyAmmo.weapon.ammo + xSupplyAmmo.amount
  xSupplyAmmo.weapon.ammo = math.min(newAmmo, xSupplyAmmo.weapon.maxAmmo)
end

return Singleton(Combat)
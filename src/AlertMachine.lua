local Class = require('hump.class')
local Singleton = require('Singleton')

local MESSAGE_PRIORITY = 1
local LOWEST_PRIORITY = 0
local LONGEST_LIFESPAN = math.huge
local ALWAYS_ACTIVE = function() return true end
local NULL_ALERT = { message = "", priority = LOWEST_PRIORITY, lifespan = LONGEST_LIFESPAN, isActive = ALWAYS_ACTIVE, }

--[[
  ALERT: {string message, num priority, time lifespan, func isActive}
  AlertMachine API:
    getPrimaryAlert() -> ALERT
    update(dt)
    set(ALERT)
]]--
local AlertMachine = Class{}

function AlertMachine:init()
  self.timeToLiveFor = {}
  self.alerts = {}
  self.primaryAlert = NULL_ALERT
  self.alertsInOrder = {}
end

function AlertMachine:getPrimaryAlert()
  return self.primaryAlert
end

function AlertMachine:update(dt)
  self:updateTimeToLiveForAlerts(dt)
  local currentPrimaryAlert = NULL_ALERT
    
  local toKill = {}
  for k, alert in pairs(self.alerts) do
    if self:isDead(alert) then
      table.insert(toKill, k)
    elseif alert.priority > currentPrimaryAlert.priority then
      currentPrimaryAlert = alert
    end
  end
  
  self.primaryAlert = currentPrimaryAlert
  self:cleanup(toKill)
  
  self.alertsInOrder = self:getAlertsInOrder()
end

local function alertID(xAlert)
  return tostring(xAlert)
end

function AlertMachine:set(xAlert)
  xAlert.priority = (xAlert.priority or MESSAGE_PRIORITY)
  xAlert.lifespan = (xAlert.lifespan or LONGEST_LIFESPAN)
  xAlert.isActive = (xAlert.isActive or ALWAYS_ACTIVE)
  local ID = alertID(xAlert)
  self.alerts[ID] = xAlert
  self.timeToLiveFor[ID] = xAlert.lifespan
end

function AlertMachine:isDead(xAlert)
  local ID = alertID(xAlert)
  return not xAlert:isActive() or self.timeToLiveFor[ID] <= 0
end

function AlertMachine:clear(xAlert)
  local ID = alertID(xAlert)
  self.timeToLiveFor[ID] = 0
end

function AlertMachine:updateTimeToLiveForAlerts(dt)
  for k, ttl in pairs(self.timeToLiveFor) do
    self.timeToLiveFor[k] = ttl - dt
  end
end

function AlertMachine:cleanup(toKill)
  for _, alertToRemoveKey in ipairs(toKill) do
    self.alerts[alertToRemoveKey] = nil
  end
end

function AlertMachine:alertsSort(A, B)
  if not A or not B then return end
  if A.priority == B.priority then
    local Aid, Bid = alertID(A), alertID(B)    
    return self.timeToLiveFor[Aid] < self.timeToLiveFor[Bid]
  else
    return A.priority >= B.priority
  end
end

function AlertMachine:getAlertsInOrder()
  local inOrder = {}
  for k, alert in pairs(self.alerts) do
    table.insert(inOrder, alert)
  end
  table.sort(inOrder, self.alertsSort)
  return inOrder
end

return Singleton(AlertMachine)
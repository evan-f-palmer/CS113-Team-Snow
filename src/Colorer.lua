local Class  = require('hump.class')
local Singleton = require('Singleton')
local Blinker = require('Blinker')
local AlertMachine = require('AlertMachine')
local Palette = require('Palette')

local RED, BLUE, GREEN, YELLOW, WHITE, GRAY = Palette.RED, Palette.BLUE, Palette.GREEN, Palette.YELLOW, Palette.WHITE, Palette.GRAY

local function SOLID(xColor)
  return {xColor[1], xColor[2], xColor[3], 255}
end
local function DIM(xColor)
  return {xColor[1]/2, xColor[2]/2, xColor[3]/2, 255}
end

local ALERT_PRIORITY_COLORS = {
  [0] = {SOLID(WHITE), DIM(WHITE)}, -- DEFAULT
  [1] = {SOLID(WHITE), DIM(WHITE)}, -- STANDARD MESSAGE
  [2] = {SOLID(YELLOW), DIM(YELLOW),}, -- MEDIUM PRIORITY
  [3] = {SOLID(RED), DIM(RED), SOLID(RED), DIM(RED),}, -- HIGH PRIORITY
  [4] = {SOLID(BLUE), DIM(BLUE)}, -- For Crystal Pickup
  [5] = {SOLID(GREEN), DIM(GREEN)}, -- Player Respawn Invincibility
  [6] = {SOLID(GREEN), SOLID(BLUE), SOLID(YELLOW), SOLID(RED)}, -- For Sinistar Kill
  [100] = {DIM(WHITE)}, -- DEBUG MESSAGES
}

local HUD_COLORS = {
  {50,200,200,125},
  {50,200,210,120},{50,200,220,115},{50,200,230,120},{50,208,240,125},{50,215,250,115},{50,224,240,110},
  {50,230,230,105},
  {50,240,224,110},{50,250,215,115},{50,240,208,100},{50,230,200,120},{50,220,200,115},{50,210,200,120},
}

local HEALTH_BAR_COLORS = { RED, YELLOW, GREEN, GREEN, GREEN}

local Colorer = Class {}
Colorer.RADAR_COLORS = {["Asteroid"] = GREEN, ["Crystal"] = BLUE, ["Worker"] = RED, ["Warrior"] = RED, ["Sinistar"] = YELLOW, ["Sinistar Construction"] = YELLOW, ["Player"] = WHITE}

function Colorer:init()
  self.blinker = Blinker()
  self.blinker:setPeriod(1)
  self.alertMachine = AlertMachine()
end

function Colorer:update(dt)
  self.blinker:update(dt)
end

function Colorer:getHeadsUpDisplayColor()
  return self.blinker:blink(unpack(HUD_COLORS))
end

function Colorer:getCurrentAlertColor()
  local primaryAlert = self.alertMachine:getPrimaryAlert()
  local alertPriority = primaryAlert.priority
  if primaryAlert.priority < 2 then
    return Palette.GRAY -- Palette.WHITE
  else
    return self:getAlertColor(alertPriority)
  end
end

function Colorer:getAlertColor(xAlertPriority)
  local priorityColors = ALERT_PRIORITY_COLORS[xAlertPriority] or ALERT_PRIORITY_COLORS[0]
  local alertColor = self.blinker:blink(unpack(priorityColors))
  return alertColor
end

function Colorer:getHealthBarColor(xHealthPercent)
  local zeroBasedIndex = math.floor((#HEALTH_BAR_COLORS-1) * xHealthPercent)  
  local index = zeroBasedIndex + 1    
  local color = HEALTH_BAR_COLORS[index] or HEALTH_BAR_COLORS[0]
  return color
end

function Colorer:getRadarColor(xType)
  return Colorer.RADAR_COLORS[xType]
end

return Singleton(Colorer)
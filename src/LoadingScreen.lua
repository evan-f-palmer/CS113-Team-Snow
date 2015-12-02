local Class        = require('hump.class')

local LoadingScreen = Class{}

function LoadingScreen:init()
  self.loader = function() return self end
end

function LoadingScreen:load()
  local nextContext = self.loader()
  return nextContext
end

function LoadingScreen:setLoader(xLoadFunction)
  self.loader = xLoadFunction
end

function LoadingScreen:setDrawer(xDrawFunction)
  self.drawer = xDrawFunction
end

function LoadingScreen:update()
  return self:load()
end

function LoadingScreen:draw()
  self:drawer()
end

return LoadingScreen

local function makeSingleton(xClass)
  local singletonInstance = xClass()
  local function fakeConstructor()
    return singletonInstance
  end
  return fakeConstructor
end

return makeSingleton
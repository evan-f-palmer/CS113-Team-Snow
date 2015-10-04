local _PACKAGE = ... and (...):match("^(.+)%.[^%.]+") and (...):match("^(.+)%.[^%.]+") .. '.' or ''

require (_PACKAGE .. 'subfolder.test')
local Class = require ('hump.class')

local Foo = Class {
  x,
}

function Foo:init(y)
  self.x = y
end

local bar = Foo(10)

print(bar.x)

print('Hello World')
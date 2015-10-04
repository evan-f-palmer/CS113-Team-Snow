local _PACKAGE = ... and (...):match("^(.+)%.[^%.]+") and (...):match("^(.+)%.[^%.]+") .. '.' or ''

require (_PACKAGE .. 'test2')

print('test')
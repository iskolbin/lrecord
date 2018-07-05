--[[

	record - v1.4.1 public domain immutable Records implementaion for Lua. All
	set/update operations yield new lua table with changed contents.

	author: Ilya Kolbin (iskolbin@gmail.com)
	url: github.com/iskolbin/lrecord

 COMPATIBILITY

 Lua 5.1, 5.2, 5.3, LuaJIT

 LICENSE

 See end of file for license information.

--]]

local Record = {}

local pairs, select, type = _G.pairs, _G.select, _G.type

local function copy( self )
	local obj = {}
	for k, v in pairs( self ) do
		obj[k] = v
	end
	return obj
end

local function make( default, partial )
	local obj = copy( default )
	if partial then
		for k, v in pairs( partial ) do
			local defaultv = default[k]
			if v ~= defaultv and type( defaultv ) == 'table' then
				obj[k] = make( defaultv, v )
			else
				obj[k] = v
			end
		end
	end
	return obj
end

Record.copy = copy

Record.make = make

local function makechanger( n, updater )
	local loadstring, concat = _G.loadstring or _G.load, table.concat
	local keys = {}
	for i = 1, n do keys[i] = 'k' .. i end
	local setters = {}
	for i = 1, n-1 do
		setters[i] = ([[
    c = {}; for k,w in pairs( o[k%d] ) do c[k] = w end; o[k%d] = c; o = c;]]):format( i, i, i )
	end
	return loadstring(([[
local pairs = _G.pairs
return function( t, %s, v )
  local oldv = t[%s]%s
  if oldv ~= v then
    local o, c = {}; for k,w in pairs( t ) do o[k] = w end
    t = o
%s
    o[%s] = %s
  end
  return t
end
]]):format( concat(keys,', '),
	concat(keys,']['),[[
  if oldv == nil then
    error( "Non existent value for key: " .. ]] .. concat(keys,'..":"..') .. [[ )
  end]],
	concat(setters,'\n'),
	keys[#keys],
	updater and 'v(o[' .. keys[#keys] .. '])' or 'v'))()
end

local function makesetter( updater )
	local setters = {[0]=function(t) return t end}
	return setters, function( t, ... )
		local n = select( '#', ... )-1
		local f = setters[n]
		if not f then
			f = makechanger( n, updater )
			setters[n] = f
		end
		return f( t, ... )
	end
end

Record.setters, Record.set = makesetter( false )

Record.updaters, Record.update = makesetter( true )

return Record

--[[
------------------------------------------------------------------------------
This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2018 Ilya Kolbin
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------
--]]

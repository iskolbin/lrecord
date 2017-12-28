--[[

	record - v1.3.3 public domain immutable Records implementaion for Lua. All
	set/update operations yield new lua table with changed contents.

	author: Ilya Kolbin (iskolbin@gmail.com)
	url: github.com/iskolbin/lrecord
	
  COMPATIBLITY

	Works with Lua 5.1+, LuaJIT

	LICENSE

	This software is dual-licensed to the public domain and under the following
	license: you are granted a perpetual, irrevocable license to copy, modify,
	publish, and distribute this file as you see fit.

--]]

local Record = {}

local error, pairs, select, type = _G.error, _G.pairs, _G.select, _G.type

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

local function makechanger( n, updater, allownil )
	local loadstring, concat = _G.loadstring or _G.load, table.concat
	local keys = {}
	for i = 1, n do keys[i] = 'k' .. i end
	local setters = {}
	for i = 1, n-1 do
		setters[i] = ([[
    c = {}; for k,w in pairs( o[k%d] ) do c[k] = w end; o[k%d] = c; o = o[k%d];]]):format( i, i, i )
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
	concat(keys,']['),
	allownil and '' or [[ 
  if oldv == nil then
    error( "Non existent value for key: " .. ]] .. concat(keys,'..":"..') .. [[ )
  end]], 
	concat(setters,'\n'),
	keys[#keys],
	updater and 'v(o[' .. keys[#keys] .. '])' or 'v'))()
end

local function makesetter( updater, allownil )
	return setmetatable( {}, { __call = function( self, t, ... )
		local n = select( '#', ... )-1
		local f = self[n]
		if not f then
			if n >= 1 then
				f = makechanger( n, updater, allownil )
				self[n] = f
			else
				return t
			end
		end
		return f( t, ... )
	end })
end

Record.set = makesetter( false, false )

Record.update = makesetter( true, false )

Record.put = makesetter( false, true )

return Record

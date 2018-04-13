--[[

	record - v1.4.0 public domain immutable Records implementaion for Lua. All
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

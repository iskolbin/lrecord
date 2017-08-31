--[[

	Record - v1.0.0 public domain immutable records implementaion for Lua. All
	set/update operations yield new lua table with changed contents. Somehow
	this is similar to FB Immutable Record, but far more simple.

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

local error, pairs, select = _G.error, _G.pairs, _G.select

function Record.make( default, partial )
	local obj = {}
	for k, v in pairs( default ) do
		obj[k] = v
	end
	if partial then
		for k, v in pairs( partial ) do
			if default[k] == nil then
				error(( 'Default record doesn\'t have %q field' ):format( tostring( k ))) 
			end
			obj[k] = v
		end
	end
	return obj
end

function Record.copy( self )
	local obj = {}
	for k, v in pairs( self ) do
		obj[k] = v
	end
	return obj
end

local copy = Record.copy

Record.error = error

function Record.set( self, ... )
	local n = select( '#', ... )
	if n > 1 then
		local obj = {}
		local currentObj, currentSelf = obj, self
		for i = 1, n-2 do
			currentObj = copy( currentSelf )
			currentSelf = currentSelf[select(i,...)]
		end
		local k, v = select(n-1,...)
		if currentSelf[k] == nil then
			Record.error(( 'Record doesn\'t have field %q'):format( k ))
		end
		currentObj[k] = v
		return obj
	else
		return self	
	end
end

function Record.set1( self, k, v )
	if self[k] ~= v then
		local obj = copy( self )
		if self[k] == nil then
			Record.error(( 'Record doesn\'t have field %q'):format( k ))
		end
		obj[k] = v
		return obj
	else
		return self
	end
end

function Record.set2( self, k1, k2, v )
	if self[k1][k2] ~= v then
		local obj = copy( self )
		obj[k1] = copy( self[k1] )
		if self[k1][k2] == nil then
			Record.error(( 'Record doesn\'t have field %q.%q'):format( k1, k2 ))
		end
		obj[k1][k2] = v
		return obj
	else
		return self
	end
end

function Record.set3( self, k1, k2, k3, v )
	if self[k1][k2][k3] ~= v then
		local obj = copy( self )
		obj[k1] = copy( self[k1] )
		obj[k1][k2] = copy( self[k1][k2] )
		if self[k1][k2][k3] == nil then
			Record.error(( 'Record doesn\'t have field %q.%q.%q'):format( k1, k2, k3 ))
		end
		obj[k1][k2][k3] = v
		return obj
	else
		return self
	end
end

function Record.update( self, ... )
	local n = select( '#', ... )
	if n > 1 then
		local obj = {}
		local currentObj, currentSelf = obj, self
		for i = 1, n-2 do
			currentObj = copy( currentSelf )
			currentSelf = currentSelf[select(i,...)]
		end
		local k, fn = select(n-1,...)
		if currentSelf[k] == nil then
			Record.error(( 'Record doesn\'t have field %q'):format( k ))
		end
		currentObj[k] = fn(currentSelf[k]) 
		return obj
	else
		return self	
	end
end

function Record.update1( self, k, fn )
	return Record.set1( self, k, fn( self[k] ))
end

function Record.update2( self, k1, k2, fn )
	return Record.set2( self, k1, k2, fn( self[k1][k2] ))
end

function Record.update3( self, k1, k2, k3, fn )
	return Record.set3( self, k1, k2, k3, fn( self[k1][k2][k3] ))
end

return Record

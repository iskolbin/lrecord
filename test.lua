local record = require('record')

local default = { x = 1, y = 2, z = { a = { b = 3, z = 4 }}}

local function equal( a, b )
	if a == b then
		return true
	elseif type( a ) == type( b ) then
		for k, v in pairs( a ) do
			if not equal( v, b[k] ) then
				return false
			end
		end
		for k, v in pairs( b ) do
			if not equal( v, a[k] ) then
				return false
			end
		end
		return true
	else
		return false
	end
end

local x = record.make( default )

assert( equal( x, default ))
assert( x ~= default )

assert( equal( record.set( x, 'z', 'a', 'b', 4 ), { x = 1, y = 2, z = { a = { b = 4, z = 4 }}} ))
assert( equal( record.set( x, 'x', 2 ), { x = 2, y = 2, z = { a = { b = 3, z = 4 }}} ))
assert( equal( record.set( x, 'z', 'a', {1,2,3}), { x = 1, y = 2, z = { a = {1,2,3}}}))
assert( equal( record.set( x, 'z', 'a', 'b', x.y), { x = 1, y = 2, z = { a = { b = 2, z = 4 }}} ))
assert( equal( record.copy( x ), x ))
assert( record.copy( x ) ~= x )
assert( equal( record.update( x, 'z', 'a', 'b', tostring ), { x = 1, y = 2, z = {a = { b = '3', z = 4 }}}))
assert( equal( record.update( x, 'z', function( v ) return v.a.b + 3 end ), { x = 1, y = 2, z = 6 }))
assert( equal( record.update( x, 'z', 'a', function( v ) return v.b end ), { x = 1, y = 2, z = { a = 3 }} ))
assert( equal( record.update( x, 'z', 'a', 'b', function( v ) return 'zxy' end ), { x = 1, y = 2, z = { a = { b = 'zxy', z = 4 }}}))

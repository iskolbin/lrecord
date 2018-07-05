local rec = require('record')
local tbl = { x = 5, y = { y = 6 }, z = { z = { z = 7 }}}

local function bench( s, f, n )
	local t = os.clock()
	for _ = 1, n do
		f()
	end
	print( s, n/(os.clock() - t),' op/sec')
end

bench( 'set ch', function() rec.set( tbl, 'x', 6 ) end, 1e6 )
bench( 'set1 ch', function() rec.setters[1]( tbl, 'x', 6 ) end, 1e6 )
bench( 'set nc', function() rec.set( tbl, 'x', 5 ) end, 1e6 )
bench( 'set1 nc', function() rec.setters[1]( tbl, 'x', 5 ) end, 1e6 )
print(2)
bench( 'set ch', function() rec.set( tbl, 'y', 'y', 7 ) end, 1e6 )
bench( 'set2 ch', function() rec.setters[2]( tbl, 'y', 'y', 7 ) end, 1e6 )
bench( 'set nc', function() rec.set( tbl, 'y', 'y', 6 ) end, 1e6 )
bench( 'set2 nc', function() rec.setters[2]( tbl, 'y', 'y', 6 ) end, 1e6 )
print(3)
bench( 'set ch', function() rec.set( tbl, 'z', 'z', 'z', 8 ) end, 1e6 )
bench( 'set3 ch', function() rec.setters[3]( tbl, 'z', 'z', 'z', 8 ) end, 1e6 )
bench( 'set nc', function() rec.set( tbl, 'z', 'z', 'z', 7 ) end, 1e6 )
bench( 'set3 nc', function() rec.setters[3]( tbl, 'z', 'z', 'z', 7 ) end, 1e6
)

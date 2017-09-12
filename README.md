Lua Record
==========

Lua helper library for immutable records

record.make( default, [partial] )
---------------------------------

Make new record from specified `default` table. If `partial` is specified then
override fields with provided values. Default table must be specified. Partial
table must contain fields which exist in default table

record.copy( record )
---------------------

Make shallow copy of the `record`. Internally uses `pairs` so it's not very
efficient for arrays

record.set( record, key1, [key2,key3,...], value )
--------------------------------------------------

Return new record with changed nested field 

record.set1( record, key, value )
---------------------------------

More efficient version of `set` for flat updates

record.set2( record, key1, key2, value )
----------------------------------------

More efficient version of `set` for single-nested updates

record.set3( record, key1, key2, key3, value )
----------------------------------------------

More efficient version of `set` for double-nested updates

record.update( record, key1, [key2,key3,...], fn )
--------------------------------------------------

Return new record with changed nested field which orignal value is passed to
`fn` function

record.update1( record, key, value )
------------------------------------

More efficient version of `update` for flat updates

record.update2( record, key1, key2, value )
-------------------------------------------

More efficient version of `updaet` for single-nested updates

record.update3( record, key1, key2, key3, value )
-------------------------------------------------

More efficient version of `update` for double-nested update

Error-handling
==============

If you try to `set`/`update` non-existing field `record.error` is
called which can be overriden

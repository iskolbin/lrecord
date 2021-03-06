[![Build Status](https://travis-ci.org/iskolbin/lrecord.svg?branch=master)](https://travis-ci.org/iskolbin/lrecord)
[![license](https://img.shields.io/badge/license-public%20domain-blue.svg)](http://unlicense.org/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

Lua Record
==========

Lua helper library for immutable records.


record.make( default, [partial] )
---------------------------------

Make new record from specified `default` table. If `partial` is specified then
override fields with provided values. Default table must be specified. Partial
table must contain fields which exist in default table.


record.copy( record )
---------------------

Make shallow copy of the `record`. Internally uses `pairs` so it's not very
efficient for arrays.


record.set( record, key1, [key2,key3,...], value )
--------------------------------------------------

Return new record with changed nested field, original value must exist.


record.update( record, key1, [key2,key3,...], fn )
--------------------------------------------------

Return new record with changed nested field which orignal value is passed to
`fn` function.

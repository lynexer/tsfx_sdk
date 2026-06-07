--[[
    ANCHOR: TSFX SDK - Table Tests
--]]

local expect = TestRunner.expect
local expectEqual = TestRunner.expectEqual

-- SECTION: Table.contains // ----------------------------------------

TestRunner.describe('TSFX.Table.contains')

expect('finds value in array', TSFX.Table.contains({ 1, 2, 3 }, 2))
expect('finds string value', TSFX.Table.contains({ 'a', 'b', 'c' }, 'b'))
expect('returns false when not found', not TSFX.Table.contains({ 1, 2, 3 }, 4))
expect('finds value in hash table', TSFX.Table.contains({ a = 1, b = 2 }, 2))
expect('returns false on empty table', not TSFX.Table.contains({}, 1))

-- !SECTION

-- SECTION: Table.count // ----------------------------------------

TestRunner.describe('TSFX.Table.count')

expectEqual('counts array entries', TSFX.Table.count({ 1, 2, 3 }), 3)
expectEqual('counts hash entries', TSFX.Table.count({ a = 1, b = 2 }), 2)
expectEqual('counts mixed entries', TSFX.Table.count({ 1, a = 2, b = 3 }), 3)
expectEqual('returns 0 for empty table', TSFX.Table.count({}), 0)

-- !SECTION

-- SECTION: Table.find // ----------------------------------------

TestRunner.describe('TSFX.Table.find')

local fVal, fKey = TSFX.Table.find({ 10, 20, 30 }, function(v) return v > 15 end)
expectEqual('find returns correct value', fVal, 20)
expectEqual('find returns correct key', fKey, 2)

local fVal2, fKey2 = TSFX.Table.find({ a = 1, b = 2, c = 3 }, function(v) return v == 2 end)
expectEqual('find works on hash table', fVal2, 2)
expectEqual('find returns hash key', fKey2, 'b')

local fNil, fNilKey = TSFX.Table.find({ 1, 2, 3 }, function(v) return v > 10 end)
expect('find returns nil value when not found', fNil == nil)
expect('find returns nil key when not found', fNilKey == nil)

-- !SECTION

-- SECTION: Table.filter // ----------------------------------------

TestRunner.describe('TSFX.Table.filter')

local filtered = TSFX.Table.filter({ 1, 2, 3, 4, 5 }, function(v) return v % 2 == 0 end)
expectEqual('filter returns correct count', #filtered, 2)
expectEqual('filter first result correct', filtered[1], 2)
expectEqual('filter second result correct', filtered[2], 4)

local filteredHash = TSFX.Table.filter({ a = 1, b = 2, c = 3 }, function(v) return v > 1 end)
expectEqual('filter on hash preserves keys', filteredHash.b, 2)
expectEqual('filter on hash preserves keys', filteredHash.c, 3)
expect('filter on hash excludes failing keys', not filteredHash.a)

local filteredEmpty = TSFX.Table.filter({ 1, 2, 3 }, function(v) return v > 10 end)
expectEqual('filter with no matches returns empty', #filteredEmpty, 0)

-- !SECTION

-- SECTION: Table.every // ----------------------------------------

TestRunner.describe('TSFX.Table.every')

expect('every returns true when all match', TSFX.Table.every({ 2, 4, 6 }, function(v) return v % 2 == 0 end))
expect('every returns false when one fails', not TSFX.Table.every({ 2, 3, 6 }, function(v) return v % 2 == 0 end))
expect('every returns true for empty table', TSFX.Table.every({}, function() return false end))

-- !SECTION

-- SECTION: Table.some // ----------------------------------------

TestRunner.describe('TSFX.Table.some')

expect('some returns true when one matches', TSFX.Table.some({ 1, 3, 4 }, function(v) return v % 2 == 0 end))
expect('some returns false when none match', not TSFX.Table.some({ 1, 3, 5 }, function(v) return v % 2 == 0 end))
expect('some returns false for empty table', not TSFX.Table.some({}, function() return true end))

-- !SECTION

-- SECTION: Table.map // ----------------------------------------

TestRunner.describe('TSFX.Table.map')

local mapped = TSFX.Table.map({ 1, 2, 3 }, function(v) return v * 2 end)
expectEqual('map doubles values correctly', mapped[1], 2)
expectEqual('map doubles values correctly', mapped[2], 4)
expectEqual('map doubles values correctly', mapped[3], 6)

local mappedHash = TSFX.Table.map({ a = 1, b = 2 }, function(v) return v + 10 end)
expectEqual('map preserves hash keys', mappedHash.a, 11)
expectEqual('map preserves hash keys', mappedHash.b, 12)

local mappedKey = TSFX.Table.map({ 'x', 'y' }, function(v, k) return k end)
expectEqual('map receives key as second arg', mappedKey[1], 1)
expectEqual('map receives key as second arg', mappedKey[2], 2)

-- !SECTION

-- SECTION: Table.reduce // ----------------------------------------

TestRunner.describe('TSFX.Table.reduce')

local sum = TSFX.Table.reduce({ 1, 2, 3, 4 }, function(acc, v) return acc + v end, 0)
expectEqual('reduce sums correctly', sum, 10)

local product = TSFX.Table.reduce({ 1, 2, 3, 4 }, function(acc, v) return acc * v end, 1)
expectEqual('reduce multiplies correctly', product, 24)

local initial = TSFX.Table.reduce({}, function(acc, v) return acc + v end, 99)
expectEqual('reduce returns initial for empty', initial, 99)

-- !SECTION

-- SECTION: Table.flatten // ----------------------------------------

TestRunner.describe('TSFX.Table.flatten')

local flat = TSFX.Table.flatten({ 1, { 2, 3 }, { 4, { 5 } } })
expectEqual('flatten depth 1 count', #flat, 4)
expectEqual('flatten depth 1 first', flat[1], 1)
expectEqual('flatten depth 1 second', flat[2], 2)
expectEqual('flatten depth 1 keeps nested table', type(flat[4]), 'table')

local flatDeep = TSFX.Table.flatten({ 1, { 2, { 3, { 4 } } } }, math.huge)
expectEqual('flatten full depth count', #flatDeep,  4)
expectEqual('flatten full depth last value', flatDeep[4], 4)

local flatAlready = TSFX.Table.flatten({ 1, 2, 3 })
expectEqual('flatten already flat table', #flatAlready, 3)

-- !SECTION

-- SECTION: Table.keys / Table.values // ----------------------------------------

TestRunner.describe('TSFX.Table.keys / values')

local keys = TSFX.Table.keys({ a = 1, b = 2, c = 3 })
expectEqual('keys returns correct count', #keys, 3)
expect('keys contains a', TSFX.Table.contains(keys, 'a'))
expect('keys contains b', TSFX.Table.contains(keys, 'b'))
expect('keys contains c', TSFX.Table.contains(keys, 'c'))

local vals = TSFX.Table.values({ a = 10, b = 20, c = 30 })
expectEqual('values returns correct count', #vals,  3)
expect('values contains 10', TSFX.Table.contains(vals, 10))
expect('values contains 20', TSFX.Table.contains(vals, 20))
expect('values contains 30', TSFX.Table.contains(vals, 30))

-- !SECTION

-- SECTION: Table.groupBy // ----------------------------------------

TestRunner.describe('TSFX.Table.groupBy')

local players = {
    { name = 'Alice', team = 'red'  },
    { name = 'Bob',   team = 'blue' },
    { name = 'Carol', team = 'red'  },
}
local grouped = TSFX.Table.groupBy(players, function(v) return v.team end)
expectEqual('groupBy red team count', #grouped.red, 2)
expectEqual('groupBy blue team count', #grouped.blue, 1)
expectEqual('groupBy red first player', grouped.red[1].name, 'Alice')
expectEqual('groupBy blue first player', grouped.blue[1].name, 'Bob')

local groupedEmpty = TSFX.Table.groupBy({}, function(v) return v end)
expectEqual('groupBy empty table is empty', TSFX.Table.count(groupedEmpty), 0)

-- !SECTION

-- SECTION: Table.unique // ----------------------------------------

TestRunner.describe('TSFX.Table.unique')

local uniq = TSFX.Table.unique({ 1, 2, 2, 3, 3, 3 })
expectEqual('unique removes duplicates', #uniq, 3)
expectEqual('unique preserves order first', uniq[1], 1)
expectEqual('unique preserves order second', uniq[2], 2)
expectEqual('unique preserves order third', uniq[3], 3)

local uniqStrings = TSFX.Table.unique({ 'a', 'b', 'a', 'c' })
expectEqual('unique works with strings', #uniqStrings, 3)

local uniqEmpty = TSFX.Table.unique({})
expectEqual('unique empty table stays empty', #uniqEmpty, 0)

-- !SECTION

-- SECTION: Table.reverse // ----------------------------------------

TestRunner.describe('TSFX.Table.reverse')

local rev = TSFX.Table.reverse({ 1, 2, 3, 4, 5 })
expectEqual('reverse first element', rev[1], 5)
expectEqual('reverse last element', rev[5], 1)
expectEqual('reverse middle element', rev[3], 3)

local revTwo = TSFX.Table.reverse({ 'a', 'b' })
expectEqual('reverse two elements', revTwo[1], 'b')
expectEqual('reverse two elements', revTwo[2], 'a')

local revOne = TSFX.Table.reverse({ 42 })
expectEqual('reverse single element unchanged', revOne[1], 42)

-- !SECTION

-- SECTION: Table.slice // ----------------------------------------

TestRunner.describe('TSFX.Table.slice')

local sliced = TSFX.Table.slice({ 1, 2, 3, 4, 5 }, 2, 4)
expectEqual('slice count correct', #sliced, 3)
expectEqual('slice first value', sliced[1], 2)
expectEqual('slice last value', sliced[3], 4)

local slicedFrom = TSFX.Table.slice({ 1, 2, 3, 4, 5 }, 3)
expectEqual('slice to end count', #slicedFrom, 3)
expectEqual('slice to end first value', slicedFrom[1], 3)

local slicedNeg = TSFX.Table.slice({ 1, 2, 3, 4, 5 }, -2)
expectEqual('negative from index count', #slicedNeg, 2)
expectEqual('negative from index first value', slicedNeg[1], 4)

local slicedNegTo = TSFX.Table.slice({ 1, 2, 3, 4, 5 }, 1, -2)
expectEqual('negative to index count', #slicedNegTo, 4)
expectEqual('negative to index last value', slicedNegTo[4], 4)

-- !SECTION

-- SECTION: Table.merge // ----------------------------------------

TestRunner.describe('TSFX.Table.merge')

local merged = TSFX.Table.merge({ a = 1, b = 2 }, { c = 3, d = 4 })
expectEqual('merge combines keys', merged.a, 1)
expectEqual('merge combines keys', merged.c, 3)
expectEqual('merge total key count', TSFX.Table.count(merged), 4)

local mergedOverwrite = TSFX.Table.merge({ a = 1, b = 2 }, { b = 99 })
expectEqual('merge last value wins on conflict', mergedOverwrite.b, 99)
expectEqual('merge non-conflicting key preserved', mergedOverwrite.a, 1)

local mergedThree = TSFX.Table.merge({ a = 1 }, { b = 2 }, { c = 3 })
expectEqual('merge three tables', TSFX.Table.count(mergedThree), 3)

-- !SECTION

-- SECTION: Table.deepCopy // ----------------------------------------

TestRunner.describe('TSFX.Table.deepCopy')

local original = { a = 1, b = { c = 2, d = { e = 3 } } }
local copy = TSFX.Table.deepCopy(original)

expectEqual('deepCopy top level value', copy.a, 1)
expectEqual('deepCopy nested value', copy.b.c, 2)
expectEqual('deepCopy deeply nested value', copy.b.d.e, 3)
expect('deepCopy nested table is not same ref', copy.b ~= original.b)
expect('deepCopy deep table is not same ref', copy.b.d ~= original.b.d)

copy.b.c = 99
expectEqual('mutating copy does not affect original', original.b.c, 2)

-- !SECTION

-- SECTION: Table.isEmpty // ----------------------------------------

TestRunner.describe('TSFX.Table.isEmpty')

expect('isEmpty returns true for empty table', TSFX.Table.isEmpty({}))
expect('isEmpty returns false for array', not TSFX.Table.isEmpty({ 1 }))
expect('isEmpty returns false for hash', not TSFX.Table.isEmpty({ a = 1 }))

-- !SECTION

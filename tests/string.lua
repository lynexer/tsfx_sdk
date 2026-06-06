--[[
    ANCHOR: TSFX SDK - String Tests
--]]

local expect = TestRunner.expect
local expectEqual = TestRunner.expectEqual
local expectMatch = TestRunner.expectMatch

-- SECTION: String.random // ----------------------------------------

TestRunner.describe('TSFX.String.random')

-- Output length
expectEqual('bare {u} produces 1 character', #TSFX.String.random('{u}'), 1)
expectEqual('{u:5} produces 5 characters', #TSFX.String.random('{u:5}'), 5)
expectEqual('{d:3}-{l:3} produces 7 characters', #TSFX.String.random('{d:3}-{l:3}'), 7)
expectEqual('literal-only pattern preserves length', #TSFX.String.random('HELLO!'), 6)

-- Token ranges
expectMatch('{d} produces a digit', TSFX.String.random('{d}'), '^%d$')
expectMatch('{u} produces uppercase', TSFX.String.random('{u}'), '^%u$')
expectMatch('{l} produces lowercase', TSFX.String.random('{l}'), '^%l$')
expectMatch('{a} produces a letter', TSFX.String.random('{a}'), '^%a$')
expectMatch('{n} produces alphanumeric', TSFX.String.random('{n}'), '^%w$')
expectMatch('{h} produces lowercase hex', TSFX.String.random('{h}'), '^[0-9a-f]$')
expectMatch('{H} produces uppercase hex', TSFX.String.random('{H}'), '^[0-9A-F]$')
expectMatch('{v} produces a vowel', TSFX.String.random('{v}'), '^[aeiou]$')
expectMatch('{c} produces a consonant', TSFX.String.random('{c}'), '^[bcdfghjklmnprstvwxyz]$')
expectMatch('{b} produces a binary digit', TSFX.String.random('{b}'), '^[01]$')

-- Count modifier
expectMatch('{u:3} produces 3 uppercase', TSFX.String.random('{u:3}'), '^%u%u%u$')
expectMatch('{d:4} produces 4 digits', TSFX.String.random('{d:4}'), '^%d%d%d%d$')
expectMatch('{h:6} produces 6 hex chars', TSFX.String.random('{h:6}'), '^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$')

-- Literals pass through
expectEqual('literal prefix preserved', TSFX.String.random('ID-{d:4}'):sub(1, 3), 'ID-')
expectEqual('{{ outputs literal brace', TSFX.String.random('{{test}'), '{test}')

-- Custom charset
local custom = TSFX.String.random('{x:6}', 'ABC')
expectMatch('{x} only uses charset chars', custom, '^[ABC][ABC][ABC][ABC][ABC][ABC]$')
expectEqual('{x:4} produces 4 characters', #TSFX.String.random('{x:4}', 'XYZ'), 4)

-- !SECTION

-- SECTION: String.splt // ----------------------------------------

TestRunner.describe('TSFX.String.splt')

local parts = TSFX.String.split('a,b,c', ',')
expectEqual('splits into correct number of parts', #parts, 3)
expectEqual('first part is correct', parts[1], 'a')
expectEqual('second part is correct', parts[2], 'b')
expectEqual('third part is correct', parts[3], 'c')

local single = TSFX.String.split('hello', ',')
expectEqual('no separator match returns whole string', #single, 1)
expectEqual('no separator match value is input', single[1], 'hello')

local limited = TSFX.String.split('a,b,c,d', ',', 2)
expectEqual('limit=2 produces 3 parts (2 splits + remainder)', #limited, 3)
expectEqual('remainder is unparsed tail', limited[3], 'c,d')

local plain = TSFX.String.split('a.b.c', '.', nil, true)
expectEqual('plain mode splits on literal dot', #plain, 3)
expectEqual('plain mode first part correct', plain[1], 'a')

local pattern = TSFX.String.split('a1b2c', '%d')
expectEqual('pattern separator splits correctly', #pattern, 3)
expectEqual('pattern split first part', pattern[1], 'a')

local empty = TSFX.String.split('', ',')
expectEqual('empty string returns one empty-string part', #empty, 1)
expectEqual('empty string part value is empty', empty[1], '')

-- !SECTION

-- SECTION: String.uuid // ----------------------------------------

TestRunner.describe('TSFX.String.uuid')

local uuid1 = TSFX.String.uuid()
local uuid2 = TSFX.String.uuid()

expectMatch('uuid matches RFC 4122 format', uuid1, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-4%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$')
expectMatch('version nibble is always 4', uuid1, '^........%-....%-4')
expectMatch('variant nibble is 8, 9, a, or b', uuid1, '^........%-....%-4...'  .. '%-[89ab]')
expectEqual('uuid is always 36 characters', #uuid1, 36)
expect('two uuids are not equal', uuid1 ~= uuid2)

-- !SECTION

-- SECTION: String.trim / trimStart / trimEnd // ----------------------------------------

TestRunner.describe('TSFX.String.trim / trimStart / trimEnd')

expectEqual('trim removes both sides', TSFX.String.trim('  hello  '), 'hello')
expectEqual('trim handles no whitespace', TSFX.String.trim('hello'), 'hello')
expectEqual('trim handles only whitespace', TSFX.String.trim('   '), '')
expectEqual('trimStart removes leading only', TSFX.String.trimStart('  hi  '), 'hi  ')
expectEqual('trimEnd removes trailing only', TSFX.String.trimEnd('  hi  '), '  hi')

-- !SECTION

-- SECTION: String.capitalize / toTitleCase // ----------------------------------------

TestRunner.describe('TSFX.String.capitalize / toTitleCase')

expectEqual('capitalize upcases first char', TSFX.String.capitalize('hello'), 'Hello')
expectEqual('capitalize leaves rest unchanged', TSFX.String.capitalize('hELLO'), 'HELLO')
expectEqual('capitalize handles empty string', TSFX.String.capitalize(''), '')
expectEqual('toTitleCase capitalises each word', TSFX.String.toTitleCase('hello world'), 'Hello World')
expectEqual('toTitleCase lowercases rest of word', TSFX.String.toTitleCase('hELLO wORLD'), 'Hello World')

-- !SECTION

-- SECTION: String.toSnakeCase / toCamelCase // ----------------------------------------

TestRunner.describe('TSFX.String.toSnakeCase / toCamelCase')

expectEqual('camelCase to snake_case', TSFX.String.toSnakeCase('helloWorld'), 'hello_world')
expectEqual('PascalCase to snake_case', TSFX.String.toSnakeCase('HelloWorld'), 'hello_world')
expectEqual('consecutive caps handled', TSFX.String.toSnakeCase('parseHTTPResponse'),'parse_http_response')
expectEqual('snake_case to camelCase', TSFX.String.toCamelCase('hello_world'), 'helloWorld')
expectEqual('multiple underscores to camel', TSFX.String.toCamelCase('one_two_three'), 'oneTwoThree')
expectEqual('already camel unchanged', TSFX.String.toCamelCase('helloWorld'), 'helloWorld')

-- !SECTION

-- SECTION: String.padStart / padEnd // ----------------------------------------

TestRunner.describe('TSFX.String.padStart / padEnd')

expectEqual('padStart pads with spaces', TSFX.String.padStart('5', 3), '  5')
expectEqual('padStart with custom char', TSFX.String.padStart('5', 3, '0'), '005')
expectEqual('padStart no-op when already long', TSFX.String.padStart('hello', 3), 'hello')
expectEqual('padEnd pads with spaces', TSFX.String.padEnd('hi', 5), 'hi   ')
expectEqual('padEnd with custom char', TSFX.String.padEnd('hi', 5, '-'), 'hi---')
expectEqual('padEnd no-op when already long', TSFX.String.padEnd('hello', 3), 'hello')

-- !SECTION

-- SECTION: String.startsWith / endsWith / includes // ----------------------------------------

TestRunner.describe('TSFX.String.startsWith / endsWith / includes')

expect('startsWith true case', TSFX.String.startsWith('fivem_sdk', 'fivem'))
expect('startsWith false case', not TSFX.String.startsWith('fivem_sdk', 'sdk'))
expect('startsWith empty prefix', TSFX.String.startsWith('hello', ''))
expect('endsWith true case', TSFX.String.endsWith('fivem_sdk', 'sdk'))
expect('endsWith false case', not TSFX.String.endsWith('fivem_sdk', 'fivem'))
expect('endsWith empty suffix', TSFX.String.endsWith('hello', ''))
expect('includes true case', TSFX.String.includes('hello world', 'world'))
expect('includes false case', not TSFX.String.includes('hello world', 'xyz'))
expect('includes treats no patterns', TSFX.String.includes('1+1=2', '+'))

-- !SECTION

-- SECTION: String.count // ----------------------------------------

TestRunner.describe('TSFX.String.count')

expectEqual('count pattern matches', TSFX.String.count('banana', 'a'), 3)
expectEqual('count plain matches', TSFX.String.count('a+b+c', '+', true), 2)
expectEqual('count no matches returns 0', TSFX.String.count('hello', 'z'), 0)
expectEqual('count pattern dot', TSFX.String.count('abc', '.'), 3)
expectEqual('count plain dot', TSFX.String.count('a.b.c', '.', true), 2)

-- !SECTION

-- SECTION: String.replaceAll // ----------------------------------------

TestRunner.describe('TSFX.String.replaceAll')

expectEqual('replaces all occurrences', TSFX.String.replaceAll('aabbaa', 'aa', 'x'), 'xbbx')
expectEqual('plain replacement, no pattern risk', TSFX.String.replaceAll('1+1=2', '+', 'plus'), '1plus1=2')
expectEqual('handles dot literally', TSFX.String.replaceAll('a.b.c', '.', '-'), 'a-b-c')
expectEqual('no match returns original', TSFX.String.replaceAll('hello', 'z', 'x'), 'hello')
expectEqual('replace with empty string', TSFX.String.replaceAll('hello', 'l', ''), 'heo')

-- !SECTION

-- SECTION: String.truncate // ----------------------------------------

TestRunner.describe('TSFX.String.truncate')

expectEqual('truncates and appends ellipsis', TSFX.String.truncate('hello world', 8), 'hello...')
expectEqual('no truncation when within limit', TSFX.String.truncate('hi', 10), 'hi')
expectEqual('exact length is not truncated', TSFX.String.truncate('hello', 5), 'hello')
expectEqual('custom ellipsis', TSFX.String.truncate('hello world', 8, '.'), 'hello w.')
expectEqual('truncate to very short length', TSFX.String.truncate('abcdef', 3), '...')

-- !SECTION

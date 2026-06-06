--[[
    MODULE: TSFX SDK - Test Runner

    Lightweight test runner with no dependencies.
--]]

TestRunner = {}
TestRunner.__index = TestRunner

TestRunner._results = {}
TestRunner._currentState = 'Unnamed'

---Sets the name of the current test suite (group of tests)
---@param name string
function TestRunner.describe(name)
    TestRunner._currentState = name
end

---Asserts that a condition is true
---@param label string Human-readable description of the assertion
---@param condition boolean
---@param extra? string Optional extra context appended to failure messages
function TestRunner.expect(label, condition, extra)
    local entry = {
        suite = TestRunner._currentState,
        label = label,
        pass = condition == true,
        extra = extra
    }

    TestRunner._results[#TestRunner._results + 1] = entry
end

---Asserts that two values are equal (==)
---@param label string
---@param actual any
---@param expected any
function TestRunner.expectEqual(label, actual, expected)
    local pass = actual == expected

    TestRunner.expect(
        label, pass,
        not pass and ('expected %q, got %q'):format(tostring(expected), tostring(actual)) or nil
    )
end

---Asserts that a value matches a Lua pattern
---@param label string
---@param value string
---@param pattern string
function TestRunner.expectMatch(label, value, pattern)
    local pass = type(value) == 'string' and value:match(pattern) ~= nil

    TestRunner.expect(
        label, pass,
        not pass and ('expected %q to match pattern %q'):format(tostring(value), pattern) or nil
    )
end

---Prints a summary of all test results
function TestRunner.report()
    local passed, failed = 0, 0
    local current = ''

    for _, r in ipairs(TestRunner._results) do
        if r.suite ~= current then
            print(('\n── %s ──'):format(r.suite))
            current = r.suite
        end

        if r.pass then
            passed += 1
            print(('  ✓ %s'):format(r.label))
        else
            failed += 1
            local msg = (''):format(r.label)
            if r.extra then msg = msg .. '  (' .. r.extra .. ')' end
            print(msg)
        end
    end

    print(('\n%d passed, %d failed, %d total\n'):format(passed, failed, passed + failed))
end

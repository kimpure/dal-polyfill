--!nocheck
--!nolint

local table = require('./table')

-- 루아우 info 의 옵션을 getinfo 의 옵션으로 매핑
local option_mapper = {
	-- luau info => getinfo
	['s'] = 'S',
	['l'] = 'S',
	['n'] = 'n',
	['f'] = 'f',
}
local option_keymap = {
	-- luau info => getinfo(table key)
	['s'] = 'short_src',
	['l'] = 'linedefined',
	['n'] = 'name',
	['f'] = 'func',
}

--// a 옵션은 안됨  (구현 불가능)
--// thread 안됨 (function or number)
local function info(thread, level_or_func, s)
	local useThread = false
	if type(thread) == 'thread' then
		if not (type(level_or_func) == "number") then
			error "invalid argument #2 for 'getinfo' (invalid level)"
		end
		if not (type(s) == 'string') then
			error "invalid argument #3 for 'getinfo' (invalid option)"
		end
		level_or_func = level_or_func + 1
	else
		s = level_or_func
		level_or_func = thread
		if not (type(level_or_func) == ("number" or "function")) then
			error "invalid argument #1 for 'getinfo' (invalid level)"
		end
		if type(level_or_func) == "number" then
			level_or_func = level_or_func + 1
		end
	end
	local getinfo_options = s:gsub(".", function(char)
		if char == "a" then
			error "invalid argument #2 to 'getinfo' (a is unsupported option)"
		end
		local option = option_mapper[char]
		if option == nil then
			error "invalid argument #2 to 'getinfo' (invalid option)"
		end
		return option
	end)
	local info = useThread and debug.getinfo(thread, level_or_func, getinfo_options) or debug.getinfo(level_or_func, getinfo_options)
	if info.short_src then
		info.short_src = string.format('[string "%s"]', info.short_src:gsub("%.lua$", ""))
	end
	local result = {}
	for char in s:gmatch(".") do
		table.insert(result, info[option_keymap[char]])
	end
	return table.unpack(result, 1, #s)
end

-- function x()
--     print((debug.info or info)(1, 'n'))
--	   print((debug.info or info)(corutine.create(x), 1, 'n'))
-- end
-- x()

return {
	info = info :: typeof(debug.info),
	traceback = debug.traceback
}
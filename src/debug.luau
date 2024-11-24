--!nocheck
--!nolint

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
local function info(thread, level_or_func, s)
    local useThread = type(thread) == 'thread'
    local options, target
    
    if useThread then
        if type(level_or_func) ~= "number" then
            error("invalid argument #2 for 'getinfo' (invalid level)")
        end
        target = level_or_func 
        options = s
    else
        options = level_or_func
        target = thread
        if type(target) == "number" then
            target = target + 1
        elseif type(target) ~= "function" then
            error("invalid argument #1 for 'getinfo' (invalid level)")
        end
    end
    
    if type(options) ~= 'string' then
        error("invalid option type (expected string)")
    end
    
    local getinfo_options = options:gsub(".", function(char)
		if char == "a" then
			error "invalid argument #2 to 'getinfo' (a is unsupported option)"
		end
		local option = option_mapper[char]
		if option == nil then
			error "invalid argument #2 to 'getinfo' (invalid option)"
		end
		return option
	end)
    
	if not options_has_l then
		options = options .. 'l'
	end

    local info = useThread and debug.getinfo(thread, target, getinfo_options) or debug.getinfo(target, getinfo_options)
    local options_line_zero = debug.getinfo(thread, target, 'l')

    if (not info) or (not options_line_zero) then
        return 
    end
    
    local result = {}
	for char in s:gmatch(".") do
		table.insert(result, info[option_keymap[char]])
	end
	return table.unpack(result, 1, #s)
end


-- 예시
-- local co = coroutine.create(function() coroutine.yield() end) coroutine.resume(co) print((debug.info or info)(co, 1, "sl"))

return {
	info = info :: typeof(debug.info),
	traceback = debug.traceback
}
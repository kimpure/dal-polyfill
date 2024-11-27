--!strict

local option_mapper = {
	['s'] = 'S',
	['l'] = 'S',
	['n'] = 'n',
	['f'] = 'f',
}

local option_keymap = {
	['s'] = 'short_src',
	['l'] = 'linedefined',
	['n'] = 'name',
	['f'] = 'func',
}

local gmatch = string.gmatch
local gsub = string.gsub

-- :: (<A..., R1..., R2...>((A...) -> (R1...), string) -> (R2...)) & (<R...>(number, string) -> (R...)) & (<R...>(thread, number, string) -> (R...))
local function info(thread: thread | number | (any) -> (any), level_or_func: number | string, s: string?)
    local useThread = type(thread) == 'thread'
    local options: any, target: any
    
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
    
    local function getInfoOptionsCall(char)
        if char == "a" then
            error "invalid argument #2 to 'getinfo' (a is unsupported option)"
        end
        local option = option_mapper[char]
        if option == nil then
            error "invalid argument #2 to 'getinfo' (invalid option)"
        end
        return option
    end

    local getinfoOptions = gsub(options, ".", getInfoOptionsCall)
    
    local info = useThread and (debug :: any).getinfo()(thread, target, getinfoOptions) or (debug :: any).getinfo()(target, getinfoOptions)
    local optionsLineZero = (debug :: any).getinfo()(thread, target, 'l')

    if (not info) or (not optionsLineZero) then
        return 
    end
    
    local result = {}
	for char in gmatch(options, ".") do
		table.insert(result, info[option_keymap[char]])
	end
	return table.unpack(result, 1, #options)
end 

-- local co = coroutine.create(function() coroutine.yield() end) coroutine.resume(co) print((debug.info or info)(co, 1, "sl"))

return {
	info = info,
	traceback = debug.traceback
}
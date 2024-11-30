--!strict

local optionMapper = {
	['s'] = 'S',
	['l'] = 'S',
	['n'] = 'n',
	['f'] = 'f',
    ['a'] = 'u'
}

local optionKeymap = {
	['s'] = 'short_src',
	['l'] = 'linedefined',
	['n'] = 'name',
	['f'] = 'func',
    ['a'] = 'isvararg',
}

local type = require'type'

local table = require'table'
local insert = table.insert
local unpack = table.unpack
local find = table.find

local string = require'string'
local gmatch = string.gmatch
local gsub = string.gsub

local function info<T, U>(thread: thread | number | (T) -> (U), level_or_func: number | string, s: string?)
    local useThread = type(thread) == 'thread'
    local options: any, target: any
    
    if useThread then
        if type(level_or_func) ~= "number" then
            error("invalid argument #2 for 'info' (invalid level)")
        end
        target = level_or_func 
        options = s
    else
        options = level_or_func
        target = thread
        if type(target) == "number" then
            target = target == 0 and 0 or target + 1
        elseif type(target) ~= "function" then
            error("invalid argument #1 for 'info' (invalid level)")
        end
    end
    
    if type(options) ~= 'string' then
        error("invalid option type (expected string)")
    end
    
    local function getInfoOptionsCall(char)
        local option = optionMapper[char]
        if option == nil then
            error "invalid argument #2 to 'info' (invalid option)"
        end
        return option
    end

    local useLua = (debug :: any).getinfo
    local debugInfo = useLua and (debug :: any).getinfo or debug.info 
    local getinfoOptions = useLua and gsub(options, ".", getInfoOptionsCall) or options
    
    local info = useThread and debugInfo(thread, target, getinfoOptions) or debugInfo(target, getinfoOptions)
    if not useLua then
        return info
    end
    
    local optionsLineZero = useThread and debugInfo(thread, target, 'l') or debugInfo(target, 'l')
    if (not info) or (not optionsLineZero) then
        return 
    end
    
    local result = {}
	for char in gmatch(options, ".") do
		insert(result, info[optionKeymap[char]])
	end

    if find(result, 'isvararg') and type(target) ~= 'number' then
        local count = 0
        while true do
            local name = (debug::any).getlocal(target, count + 1)
            if not name then break end
            count = count + 1
        end
        insert(result, find(result, 'isvararg') :: number - 1)
    end

	return unpack(result, 1, #options)
end 

return {
	info = info,
	traceback = debug.traceback
}
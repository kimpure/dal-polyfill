local type = require('./type')

local table = require("./table")
local insert = table.insert
local unpack = table.unpack

local string = require("./string")
local gmatch = string.gmatch
local gsub = string.gsub
local find = table.find

local optionMapper = {
	["s"] = "S",
	["l"] = "S",
	["n"] = "n",
	["f"] = "f",
}

local optionKeymap = {
	["s"] = "short_src",
	["l"] = "linedefined",
	["n"] = "name",
	["f"] = "func",
}

local function getInfoOptionsCall(char)
	local option = optionMapper[char]
	if option == nil then
		error("invalid argument #2 to 'info' (invalid option)")
	end
	return option
end

local info
if debug.info then
	info = debug.info
elseif (debug :: any).getinfo and (debug :: any).getlocal then
	local getinfo = (debug :: any).getinfo
	local getlocal = (debug :: any).getlocal

	info = function<T, U>(thread: thread | number | (T) -> U, levelOrFunc: number | string, s: string?)
		local useThread = type(thread) == "thread"
		local options: any, target: any

		if useThread then
			if type(levelOrFunc) ~= "number" then
				error("invalid argument #2 for 'info' (invalid level)")
			end
			target = levelOrFunc
			options = s
		else
			options = levelOrFunc
			target = thread
			if type(target) == "number" then
				target = target == 0 and 0 or target + 1
			elseif type(target) ~= "function" then
				error("invalid argument #1 for 'info' (invalid level)")
			end
		end

		if type(options) ~= "string" then
			error("invalid option type (expected string)")
		end

		local getinfoOptions = gsub(options, ".", getInfoOptionsCall)

		local info = useThread and getinfo(thread, target, getinfoOptions) or getinfo(target, getinfoOptions)

		local optionsLineZero = useThread and getinfo(thread, target, "l") or getinfo(target, "l")
		if (not info) or not optionsLineZero then
			return
		end

		local result = {}
		for char in gmatch(options, ".") do
			insert(result, info[optionKeymap[char]])
		end

		if find(result, "isvararg") and type(target) ~= "number" then
			local count = 0
			while true do
				local name = getlocal(target, count + 1)
				if not name then
					break
				end
				count = count + 1
			end
			insert(result, find(result, "isvararg") :: number - 1)
		end

		return unpack(result, 1, #options)
	end :: any
else
	info = function() end :: any
end

return {
	info = debug.info or info,
	traceback = debug.traceback or function() end,
}

local weakTypes = require("./weakTypes")
local nativeTypes = require("./nativeTypes")

return function(value: any): string
	local t = type(value)
	if t == "nil" then
		return t
	end
	local customtype = weakTypes[value]
	if customtype then
		return customtype
	end
	local mt = getmetatable(value :: any)
	customtype = nativeTypes[mt]
	if customtype then
		return customtype
	end
	return t
end

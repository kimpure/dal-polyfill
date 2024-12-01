local originalType = type
local type = require("./type")
local customTypes = require("./customTypes")

return function(value: any): string
	local t = originalType(value)
	if t == "nil" then
		return t
	end
	local mt = getmetatable(value :: any)
	local customtype = customTypes[mt]
	if customtype then
		return customtype
	end
	return type(value)
end

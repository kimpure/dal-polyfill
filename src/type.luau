local weakTypes = require("./weakTypes")
local nativeTypes = require("./nativeTypes")

return function(value: any): string
	if _G.DAL_runtime_type_checking then
		if value == nil then
			error("missing argument #1")
		end
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
	return type(value)
end

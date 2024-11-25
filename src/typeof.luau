local type = require("./type")
local customTypes = require("./customTypes")

return function(value: any): string
	if _G.DAL_runtime_type_checking then
		if value == nil then
			error("missing argument #1")
		end
	end
	local mt = getmetatable(value :: any)
	local customtype = customTypes[mt]
	if customtype then
		return customtype
	end
	return type(value)
end

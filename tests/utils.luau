local utils = {}

local luau = require("@lune/luau")

function utils.executePolyfill(code: string)
	_G.DAL_test = true
	local globals = require("../src/globals")
	return luau.load(code, {
		debugName = "polyfill execution",
		environment = globals,
		injectGlobals = true
	})()
end

function utils.execute(code: string): (any, any)
	local luauResult = luau.load(code, {
		debugName = "luau execution"
	})()
	local polyfillResult = utils.executePolyfill(code)

	return luauResult, polyfillResult
end

return utils

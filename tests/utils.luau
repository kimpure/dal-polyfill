local utils = {}
local luau = require("@lune/luau")
local frktest = require("@frktest/")
local check = frktest.assert.check
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")

local function pcallWithoutTrace(fn, ...)
	return xpcall(fn, function(err)
		return err:gsub("^[^:]+:%d+: ", "")
	end, ...)
end

local polyfill: { config: { [string]: boolean } } = serde.decode("toml", fs.readFile("polyfill.toml"))
for k, v in polyfill.config do
	_G["DAL_" .. k] = v
end
_G.DAL_test = true
local globals = require("../src/globals")
;(globals :: any).pcall = pcallWithoutTrace
;(globals :: any)._G = _G

function utils.executePolyfill(code: string)
	return luau.load(code, {
		debugName = "polyfill execution",
		environment = globals,
		injectGlobals = true
	})()
end

function utils.execute(code: string): (any, any)
	local luauResult = luau.load(code, {
		debugName = "luau execution",
		environment = {
			pcall = pcallWithoutTrace,
			_VERSION = "Luau",
		}
	})()
	local polyfillResult = utils.executePolyfill(code)

	return luauResult, polyfillResult
end

--[=[
	Return types must be a string.
]=]
function utils.executeWithLuau(code: string): (string, string)
	local luauResult = process.spawn("luau", nil, { stdin = [[pcall = function(fn, ...) return xpcall(fn, function(err) return err:gsub("^[^:]+:%d+: ", "") end, ...)  end;]] .. code })
	if luauResult.ok then
		return luauResult.stdout:sub(1, -3), utils.executePolyfill(code)
	else
		error(`Luau failure:\nerr: {luauResult.stderr}\nstdout: {luauResult.stdout}`)
	end
end

function utils.checkTableEntriesEqual(t0: { any }, t1: { any })
	for i, v in t0 do
		local obj = t1[i]
		if type(v) == "table" then
			if type(obj) == "table" then
				utils.checkTableEntriesEqual(v, obj)
			else
				error("The comparison object is not a table")
			end
		else
			check.equal(v, obj)
		end
	end
end

return utils

local nativeTypes = require("./nativeTypes")
local weakTypes = require("./weakTypes")
local frozenTables = require("./frozenTables")
local privateKey = require("./privateKey")
local proxies = require("./proxies")
local lockedTables = require("./lockedTables")
local isNumber = require("./isNumber")
local expectString = require("./expectString")
local typeof = require("./typeof")
local type = require("./type")
local isString = require("./isString")
local expectTable = require("./expectTable")

local function dal_rawget(t: {}, k: any): any
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "rawget")
	end
	if _G.DAL_emulate_type_error then
		if k == nil then
			error("missing argument #2")
		end
	end

	if proxies[t] then
		return t[k]
	end
	return rawget(t, k)
end

local function dal_rawset(t: {}, k: any, v: any): ()
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "rawset")
	end
	if _G.DAL_emulate_type_error then
		if k == nil then
			error("missing argument #2")
		elseif v == nil then
			error("missing argument #3")
		end
	end

	if proxies[t] then
		t[k] = v
	else
		rawset(t, k, v)
	end
end

local dal_next: typeof(next)
if _G.DAL_runtime_type_checking then
	dal_next = function<K, V>(t: { [K]: V }, i: K?): (K?, V)
		expectTable(t, "table", 1, "next")
		return next(t, i)
	end
else
	dal_next = next
end

local dal_ipairs: typeof(ipairs)
if _G.DAL_emulate_frozen_table or _G.DAL_runtime_type_checking then
	dal_ipairs = function<V>(t: { V }): (({ V }, number) -> (number?, V), { V }, number)
		if _G.DAL_runtime_type_checking then
			expectTable(t, "table", 1, "ipairs")
		end

		if _G.DAL_emulate_frozen_table then
			local frozen = frozenTables[t]
			if frozen then
				t = frozen[privateKey]
			end
		end

		return ipairs(t)
	end
else
	dal_ipairs = ipairs
end

local proxyMetatables = {}
local dal_getmetatable
if _G.DAL_emulate_frozen_table and _G.DAL_emulate_newproxy then
	dal_getmetatable = function(value: any): any
		if _G.DAL_emulate_type_error then
			if value == nil then
				error("missing argument #1")
			end
		end

		local frozen = frozenTables[value]
		if frozen then
			return frozen[1]
		end
		local mt = proxies[value] or getmetatable(value)
		if nativeTypes[mt] or proxyMetatables[value] then
			return nil
		end
		return mt
	end
elseif _G.DAL_emulate_frozen_table then
	dal_getmetatable = function(value: any): any
		if _G.DAL_emulate_type_error then
			if value == nil then
				error("missing argument #1")
			end
		end

		local frozen = frozenTables[value]
		if frozen then
			return frozen[1]
		end
		return getmetatable(value)
	end
elseif _G.DAL_emulate_newproxy then
	dal_getmetatable = function(value: any): any
		if _G.DAL_emulate_type_error then
			if value == nil then
				error("missing argument #1")
			end
		end

		local mt = proxies[value] or getmetatable(value)
		if nativeTypes[mt] or proxyMetatables[value] then
			return nil
		end
		return getmetatable(value)
	end
else
	dal_getmetatable = function(value: any): any
		if _G.DAL_emulate_type_error then
			if value == nil then
				error("missing argument #1")
			end
		end

		local mt = getmetatable(value)
		if nativeTypes[mt] then
			return nil
		end
		return mt
	end
end

local function __DAL_getmetatable_iter(value)
	if _G.DAL_emulate_type_error then
		if value == nil then
			error("missing argument #1")
		end
	end

	local iterMethod = lockedTables[value]
	if iterMethod then
		return {
			__iter = iterMethod,
		}
	end
	return dal_getmetatable(value)
end

local function dal_setmetatable(tbl: {}, mt: { [any]: any } | nil)
	if _G.DAL_runtime_type_checking then
		local funcName = "setmetatable"
		expectTable(tbl, "table", 1, funcName)
		if mt ~= nil and typeof(mt) ~= "table" then
			error(`invalid argument #2 to '{funcName}' (nil or table expected, got {typeof(mt)})`)
		end
	end

	if mt and mt.__metatable then
		local iterMethod = mt.__iter
		if iterMethod then
			lockedTables[tbl] = iterMethod
		else
			lockedTables[tbl] = false
		end
	end
	return setmetatable(tbl, mt)
end

local Proxy = {}

function Proxy.__newindex(self, k, v)
	self[privateKey][k] = v
	rawset(self, k, v)
end

local userdata = {}

function userdata.__index(self, k)
	error(`attempt to index {typeof(self)} with '{k}'`)
end

function userdata.__newindex(self, k)
	error(`attempt to index {typeof(self)} with '{k}'`)
end

function userdata.__len(self)
	error(`attempt to get length of a {typeof(self)} value`)
end

function userdata.__call(self)
	error(`attempt to call a {typeof(self)} value`)
end

local function arithmeticError(metamethod, a, b)
	local aType = typeof(a)
	local bType = typeof(b)
	if aType == bType then
		error(`attempt to perform arithmetic ({metamethod}) on {aType}`)
	else
		error(`attempt to perform arithmetic ({metamethod}) on {aType} and {bType}`)
	end
end

function userdata.__add(a, b)
	arithmeticError("add", a, b)
end

function userdata.__sub(a, b)
	arithmeticError("sub", a, b)
end

function userdata.__mul(a, b)
	arithmeticError("mul", a, b)
end

function userdata.__div(a, b)
	arithmeticError("div", a, b)
end

function userdata.__unm(a, b)
	arithmeticError("unm", a, b)
end

function userdata.__mod(a, b)
	arithmeticError("mod", a, b)
end

function userdata.__pow(a, b)
	arithmeticError("pow", a, b)
end

function userdata.__idiv(a, b)
	arithmeticError("idiv", a, b)
end

function userdata.__lt(a, b)
	error(`attempt to compare {typeof(a)} < {typeof(b)}`)
end

function userdata.__le(a, b)
	error(`attempt to compare {typeof(a)} <= {typeof(b)}`)
end

function userdata.__concat(a, b)
	error(`attempt to concatenate {typeof(a)} with {typeof(b)}`)
end

function userdata.__tostring(self)
	local mt = getmetatable(self)
	setmetatable(self :: any, nil)
	local display = "userdata: " .. tostring(self):sub(8)
	setmetatable(self :: any, mt)
	return display
	-- setmetatable(self :: any, nil)
	-- local display = "userdata: " .. tostring(self):sub(8)
	-- setmetatable(self :: any, userdata)
	-- return display
end

function userdata.__iter(self)
	error(`attempt to iterate over a {typeof(self)} value`)
end

nativeTypes[userdata] = "userdata"

local dal_newproxy
if _G.DAL_emulate_newproxy then
	dal_newproxy = function(mt: boolean?)
		if _G.DAL_emulate_type_error then
			if mt ~= nil and type(mt) ~= "boolean" then
				error(`invalid argument #1 to 'newproxy' (nil or boolean expected, got {typeof(mt)})`)
			end
		end

		local newud = {}
		if mt then
			-- selene: allow(manual_table_clone)
			local proxyMt = {}
			for i, v in pairs(userdata) do
				proxyMt[i] = v
			end
			setmetatable(newud, proxyMt)
			local p = {
				__newindex = function(self, k, v)
					proxyMt[k] = v
					rawset(self, k, v)
				end,
			}
			local pt = setmetatable({}, p)
			proxies[newud] = pt
			proxyMetatables[pt] = p
			weakTypes[newud] = "userdata"
		else
			setmetatable(newud, userdata)
		end
		return newud
	end
else
	dal_newproxy = function(mt: boolean?)
		if _G.DAL_emulate_type_error then
			if mt ~= nil and type(mt) ~= "boolean" then
				error(`invalid argument #1 to 'newproxy' (nil or boolean expected, got {typeof(mt)})`)
			end
		end

		local newud = {}
		if mt then
			setmetatable(newud, {})
			weakTypes[newud] = "userdata"
		else
			setmetatable(newud, userdata)
		end
		return newud
	end
end

local dal_gcinfo = gcinfo
if not dal_gcinfo then
	dal_gcinfo = function(): number
		return collectgarbage("count")
	end
end

local dal_setfenv = setfenv
if not dal_setfenv then
	dal_setfenv = function<T..., R...>(fnOrIndex: (T...) -> R... | number, env): ((T...) -> R...)?
		fnOrIndex = fnOrIndex or 1
		if isNumber(fnOrIndex) then
			local info = (debug :: any).getinfo(fnOrIndex) :: {
				func: (T...) -> R...,
				what: string,
			}
			if info.what == "C" then
				error("invalid argument #1 to 'getfenv' (invalid level)")
			end
			fnOrIndex = info.func
		elseif type(fnOrIndex) ~= "function" then
			error(`invalid argument #1 to 'setfenv' (function expected, got {typeof(fnOrIndex)})`)
		end
		local i = 1
		while true do
			local name = (debug :: any).getupvalue(fnOrIndex, i)
			if name == "_ENV" then
				(debug :: any).upvaluejoin(fnOrIndex, i, function()
					return env
				end, 1)
				break
			elseif not name then
				break
			end
			i = i + 1
		end
		return fnOrIndex :: any -- idk
	end
end

local dal_getfenv = getfenv
if not dal_getfenv then
	dal_getfenv = function(fnOrIndex: (() -> () | number)?)
		fnOrIndex = fnOrIndex or 1
		if isNumber(fnOrIndex) then
			local info = (debug :: any).getinfo(fnOrIndex) :: {
				func: () -> (),
				what: string,
			}
			if info.what == "C" then
				error("invalid argument #1 to 'getfenv' (invalid level)")
			end
			fnOrIndex = info.func
		elseif type(fnOrIndex) ~= "function" then
			error(`invalid argument #1 to 'getfenv' (function expected, got {typeof(fnOrIndex)})`)
		end
		local i = 1
		while true do
			local name, val = (debug :: any).getupvalue(fnOrIndex, i)
			if name == "_ENV" then
				return val
			elseif not name then
				break
			end
			i = i + 1
		end
		return {} -- idk
	end
end

local dal_loadstring = loadstring
if not dal_loadstring then
	dal_loadstring = function<A...>(contents: string, chunkname: string?): (((A...) -> any)?, string?)
		if _G.DAL_runtime_type_checking then
			local funcName = "loadstring"
			expectString(contents, 1, funcName)
			if chunkname ~= nil and not isString(chunkname) then
				error(`invalid argument #2 to '{funcName}' (string expected, got {typeof(chunkname)})`)
			end
		end

		-- selene: allow(incorrect_standard_library_use)
		return load(contents, chunkname, "t")
	end
end

return {
	-- globals
	type = type :: typeof(type),
	typeof = typeof :: typeof(typeof),
	rawget = dal_rawget :: typeof(rawget),
	rawset = dal_rawset :: typeof(rawset),
	next = dal_next :: typeof(next),
	unpack = table.unpack :: typeof(unpack),
	pairs = require("./pairs"),
	ipairs = dal_ipairs :: typeof(ipairs),
	getmetatable = dal_getmetatable :: typeof(getmetatable),
	__DAL_getmetatable_iter = __DAL_getmetatable_iter :: typeof(getmetatable),
	setmetatable = dal_setmetatable :: typeof(setmetatable),
	newproxy = dal_newproxy :: typeof(newproxy),
	gcinfo = dal_gcinfo :: typeof(gcinfo),
	setfenv = dal_setfenv :: typeof(setfenv),
	getfenv = dal_getfenv :: typeof(getfenv),
	_VERSION = "Luau",
	loadstring = dal_loadstring :: typeof(loadstring),

	-- libraries
	bit32 = require("./bit32"),
	buffer = require("./buffer"),
	debug = require("./debug"),
	math = require("./math"),
	os = require("./os"),
	string = require("./string"),
	table = require("./table"),
}

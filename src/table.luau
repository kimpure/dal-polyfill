local lockedTables = require("./lockedTables")
local expectTable = require("./expectTable")
local expectNumber = require("./expectNumber")
local expect = require("./expect")
local dal_pairs = require("./pairs")
local frozenTables = require("./frozenTables")
local privateKey = require("./privateKey")

local function clear(t: {})
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "clear")
	end

	for i in pairs(t) do
		t[i] = nil
	end
end

local clone: any
if _G.DAL_allow_debug_library_usage and (debug :: any).getmetatable then
	local getmt = (debug :: any).getmetatable
	clone = function(t: {})
		if _G.DAL_runtime_type_checking then
			expectTable(t, "table", 1, "clone")
		end

		local mt = getmt(t)
		if mt.__metatable then
			error("invalid argument #1 to 'clone' (table has a protected metatable)")
		end
		-- selene: allow(manual_table_clone)
		local new = {}
		for i, v in pairs(t) do
			new[i] = v
		end
		setmetatable(new, mt)
		return new
	end
else
	clone = function(t)
		if _G.DAL_runtime_type_checking then
			expectTable(t, "table", 1, "clone")
		end

		if lockedTables[t] == false then
			error("invalid argument #1 to 'clone' (table has a protected metatable)")
		end
		-- selene: allow(manual_table_clone)
		local new = {}
		for i, v in pairs(t) do
			new[i] = v
		end
		setmetatable(new, getmetatable(t))
		return new
	end
end

local function create<V>(count: number, value: V?): { V }
	if _G.DAL_emulate_type_error then
		expectNumber(count, 1, "create")
	end

	local new = {}
	if value ~= nil then
		for i = 1, count do
			new[i] = value
		end
	end
	return new
end

local function find(t: {}, value: any): number?
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "find")
	end
	if _G.DAL_emulate_type_error then
		if value == nil then
			error("missing argument #2")
		end
	end

	for i, v in ipairs(t) do
		if v == value then
			return i
		end
	end
	return nil
end

local function foreach<K, V>(t: { [K]: V }, fn: (K, V) -> ()): ()
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "foreach")
	end
	if _G.DAL_emulate_type_error then
		expect(fn, "function", 2, "foreach")
	end

	for k, v in dal_pairs(t) do
		fn(k, v)
	end
end

local function foreachi<V>(t: { V }, fn: (number, V) -> ()): ()
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "foreachi")
	end
	if _G.DAL_emulate_type_error then
		expect(fn, "function", 2, "foreachi")
	end

	for i, v in pairs(t) do
		if type(i) == "number" then
			fn(i, v)
		end
	end
end

local FrozenTable = {}

function FrozenTable.__index(self, k)
	return self[privateKey][k]
end

function FrozenTable.__newindex()
	error("attempt to modify a readonly table", 2)
end

function FrozenTable.__tostring(self): string
	return tostring(self[privateKey])
end

function FrozenTable.__len(self): number
	return #self[privateKey]
end

local function freeze(t: typeof(setmetatable({} :: {}, {} :: {})))
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "freeze")
	end

	if _G.DAL_emulate_frozen_table then
		local mt = getmetatable(t)
		local freezeMt
		if mt then
			freezeMt = clone(FrozenTable)
			for method, f in mt do
				if method ~= "__newindex" then
					freezeMt[method] = f
				end
			end
		else
			freezeMt = FrozenTable
		end
		local frozen = setmetatable({
			[privateKey] = t,
		}, freezeMt)

		-- frozentables[frozen] = {
		-- 	[1] = mt,
		-- 	[2] = t :: any,
		-- }
		frozenTables[frozen] = mt or false
		-- iteratables[frozen] = t

		return frozen
	else
		frozenTables[t] = false
		return t
	end
end

local function isfrozen(t: {}): boolean
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "isfrozen")
	end

	return frozenTables[t] ~= nil
end

local unpack = table.unpack
local pack = table.pack

local function getn(t: {}): number
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "getn")
	end

	return pack(unpack(t)).n
end

local function maxn(t: {}): number
	if _G.DAL_runtime_type_checking then
		expectTable(t, "table", 1, "maxn")
	end

	local max = 0
	for k, _ in pairs(t) do
		if type(k) == "number" and k > max then
			max = k
		end
	end
	return max
end

return {
	clear = clear :: typeof(table.clear),
	clone = clone :: typeof(table.clone),
	create = create :: typeof(table.create),
	find = find :: typeof(table.find),
	foreach = foreach :: typeof(table.foreach),
	foreachi = foreachi :: typeof(table.foreachi),
	freeze = (freeze :: any) :: typeof(table.freeze),
	getn = getn :: typeof(table.getn),
	isfrozen = isfrozen :: typeof(table.isfrozen),
	maxn = maxn :: typeof(table.maxn),
	concat = table.concat,
	insert = table.insert,
	move = table.move,
	pack = table.pack,
	remove = table.remove,
	sort = table.sort,
	unpack = table.unpack,
} :: typeof(table)

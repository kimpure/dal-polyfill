local expectTable = require("./expectTable")
local frozenTables = require("./frozenTables")
local privateKey = require("./privateKey")
local djb2 = require("./djb2")

local insert = table.insert
local sort = table.sort

if _G.DAL_hash_iterator then
	return function<K, V>(t: { [K]: V }): (({ [K]: V }, K?) -> (K?, V), { [K]: V }, nil)
		if _G.DAL_runtime_type_checking then
			expectTable(t, "table", 1, "pairs")
		end

		if _G.DAL_emulate_frozen_table then
			local frozen = frozenTables[t]
			if frozen then
				t = frozen[privateKey]
			end
		end

		local keys = {}
		local hashmap = {}
		for key in pairs(t) do
			local hash
			if type(key) == "number" then
				hash = key
			else
				hash = djb2(tostring(key)) :: any
			end
			insert(keys, hash)
			hashmap[hash] = key
		end

		sort(keys, function(a: any, b)
			return a < b
		end)

		local function iterator(tbl: { [K]: V }, index: K?): (K?, V)
			local nextIndex = next(tbl, index)
			if not nextIndex then
				return nil, nil :: any
			end
			local hashkey = keys[nextIndex :: any]
			local key = hashmap[hashkey]
			return key, tbl[key]
		end

		return iterator, t, nil
	end
elseif _G.DAL_emulate_frozen_table or _G.DAL_runtime_type_checking then
	return function<K, V>(t: { [K]: V })
		if _G.DAL_runtime_type_checking then
			expectTable(t, "table", 1, "pairs")
		end

		if _G.DAL_emulate_frozen_table then
			local frozen = frozenTables[t]
			if frozen then
				t = frozen[privateKey]
			end
		end

		return pairs(t)
	end
else
	return pairs
end

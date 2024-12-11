local dalbit_next: typeof(next)
if _G.DALBIT_emulate_next then
	if _G.DALBIT_luau_hash_table then -- TODO: Needs benchmarks!
		dalbit_next = require("./luauNext")
	else
		dalbit_next = require("./djb2Next")
	end
else
	dalbit_next = next
end

return dalbit_next

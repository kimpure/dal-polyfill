local dal_next: typeof(next)
if _G.DAL_emulate_next then
	if _G.DAL_luau_hash_table then -- TODO: Needs benchmarks!
		dal_next = require("./luauNext")
	else
		dal_next = require("./djb2Next")
	end
else
	dal_next = next
end

return dal_next

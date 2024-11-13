<<<<<<< HEAD
local function getinfo(thred: thread, level: number, options: string)
	local result = {}
	for i=1, #options do
		local v: string = options:sub(i, i)
		if v == 'n'  then
			result.name = debug.getinfo(thred, level, 'n')
		elseif v == 's' then
			result.source = debug.getinfo(thred, level, 'S')
		elseif v == 'l' then
			result.linedefined = debug.getinfo(thred, level, 'l')
		elseif v == 'a' then
			result.isvararg = debug.getinfo(thred, level, 'u')
		elseif v == 'f' then
			result.func = debug.getinfo(thred, level, 'f')
		end
	end
	return result
end

return {
	getinfo = getinfo :: typeof(debug.info),
	traceback = debug.traceback
}
local function getinfo(thred: thread, level: number, options: string)
	local result = {}
	for i=1, #options do
		local v: string = options:sub(i, i)
		if v == 'n'  then
			result.name = debug.info(thred, level, 'n')
		elseif v == 's' then
			result.source = debug.info(thred, level, 'S')
		elseif v == 'l' then
			result.linedefined = debug.info(thred, level, 'l')
		elseif v == 'a' then
			result.isvararg = debug.info(thred, level, 'u')
		elseif v == 'f' then
			result.func = debug.info(thred, level, 'f')
		end
	end
	return result
end

return {
	getinfo = getinfo :: typeof(debug.info),
	traceback = debug.traceback
}
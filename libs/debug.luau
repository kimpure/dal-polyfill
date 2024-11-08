return ({
	getinfo = function(thred, level, options) 
		local result = {}
		for i=1, #options do
			local v: string = options:sub(i, i)
			if v == 'n'  then
				result.name = debug.info(thred, level, 'n')
			elseif v == 'S' then
				result.source = debug.info(thred, level, 's')
			elseif v == 'l' then
				result.linedefined = debug.info(thred, level, 'l')
			elseif v == 'u' then
				result.isvararg = debug.info(thred, level, 'a')
			elseif v == 'f' then
				result.func = debug.info(thred, level, 'f')
			end
		end
	end,
	traceback = debug.traceback, 
} :: any) :: typeof(debug.info)
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
} :: any) :: {
	getinfo: (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "n") -> {name: string | nil,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "nS") -> {name: string | nil,source: string,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "nSl") -> {name: string | nil,source: string,linedefined: number,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "nSlu") -> {name: string | nil,source: string,linedefined: number,isvararg: boolean,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "nSluf") -> {name: string | nil,source: string,linedefined: number,isvararg: boolean,func: thread,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "S") -> {source: string,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "Sl") -> {source: string,linedefined: number,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "Slu") -> {source: string,linedefined: number,isvararg: boolean,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "Sluf") -> {source: string,linedefined: number,isvararg: boolean,func: thread,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "Slufn") -> {source: string,linedefined: number,isvararg: boolean,func: thread,name: string | nil,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "l") -> {linedefined: number,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "lu") -> {linedefined: number,isvararg: boolean,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "luf") -> {linedefined: number,isvararg: boolean,func: thread,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "lufn") -> {linedefined: number,isvararg: boolean,func: thread,name: string | nil,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "lufnl") -> {linedefined: number,isvararg: boolean,func: thread,name: string | nil})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "u") -> {isvararg: boolean,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "uf") -> {isvararg: boolean,func: thread,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "ufn") -> {isvararg: boolean,func: thread,name: string | nil,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "ufnl") -> {isvararg: boolean,func: thread,name: string | nil,linedefined: number,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "ufnlf") -> {isvararg: boolean,func: thread,name: string | nil,linedefined: number,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "f") -> {func: thread,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "fn") -> {func: thread,name: string | nil,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "fnl") -> {func: thread,name: string | nil,linedefined: number,})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "fnlf") -> {func: thread,name: string | nil,linedefined: number})& (<T..., U...>(thred: thread | (T...)->(U...), level: number, options: "fnlfl") -> {func: thread,name: string | nil,linedefined: number}),
	traceback: typeof(debug.traceback), 
}

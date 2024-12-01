local expectString = require("./expectString")
local isString = require("./isString")
local typeof = require("./typeof")

local gmatch = string.gmatch
local insert = table.insert

local function split(inputstr: string, sep: string): { string }
	if _G.DAL_emulate_type_error then
		local funcName = "split"
		expectString(inputstr, 1, funcName)
		if sep ~= nil and not isString(sep) then
			error(`invalid argument #2 to '{funcName}' (string expected, got {typeof(sep)})`)
		end
	end
	sep = sep or "%s"
	local t = {}
	for field, s in gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
		insert(t, field)
		if s == "" then
			return t
		end
	end
	return { inputstr }
end

pcall(function()
	local stringMt = (getmetatable :: any)("")
	stringMt.split = split
end)

local dal_string
if _G.DAL_test then
	dal_string = {
		split = split,
		byte = string.byte,
		char = string.char,
		find = string.find,
		format = string.format,
		gmatch = string.gmatch,
		gsub = string.gsub,
		len = string.len,
		lower = string.lower,
		match = string.match,
		pack = string.pack,
		packsize = string.packsize,
		rep = string.rep,
		reverse = string.reverse,
		sub = string.sub,
		unpack = string.unpack,
		upper = string.upper,
	} :: typeof(string)
else
	dal_string = {
		split = string.split or split,
		byte = string.byte,
		char = string.char,
		find = string.find,
		format = string.format,
		gmatch = string.gmatch,
		gsub = string.gsub,
		len = string.len,
		lower = string.lower,
		match = string.match,
		pack = string.pack,
		packsize = string.packsize,
		rep = string.rep,
		reverse = string.reverse,
		sub = string.sub,
		unpack = string.unpack,
		upper = string.upper,
	} :: typeof(string)
end

return dal_string

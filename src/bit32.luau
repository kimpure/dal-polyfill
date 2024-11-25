local expectNumber = require("./expectNumber")

local LN2 = math.log(2)
local log = math.log
local floor = math.floor
local band = bit32.band
local rshift = bit32.rshift
local lshift = bit32.lshift
local bnot = bit32.bnot
local bor = bit32.bor

local function arshift(x: number, disp: number): number
	if _G.DAL_emulate_type_error then
		local funcName = "arshift"
		expectNumber(x, 1, funcName)
		expectNumber(disp, 2, funcName)
	end

	x = band(x, 0xFFFFFFFF)

	local z = rshift(x, disp)

	if band(x, 0x80000000) ~= 0 then
		z = bor(z, lshift(0xFFFFFFFF, 32 - disp))
	end

	return z
end

-- local function btest(x: number, y: number): boolean -- can be converted directly into `((x&y)&0xFFFFFFFF~=0)`?
-- 	return bit32.band(x, y) ~= 0
-- end

local function extract(n: number, field: number, width: number): number
	if _G.DAL_emulate_type_error then
		local funcName = "extract"
		expectNumber(n, 1, funcName)
		expectNumber(field, 2, funcName)
		expectNumber(width, 3, funcName)
	end

	width = width or 1
	return band(rshift(n, field), 2 ^ width - 1)
end

local function rrotate(x: number, disp: number): number
	if _G.DAL_emulate_type_error then
		local funcName = "rrotate"
		expectNumber(x, 1, funcName)
		expectNumber(disp, 2, funcName)
	end

	disp = disp % 32
	local low = band(x, 2 ^ disp - 1)
	return rshift(x, disp) + lshift(low, 32 - disp)
end

local function lrotate(x: number, disp: number): number
	if _G.DAL_emulate_type_error then
		local funcName = "rrotate"
		expectNumber(x, 1, funcName)
		expectNumber(disp, 2, funcName)
	end

	return rrotate(x, -disp)
end

local function replace(n: number, v: number, field: number, width: number): number
	if _G.DAL_emulate_type_error then
		local funcName = "replace"
		expectNumber(n, 1, funcName)
		expectNumber(v, 2, funcName)
		expectNumber(field, 3, funcName)
		expectNumber(width, 4, funcName)
	end

	width = width or 1
	local mask1 = 2 ^ width - 1
	v = band(v, mask1) -- required by spec?
	local mask = bnot(lshift(mask1, field))
	return band(n, mask) + lshift(v, field)
end

local function countrz(x: number): number
	if _G.DAL_emulate_type_error then
		expectNumber(x, 1, "countrz")
	end

	local as32bit = rshift(x, 0)
	if as32bit == 0 then
		return 32
	end

	local count = 0
	while band(as32bit, 1) == 0 do
		as32bit = rshift(as32bit, 1)
		count += 1
	end
	return count
end

local function countlz(x: number): number
	if _G.DAL_emulate_type_error then
		expectNumber(x, 1, "countlz")
	end

	local as32bit = rshift(x, 0)
	if as32bit == 0 then
		return 32
	end
	return 31 - floor(log(as32bit) / LN2)
end

local function byteswap(n: number): number
	if _G.DAL_emulate_type_error then
		expectNumber(n, 1, "byteswap")
	end

	return bor(bor(bor(lshift(n, 24), band(lshift(n, 8), 0xff0000)), band(rshift(n, 8), 0xff00)), rshift(n, 24))
end

if not _G.DAL_test and bit32 then
	return bit32 :: any
else
	return {
		arshift = arshift :: typeof(bit32.arshift),
		extract = extract :: typeof(bit32.extract),
		rrotate = rrotate :: typeof(bit32.rrotate),
		lrotate = lrotate :: typeof(bit32.lrotate),
		replace = replace :: typeof(bit32.replace),
		countrz = countrz :: typeof(bit32.countrz),
		countlz = countlz :: typeof(bit32.countlz),
		byteswap = byteswap :: typeof(bit32.byteswap),
	} -- for lua54 or something
end

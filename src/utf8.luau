local bit32 = require("./bit32")
local bor = bit32.bor
local band = bit32.band
local rshift = bit32.rshift
local lshift = bit32.lshift

local string = require("./string")
local char = string.char
local byte = string.byte
local sub = string.sub

local math = require("./math")
local abs = math.abs
local floor = math.floor

local table = require("./table")
local unpack = table.unpack

local function bytesToCodePoint(bytes: { [number]: number }): number
	local codePoint

	if #bytes == 1 then
		codePoint = bytes[1]
	elseif #bytes == 2 then
		codePoint = bor(lshift(band(bytes[1], 0x1F), 6), band(bytes[2], 0x3F))
	elseif #bytes == 3 then
		codePoint = bor(lshift(band(bytes[1], 0x0F), 12), lshift(band(bytes[2], 0x3F), 6), band(bytes[3], 0x3F))
	elseif #bytes == 4 then
		codePoint = bor(
			lshift(band(bytes[1], 0x07), 18),
			lshift(band(bytes[2], 0x3F), 12),
			lshift(band(bytes[3], 0x3F), 6),
			band(bytes[4], 0x3F)
		)
	end

	return codePoint
end

local function bytesToUniCode(bytes: { [number]: number }): number
	if bytes[1] < 0x80 then
		return bytes[1]
	end

	if band(bytes[1], 0xE0) == 0xC0 then
		return bor(lshift(band(bytes[1], 0x1F), 6), band(bytes[2], 0x3F))
	end

	if band(bytes[1], 0xF0) == 0xE0 then
		return bor(lshift(band(bytes[1], 0x0F), 12), lshift(band(bytes[2], 0x3F), 6), band(bytes[3], 0x3F))
	end

	if band(bytes[1], 0xF8) == 0xF0 then
		return bor(
			lshift(band(bytes[1], 0x07), 18),
			lshift(band(bytes[2], 0x3F), 12),
			lshift(band(bytes[3], 0x3F), 6),
			band(bytes[4], 0x3F)
		)
	end

	return error("Incorrect utf8Encode value")
end

local function uniCodeToBytes(codePoint: number): ({ [number]: number }, number)
	if codePoint < 0x80 then
		return { codePoint }, 1
	end

	if codePoint < 0x800 then
		return {
			bor(0xC0, rshift(codePoint, 6)),
			bor(0x80, band(codePoint, 0x3F)),
		}, 2
	end

	if codePoint < 0x10000 then
		return {
			bor(0xE0, rshift(codePoint, 12)),
			bor(0x80, band(rshift(codePoint, 6), 0x3F)),
			bor(0x80, band(codePoint, 0x3F)),
		},
			3
	end

	if codePoint < 0x110000 then
		return {
			bor(0xF0, rshift(codePoint, 18)),
			bor(0x80, band(rshift(codePoint, 12), 0x3F)),
			bor(0x80, band(rshift(codePoint, 6), 0x3F)),
			bor(0x80, band(codePoint, 0x3F)),
		},
			4
	end

	return error("utf8 max byte is 4")
end

local function utf8Decode(bytes: { [number]: number }): (string, number)
	local code = bytesToCodePoint(bytes)

	if bytes[1] < 0x80 then
		return char(code), 1
	end

	if band(bytes[1], 0xE0) == 0xC0 then
		return char(0xC0 + floor(code / 0x40), 0x80 + (code % 0x40)), 2
	end

	if band(bytes[1], 0xF0) == 0xE0 then
		return char(0xE0 + floor(code / 0x1000), 0x80 + (floor(code / 0x40) % 0x40), 0x80 + (code % 0x40)), 3
	end

	if band(bytes[1], 0xF8) == 0xF0 then
		return char(
			0xF0 + floor(code / 0x40000),
			0x80 + (floor(code / 0x1000) % 0x40),
			0x80 + (floor(code / 0x40) % 0x40),
			0x80 + (code % 0x40)
		),
			4
	end

	return error("Incorrect utf8Encode value")
end

--// developer test only (무시가능)
-- local encodeValue = utf8Encode('한')
-- print(encodeValue)
-- print(utf8Decode(encodeValue))

local function utf8Char(...: number): string
	local result = ""
	for _, v in { ... } do
		result ..= utf8Decode(uniCodeToBytes(v :: number) :: any)
	end
	return result
end

--// utf8 char test
-- print(utf8.char(65, 66, 67))
-- print(utf8Char(65, 66, 67))

local function utf8Offset(s: string, n: number, i: number?): number?
	if n < 0 or n >= #s then
		return nil
	end
	
	i = i or 1 :: number
	local len = #s

	if i < 1 or i > len then
		error("invalid argument #3 to 'offset' (position out of range)")
	end

	if i == 0 then
		return i
	end

	local step = if n > 0 then 1 else -1
	local count = abs(n)

	while count > 0 do
		if i < 1 or i > len then
			return nil
		end

		if band(byte(s, i), 0xC0) ~= 0x80 then
			count = count - 1
		end

		if count == 0 then
			break
		end

		i = i :: number + step
	end

	return i
end

--// utf8 offset test
-- print(utf8.offset('한', 1, 5))
-- print(utf8Offset('한', 1, 5))

local function utf8Codepoint(str: string, i: number?, j: number?): ...number
	local i = i or 1
	local j = j or i
	local result = {}
	local currentPos = 1
	local currentChar = 1

	while currentPos <= #str do
		local codePoint, length = uniCodeToBytes(bytesToUniCode{ byte(sub(str, currentPos), 1, -1) })

		if currentChar >= i and currentChar <= j then
			result[#result + 1] = bytesToCodePoint(codePoint)
		end

		currentPos = currentPos + length
		currentChar = currentChar + 1
	end

	return unpack(result)
end

--// utf8 codepoint test
-- print(utf8.codepoint('뷁둙', 1, 4))
-- print(utf8Codepoint('뷁뚥', 1, 4))

local function utf8Len(str: string, i: number?, j: number?): ...number
	local i = i or 1
	local j = j or i
	local result = 1
	local currentPos = 1
	local currentChar = 1

	while currentPos <= #str do
		local _, length = uniCodeToBytes(bytesToUniCode{ byte(sub(str, currentPos), 1, -1) })

		if currentChar >= i and currentChar <= j then
			result += 1
		end

		currentPos = currentPos + length
		currentChar = currentChar + 1
	end

	return result
end

--// utf8 len test
-- print(utf8.len('한글'))
-- print(utf8Len('한글'))

local function utf8Codes(str: string)
    return function(str: string, index: number): (number, number)
		local firestLoop = index == 0
		index = firestLoop and 1 or index
		if index <= #str then
			local bytes, length = uniCodeToBytes(bytesToUniCode{ byte(sub(str, index), 1, -1) })

			if firestLoop then
				return index, bytesToCodePoint(bytes)
			end

			if index + length <= #str then
				local after, _ = uniCodeToBytes(bytesToUniCode{ byte(sub(str, index + length), 1, -1) })
				return index + length, bytesToCodePoint(after)
			end
			return nil :: any, nil :: any
        end
		return nil :: any, nil :: any
    end, str, 0
end
--// utf8 Codes test
-- for pos, code in utf8.codes('안녕하세요') do
--     print(pos, code)
-- end
-- for pos, code in utf8Codes('안녕하세요') do
--     print(pos, code)
-- end

return {
	offset = utf8Offset,
	codepoint = utf8Codepoint,
	char = utf8Char,
	len = utf8Len,
	codes = utf8Codes,
}

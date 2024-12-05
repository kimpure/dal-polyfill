--!strict
local bit32 = require './bit32'
local bor = bit32.bor
local band = bit32.band
local rshift = bit32.rshift
local lshift = bit32.lshift

local string = require './string'
local char = string.char
local byte = string.byte
local sub = string.sub

local math = require './math'
local abs = math.abs

local table = require './table'
local unpack = table.unpack

local function encodeCharByte(bytes: { [number]: number })
    local codePoint

    if #bytes == 1 then
        codePoint = bytes[1]
    elseif #bytes == 2 then
        codePoint = bor(
            lshift(band(bytes[1], 0x1F), 6), 
            band(bytes[2], 0x3F)
        ) 
    elseif #bytes == 3 then
        codePoint = bor(
            lshift(band(bytes[1], 0x0F), 12),
            lshift(band(bytes[2], 0x3F), 6), 
            band(bytes[3], 0x3F)
        ) 
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

local function getUtf8Code(bytes: { [number]: number }): number
    --// 1byte char
    if bytes[1] < 0x80 then
        return bytes[1]
    end

    --// 2byte char
    if band(bytes[1], 0xE0) == 0xC0 then
        return bor(
            lshift(band(bytes[1], 0x1F), 6), 
            band(bytes[2], 0x3F)
        )
    end

    --// 3byte char
    if band(bytes[1], 0xF0) == 0xE0 then
        return bor(
            lshift(band(bytes[1], 0x0F), 12),
            lshift(band(bytes[2], 0x3F), 6),
            band(bytes[3], 0x3F) 
        )
    end

    --// 4byte char
    if band(bytes[1], 0xF8) == 0xF0 then
        return bor(
            lshift(band(bytes[1], 0x07), 18),
            lshift(band(bytes[2], 0x3F), 12),
            lshift(band(bytes[3], 0x3F), 6),
            band(bytes[4], 0x3F) 
        )
    end

    return error('Incorrect utf8Encode value')
end

local function utf8Encode(char: string): { [number]: number }
    local codePoint = encodeCharByte{byte(char, 1, -1)}

    --// 1byte char
    if codePoint < 0x80 then
        return { codePoint }
    end

    --// 2byte char
    if codePoint < 0x800 then
        return {
            bor(0xC0, rshift(codePoint, 6)),
            bor(0x80, band(codePoint, 0x3F)),
        }
    end

    --// 3byte char
    if codePoint < 0x10000 then
        return {
            bor(0xE0, rshift(codePoint, 12)),
            bor(0x80, band(rshift(codePoint, 6), 0x3F)),
            bor(0x80, band(codePoint, 0x3F)),
        }
    end

    --// 4byte char
    if codePoint < 0x110000 then
        return {
            bor(0xF0, rshift(codePoint, 18)),
            bor(0x80, band(rshift(codePoint, 12), 0x3F)),
            bor(0x80, band(rshift(codePoint, 6), 0x3F)),
            bor(0x80, band(codePoint, 0x3F))
        }
    end

    return error('utf8 max byte is 4')
end

local function utf8Decode(bytes: { [number]: number }): string
    local code = getUtf8Code(bytes)

    --// 1byte char
    if bytes[1] < 0x80 then
        return char(code)
    end

    --// 2byte char
    if band(bytes[1], 0xE0) == 0xC0 then
        return char(
            0xC0 + math.floor(code / 0x40),
            0x80 + (code % 0x40)
        ) 
    end

    --// 3byte char
    if band(bytes[1], 0xF0) == 0xE0 then
        return char(
            0xE0 + math.floor(code / 0x1000),
            0x80 + (math.floor(code / 0x40) % 0x40),
            0x80 + (code % 0x40)
        )
    end

    --// 4byte char
    if band(bytes[1], 0xF8) == 0xF0 then
        return char(
            0xF0 + math.floor(code / 0x40000),
            0x80 + (math.floor(code / 0x1000) % 0x40),
            0x80 + (math.floor(code / 0x40) % 0x40),
            0x80 + (code % 0x40)
        )
    end

    return error('Incorrect utf8Encode value')
end

--// developer test only (무시가능)
-- local encodeValue = utf8Encode('한')
-- print(encodeValue)
-- print(utf8Decode(encodeValue))

local function utf8Char(...: number)
    local result = ''
    for k, v in { ... } do
        result ..= utf8Decode(utf8Encode(char(v))) 
    end
    return result
end

--// utf8 char test
-- print(utf8.char(65, 66, 67))
-- print(utf8Char(65, 66, 67))

local function utf8Offset(s: string, n: number, i: number?): number?
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
-- print(utf8.offset('한', 0, 1))
-- print(utf8Offset('한', 0, 1))

local function utf8Codepoint(s: string, i: number, j: number?)
    j = j or i
    local result = {}
    while i <= j::number do
        result[#result + 1] = getUtf8Code(utf8Encode(sub(s, i, i)))
        i += 1
    end
    
    return unpack(result)
end

print(utf8.codepoint('한글', 1, 2))
print(utf8Codepoint('한글', 1, 2))

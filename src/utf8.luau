--!strict
local bit32 = require './bit32'
local bor = bit32.bor
local band = bit32.band
local rshift = bit32.rshift
local lshift = bit32.lshift

local string = require './string'
local char = string.char

local function utf8Encode(char: string): { [number]: number }
    local bytes = { char:byte(1, -1) }
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
    --// 1byte char
    if bytes[1] < 0x80 then
        return char(bytes[1])
    end

    --// 2byte char
    if band(bytes[1], 0xE0) == 0xC0 then
        local code = bor(
            lshift(band(bytes[1], 0x1F), 6), 
            band(bytes[2], 0x3F)
        )
        return char(
            0xC0 + math.floor(code / 0x40),
            0x80 + (code % 0x40)
        ) 
    end

    --// 3byte char
    if band(bytes[1], 0xF0) == 0xE0 then
        local code = bor(
            lshift(band(bytes[1], 0x0F), 12),
            lshift(band(bytes[2], 0x3F), 6),
            band(bytes[3], 0x3F) 
        )
        return char(
            0xE0 + math.floor(code / 0x1000),
            0x80 + (math.floor(code / 0x40) % 0x40),
            0x80 + (code % 0x40)
        )
    end

    --// 4byte char
    if band(bytes[1], 0xF8) == 0xF0 then
        local code = bor(
            lshift(band(bytes[1], 0x07), 18),
            lshift(band(bytes[2], 0x3F), 12),
            lshift(band(bytes[3], 0x3F), 6),
            band(bytes[4], 0x3F) 
        )
        return char(
            0xF0 + math.floor(code / 0x40000),
            0x80 + (math.floor(code / 0x1000) % 0x40),
            0x80 + (math.floor(code / 0x40) % 0x40),
            0x80 + (code % 0x40)
        )
    end

    return error('Incorrect utf8Encode value')
end

local encodeValue = utf8Encode('한')
print(encodeValue)
print(utf8Decode(encodeValue))

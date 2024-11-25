local frktest = require("@frktest/")
local test = frktest.test
local check = frktest.assert.check
local utils = require("./utils")

return function()
	test.suite("bit32", function()
		test.case("arshift", function()
			check.equal(utils.execute([[

			return bit32.arshift(0b1111, 2)

			]]))

			check.equal(utils.execute([[

			return bit32.arshift(-4, 1)

			]]))

			check.equal(utils.execute([[

			return bit32.arshift(0xFF, 32)

			]]))
		end)

		test.case("extract", function()
			check.equal(utils.execute([[

			return bit32.extract(0x1234, 4, 4)

			]]))

			check.equal(utils.execute([[

			return bit32.extract(0xFFFF, 8, 8)

			]]))
		end)

		test.case("rrotate", function()
			check.equal(utils.execute([[

			return bit32.rrotate(0x12345678, 4)

			]]))

			check.equal(utils.execute([[

			return bit32.rrotate(0x80000000, 1)

			]]))
		end)

		test.case("lrotate", function()
			check.equal(utils.execute([[

			return bit32.lrotate(0x12345678, 4)

			]]))

			check.equal(utils.execute([[

			return bit32.lrotate(0x80000000, 1)

			]]))
		end)
	end)

	test.suite("buffer", function()
		test.case("integers", function()
			local luauResult, polyfillResult = utils.execute([[

			local offset = 0
			local b = buffer.create(14)

			-- writing unsigned
			buffer.writeu8(b, offset, 2^8-1)
			offset += 1

			buffer.writeu16(b, offset, 2^16-1)
			offset += 2

			buffer.writeu32(b, offset, 2^32-1)
			offset += 4

			-- writing signed
			buffer.writei8(b, offset, 2^7-1)
			offset += 1

			buffer.writei16(b, offset, 2^15-1)
			offset += 2

			buffer.writei32(b, offset, 2^31-1)
			offset += 4

			-- reading unsigned
			offset = 0
			buffer.readu8(b, offset)
			offset += 1

			buffer.readu16(b, offset)
			offset += 2

			buffer.readu32(b, offset)
			offset += 4

			-- reading signed
			buffer.readi8(b, offset)
			offset += 1

			buffer.readi16(b, offset)
			offset += 2

			buffer.readi32(b, offset)
			offset += 4

			return buffer.tostring(b)

			]])

			check.equal(luauResult, polyfillResult)
		end)
	end)
end

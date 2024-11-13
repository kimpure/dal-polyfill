<<<<<<< HEAD
local byte = string.byte

return function(str)
	local hash = 5381

	for i = 1, #str do
		hash = hash * 33 + byte(str, i)
		hash = bit32.band(hash, 0xffffffff)
	end

	return hash
end
=======
local byte = string.byte

return function(str: string): number
	local hash = 5381

	for i = 1, #str do
		hash = hash * 33 + byte(str, i)
		hash = bit32.band(hash, 0xffffffff)
	end

	return hash
end
>>>>>>> d044ffc3966df21a5ac0de8a43c85d7a853d46bd

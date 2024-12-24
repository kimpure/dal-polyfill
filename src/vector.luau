type vector = {
    x: number,
    y: number,
    z: number,
}

local privateKey = require("./privateKey")

local floor = math.floor
local atan2 = math.atan2

--[=[
TODO: Add type checking && privatekey

if not vec[privateKey] then
    return
end
]=]

function vector_create(x: number, y: number, z: number): vector
    return setmetatable({ 
        x=x, 
        y=y, 
        z=z,
        [privateKey] = true,
    }, {
        __newindex = function(_, key)
            error(`attempt to index vector with '{key}'`)
        end,
        __tostring = function(self)
            return `{self.x}, {self.y}, {self.z}`
        end,
    }) :: any
end

-- print(vector.create(1, 2, 3))
-- print(vector_create(1, 2, 3))

function vector_magnitude(vec: vector)
    return (vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5
end

-- print(math.round(vector.magnitude(vector.create(10, 5, 5)) * 1000) / 1000)
-- print(math.round(vector_magnitude(vector_create(10, 5, 5)) * 1000) / 1000)

function vector_normalize(vec: vector)
    local invSqrt = 1 / ((vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5)
    return vector_create(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end

-- print(vector.normalize(vector.create(10, 5, 5)))
-- print(vector_normalize(vector_create(10, 5, 5)))

function vector_cross(vec1: vector, vec2: vector)
    return vector_create(vec1.y * vec2.z - vec1.z * vec2.y, vec1.z * vec2.x - vec1.x * vec2.z, vec1.x * vec2.y - vec1.y * vec2.x)
end

-- print(vector.cross(vector.create(10, 5, 5), vector.create(5, 5, 10)))
-- print(vector_cross(vector_create(10, 5, 5), vector_create(5, 5, 10)))

function vector_dot(vec1: vector, vec2: vector)
    return (vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z)
end

-- print(vector.dot(vector.create(10, 5, 5), vector.create(5, 5, 10)))
-- print(vector_dot(vector_create(10, 5, 5), vector_create(5, 5, 10)))

function vector_angle(vec1: vector, vec2: vector, axis: vector?)
    local cross = { vec1.y * vec2.z - vec1.z * vec2.y, vec1.z * vec2.x - vec1.x * vec2.z, vec1.x * vec2.y - vec1.y * vec2.x }

    local sin_vec1 = (cross[1]^2 + cross[2]^2 + cross[3] ^2) ^ 0.5
    local cos_vec1 = vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
    local angle = atan2(sin_vec1, cos_vec1)

    if axis then
        if (cross[1] * axis.x + cross[2] * axis.y + cross[3] * axis.z) < 0 then
            angle = -angle
        end
    end

    return angle
end

-- print(vector.angle(vector.create(10, 5, 5), vector.create(5, 5, 10), vector.create(10, 5, 5)))
-- print(vector_angle(vector_create(10, 5, 5), vector_create(5, 5, 10), vector_create(10, 5, 5)))

function vector_floor(vec: vector)
    return vector_create(floor(vec.x), floor(vec.y), floor(vec.z))
end

-- print(vector.floor(vector.create(10.123, 20.234, 30.345)))
-- print(vector_floor(vector_create(10.123, 20.234, 30.345)))



local zero = vector_create(0, 0, 0)
local one = vector_create(1, 1, 1)

return vector
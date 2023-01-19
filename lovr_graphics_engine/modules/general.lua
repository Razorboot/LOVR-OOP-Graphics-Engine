--# Point
local General = {}


--# Base Functions
function General.getVec4From(...)
    local vec4 = ...
    local itemType = type(vec4)

    if itemType == "userdata" then
        if pcall(function() vec4:unpack() end) then
            local x, y, z, w = vec4:unpack()
            if not x then x = 0 end if not y then y = 0 end if not z then z = 0 end if not w then w = 0 end
            return lovr.math.vec4(x, y, z, w)
        end
    elseif itemType == "table" then
        if #vec4 > 3 then
            return lovr.math.vec4(vec4[1], vec4[2], vec4[3], vec4[4])
        end
    elseif itemType == "number" then
        local x, y, z, w = ...
        if not x then x = 0 end if not y then y = 0 end if not z then z = 0 end if not w then w = 0 end
        return lovr.math.vec4(x, y, z, w)
    end
end

function General.getVec3From(...)
    local vec3 = ...
    local itemType = type(vec3)

    if itemType == "userdata" then
        if pcall(function() vec3:unpack() end) then
            local x, y, z = vec3:unpack()
            if not x then x = 0 end if not y then y = 0 end if not z then z = 0 end
            return lovr.math.vec3(x, y, z)
        end
    elseif itemType == "table" then
        if #vec3 > 2 then
            return lovr.math.vec3(vec3[1], vec3[2], vec3[3])
        end
    elseif itemType == "number" then
        local x, y, z = ...
        if not x then x = 0 end if not y then y = 0 end if not z then z = 0 end
        return lovr.math.vec3(x, y, z)
    end
end


--# Math Functions
function General.lerp(a, b, t)
    return a + (b - a) * t
end

function General.clamp(num, min, max)
    if num > max then return max end
    if num < min then return min end
    return num
end


--# Finalize
return General
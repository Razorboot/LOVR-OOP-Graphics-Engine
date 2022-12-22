--# Include
local Object = require "libs.classic"


--# Point
local Transform = {}


--# Methods
function Transform:new()
    self.matrix = lovr.math.mat4()
    self.position = lovr.math.vec3()
    self.scale = lovr.math.vec3()
    self.rotation = lovr.math.vec4()
end

function self:setMatrix(mat4, pos, scale, rot)
    local m1, m2, m3, m4,
    m5, m6, m7, m8,
    m9, m10, m11, m12,
    m13, m14, m15, m16

    local rotx, roty, rotz, rotw

    if mat4 then 
        m1, m2, m3, m4,
        m5, m6, m7, m8,
        m9, m10, m11, m12,
        m13, m14, m15, m16 = mat4:unpack(true) -- x, y, z, 

        rotx, roty, rotz, rotw = lovr.math.quat(mat4):unpack()
    end

    self.transform.position.x, self.transform.position.y, self.transform.position.z = m13 or pos.x or self.transform.position.x, m14 or pos.y or self.transform.position.y, m15 or pos.z or self.transform.position.z
    self.transform.scale.x, self.transform.scale.y, self.transform.scale.z = scale.x or self.transform.scale.x, scale.y or self.transform.scale.y, scale.z or self.transform.scale.z
    self.transform.rotation.x, self.transform.rotation.y, self.transform.rotation.z, self.transform.rotation.w = rotx or rot.x or self.transform.rotation.x, roty or rot.y or self.transform.rotation.y, rotz or rot.z or self.transform.rotation.z, rotw or rot.w or self.transform.rotation.w
end


--# Finalize
return Transform
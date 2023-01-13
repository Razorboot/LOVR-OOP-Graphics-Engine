--# Include
local Object = require "lovr_graphics_engine.libs.classic"


--# Point
local Transform = Object:extend()


--# Methods
function Transform:new(info)
    self.matrix = lovr.math.newMat4()
    self.position = lovr.math.newVec3()
    self.scale = lovr.math.newVec3()
    self.rotation = lovr.math.newVec4()

    info = info or {scale = lovr.math.vec3(1, 1, 1)}
    if not info.scale then info.scale = lovr.math.vec3(1, 1, 1) end
    self:setMatrix(info)
    
    -- Previous variables for detecting if there are changes in any of the transformation values
    self.changed = true
end

function Transform:cloneMatrix()
    return lovr.math.mat4(self.matrix:unpack(true))
end

function Transform:setMatrix(info)
    local oldMatrix = lovr.math.mat4(self.matrix:unpack(true))

    local mat4, pos, scale, rot = info.matrix, info.position, info.scale, info.rotation

    local m1, m2, m3, m4,
    m5, m6, m7, m8,
    m9, m10, m11, m12,
    m13, m14, m15, m16

    local newx, newy, newz
    local rotx, roty, rotz, rotw
    local scalex, scaley, scalez

    if mat4 then 
        m1, m2, m3, m4,
        m5, m6, m7, m8,
        m9, m10, m11, m12,
        m13, m14, m15, m16 = mat4:unpack(true)

        newx, newy, newz = Transform.getPositionFromMat4(mat4)
        rotx, roty, rotz, rotw = lovr.math.quat(mat4):unpack()
        --scalex, scaley, scalez = lovr.math.vec3(m1, m2, m3):length(), lovr.math.vec3(m5, m6, m7):length(), lovr.math.vec3(m9, m10, m11):length() -- Honestly have no idea if this is right
        scalex, scaley, scalez = Transform.getScaleFromMat4(mat4)

        self.matrix = lovr.math.newMat4(
        m1, m2, m3, m4,
        m5, m6, m7, m8,
        m9, m10, m11, m12,
        m13, m14, m15, m16)
    end

    -- Get the position to set self.position to
    local setPos
    if newx and new and newz then
        setPos = lovr.math.vec3(newx, newy, newz)
    end
    if not setPos then
        if pos then setPos = pos end
    end
    if not setPos then
        setPos = self.position
    end

    -- Get the scale to set self.scale to
    local setScale
    if scalex and scaley and scalez then
        setScale = lovr.math.vec3(scalex, scaley, scalez)
    end
    if not setScale then
        if scale then setScale = scale end
    end
    if not setScale then
        setScale = self.scale
    end

    -- Get the rotation to set self.rotation to
    local setRot
    if rotx and roty and rotz and rotw then
        setRot = lovr.math.vec4(rotx, roty, rotz, rotw)
    end
    if not setRot then
        if rot then setRot = rot end
    end
    if not setRot then
        setRot = self.rotation
    end

    -- Set transformation vars
    self.position.x, self.position.y, self.position.z = setPos.x, setPos.y, setPos.z
    self.scale.x, self.scale.y, self.scale.z = setScale.x, setScale.y, setScale.z
    self.rotation.x, self.rotation.y, self.rotation.z, self.rotation.w = setRot.x, setRot.y, setRot.z, setRot.w

    if pos or scale or rot then
        -- Reconstruct the transformation matrix if the position, scale, or rot is changed
        self.matrix = lovr.math.newMat4():translate(self.position.x, self.position.y, self.position.z):rotate(self.rotation.x, self.rotation.y, self.rotation.z, self.rotation.w):scale(self.scale.x, self.scale.y, self.scale.z)
    end

    -- Check change
    self:updateChanged(oldMatrix)
end

function Transform:updateChanged(oldMatrix)
    local m1, m2, m3, m4,
    m5, m6, m7, m8,
    m9, m10, m11, m12,
    m13, m14, m15, m16 = self.matrix:unpack(true)

    local pm1, pm2, pm3, pm4,
    pm5, pm6, pm7, pm8,
    pm9, pm10, pm11, pm12,
    pm13, pm14, pm15, pm16 = oldMatrix:unpack(true)

    if pm1 ~= m1 then return true end
    if self.changed == false then if pm2 ~= m2 then self.changed = true return end end
    if self.changed == false then if pm3 ~= m3 then self.changed = true return end end
    if self.changed == false then if pm4 ~= m4 then self.changed = true return end end
    if self.changed == false then if pm5 ~= m5 then self.changed = true return end end
    if self.changed == false then if pm6 ~= m6 then self.changed = true return end end
    if self.changed == false then if pm7 ~= m7 then self.changed = true return end end
    if self.changed == false then if pm8 ~= m8 then self.changed = true return end end
    if self.changed == false then if pm10 ~= m10 then self.changed = true return end end
    if self.changed == false then if pm11 ~= m11 then self.changed = true return end end
    if self.changed == false then if pm12 ~= m12 then self.changed = true return end end
    if self.changed == false then if pm13 ~= m13 then self.changed = true return end end
    if self.changed == false then if pm14 ~= m14 then self.changed = true return end end
    if self.changed == false then if pm15 ~= m15 then self.changed = true return end end
    if self.changed == false then if pm16 ~= m16 then self.changed = true return end end
end


--# Misc Functions
function Transform.getRotationFromMat4(mat4)
    rotx, roty, rotz, rotw = lovr.math.quat(mat4):unpack()
    return rotx, roty, rotz, rotw
end

function Transform.getScaleFromMat4(mat4)
    local x, y, z, sx, sy, sz, rx, ry, rz, rw = mat4:unpack()
    return sx, sy, sz
end

function Transform.getPositionFromMat4(mat4)
    local x, y, z, sx, sy, sz, rx, ry, rz, rw = mat4:unpack()
    return x, y, z
end

function Transform.getPose(mat4)
    local x, y, z, sx, sy, sz, rx, ry, rz, rw = mat4:unpack()
    return x, y, z, rx, ry, rz, rw
end

function Transform.getTransformMatFromMat4(mat4)
    return lovr.math.newMat4():translate( Transform.getPositionFromMat4(mat4) ):rotate( Transform.getRotationFromMat4(mat4) ):scale( Transform.getScaleFromMat4(mat4) )
end

function Transform.getStringFromMat4(mat4)
	local m1, m2, m3, m4,
	m5, m6, m7, m8,
	m9, m10, m11, m12,
	m13, m14, m15, m16 = mat4:unpack( true )

	local mat4String = tostring( m1 ..
		", " ..
		m2 .. ", " .. m3 ..
		", " .. m4 .. ", \n" .. m5 .. ", " .. m6 .. ", " .. m7 .. ", " .. m8 ..
		", \n" .. m9 .. ", " .. m10 .. ", " .. m11 .. ", " .. m12 .. ", \n" .. m13 .. ", " .. m14 .. ", " .. m15 .. ", " .. m16 ) -- Used for debugging purposes!

	return mat4String
end

function Transform.getMatrixRelativeTo(primaryMatrix, otherMatrix)
    local globalTransform = lovr.math.mat4():translate( Transform.getPositionFromMat4(primaryMatrix) ):rotate( Transform.getRotationFromMat4(primaryMatrix) )
    local parentGlobalTransform = otherMatrix

    -- Get the offset matrix from the detached GLOBAL transform to the parent node
    local globalTransform_inverted = lovr.math.mat4(globalTransform:unpack(true)):invert()
    local parentGlobalTransform_new = lovr.math.mat4(parentGlobalTransform:unpack(true))
    local offsetMatrix = globalTransform_inverted:mul(parentGlobalTransform_new)
    offsetMatrix = lovr.math.newMat4():translate( Transform.getPositionFromMat4(offsetMatrix) ):rotate( Transform.getRotationFromMat4(offsetMatrix) )
    offsetMatrix = offsetMatrix:invert()

    -- Finalize: Keep in mind we update the local transform because the final global transform is recalculated on updateGlobalTransform()
    offsetMatrix:scale(Transform.getScaleFromMat4(primaryMatrix))
    return offsetMatrix
end
    

--# Finalize
return Transform
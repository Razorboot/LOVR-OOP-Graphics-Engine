--# Include
local Object = require "lovr_graphics_engine.libs.classic"
local Transform = require "lovr_graphics_engine.modules.transform"


--# Point
local Body = Object:extend()


--# Variables
local defaults = {
    position = lovr.math.newVec3(0, 0, 0),
    scale = lovr.math.newVec3(1, 1, 1),
    rotation = lovr.math.newVec4(0, 0, 0, 0)
}


--# Misc Functions
function getLengthAndRadius(w, h, d)
    local length = nil
    local radius = lovr.math.vec2()

    if w > h and w > d then
        length = w
        radius.x, radius.y = h, d
        return length, radius
    end
    if h > w and h > d then
        length = h
        radius.x, radius.y = w, d
        return length, radius
    end
    if d > w and d > h then
        length = d
        radius.x, radius.y = w, h
        return length, radius
    end
end


--# Core Functions
function Body:new(node, info)
    -- Parent node
    self.node = node

    -- General
    self.name = info.body_name or "Body ("..tostring(#node.attachments.bodies + 1)..")"
    self.type = "body"

    -- Pose parameters for the collider
    local x, y, z = defaults.position.x, defaults.position.y, defaults.position.z
    local w, h, d = defaults.scale.x, defaults.scale.y, defaults.scale.z
    local rotx, roty, rotz, rotw = defaults.rotation.x, defaults.rotation.y, defaults.rotation.z, defaults.rotation.w

    if info.transform then
        x, y, z = info.transform.position.x, info.transform.position.y, info.transform.position.z

        if info.use_dimensions == true then
            w, h, d = info.model:getDimensions()
            w, h, d = w * info.transform.scale.x, h * info.transform.scale.y, d * info.transform.scale.z
        end

        rotx, roty, rotz, rotw = info.transform.rotation.x, info.transform.rotation.y, info.transform.rotation.z, info.transform.rotation.w
    end

    --self.offsetTransform = Transform({pos = lovr.math.vec3(x, y, z), scale = lovr.math.vec3(w, h, d), rot = lovr.math.vec4(rotx, roty, rotz, rotw)})
    self.transform = Transform({pos = lovr.math.vec3(x, y, z), scale = lovr.math.vec3(w, h, d), rot = lovr.math.vec4(rotx, roty, rotz, rotw)})
    self.prevNodeTransform = lovr.math.newMat4(self.node.transform.matrix:unpack(true))
    self.prevIsKinematic = false

    -- Set the collider of the model based on the type of collider that is created
    if info.collider_type == "box" then
        self.collider = self.node.scene.physWorld:newBoxCollider(x, y, z, w, h, d)
    elseif info.collider_type == "capsule" then
        local length, radius = getLengthAndRadius(w, h, d)
        self.collider = self.node.scene.physWorld:newCapsuleCollider(x, y, z, info.radius or radius:length(), info.length or length)
    elseif info.collider_type == "cylinder" then
        local length, radius = getLengthAndRadius(w, h, d)
        self.collider = self.node.scene.physWorld:newCylinderCollider(x, y, z, info.radius or radius:length(), info.length or length)
    elseif info.collider_type == "sphere" then
        self.collider = self.node.scene.physWorld:newSphereCollider(x, y, z, info.radius or self.transform.scale:length())
    elseif info.collider_type == "mesh" then
        if not info.model then
            self.collider = self.node.scene.physWorld:newMeshCollider(info.vertices, info.indices)
        else
            self.collider = self.node.scene.physWorld:newMeshCollider(info.model)
        end
    else
        self.collider = self.node.scene.physWorld:newCollider(x, y, z)
    end

    -- Set the pose of the collider to that of the transform
    if self.collider then self.collider:setPose(Transform.getPose(self.transform.matrix)) end

    -- Add to bodies of node
    table.insert(self.node.attachments.bodies, self)
end

function Body:update()
    self:updateTransform()
end

function Body:updateTransform()
    if self.collider:isKinematic() == false then 
        --self.transform:setMatrix({pos = lovr.math.vec3(x, y, z), rot = lovr.math.vec4(angle, ax, ay, az)})
        self.transform:setMatrix({mat4 = lovr.math.mat4():translate(self.collider:getPosition()):rotate(self.collider:getOrientation())  })
    else
        local initialMat = lovr.math.mat4():translate(self.node.transform.position):rotate(self.node.transform.rotation.x, self.node.transform.rotation.y, self.node.transform.rotation.z, self.node.transform.rotation.w)
        local finalMat = initialMat:translate( Transform.getPositionFromMat4(self.offsetMatrix) ):rotate( Transform.getRotationFromMat4(self.offsetMatrix) )
        
        --[[local ref_prevNodeTransform = lovr.math.mat4():translate( Transform.getPositionFromMat4(self.prevNodeTransform) ):rotate( Transform.getRotationFromMat4(self.prevNodeTransform) ):scale(1, 1, 1)
        local ref_prevTransformMat = lovr.math.mat4():translate( Transform.getPositionFromMat4(self.prevTransformMat) ):rotate( Transform.getRotationFromMat4(self.prevTransformMat) ):scale(1, 1, 1)
        local ref_curNodeTransform = lovr.math.mat4():translate(self.node.transform.position):rotate(self.node.transform.rotation.x, self.node.transform.rotation.y, self.node.transform.rotation.z, self.node.transform.rotation.w):scale(1, 1, 1)

        local desiredCF = lovr.math.mat4(ref_curNodeTransform:unpack(true))

        local offset = ref_curNodeTransform:invert() * Transform.getTransformMatFromMat4(self.transform.matrix)
        local finalMat = desiredCF * offset
        local finalMatForTransform = Transform.getTransformMatFromMat4(finalMat)]]

        self.transform:setMatrix({mat4 = finalMat})

        self.collider:setPose(Transform.getPose(finalMat))
    end
end


--# Helper Functions
function Body:setKinematic(bool)
    self.collider:setKinematic(bool)

    if bool == true then
        --self.prevTransformMat = lovr.math.newMat4(self.node.transform.matrix:unpack(true))
        --self.offsetMatrix = self.prevTransformMat:mul(lovr.math.newMat4(self.transform.matrix:unpack(true)):invert())

        self.prevNodeTransform = lovr.math.newMat4(self.node.transform.matrix:unpack(true))
        self.prevTransformMat = lovr.math.newMat4(self.transform.matrix:unpack(true))
        --print("\n-------------------------------------------------")
        --print(Transform.getStringFromMat4(self.prevTransformMat))
        self.offsetMatrix = lovr.math.newMat4(self.prevTransformMat:unpack(true)):mul(lovr.math.newMat4(self.node.transform.matrix:unpack(true)):invert())

        --self.offsetMatrix = self.prevTransformMat:translate(-self.node.transform.position.x, -self.node.transform.position.y, -self.node.transform.position.z):rotate(-self.node.transform.rotation.x, -self.node.transform.rotation.y, -self.node.transform.rotation.z)
    else
        self.collider:setPose(Transform.getPose(self.transform.matrix))
    end
end


--# Finalize
return Body
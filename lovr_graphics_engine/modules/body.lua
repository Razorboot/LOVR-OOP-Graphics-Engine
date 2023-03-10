--# Include
local Node = require "lovr_graphics_engine.modules.node"
local Transform = require "lovr_graphics_engine.modules.transform"
local General = require "lovr_graphics_engine.modules.general"


--# Point
local Body = Node:extend()


--# Variables
local defaults = {
    position = lovr.math.newVec3(0, 0, 0),
    scale = lovr.math.newVec3(1, 1, 1),
    rotation = lovr.math.newVec4(0, 0, 0, 0)
}


--# Misc Functions
function getLengthAndRadius(w, h, d)
    local length = d
    local radius = lovr.math.vec2(w, h)

    return length, radius

    --[[if w > h and w > d then
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
    end]]
end


--# Core Methods
function Body:new(info)
    Node.newDefault(self, info)

    -- General
    self.name = info.name or "MyBody"
    self.type = "Body"

    -- Pose parameters for the collider
    local x, y, z = defaults.position.x, defaults.position.y, defaults.position.z
    local w, h, d = defaults.scale.x, defaults.scale.y, defaults.scale.z
    local rotx, roty, rotz, rotw = defaults.rotation.x, defaults.rotation.y, defaults.rotation.z, defaults.rotation.w

    --[[if info.transform then
        x, y, z = info.transform.position.x, info.transform.position.y, info.transform.position.z

        if info.use_dimensions == true then
            w, h, d = info.model:getDimensions()
            w, h, d = w * info.transform.scale.x, h * info.transform.scale.y, d * info.transform.scale.z
        end

        rotx, roty, rotz, rotw = info.transform.rotation.x, info.transform.rotation.y, info.transform.rotation.z, info.transform.rotation.w
    end]]

    if info.use_dimensions == true then
        w, h, d = info.model:getDimensions()
        w, h, d = w * info.scale.x, h * info.scale.y, d * info.scale.z
    end

    if info.dimensions then
        w, h, d = unpack(info.dimensions)
    end

    -- Set transform
    self.localTransform:setMatrix({scale = lovr.math.vec3(w, h, d)})

    -- Set the collider of the model based on the type of collider that is created
    self.model = info.model
    self.collider = nil
    self.colliderType = info.collider_type
    if info.collider_type == "box" then
        self.collider = self.scene.physWorld:newBoxCollider(x, y, z, w, h, d)
    elseif info.collider_type == "capsule" then
        local length, radius = getLengthAndRadius(w, h, d)
        self.collider = self.scene.physWorld:newCapsuleCollider(x, y, z, info.radius or radius:length(), info.length or length)
    elseif info.collider_type == "cylinder" then
        local length, radius = getLengthAndRadius(w, h, d)
        self.collider = self.scene.physWorld:newCylinderCollider(x, y, z, info.radius or radius:length(), info.length or length)
    elseif info.collider_type == "sphere" then
        self.collider = self.scene.physWorld:newSphereCollider(x, y, z, info.radius or self.localTransform.scale:length())
    elseif info.collider_type == "mesh" then
        if not info.model then
            self.collider = self.scene.physWorld:newMeshCollider(info.vertices, info.indices)
        else
            self.collider = self.scene.physWorld:newMeshCollider(info.model)
        end
    else
        self.collider = self.scene.physWorld:newCollider(x, y, z)
    end

    -- Set the pose of the collider to that of the transform
    if self.collider then self.collider:setPose(Transform.getPose(self.globalTransform.matrix)) end
end

function Body:destroy()
    self.collider:destroy()
    Node.destroyDefault(self)
end


--# Update Methods
function Body:update()
    if self.collider:isKinematic() == true then
        -- Only update the global transform since the local transform is set manually
        self:updateGlobalTransform()
    else
        -- Transform is now 100% physics based, meaning local transform has to be recalculated after global transform is changed
        self:updateGlobalTransform()
    end

    -- Change size of the selection box to reflect these changes
    if self.localTransform.changed == true then
        self.selectionCollider:getShapes()[1]:setDimensions(self.localTransform.scale:unpack())
    end
end

function Body:updateGlobalTransform()
    if self.collider then
        if self.collider:isKinematic() == false then
            -- Rigidbody is physical, meaning the global transform is always that of the rigidbody
            local x, y, z, rotx, roty, rotz, rotw = self.collider:getPose()
            self.globalTransform:setMatrix({ position = lovr.math.vec3(x, y, z), rotation = lovr.math.vec4(rotx, roty, rotz, rotw) })
            self:updateLocalTransform()

            -- Change size of the selection box to reflect these changes
            self.selectionCollider:getShapes()[1]:setDimensions(self.localTransform.scale:unpack())

            for _, descendantNode in pairs(self:getDescendants()) do
                descendantNode:updateGlobalTransform()
            end
        else
            if self.localTransform.changed == false and self.globalTransform.changed == false and self.parent.globalTransform.changed == false then return false end
            
            --[[local x, y, z = self.parent.globalTransform.position:unpack()
            local rotx, roty, rotz, rotw = self.parent.globalTransform.rotation:unpack()

            -- initial mat is the global node transform
            local initialMat = lovr.math.mat4():translate(x, y, z):rotate(rotx, roty, rotz, rotw):scale(1, 1, 1)
            local finalMat = initialMat * lovr.math.mat4(self.localTransform.matrix:unpack(true))

            -- Finalize
            self.globalTransform:setMatrix({matrix = finalMat})
            self.collider:setPose(Transform.getPose(finalMat))]]

            -- If this is a root node then no update is needed
            if self.parent == nil then
                self.globalTransform:setMatrix({matrix = self.localTransform.matrix})
                
                for _, descendantNode in pairs(self:getDescendants()) do
                    descendantNode:updateGlobalTransform()
                end

                return 
            end

            -- Get parent global transform
            local newTempTransformMatrix = lovr.math.mat4(self.parent.globalTransform.matrix:unpack(true))
            newTempTransformMatrix:translate(self.localTransform.position):rotate(self.localTransform.rotation.x, self.localTransform.rotation.y, self.localTransform.rotation.z, self.localTransform.rotation.w)

            -- Finalize
            self.globalTransform:setMatrix({
                position = lovr.math.vec3(Transform.getPositionFromMat4(newTempTransformMatrix)),
                rotation = lovr.math.vec4(Transform.getRotationFromMat4(newTempTransformMatrix))
            })

            self.collider:setPose(Transform.getPose(lovr.math.mat4(self.globalTransform.matrix:unpack(true))))

            -- Change size of the selection box to reflect these changes
            self.selectionCollider:getShapes()[1]:setDimensions(self.localTransform.scale:unpack())

            for _, descendantNode in pairs(self:getDescendants()) do
                descendantNode:updateGlobalTransform()
            end
        end
    end
end


--# Helper Methods
function Body:setKinematic(bool)
    self.collider:setKinematic(bool)

    -- true means the collider is attached
    if bool == true then
        self:updateLocalTransform()
    end
end

function Body:setGlobalPosition(...)
    local pos = General.getVec3From(...)
    local primaryMatrix = lovr.math.mat4():translate(pos):rotate(self.globalTransform.rotation.x, self.globalTransform.rotation.y, self.globalTransform.rotation.z, self.globalTransform.rotation.w)

    if self.collider:isKinematic() == true then
        local finalMat = Transform.getMatrixRelativeTo(primaryMatrix, self.parent.globalTransform.matrix)
        self.localTransform:setMatrix({ position = lovr.math.vec3(Transform.getPositionFromMat4(finalMat)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(finalMat)) })
    else
        self.collider:setPose(Transform.getPose(primaryMatrix))
    end

    self:updateGlobalTransform()
end

function Body:setGlobalRotation(...)
    local rot = General.getVec4From(...)
    local primaryMatrix = lovr.math.mat4():translate(self.globalTransform.position):rotate(rot:unpack())

    if self.collider:isKinematic() == true then
        local finalMat = Transform.getMatrixRelativeTo(primaryMatrix, self.parent.globalTransform.matrix)
        self.localTransform:setMatrix({ position = lovr.math.vec3(Transform.getPositionFromMat4(finalMat)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(finalMat)) })
    else
        self.collider:setPose(Transform.getPose(primaryMatrix))
    end

    self:updateGlobalTransform()
end

function Body:setGlobalTransformMatrix(mat4)
    local primaryMatrix = lovr.math.mat4():translate( Transform.getPositionFromMat4(mat4) ):rotate( Transform.getRotationFromMat4(mat4) )
    
    if self.collider:isKinematic() == true then
        local finalMat = Transform.getMatrixRelativeTo(primaryMatrix, self.parent.globalTransform.matrix)
        self.localTransform:setMatrix({ position = lovr.math.vec3(Transform.getPositionFromMat4(finalMat)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(finalMat)) })
    else
        self.collider:setPose(Transform.getPose(primaryMatrix))
    end
    
    self:updateGlobalTransform()
end


--# Finalize
return Body
--# Include
local Object = require "lovr_graphics_engine.libs.classic"
local Transform = require "lovr_graphics_engine.modules.transform"
local General = require "lovr_graphics_engine.modules.general"


--# Point
local Node = Object:extend()


--# Misc Methods
function Node.newDefault(object, info)
    if not info.scene then error("This Node is not attached to a scene!") return nil end
    
    -- General
    object.name = info.name or "MyNode"
    object.type = "Node"
    object.visible = true or info.visible

    -- Scene graph implementation
    object.scene = info.scene
    object.parent = info.parent
    object.children = {}

    -- Add to parent children
    if object.parent then
        table.insert(object.parent.children, object)
    end

    -- Other
    object.localTransform = Transform()
    object.globalTransform = Transform()

    -- Collision box - for selecting the object with your mouse in the editor
    object.selectionCollider = info.scene.selectionWorld:newBoxCollider(0, 0, 0, 1, 1, 1)
    object.selectionCollider:getShapes()[1]:setSensor(true)

    object:updateGlobalTransform()
end

function Node.destroyDefault(object)
    -- Remove all child nodes
    for _, node in pairs(object.children) do
        node:destroy()
    end

    -- Remove the node from the parent node children
    --if object.parent then
        --[[for i, node in pairs(object.parent.children) do
            if node == object then 
                table.remove(object.parent.children, i)
                object.parent = nil
                setmetatable(object, nil)
                object = getmetatable(object)
                return
            end
        end]]
    --end
    object:setParent()

    object.__index = nil
    setmetatable(object, nil)
    object = nil
end


--# Core Methods
function Node:new(info)
    Node.newDefault(self, info)
end

function Node:destroy()
    Node.destroyDefault(self)
end


--# Helper Methods
function Node:setParent(newParent)
    local prevParent = self.parent
    self.parent = newParent

    -- Self node is no longer a part of the old parent node, so we must remove it.
    if prevParent then
        for i, node in pairs(prevParent.children) do
            if node == self then table.remove(prevParent.children, i) end
        end
    end

    -- We need to move self node to the new parent node children.
    if newParent then
        table.insert(newParent.children, self)
    end
end

function Node:findFirstChild(name)
    -- Search all children of the node until found.
    for _, node in pairs(self.children) do
        if node.name == name then return node end
    end

    print("Child named ("..name..") not found.")
end

function Node:findFirstParent(name)
    -- If name argument not passed in, then just return the self.parent.
    if not name then return self.parent end
    
    -- Search all parents of the node until the node with that name is found.
    local currentParent = self.parent
    local iteration = 0
    repeat
        iteration = iteration + 1
        if currentParent.name == name then return currentParent end
        if currentParent.parent ~= nil then
            currentParent = currentParent.parent
        else
            break
        end
    until iteration > 999

    print("Parent named ("..name..") not found.")
end

function Node:getRoot()
    -- Return current node object if it is the root node.
    if self.scene then
        if self.scene.root == self then return self end
    end
    if self.parent == nil then
        return self
    end

    -- Go up the scene graph until root node found.
    local currentParent = self.parent
    repeat
        currentParent = currentParent.parent
    until currentParent == nil

    return currentParent
end

function Node:getDescendants()
    local descendants = {}

    local function Scan(parent)
        for _,v in pairs(parent.children) do
            table.insert(descendants, v)
            Scan(v)
        end
    end

    Scan(self)
    return descendants
end

function Node:findFirstDescendant(name)
    local descendants = self:getDescendants()

    for _, node in pairs(descendants) do
        if node.name == name then return node end
    end
end

--# Misc Methods
function Node:setGlobalPosition(...)
    local pos = General.getVec3From(...)

    local primaryMatrix = lovr.math.mat4():translate(pos):rotate(self.globalTransform.rotation.x, self.globalTransform.rotation.y, self.globalTransform.rotation.z, self.globalTransform.rotation.w)
    local finalMat = nil
    if self.parent then
        finalMat = Transform.getMatrixRelativeTo(primaryMatrix, self.parent.globalTransform.matrix)
    else
        finalMat = primaryMatrix
    end
    self.localTransform:setMatrix({ position = lovr.math.vec3(Transform.getPositionFromMat4(finalMat)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(finalMat)) })
    self:updateGlobalTransform()
end

function Node:setGlobalRotation(...)
    local rot = General.getVec4From(...)

    local primaryMatrix = lovr.math.mat4():translate(self.globalTransform.position):rotate(rot:unpack())
    local finalMat = nil
    if self.parent then
        finalMat = Transform.getMatrixRelativeTo(primaryMatrix, self.parent.globalTransform.matrix)
    else
        finalMat = primaryMatrix
    end
    self.localTransform:setMatrix({ position = lovr.math.vec3(Transform.getPositionFromMat4(finalMat)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(finalMat)) })
    self:updateGlobalTransform()
end

function Node:setGlobalTransformMatrix(mat4)
    local primaryMatrix = lovr.math.mat4():translate( Transform.getPositionFromMat4(mat4) ):rotate( Transform.getRotationFromMat4(mat4) )
    local finalMat = nil
    if self.parent then
        finalMat = Transform.getMatrixRelativeTo(primaryMatrix, self.parent.globalTransform.matrix)
    else
        finalMat = primaryMatrix
    end
    self.localTransform:setMatrix({ position = lovr.math.vec3(Transform.getPositionFromMat4(finalMat)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(finalMat)) })
    self:updateGlobalTransform()
end

function Node:setLocalPosition(...)
    local pos = General.getVec3From(...)
    self.localTransform:setMatrix({position = pos})
    self:updateGlobalTransform()
end

function Node:setLocalRotation(...)
    local rot = General.getVec4From(...)
    self.localTransform:setMatrix({rotation = lovr.math.vec4(rot:unpack())})
    self:updateGlobalTransform()
end

function Node:setLocalTransformMatrix(mat4)
    self.localTransform:setMatrix({position = lovr.math.vec3(Transform.getPositionFromMat4(mat4)), rotation = lovr.math.vec4(Transform.getRotationFromMat4(mat4)), scale = lovr.math.vec3(Transform.getScaleFromMat4(mat4)) })
    self:updateGlobalTransform()
end

function Node:setScale(...)
    local sc = General.getVec3From(...)
    self.localTransform:setMatrix({scale = sc})
    self:updateGlobalTransform()
end

function Node:lookAt(...)
    local pos = General.getVec3From(...)
    local normPos = lovr.math.vec3(pos:unpack()) - lovr.math.vec3(self.globalTransform.position:unpack())
    local newRot = lovr.math.quat(normPos:normalize())
    self:setGlobalRotation(lovr.math.vec4(newRot:unpack()))
end

function Node:lookToward(...)
    local direction = General.getVec3From(...)
    local newRot = lovr.math.quat(lovr.math.vec3(direction:unpack()):normalize())
    self:setGlobalRotation(lovr.math.vec4(newRot:unpack()))
end

function Node:getLookVector()
    return lovr.math.quat(self.globalTransform.rotation:unpack()):direction()
end


--# Update Methods
function Node:updateLocalTransform()
    -- If this is a root node then no update is needed
    if self.parent == nil then
        self.localTransform:setMatrix({matrix = self.globalTransform.matrix})
        return 
    end

    -- No update is needed if the parent global transform or the current global transform wasn't modified
    if self.parent.globalTransform.changed == false and self.globalTransform.changed == false then
        return
    end

    -- Action
    local prevTransformMat = lovr.math.mat4():translate(self.globalTransform.position):rotate(self.globalTransform.rotation.x, self.globalTransform.rotation.y, self.globalTransform.rotation.z, self.globalTransform.rotation.w)

    -- Get parent global transform
    local newTempTransformMatrix = self.parent.globalTransform.matrix

    -- Get the offset matrix from the detached GLOBAL transform to the parent node
    local prevTransformMat_inverted = lovr.math.mat4(prevTransformMat:unpack(true)):invert()
    local nodeTransform_new = lovr.math.mat4(newTempTransformMatrix:unpack(true))
    local offsetMatrix = prevTransformMat_inverted:mul(nodeTransform_new)
    offsetMatrix = lovr.math.mat4():translate( Transform.getPositionFromMat4(offsetMatrix) ):rotate( Transform.getRotationFromMat4(offsetMatrix) )
    offsetMatrix = offsetMatrix:invert()

    -- Finalize
    self.localTransform:setMatrix({
        position = lovr.math.vec3(Transform.getPositionFromMat4(offsetMatrix)), 
        rotation = lovr.math.vec4(Transform.getRotationFromMat4(offsetMatrix)), 
        scale = lovr.math.vec3(Transform.getScaleFromMat4(offsetMatrix))
    })
end

function Node:updateGlobalTransform()
    -- If this is a root node then no update is needed
    if self.parent == nil then
        --self.globalTransform:setMatrix({matrix = self.localTransform.matrix})
        self.globalTransform:setMatrix({
            position = lovr.math.vec3(self.localTransform.position:unpack()),
            rotation = lovr.math.vec4(self.localTransform.rotation:unpack()),
            scale = lovr.math.vec3(self.localTransform.scale.x, self.localTransform.scale.y, self.localTransform.scale.z)
        })

        -- Make sure the selection collider gets updated
        self.selectionCollider:setPose(Transform.getPose(self.globalTransform.matrix))

        -- This is only required on the global transform update, because updating the local transform consequently updates the global transform.
            -- Bodies are a special case though because their transform can be independent and therefore all child transforms must be updated accordingly.
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
        rotation = lovr.math.vec4(Transform.getRotationFromMat4(newTempTransformMatrix)),
        scale = lovr.math.vec3(self.localTransform.scale.x, self.localTransform.scale.y, self.localTransform.scale.z)
    })

    -- Make sure the selection collider gets updated
    self.selectionCollider:setPose(Transform.getPose(self.globalTransform.matrix))

    -- This is only required on the global transform update, because updating the local transform consequently updates the global transform.
        -- Bodies are a special case though because their transform can be independent and therefore all child transforms must be updated accordingly.
    for _, descendantNode in pairs(self:getDescendants()) do
        descendantNode:updateGlobalTransform()
    end
end


--# Finalize
return Node
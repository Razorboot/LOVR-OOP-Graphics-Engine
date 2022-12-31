--# Include
local Object = require "libs.classic"
local Transform = require "modules.transform"


--# Point
local Model = Object:extend()


--# Variables
assets = 'assets/'

local defaults = {
    diffuseMap_filepath = tostring(assets..'textures/brick_diff.png'),
    specularMap_filepath = tostring(assets..'textures/brick_spec.png'),
    normalMap_filepath = tostring(assets..'textures/brick_norm.png'),
}


--# Core Functions
function Model:new(node, info)
    -- Presets
    self.node = node
    self.name = info.model_name or tostring("Model ("..tostring(#node.attachments.models + 1)..")")

    self.modelInstance = lovr.graphics.newModel(info.model_filepath)
    self.offsetTransform = Transform({
        pos = node.transform.position + (info.model_position or lovr.math.vec3(0, 0, 0)), 
        rot = node.transform.rotation + (info.model_rotation or lovr.math.vec4()),
        scale = node.transform.scale + (info.model_scale or lovr.math.vec3(1, 1, 1))
    })
    self.globalTransform = Transform()
    self.diffuseMap = lovr.graphics.newTexture(info.diffuseMap_filepath or defaults.diffuseMap_filepath )
    self.specularMap = lovr.graphics.newTexture(info.specularMap_filepath or defaults.specularMap_filepath )
    self.normalMap = lovr.graphics.newTexture(info.normalMap_filepath or defaults.normalMap_filepath )

    -- Physics
    self.collider = nil

    -- General vars
    self.type = "model"

    -- Insert the instance into the node models array
    table.insert(node.attachments.models, self)
end

function Model:update()
    if self.collider then
        local x, y, z = self.collider:getPosition()
	    local angle, ax, ay, az = self.collider:getOrientation()

        self.offsetTransform:setMatrix({pos = lovr.math.vec3(x, y, z), rot = lovr.math.vec4(angle, ax, ay, az) })
    end

    self:updateGlobalTransform()
end

function Model:draw(pass, mode)
    local useParentNodeTransform = true

    -- if the model has a collider, then we want to render only it's own transform and not the transform of the parent node multiplied by offsetTransform
    if self.collider then
        --if self.collider:isAwake() == true then
            useParentNodeTransform = false
        --end
    end

    -- Set the current textures of the pass to the model textures
    if mode == "full" then
        pass:send( 'diffuseMap', self.diffuseMap )
	    pass:send( 'specularMap', self.specularMap )
	    pass:send( 'normalMap', self.normalMap )
    end

    -- Draw the actual model
    if useParentNodeTransform == true then
        --[[local initialMat = lovr.math.mat4():translate(self.node.transform.position):rotate(self.node.transform.rotation.x, self.node.transform.rotation.y, self.node.transform.rotation.z, self.node.transform.rotation.w)
        local finalMat = initialMat:translate(self.offsetTransform.position):rotate(self.offsetTransform.rotation.x, self.offsetTransform.rotation.y, self.offsetTransform.rotation.z, self.offsetTransform.rotation.w):scale(self.offsetTransform.scale.x, self.offsetTransform.scale.y, self.offsetTransform.scale.z)]]
        
        pass:draw( self.modelInstance, self.globalTransform.matrix )
    else
        pass:draw( self.modelInstance, self.offsetTransform.matrix )
    end
end

function Model:updateGlobalTransform()
    local initialMat = lovr.math.mat4():translate(self.node.transform.position):rotate(self.node.transform.rotation.x, self.node.transform.rotation.y, self.node.transform.rotation.z, self.node.transform.rotation.w)
    local finalMat = initialMat:translate(self.offsetTransform.position):rotate(self.offsetTransform.rotation.x, self.offsetTransform.rotation.y, self.offsetTransform.rotation.z, self.offsetTransform.rotation.w):scale(self.offsetTransform.scale.x, self.offsetTransform.scale.y, self.offsetTransform.scale.z)

    self.globalTransform:setMatrix({mat4 = finalMat})
end


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

function Model:setCollider(info)
    local x, y, z = self.offsetTransform.position.x, self.offsetTransform.position.y, self.offsetTransform.position.z
    local w, h, d = 1, 1, 1

    if info.use_dimensions == true then
        w, h, d = self.modelInstance:getDimensions()
    end

    -- Set the collider of the model based on the type of collider that is created
    if info.collider_type == "box" then
        self.collider = self.node.scene.physWorld:newBoxCollider(info.x or x, info.y or y, info.z or z, info.w or w, info.h or h, info.d or d)
    elseif info.collider_type == "capsule" then
        local length, radius = getLengthAndRadius(w, h, d)
        self.collider = self.node.scene.physWorld:newCapsuleCollider(info.x or x, info.y or y, info.z or z, info.radius or radius:length(), info.length or length)
    elseif info.collider_type == "cylinder" then
        local length, radius = getLengthAndRadius(w, h, d)
        self.collider = self.node.scene.physWorld:newCylinderCollider(info.x or x, info.y or y, info.z or z, info.radius or radius:length(), info.length or length)
    elseif info.collider_type == "sphere" then
        self.collider = self.node.scene.physWorld:newSphereCollider(info.x or x, info.y or y, info.z or z, info.radius or lovr.math.vec3(w, h, d):length())
    elseif info.collider_type == "mesh" then
        if not info.model then
            self.collider = self.node.scene.physWorld:newMeshCollider(info.vertices, info.indices)
        else
            self.collider = self.node.scene.physWorld:newMeshCollider(info.model)
        end
    else
        self.collider = self.node.scene.physWorld:newCollider(info.x or x, info.y or y, info.z or z)
    end
end


--# Finalize
return Model
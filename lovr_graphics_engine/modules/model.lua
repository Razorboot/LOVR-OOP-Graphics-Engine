--# Include
local Object = require "lovr_graphics_engine.libs.classic"
local Transform = require "lovr_graphics_engine.modules.transform"


--# Point
local Model = Object:extend()


--# Variables
assets = 'lovr_graphics_engine/assets_default/'

local defaults = {
    diffuseMap_filepath = tostring(assets..'textures/brick_diff.png'),
    specularMap_filepath = tostring(assets..'textures/brick_spec.png'),
    normalMap_filepath = tostring(assets..'textures/brick_norm.png'),
    texture_mode = "UV"
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
    self.textureMode = info.texture_mode or defaults.texture_mode

    -- Addorn the model to a physics body
    self.affixer = nil -- If set to nil, the model will just be attached to the node

    -- Set the transform
    self:updateGlobalTransform()

    -- General vars
    self.type = "model"

    -- Insert the instance into the node models array
    table.insert(node.attachments.models, self)
end

function Model:update()
    self:updateGlobalTransform()
end

function Model:draw(pass, mode)
     -- Set the current textures of the pass to the model textures
     if mode == "full" then
        pass:send( 'normalMap', self.normalMap )
        pass:send( 'diffuseMap', self.diffuseMap )
	    pass:send( 'specularMap', self.specularMap )
	    pass:send( 'normalMap', self.normalMap )

        local texInt = 0
        if self.textureMode == "UV" then
            texInt = 0
        elseif self.textureMode == "Tile" then
            texInt = 1
        end
        pass:send( 'textureMode', texInt )
    end

    pass:draw( self.modelInstance, self.globalTransform.matrix )
end

function Model:updateGlobalTransform()
    local initialMat

    -- Set the initial transform to that of the affixer if it exists.
    -- Otherwise, the parent node transform is used.
    if self.affixer == nil then
        initialMat = lovr.math.mat4():translate(self.node.transform.position):rotate(self.node.transform.rotation.x, self.node.transform.rotation.y, self.node.transform.rotation.z, self.node.transform.rotation.w)
    else
        local affixerTransform
        if (self.affixer.type == "node" or self.affixer.type == "body") then
            affixerTransform = self.affixer.transform
        else
            affixerTransform = self.affixer.globalTransform
        end

        initialMat = lovr.math.mat4():translate(affixerTransform.position):rotate(affixerTransform.rotation.x, affixerTransform.rotation.y, affixerTransform.rotation.z, affixerTransform.rotation.w)
    end

    local finalMat = initialMat:translate(self.offsetTransform.position):rotate(self.offsetTransform.rotation.x, self.offsetTransform.rotation.y, self.offsetTransform.rotation.z, self.offsetTransform.rotation.w):scale(self.offsetTransform.scale.x, self.offsetTransform.scale.y, self.offsetTransform.scale.z)

    self.globalTransform:setMatrix({mat4 = finalMat})
end


--# Finalize
return Model
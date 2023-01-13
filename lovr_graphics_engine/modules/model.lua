--# Include
local Node = require "lovr_graphics_engine.modules.node"
local Transform = require "lovr_graphics_engine.modules.transform"


--# Point
local Model = Node:extend()


--# Variables
assets = 'lovr_graphics_engine/assets_default/'

local defaults = {
    diffuseMap_filepath = tostring(assets..'textures/brick_diff.png'),
    specularMap_filepath = tostring(assets..'textures/brick_spec.png'),
    normalMap_filepath = tostring(assets..'textures/brick_norm.png'),
    texture_mode = "UV",
    tile_scale = 1.0
}


--# Core Methods
function Model:new(info)
    Node.newDefault(self, info)

    -- General
    self.name = info.name or "MyModel"
    self.type = "Model"

    -- Specific variables
    self.filepath = info.filepath
    self.modelInstance = lovr.graphics.newModel(info.filepath)
    self.diffuseMap_filepath = info.diffuseMap_filepath or defaults.diffuseMap_filepath
    self.diffuseMap = lovr.graphics.newTexture(self.diffuseMap_filepath )
    self.specularMap_filepath = info.specularMap_filepath or defaults.specularMap_filepath
    self.specularMap = lovr.graphics.newTexture(self.specularMap_filepath )
    self.normalMap_filepath = info.normalMap_filepath or defaults.normalMap_filepath
    self.normalMap = lovr.graphics.newTexture(self.normalMap_filepath )

    -- Texturing properties
    self.textureMode = info.texture_mode or defaults.texture_mode
    self.tileScale = info.tile_scale or lovr.math.newVec3(defaults.tile_scale, defaults.tile_scale, defaults.tile_scale)
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
        local w, h, d = self.modelInstance:getDimensions()

        pass:send( 'textureMode', texInt )
        pass:send( 'objPos', {self.globalTransform.position.x, self.globalTransform.position.y, self.globalTransform.position.z} )
        pass:send( 'objScale', {w * self.localTransform.scale.x, h * self.localTransform.scale.y, d * self.localTransform.scale.z} )
        pass:send( 'objTileScale', {self.tileScale.x, self.tileScale.y, self.tileScale.z} )

        local normMatrix = lovr.math.mat4():translate(self.globalTransform.position):rotate(self.globalTransform.rotation.x, self.globalTransform.rotation.y, self.globalTransform.rotation.z, self.globalTransform.rotation.w):scale(self.globalTransform.scale)
        normMatrix = (normMatrix:invert()):transpose()
        pass:send( 'inverseNormalMatrix', {normMatrix:unpack(true)} )

        --[[local modelMatrix = lovr.math.mat4():translate(self.globalTransform.position):rotate(-self.globalTransform.rotation.x, -self.globalTransform.rotation.y, -self.globalTransform.rotation.z, -self.globalTransform.rotation.w):scale(self.localTransform.scale * lovr.math.vec3(w, h, d))
        pass:send( 'triplanarModelMatrix', {modelMatrix:unpack(true)} )]]
    end

    pass:draw( self.modelInstance, self.globalTransform.matrix )
end


--# Update Methods
function Model:update()
    --[[ No need to continue if there was no change in:
        1.) local transform
        2.) global transform
        3.) global transform of the parent
    ]]
    if self.localTransform.changed == false and self.globalTransform.changed == false and self.parent.globalTransform.changed == false then return false end

    -- Local transform is set manually, this means we only need to update the global transform to reflect changes in local transform
    self:updateGlobalTransform()
end


--# Finalize
return Model
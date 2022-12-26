--# Include
local Object = require "libs.classic"
local Transform = require "modules.transform"


--# Variables
assets = 'assets/'


--# Point
local Node = Object:extend()


--# Variables
local defaults = {
    node_name = "NodeNew",
    light_depthSize = 1024*2
}


--# Methods
function Node:new(info)
    -- Base attachments: Attachments are different attributes a node can have, like a model, lightsource, etc.
    self.name = info.node_name or "Node"..tostring(#info.node_scene.nodes + 1) or "NodeNew"
    self.attachments = {}
    self.attachments.models = {}
    self.attachments.lights = {}

    -- Transform: Transform matrix using my transform class.
    self.transform = Transform()

    --[[m1, m2, m3, m4,
    m5, m6, m7, m8,
    m9, m10, m11, m12,
    m13, m14, m15, m16 --> x, y, z, w]]
end

-- A model is an attribute that a node can have: Includes textures, and the model mesh itself.
function Node:attachModel(info)
    local modelManifold = {}
    modelManifold.offsetTransform = Transform()
    modelManifold.model = lovr.graphics.newModel(info.model_filepath)
    modelManifold.diffuseMap = lovr.graphics.newTexture(info.diffuseMap_filepath or tostring(assets..'textures/brick_diff.png') )
    modelManifold.specularMap = lovr.graphics.newTexture(info.specularMap_filepath or tostring(assets..'textures/brick_spec.png') )
    modelManifold.normalMap = lovr.graphics.newTexture(info.normalMap_filepath or tostring(assets..'textures/brick_norm.png') )
    
    -- Apply the model manifold to the model attachments and finalize.
    local newIndex = #self.attachments.models + 1
    self.attachments.models[newIndex] = modelManifold
    return self.attachments.models[newIndex]
end

-- A lightsource is another attribute: Includes the type of light source, whether shadows are enabled, other lighting properties.
function Node:attachLightSource(info)
    local lightManifold = {}

    -- General light vars
    lightManifold.offsetTransform = Transform()
    lightManifold.type = info.light_type or "pointLight"

    lightManifold.color = info.light_color
    lightManifold.ambience = info.light_ambience
    lightManifold.pos = info.light_pos
    lightManifold.range = info.light_range

    -- Specific light settings
    if lightManifold.type == "spotLight" then
        lightManifold.spotDir = info.spot_dir
        lightManifold.angle = info.light_angle
    elseif lightManifold.type == "pointLight" then

    end

    -- Shadow settings
    if info.light_hasShadows == true and lightManifold.type == "spotLight" then
        local depthBufferSize = info.light_depthSize or defaults.light_depthSize
        lightManifold.depthTex = lovr.graphics.newTexture(depthBufferSize, depthBufferSize, {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})
    end

    -- Apply the light manifold to the light attachments and finalize.
    local newIndex = #self.attachments.lights + 1
    self.attachments.lights[newIndex] = modelManifold
    return self.attachments.lights[newIndex]
end


--# Finalize
return Node
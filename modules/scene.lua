--# Include
local Object = require "libs.classic"
local forwardShader = require 'shaders.forward_arrays'


--# Point
local Scene = Object:extend()


--# Creation Functions
function Scene:new(nodes)
    -- All the nodes in the scene
    self.nodes = nodes or {}

    -- Default variables
    self.defaults = {
        light_depthSize = 1024*1.5,
        depthTexOptions = { format = 'd32f', mipmaps = false, usage = { 'render', 'sample' } }
    }
    self.lighting = {
        ambience = lovr.math.newVec3((9/255) * 0.55, (9/255) * 0.55, (15/255) * 0.55)
    }

    -- Timer
	lovr.timer.step() -- Reset the timer before the first update
    self.timer = 0

    -- Rendering
    self.passes = {}
    
    -- Camera (Soon to be replaced with it's own class)
    self.hx, self.hy, self.hz = 0, 0, 0

    -- Physics
        -- Create Physics World
	self.physWorld = lovr.physics.newWorld( nil, nil, nil, false )
	self.physWorld:setLinearDamping( .01 )
	self.physWorld:setAngularDamping( .005 )

    -- Lights
    self.lightDepthTexArray = nil
    self.lightDepthTexArray_Views = {}
    self:resetShadows()
end


--# Helper Functions
function Scene:getModels()
    local models = {}

    for _, node in pairs(self.nodes) do
        for _, model in pairs(node.attachments.models) do
            table.insert(models, model)
        end
    end

    return models
end

function Scene:getLights(info)
    local lights = {}
    info = info or {}

    for _, node in pairs(self.nodes) do
        for _, light in pairs(node.attachments.lights) do
            if (info.only_shadows or false) == true then
                if light.hasShadows == true then table.insert(lights, light) end
            else
                table.insert(lights, light)
            end
        end
    end

    return lights
end

function Scene:getBodies()
    local bodies = {}

    for _, node in pairs(self.nodes) do
        for _, body in pairs(node.attachments.bodies) do
            table.insert(bodies, body)
        end
    end

    return bodies
end


function Scene:getNode(name)
    for _, node in pairs(self.nodes) do
        if node.name == name then return node end
    end
end

function Scene:resetShadows()
    local allLights = self:getLights()
    if #allLights < 1 then allLights = {1} end

    --self.lightDepthTexArray = lovr.graphics.newTexture( depthBufferSize, depthBufferSize, #self:getLights({only_shadows = true}), depthTexOptions )
    local depthBufferSize = self.defaults.light_depthSize
    self.lightDepthTexArray = lovr.graphics.newTexture( depthBufferSize, depthBufferSize, #allLights, self.defaults.depthTexOptions )
    self.lightDepthTexArray_Views = {}
    for i = 1, #allLights do
        table.insert(self.lightDepthTexArray_Views, self.lightDepthTexArray:newView('array', i, 1, 1, 1))
    end
end


--# Draw Functions
function Scene:drawDepth(pass, proj, pose)
    -- Set view to that of the light source or whatever proj/pose
    pass:setProjection( 1, proj )
	pass:setViewPose( 1, pose )

    -- Render all models
    for _, model in pairs(self:getModels()) do
        model:draw(pass, "depth")
    end
end

function Scene:drawFull(pass)
    -- Presets
    pass:setCullMode( 'back' )
	pass:setViewPose( 1, lovr.headset.getPose() )

    -- Create the buffers for the necessary values of each light source
    local vec4_light_origins = {}
	local vec4_light_targets = {}
	local vec4_spotDirs = {}
	local light_space_matrices = {}
	local light_ranges = {}
	local light_cutOffs = {}

    local light_colors = {}
    local light_shadowsEnabled = {}
    local light_types = {}

    local allLights = self:getLights()

    for i, light in pairs(allLights) do
        local target = light:getTarget()

		local light_origin_vec4 = lovr.math.vec4(light.globalTransform.position.x, light.globalTransform.position.y, light.globalTransform.position.z, 0)
		local light_target_vec4 = lovr.math.vec4(target.x, target.y, target.z, 0)
		local spotDir_vec4 = (light_target_vec4:sub( light_origin_vec4 )):normalize()

        local projMultView
        if light.hasShadows == true then
            projMultView = light.projection * light.view
        else
            projMultView = lovr.math.mat4()
        end

		table.insert(vec4_light_origins, light_origin_vec4)
		table.insert(vec4_light_targets, light_target_vec4)
		table.insert(vec4_spotDirs, spotDir_vec4)
		table.insert(light_space_matrices, projMultView)
		table.insert(light_ranges, light.range)
		table.insert(light_cutOffs, light.angle )

        local shadowsInt = 0
        if light.hasShadows == true then shadowsInt = 1 end
        table.insert(light_shadowsEnabled, shadowsInt )

        local typeInt = 0
        if light.type == "pointLight" then typeInt = 1 elseif light.type == "spotLight" then typeInt = 0 end
        table.insert(light_types, typeInt )

        table.insert(light_colors, lovr.math.vec4(light.color.x, light.color.y, light.color.z, 1.0) )
	end

    -- The final render shader
	pass:setShader( forwardShader )
	pass:setViewPose( 1, lovr.headset.getPose() )

    lightColor_Buffer = lovr.graphics.getBuffer( light_colors, 'vec4' )
    lightPos_Buffer = lovr.graphics.getBuffer( vec4_light_origins, 'vec4' )
	spotDir_Buffer = lovr.graphics.getBuffer( vec4_spotDirs, { 'vec4', layout = 'std140' } )
	LightSpaceMatrix_Buffer = lovr.graphics.getBuffer( light_space_matrices, 'mat4' )
	cutOff_Buffer = lovr.graphics.getBuffer( light_cutOffs, { 'float', layout = 'std140' } )
	range_Buffer = lovr.graphics.getBuffer( light_ranges, { 'float', layout = 'std140' } )

    type_Buffer = lovr.graphics.getBuffer( light_types, 'int' )
    hasShadows_Buffer = lovr.graphics.getBuffer( light_shadowsEnabled, 'int' )

    --[[pass:send( 'lightType_Buffer', type_Buffer )
    pass:send( 'lightHasShadows_Buffer', hasShadows_Buffer )]]

    -- Send all buffers
	pass:send( 'liteColor_Buffer', lightColor_Buffer )
	pass:send( 'lightPos_Buffer', lightPos_Buffer )
	pass:send( 'spotDir_Buffer', spotDir_Buffer )
	pass:send( 'LightSpaceMatrix_Buffer', LightSpaceMatrix_Buffer )
	pass:send( 'cutOff_Buffer', cutOff_Buffer )
	pass:send( 'range_Buffer', range_Buffer )

    pass:send( 'lightType_Buffer', type_Buffer )
    pass:send( 'lightHasShadows_Buffer', hasShadows_Buffer )

    -- Set the shader constants!
	pass:send( 'numLights', #allLights )
	pass:send( 'viewPos', { self.hx, self.hy, self.hz } )
	pass:send( 'ambience', { self.lighting.ambience.x, self.lighting.ambience.y, self.lighting.ambience.z, 1.0 } )
	pass:send( 'specularStrength', 3.0 )
	pass:send( 'metallic', 32.0 )
	pass:send( 'texelSize', 1.0 / self.defaults.light_depthSize )

	-- Send all of the light shadowmaps
	pass:send( 'depthBuffers', self.lightDepthTexArray )

	-- Render all models with textures applied
    for _, model in pairs(self:getModels()) do
        model:draw(pass, "full")
    end

    -- Submit passes 
    pass:setShader()

    --pass:sphere( lovr.math.vec3(0, 0.5, 0), 0.1 ) -- Represents light origin

	table.insert( self.passes, pass )

    -- Finalize
	return lovr.graphics.submit( self.passes )
end


--# Update Functions
function Scene:update(dt)
    -- Update the physics simulation
	self.physWorld:update( lovr.timer.getDelta() )

	-- Adjust timer
	self.timer = self.timer + dt

    if lovr.headset then
		self.hx, self.hy, self.hz = lovr.headset.getPosition()
	end
end

function Scene:updateLights()
    -- Preset
    local allLights = self:getLights()

    -- Update all lights in the scene
    for _, light in pairs(allLights) do
        light:update()
    end

    -- Render all depth maps for lights with hasShadows set to true
    local lightDepthPasses = {}
    for i, light in pairs(allLights) do
        if light.hasShadows == true then
            local passDepth = lovr.graphics.getPass('render', { depth = self.lightDepthTexArray_Views[i], samples = 1 })

            passDepth:setCullMode( 'back' )
            passDepth:setProjection( 1, light.projection )
            passDepth:setViewPose( 1, light.pose )
            self:drawDepth(passDepth, light.projection, light.pose)

            table.insert(lightDepthPasses, passDepth)
        end
    end

    -- Finalize
    self.passes = {}
    for _, passDepth in pairs(lightDepthPasses) do
        table.insert(self.passes, passDepth)
    end
end

function Scene:updateModels()
    for _, model in pairs(self:getModels()) do
        model:update()
    end
end

function Scene:updateBodies()
    for _, body in pairs(self:getBodies()) do
        body:update()
    end
end


--# Finalize
return Scene
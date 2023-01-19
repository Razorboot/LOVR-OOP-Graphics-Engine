--# Include
local Serpent = require "lovr_graphics_engine.libs.serpent"
local Object = require "lovr_graphics_engine.libs.classic"
local forwardShader = require "lovr_graphics_engine.shaders.forward_arrays"
local particleForwardShader = require "lovr_graphics_engine.shaders.forward_particle"

local Node = require "lovr_graphics_engine.modules.node"
local Body = require "lovr_graphics_engine.modules.body"
local Light = require "lovr_graphics_engine.modules.light"
local Model = require "lovr_graphics_engine.modules.model"
local Particle = require "lovr_graphics_engine.modules.particle"
local Transform = require "lovr_graphics_engine.modules.transform"


--# Point
local Scene = Object:extend()


--# Creation Methods
function Scene:new()
    -- All the nodes in the scene
    self.root = nil

    -- Default variables
    self.defaults = {
        light_depthSize = 1024*1.5,
        depthTexOptions = { format = 'd32f', mipmaps = false, usage = { 'render', 'sample' } }
    }
    self.lighting = {
        ambience = lovr.math.newVec3((9/255) / 10.0, (9/255) / 10.0, (15/255) / 10.0)
    }

    -- Timer
	lovr.timer.step() -- Reset the timer before the first update
    self.timer = 0

    -- Rendering
    self.passes = {}

    -- Temporary selections
    self.tempNodes = {
        Model = {},
        Light = {},
        Body = {},
        Particle = {}
    }
    
    -- Camera (Soon to be replaced with it's own class)
    self.camera = {}
    self.camera.depthTexture = lovr.graphics.newTexture(lovr.headset.getDisplayWidth(), lovr.headset.getDisplayHeight(), {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})
    local left, right, top, bottom = lovr.headset.getViewAngles(1)
    local near, far = lovr.headset.getClipDistance()
    self.camera.proj = lovr.math.newMat4():fov(left, right, top, bottom, near, far)
    self.camera.view = lovr.math.newMat4()
    self.camera.viewSpaceMatrix = nil

    -- Physics
        -- Create Physics World
	self.physWorld = lovr.physics.newWorld( nil, nil, nil, false )
    self.selectionWorld = lovr.physics.newWorld(nil, nil, nil, false)
	self.physWorld:setLinearDamping( .01 )
	self.physWorld:setAngularDamping( .005 )

    -- Lights
    self.lightDepthTexArray = nil
    self.lightDepthTexArray_Views = {}
    self:resetShadows()
end


--# Helper Methods
function Scene:setTempNodes()
    for i, section in pairs(self.tempNodes) do
        self.tempNodes[i] = {}
    end

    for _, node in pairs(self.root:getDescendants()) do
        if self.tempNodes[node.type] then
            table.insert(self.tempNodes[node.type], node)
        else
            if node.type == "PointLight" or node.type == "SpotLight" then
                table.insert(self.tempNodes["Light"], node)
            end
        end
    end
end

function Scene:getModels()
    return self.tempNodes["Model"]
end

function Scene:getLights()
    return self.tempNodes["Light"]
end

function Scene:getBodies()
    return self.tempNodes["Body"]
end

function Scene:getParticles()
    return self.tempNodes["Particle"]
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


--# File Saving
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function lines_from(file)
    if not file_exists(file) then return {} end
    local lines = {}
    local lines_str = ""
    for line in io.lines(file) do 
        lines[#lines + 1] = line
        lines_str = lines_str.." "..tostring(line)
    end
    return lines, lines_str
end

function Scene.createFromFile(path)
    local lines_t, lines_str = lines_from(lovr.filesystem.getRealDirectory("main.lua").."/"..path..".lua")
    if #lines_t <= 0 then error("Save file either does not exist, is not a Lua file, or is empty.") return false end
    local ok, filetable = Serpent.load(lines_str)

    -- Scene Creation
    local newScene = Scene()

    -- Node setup
    local function scanChild(children, parent)
        for _, nodeManifold in pairs(children) do
            local localMatrix = lovr.math.mat4(unpack(nodeManifold.localTransform))
            local globalMatrix = lovr.math.mat4(unpack(nodeManifold.globalTransform))

            local info = {}
            info.scene = newScene
            info.name = nodeManifold.name
            info.type = nodeManifold.type
            info.visible = nodeManifold.visible
            info.parent = parent

            local node = nil

            -- Create a new node depending on node type
            if nodeManifold.type == "Model" then
                info.filepath = nodeManifold.filepath
                info.diffuseMap_filepath = nodeManifold.diffuseMap_filepath
                info.specularMap_filepath = nodeManifold.specularMap_filepath
                info.normalMap_filepath = nodeManifold.normalMap_filepath
                info.texture_mode = nodeManifold.textureMode
                info.tile_scale = lovr.math.newVec3(unpack(nodeManifold.tileScale))
                node = Model(info)

            elseif nodeManifold.type == "PointLight" or nodeManifold.type == "SpotLight" then
                info.color = lovr.math.newVec3(unpack(nodeManifold.color))
                --info.range = nodeManifold.range
                if nodeManifold.angle then
                    info.angle = nodeManifold.angle
                end
                info.hasShadows = nodeManifold.hasShadows
                node = Light(info)
                if nodeManifold.angle then
                    node.angle = nodeManifold.angle
                end

            elseif nodeManifold.type == "Body" then
                if nodeManifold.isMeshShape == true then
                    info.vertices, info.indices = unpack(nodeManifold.meshInfo)
                    info.collider_type = "mesh"
                end
                node = Body(info)

                for _, shapeManifold in pairs(nodeManifold.collider.shapes) do
                    if shapeManifold.shapeType ~= "MeshShape" then
                        local newShape
                        if shapeManifold.shapeType == "BoxShape" then
                            newShape = lovr.physics.newBoxShape(unpack(shapeManifold.dimensions))
                        elseif shapeManifold.shapeType == "CylinderShape" then
                            newShape = lovr.physics.newCylinderShape(unpack(shapeManifold.dimensions))
                        elseif shapeManifold.shapeType == "CapsuleShape" then
                            newShape = lovr.physics.newCapsuleShape(unpack(shapeManifold.dimensions))
                        elseif shapeManifold.shapeType == "SphereShape" then
                            newShape = lovr.physics.newSphereShape(unpack(shapeManifold.dimensions))
                        end
                        node.collider:addShape(newShape)
                    end
                end

                node:setKinematic(nodeManifold.collider.isKinematic)
            
            elseif nodeManifold.type == "Particle" then
                info.diffuseMap_filepath = nodeManifold.diffuseMap_filepath

                node = Particle(info)
                -- Specifics
                node.faceCamera = nodeManifold.faceCamera
                node.depthMode = nodeManifold.depthMode
                node.brightness = nodeManifold.brightness
                node.enabled = nodeManifold.enabled
                node.hasDepthTest = nodeManifold.hasDepthTest
                node.hasShadowCastings = nodeManifold.hasShadowCastings
                node.brightness = nodeManifold.brightness

                -- Phys Variables
                node.gravity = nodeManifold.gravity
                node.friction = nodeManifold.friction
                node.timeStep = nodeManifold.timeStep
                node.hasCollisions = nodeManifold.hasCollisions
                node.collisionDist = nodeManifold.collisionDist
                node.incrementTime = nodeManifold.incrementTime
                node.lifeTime = nodeManifold.lifeTime
                node.edgeSmooth = nodeManifold.edgeSmooth
                node.useLookVector = nodeManifold.useLookVector
            end
            --node.localTransform:setMatrix({matrix = localMatrix})
            --node.globalTransform:setMatrix({matrix = globalMatrix})
            -- Finalize
            node:setLocalTransformMatrix(localMatrix)
            node:setGlobalTransformMatrix(globalMatrix)
            if #nodeManifold.children > 0 then
                scanChild(nodeManifold.children, node)
            end
        end
    end

    -- Start iterating through the root node and to the children
    if filetable.root then
        local nodeManifold = filetable.root

        local info = {}
        info.scene = newScene
        info.name = nodeManifold.name
        info.type = nodeManifold.type
        info.localTransform = Transform({matrix = lovr.math.mat4(unpack(nodeManifold.localTransform)) })
        info.globalTransform = Transform({matrix = lovr.math.mat4(unpack(nodeManifold.globalTransform)) })

        local rootNode = Node(info)
        newScene.root = rootNode

        if #filetable.root.children > 0 then
            scanChild(filetable.root.children, rootNode)
        end
    end

    -- Finalize
    return newScene
end

function Scene:saveToFile(filename)
    -- Create a table that stores all of the important scene variables
    local exportManifold = {}
    exportManifold.sceneProperties = {}
    
    -- Extract scene variables
    for i, v in pairs(self) do
        if type(self[i]) == "table" then
            v = {}

            for i2, v2 in pairs(self[i]) do
                if pcall(function() v2:unpack() end) then
                    v[i2] = {self[i][i2]:unpack()}
                end
            end
        end

        if pcall(function() self[i]:unpack() end) then
            v = {self[i]:unpack()}
        end

        if self[i] ~= "root" and self[i] ~= "passes" and type(v) ~= "userdata" then
            exportManifold.sceneProperties[i] = v
        end
    end

    -- Export scene nodes
    local nodeDescendants = self.root:getDescendants()
    local nodeCount = 0

    for i, node in pairs(nodeDescendants) do
        node.id = i 
    end

    function createManifoldFromNode(node)
        local manifold = {}
        manifold.children = {}

        for i, v in pairs(node) do
            local newV = nil
            local dataType = type(v)

            --[[if not newV then
                if type(self[i]) == "table" then
                    newV = {}
                    
                    for i2, v2 in pairs(self[i]) do
                        if pcall(function() v2:unpack() end) then
                            newV[i2] = {self[i][i2]:unpack()}
                        end
                    end
                end
            end]]

            if dataType == "string" or dataType == "number" or dataType == "boolean" then
                newV = v
                if i == "previousTime" then newV = 0 end
            end

            if not newV then
                if i == "particleManifolds" then
                    newV = nil
                end
            end

            if not newV then 
                if i == "directionalForceRange" then
                    newV = {}
                    for ti, tv in pairs(node[i]) do
                        newV[ti] = {tv.x, tv.y}
                    end
                end
            end

            if not newV then 
                if i == "scaleRange" then
                    newV = {}
                    for ti, tv in pairs(node[i]) do
                        newV[ti] = {tv.x, tv.y, tv.z}
                    end
                end
            end

            if not newV then 
                if i == "alphaRange" then
                    newV = {}
                    for ti, tv in pairs(node[i]) do
                        newV[ti] = tv
                    end
                end
            end

            if not newV then
                if i == "ambience" or i == "color" then
                    newV = {node[i].x, node[i].y, node[i].z}
                end
            end

            if not newV then
                if i == "localTransform" or i == "globalTransform" then
                    --newV = {node[i].matrix:unpack(true)}
                    newV = lovr.math.mat4():translate(node[i].position):rotate(node[i].rotation.x, node[i].rotation.y, node[i].rotation.z, node[i].rotation.w):scale(node[i].scale)
                    newV = {newV:unpack(true)}
                end
            end

            if not newV then
                if pcall(function() node[i]:unpack() end) then
                    newV = {node[i]:unpack()}
                end
            end

            if i == "collider" and not newV then
                local collider = node[i]

                newV = {}
                newV.pose = collider:getPose()
                newV.isMeshShape = false
                newV.shapes = {}
                newV.isKinematic = collider:isKinematic()
                for _, shape in pairs(collider:getShapes()) do
                    local shapeType = tostring(shape)
                    if shapeType ~= "MeshShape" then
                        local shapeManifold = {}
                        shapeManifold.shapeType = shapeType
                        if shapeType == "BoxShape" then
                            shapeManifold.dimensions = {shape:getDimensions()}
                        elseif shapeType == "CapsuleShape" or shapeType == "CylinderShape" then
                            shapeManifold.dimensions = {shape:getRadius(), shape:getLength()}
                        elseif shapeType == "SphereCollider" then
                            shapeManifold.dimensions = {shape:getRadius()}
                        end
                        table.insert(newV.shapes, shapeManifold)
                    else
                        newV.isMeshShape = true
                        newV.meshInfo = {node.model:getTriangles()}
                    end
                end
            end

            -- Finalize
            if i ~= "scene" and i ~= "children" then
                manifold[i] = newV
            end
        end

        return manifold
    end

    function scanChild(node, manifold, rootManifold)
        for _, child in pairs(node.children) do
            table.insert(manifold.children, createManifoldFromNode(child))
            
            if #child.children > 0 then
                rootManifold = scanChild(child, manifold.children[#manifold.children], rootManifold)
            end
        end

        return rootManifold
    end

    function convertNode(node)
        local manifold = createManifoldFromNode(node)

        scanChild(node, manifold, manifold)

        return manifold
    end

    if self.root then 
        exportManifold.root = convertNode(self.root)
    end
    
    local saveFile = io.open(lovr.filesystem.getRealDirectory("main.lua").."/"..filename..".lua", 'w')
    saveFile:write(Serpent.block(exportManifold))
    saveFile:close()
    --lovr.filesystem.write(filename..".lua", Serpent.block(exportManifold))
end


--# Draw Methods
function Scene:drawDepth(pass, proj, pose)
    -- Set view to that of the light source or whatever proj/pose
    if proj and pose then
        pass:setProjection( 1, proj )
        pass:setViewPose( 1, pose )
    end

    -- Render all models
    for _, model in pairs(self:getModels()) do
        if model.visible == true and model.canCastShadows == true then
            model:draw(pass, "depth")
        end
    end
end

function Scene:drawFull(pass)
    -- Presets
    pass:setCullMode( 'back' )
	--pass:setViewPose( 1, lovr.headset.getPose() )

    -- Create the buffers for the necessary values of each light source
    local vec4_light_origins = {}
	local vec4_light_targets = {}
	local vec4_spotDirs = {}
	local light_space_matrices = {}
	local light_ranges = {}
	local light_cutOffs = {}

    local light_colors = {}
    local light_shadowsEnabled = {}
    local light_visible = {}
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

        local visibleInt = 0
        if light.visible == false then visibleInt = 1 end
        table.insert(light_visible, visibleInt )

        local shadowsInt = 0
        if light.hasShadows == true then shadowsInt = 1 end
        table.insert(light_shadowsEnabled, shadowsInt )

        local typeInt = 0
        if light.type == "PointLight" then typeInt = 1 elseif light.type == "SpotLight" then typeInt = 0 end
        table.insert(light_types, typeInt )

        table.insert(light_colors, lovr.math.vec4(light.color.x, light.color.y, light.color.z, 1.0) )
	end

    -- The final render shader
	pass:setShader( forwardShader )

    lightColor_Buffer = lovr.graphics.getBuffer( light_colors, 'vec4' )
    lightPos_Buffer = lovr.graphics.getBuffer( vec4_light_origins, 'vec4' )
	spotDir_Buffer = lovr.graphics.getBuffer( vec4_spotDirs, { 'vec4', layout = 'std140' } )
	LightSpaceMatrix_Buffer = lovr.graphics.getBuffer( light_space_matrices, 'mat4' )
	cutOff_Buffer = lovr.graphics.getBuffer( light_cutOffs, { 'float', layout = 'std140' } )
	range_Buffer = lovr.graphics.getBuffer( light_ranges, { 'float', layout = 'std140' } )

    type_Buffer = lovr.graphics.getBuffer( light_types, { 'float', layout = 'std140' } )
    hasShadows_Buffer = lovr.graphics.getBuffer( light_shadowsEnabled, { 'int', layout = 'std140' } )
    lightVisible_Buffer = lovr.graphics.getBuffer( light_visible, { 'int', layout = 'std140' } )

    -- Send all buffers
	pass:send( 'liteColor_Buffer', lightColor_Buffer )
	pass:send( 'lightPos_Buffer', lightPos_Buffer )
	pass:send( 'spotDir_Buffer', spotDir_Buffer )
	pass:send( 'LightSpaceMatrix_Buffer', LightSpaceMatrix_Buffer )
	pass:send( 'cutOff_Buffer', cutOff_Buffer )
	pass:send( 'range_Buffer', range_Buffer )

    pass:send( 'lightType_Buffer', type_Buffer )
    pass:send( 'lightHasShadows_Buffer', hasShadows_Buffer )

    pass:send( 'lightVisible_Buffer', lightVisible_Buffer )

    -- Set the shader constants!
	pass:send( 'numLights', #allLights )
	pass:send( 'ambience', { self.lighting.ambience.x, self.lighting.ambience.y, self.lighting.ambience.z, 1.0 } )
	pass:send( 'specularStrength', 3.0 )
	pass:send( 'metallic', 32.0 )
	pass:send( 'texelSize', 1.0 / self.defaults.light_depthSize )

	-- Send all of the light shadowmaps
	pass:send( 'depthBuffers', self.lightDepthTexArray )

	-- Render all models with textures applied
    for _, model in pairs(self:getModels()) do
        if model.visible == true then
            model:draw(pass, "full")
        end
    end

    -- Render all particles
    pass:setShader(particleForwardShader)

    -- Send all buffers
	pass:send( 'liteColor_Buffer', lightColor_Buffer )
	pass:send( 'lightPos_Buffer', lightPos_Buffer )
	pass:send( 'spotDir_Buffer', spotDir_Buffer )
	pass:send( 'LightSpaceMatrix_Buffer', LightSpaceMatrix_Buffer )
	pass:send( 'cutOff_Buffer', cutOff_Buffer )
	pass:send( 'range_Buffer', range_Buffer )

    pass:send( 'lightType_Buffer', type_Buffer )
    pass:send( 'lightHasShadows_Buffer', hasShadows_Buffer )

    pass:send( 'lightVisible_Buffer', lightVisible_Buffer )

    -- Set the shader constants!
	pass:send( 'numLights', #allLights )
    pass:send( 'ambience', { self.lighting.ambience.x, self.lighting.ambience.y, self.lighting.ambience.z, 1.0 } )
    pass:send( 'texelSize', 1.0 / self.defaults.light_depthSize )
    -- Send all of the light shadowmaps
	pass:send( 'depthBuffers', self.lightDepthTexArray )

    for _, particle in pairs(self:getParticles()) do
        if particle.visible == true then
            particle:draw(pass)
        end
    end

    -- Submit passes 
    pass:setShader()

	table.insert( self.passes, pass )

    -- Finalize
	return lovr.graphics.submit( self.passes )
end


--# Update Methods
function Scene:update(dt)
    -- Update the physics simulation
	self.physWorld:update( lovr.timer.getDelta() )

	-- Adjust timer
	self.timer = self.timer + dt
    
    -- Set tempNodes
    self:setTempNodes()

    -- Render the general depth map from the camera
    self.camera.pose = lovr.math.newMat4(lovr.headset.getPose())
    self.camera.view:set(self.camera.pose)
    self.camera.viewSpaceMatrix = self.camera.proj * self.camera.view

    local passDepth = lovr.graphics.getPass('render', {depth = {texture = self.camera.depthTexture}, samples = 1})
    passDepth:setCullMode( 'back' )
    passDepth:setViewPose( 1, lovr.headset.getPose() )
    passDepth:setProjection( 1, self.camera.proj )
    self:drawDepth(passDepth)
    lovr.graphics.submit(passDepth)
    --table.insert(self.passes, passDepth)

    -- Update the transformation of all bodies in the scene
    self:updateBodies()
    -- Update the transformation of all models in the scene
    self:updateModels()
    -- Update the shadowmap depth buffers and transformation of all lights in the scene
    self:updateLights()
    -- Update particle physics
    self:updateParticles()
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
            --passDepth:setProjection( 1, light.projection )
            --passDepth:setViewPose( 1, light.pose )
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

function Scene:updateParticles(dt)
    for _, particle in pairs(self:getParticles()) do
        particle:update(dt)
    end
end


--# Finalize
return Scene
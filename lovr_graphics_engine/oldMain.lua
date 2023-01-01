--# Include
lovr.mouse = require 'lovr-mouse'
spotlightShader = require 'shaders.spotlight_arrays'
Node = require 'modules.node'

--# Variables
local passes = {}
local numLights = 0

--# Main
function lovr.load()
	-- Filepath specification
	assets = 'assets/'

	-- Initialize our model
	model = lovr.graphics.newModel( assets .. 'models/treasure_chest_1k.gltf' )

	diffuseMap = lovr.graphics.newTexture( assets .. 'textures/treasure_chest_diff_1k.jpg' )
	specularMap = lovr.graphics.newTexture( assets .. 'textures/treasure_chest_rough_1k.jpg' )
	normalMap = lovr.graphics.newTexture( assets .. 'textures/treasure_chest_nor_gl_1k.jpg' )

	defaultDiffuseMap = lovr.graphics.newTexture( assets .. 'textures/brick_diff.png' )
	defaultSpecularMap = lovr.graphics.newTexture( assets .. 'textures/brick_spec.png' )
	defaultNormalMap = lovr.graphics.newTexture( assets .. 'textures/brick_norm.png' )

	tvDiffuseMap = lovr.graphics.newTexture( assets .. 'textures/Television_01_diff_1k.jpg' )
	tvSpecularMap = lovr.graphics.newTexture( assets .. 'textures/Television_01_roughness_1k.jpg' )
	tvNormalMap = lovr.graphics.newTexture( assets .. 'textures/Television_01_nor_gl_1k.jpg' )

	-- Create Physics World
	world = lovr.physics.newWorld( nil, nil, nil, false )
	world:setLinearDamping( .01 )
	world:setAngularDamping( .005 )

	-- Create boxes!
	boxes = {}

	-- Create all models and phys objects
	ground = world:newBoxCollider( 0, -3.5, 0, 20, .05, 20 )
	ground:setFriction( 0.1 )
	ground:setKinematic( true )
	table.insert( boxes, ground )

	box2Model = lovr.graphics.newModel( assets .. 'models/tv_centered.glb' )
	local b2w, b2h, b2d = box2Model:getDimensions()
	box2 = world:newBoxCollider( 0, -2.5, 0, b2w + 0.15, b2h + 0.05, b2d + 0.05 )
	box2:setFriction( 1.5 )
	table.insert( boxes, box2 )

	width, height, depth = model:getDimensions()
	chestBox = world:newBoxCollider( 0, 0, 0, width, height, depth )
	chestBox:setFriction( 1 )
	chestBox:applyTorque( 10, 0, 0 )
	chestBox:applyForce( 8, 10.0, 0.0 )

	-- Start Timer
	lovr.timer.step() -- Reset the timer before the first update

	-- Variables
	hx, hy, hz = 0.0, 0.0, 0.0
	mx, my = lovr.mouse.getX(), lovr.mouse.getY()

	pos = 0
	timer = 0

	--[[# Light Settings
	light_pose = lovr.math.newMat4()
	light_view = lovr.math.newMat4()
	light_projection = lovr.math.newMat4():perspective( math.rad( (25 * 4) ), 1, 0.01 )
	light_target = lovr.math.newVec3()
	light_origin = lovr.math.newVec3()

	light2_pose = lovr.math.newMat4()
	light2_view = lovr.math.newMat4()
	light2_projection = lovr.math.newMat4():perspective( math.rad( (25 * 4) ), 1, 0.01 )
	light2_target = lovr.math.newVec3()
	light2_origin = lovr.math.newVec3()]]

	depthBufferSize = 1024
	local depthTexOptions = { format = 'd32f', mipmaps = false, usage = { 'render', 'sample' } }

	lights = {}

	lights[1] = {
		light_type = "spotLight",
		light_hasShadows = true,
		light_range = 15.0,
		light_pose = lovr.math.newMat4(),
		light_view = lovr.math.newMat4(),
		light_projection = lovr.math.newMat4():perspective( math.cos( math.rad( 5 ) ), 1, 0.01 ),
		light_origin = lovr.math.newVec3(),
		light_target = lovr.math.newVec3(),
	}
	lights[2] = {
		light_type = "spotLight",
		light_hasShadows = true,
		light_range = 20.0,
		light_pose = lovr.math.newMat4(),
		light_view = lovr.math.newMat4(),
		light_projection = lovr.math.newMat4():perspective( math.cos( math.rad( 5 ) ), 1, 0.01 ),
		light_origin = lovr.math.newVec3(),
		light_target = lovr.math.newVec3(),
	}
	lights[3] = {
		light_type = "spotLight",
		light_hasShadows = true,
		light_range = 20.0,
		light_pose = lovr.math.newMat4(),
		light_view = lovr.math.newMat4(),
		light_projection = lovr.math.newMat4():perspective( math.cos( math.rad( 5 ) ), 1, 0.01 ),
		light_origin = lovr.math.newVec3(),
		light_target = lovr.math.newVec3(),
	}
	--[[lights[3] = {
		light_type = "pointLight",
		light_hasShadows = true,
		light_range = 20.0,
		light_pose = lovr.math.newMat4(),
		light_view = lovr.math.newMat4(),
		light_projection = lovr.math.newMat4():perspective( math.rad( (25 * 4) ), 1, 0.01 ),
		light_origin = lovr.math.newVec3(),
		light_target = lovr.math.newVec3(),
	}]]

	numLights = #lights

	lightDepthTexArray = lovr.graphics.newTexture( depthBufferSize, depthBufferSize, numLights, depthTexOptions )
	lightDepthTexArray_Views = {}
	for i = 1, numLights do
		table.insert(lightDepthTexArray_Views, lightDepthTexArray:newView('array', i, 1, 1, 1))
	end
end

--# Helper Functions for rendering
function drawBox( pass, box )
	local x, y, z = box:getPosition()
	pass:cube( lovr.math.mat4():translate( x, y, z ):rotate( box:getOrientation() ):scale( box:getDimensions() ) )
end

function drawScene( pass, proj, pose )
	-- Draw
	pass:setProjection( 1, proj )
	pass:setViewPose( 1, pose )
	pass:draw( box2Model, lovr.math.mat4():translate( box2:getPosition() ):rotate( box2:getOrientation() ):translate( 0, 0, 0 ):scale( 1.25, 1.25, 1.25 ) )

	pass:setProjection( 1, proj )
	pass:setViewPose( 1, pose )

	local x, y, z = chestBox:getPosition()
	local angle, ax, ay, az = chestBox:getOrientation()

	pass:setProjection( 1, proj )
	pass:setViewPose( 1, pose )
	pass:draw( model, lovr.math.mat4():translate( x, y, z ):rotate( angle, ax, ay, az ):translate( 0.0, -0.3, 0 ) )

	pass:setProjection( 1, proj )
	pass:setViewPose( 1, pose )
	pass:cube( lovr.math.mat4():translate( ground:getPosition() ):rotate( ground:getOrientation() ):scale( 20, 0.05, 20 ) )
end

function getStringFromMat4(mat4)
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

function getStringFromMat4_Sub(mat4, nmat)
	local m1, m2, m3, m4,
	m5, m6, m7, m8,
	m9, m10, m11, m12,
	m13, m14, m15, m16 = mat4:unpack( true )

	local mn1, mn2, mn3, mn4,
	mn5, mn6, mn7, mn8,
	mn9, mn10, mn11, mn12,
	mn13, mn14, mn15, mn16 = nmat:unpack( true )

	local mat4String = tostring(m1 - m2)..", "..tostring(mn2 - m2)..", "..tostring(mn3 - m3)..", "..tostring(mn4 - m4)
	..", \n"..tostring(mn5 - m5)..", "..tostring(mn6 - m6)..", "..tostring(mn7 - m7)..", "..tostring(mn8 - m8)
	..", \n"..tostring(mn9 - m9)..", "..tostring(mn10 - m11)..", "..tostring(mn12 - m13)..", "..tostring(mn14 - m14)
	..", \n"..tostring(mn15 - m15)..", "..tostring(mn16 - m16)

	return mat4String
end

function drawFull( pass )
	pass:setViewPose( 1, lovr.headset.getPose() )

	-- Draw
	pass:send( 'diffuseMap', tvDiffuseMap )
	pass:send( 'specularMap', tvSpecularMap )
	pass:send( 'normalMap', tvNormalMap )
	pass:draw( box2Model, lovr.math.mat4():translate( box2:getPosition() ):rotate( box2:getOrientation() ):translate( 0, 0, 0 ):scale( 1.25, 1.25, 1.25 ) )

	pass:setViewPose( 1, lovr.headset.getPose() )

	local x, y, z = chestBox:getPosition()
	local angle, ax, ay, az = chestBox:getOrientation()

	pass:send( 'diffuseMap', diffuseMap )
	pass:send( 'specularMap', specularMap )
	pass:send( 'normalMap', normalMap )

	pass:setViewPose( 1, lovr.headset.getPose() )
	pass:draw( model, lovr.math.mat4():translate( x, y, z ):rotate( angle, ax, ay, az ):translate( 0.0, -0.3, 0 ) )

	pass:send( 'diffuseMap', defaultDiffuseMap )
	pass:send( 'specularMap', defaultSpecularMap )
	pass:send( 'normalMap', defaultNormalMap )

	pass:setViewPose( 1, lovr.headset.getPose() )
	pass:cube( lovr.math.mat4():translate( ground:getPosition() ):rotate( ground:getOrientation() ):scale( 20, 0.05, 20 ) )
end

function lovr.keypressed( key, scancode, repeating )
	if key == "up" then mx = mx + 5.0 end
	if key == "down" then mx = mx - 5.0 end
end

function lovr.update( dT )
	-- Update the physics simulation
	world:update( lovr.timer.getDelta() )

	-- Adjust timer
	timer = timer + dT

	-- Floats that are passed into the light positions
	pos = math.sin( timer ) * 2
	pos2 = math.sin( timer * 2 ) * -3

	-- Phys update
	local rmbDown = lovr.mouse.isDown( 2 )

	local deltaX = lovr.mouse.getX() - mx
	local deltaY = lovr.mouse.getY() - my

	mx, my = lovr.mouse.getX(), lovr.mouse.getY()

	-- Create a transformation matrix that represents a force relative to the orientation of the camera
	local ha, hrx, hry, hrz = lovr.headset.getOrientation( 'head' )
	local relativePos = lovr.math.mat4():rotate( lovr.headset.getOrientation( 'head' ) ):translate( deltaX, -deltaY, 0 )
	local m1, m2, m3, m4,
	m5, m6, m7, m8,
	m9, m10, m11, m12,
	m13, m14, m15, m16 = relativePos:unpack( true ) -- x, y, z, w

	-- Apply the above transformation force to the box
	if tostring( rmbDown ) == "true" then
		chestBox:applyForce( m13, m14, m15 )
	end

	-- Adjust head position (for specular)
	if lovr.headset then
		hx, hy, hz = lovr.headset.getPosition()
	end

	-- Set light matrix for the shadowmap
	lights[1].light_target = lovr.math.vec3( 0, -1.0, 0 )
	lights[1].light_origin = lovr.math.vec3( pos, 2.5, -pos )

	lights[2].light_target = lovr.math.vec3( 0, -1.2, 0 )
	lights[2].light_origin = lovr.math.vec3( 0, 2.5, pos2 )

	lights[3].light_target = lovr.math.vec3( 0, -1.2, 0 )
	lights[3].light_origin = lovr.math.vec3( -pos2, 2.5, 0 )

	for i = 1, numLights do
		lights[i].light_pose:target( lights[i].light_origin, lights[i].light_target )
		lights[i].light_view:set( lights[i].light_pose ):invert()
	end

	local lightDepthPasses = {}
	for i = 1, numLights do
		local lightRef = lights[i]

		local passDepth = lovr.graphics.getPass('render', { depth = lightDepthTexArray_Views[i], samples = 1 })
		passDepth:setCullMode( 'back' )
		passDepth:setProjection( 1, lightRef.light_projection )
		passDepth:setViewPose( 1, lightRef.light_pose )
		drawScene( passDepth, lightRef.light_projection, lightRef.light_pose )

		table.insert(lightDepthPasses, passDepth)
	end

	-- Insert each pass into the passes array: These will be submitted in the draw function
	passes = {}
	for _, passDepth in pairs(lightDepthPasses) do
		table.insert(passes, passDepth)
	end
end

function lovr.draw( pass )
	-- Making sure that the shader settings are set back to defaults before rendering!
	pass:setCullMode( 'back' )
	pass:setViewPose( 1, lovr.headset.getPose() )

	local vec4_light_origins = {}
	local vec4_light_targets = {}
	local vec4_spotDirs = {}
	local light_space_matrices = {}
	local light_ranges = {}
	local light_cutOffs = {}

	for i = 1, numLights do
		local lightRef = lights[i]

		local light_origin_vec4 = lovr.math.vec4(lightRef.light_origin.x, lightRef.light_origin.y, lightRef.light_origin.z, 0)
		local light_target_vec4 = lovr.math.vec4(lightRef.light_target.x, lightRef.light_target.y, lightRef.light_target.z, 0)
		local spotDir_vec4 = (light_target_vec4:sub( light_origin_vec4 )):normalize()

		table.insert(vec4_light_origins, light_origin_vec4)
		table.insert(vec4_light_targets, light_target_vec4)
		table.insert(vec4_spotDirs, spotDir_vec4)
		table.insert(light_space_matrices, lightRef.light_projection * lightRef.light_view)
		table.insert(light_ranges, lightRef.light_range)
		table.insert(light_cutOffs, math.cos( math.rad( 5 ) ))
	end

	-- The final render shader
	pass:setShader( spotlightShader )
	pass:setViewPose( 1, lovr.headset.getPose() )

	-- Create and send buffers for each light source and it's settings. Each index in the array is the value for the lights index.
	liteColor_Buffer = lovr.graphics.getBuffer( { lovr.math.vec4( 1.0, 0.0, 0.0, 1.0 ), lovr.math.vec4( 0.0, 1.0, 0.0, 1.0 ), lovr.math.vec4( 0.0, 0.0, 1.0, 1.0 ) }, 'vec4' )

	lightPos_Buffer = lovr.graphics.getBuffer( vec4_light_origins, 'vec4' )
	spotDir_Buffer = lovr.graphics.getBuffer( vec4_spotDirs, { 'vec4', layout = 'std140' } )
	LightSpaceMatrix_Buffer = lovr.graphics.getBuffer( light_space_matrices, 'mat4' )
	cutOff_Buffer = lovr.graphics.getBuffer( light_cutOffs, { 'float', layout = 'std140' } )
	range_Buffer = lovr.graphics.getBuffer( light_ranges, { 'float', layout = 'std140' } )

	pass:send( 'liteColor_Buffer', liteColor_Buffer )
	pass:send( 'lightPos_Buffer', lightPos_Buffer )
	pass:send( 'spotDir_Buffer', spotDir_Buffer )
	pass:send( 'LightSpaceMatrix_Buffer', LightSpaceMatrix_Buffer )
	pass:send( 'cutOff_Buffer', cutOff_Buffer )
	pass:send( 'range_Buffer', range_Buffer )

	-- Set the shader constants!
	pass:send( 'numLights', numLights )

	pass:send( 'viewPos', { hx, hy, hz } )
	pass:send( 'ambience', { (9/255) * 0.25, (9/255) * 0.25, (15/255) * 0.25, 1.0 } )

	pass:send( 'specularStrength', 3.0 )
	pass:send( 'metallic', 32.0 )

	pass:send( 'texelSize', 1.0 / depthBufferSize )

	-- Send all of the light shadowmaps
	pass:send( 'depthBuffers', lightDepthTexArray )

	-- Draw every model in the scene and send relative textures for each model
	drawFull( pass )

	-- Clear shader pass and render spheres to represent light sources
	pass:setShader()

	pass:sphere( lights[1].light_origin, 0.1 ) -- Represents light origin
	pass:sphere( lights[2].light_origin, 0.1 ) -- Represents light origin
	pass:sphere( lights[3].light_origin, 0.1 ) -- Represents light target

	pass:text("I LOVE FISH")
	
	-- Submit passes 
	table.insert( passes, pass )
	return lovr.graphics.submit( passes )
end

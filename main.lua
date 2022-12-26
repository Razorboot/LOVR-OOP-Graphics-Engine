--# Include
lovr.mouse = require 'lovr-mouse'
spotlightShader = require 'shaders.spotlight_arrays'

--# Variables
local passes = {}

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

	--# Light Matrix
	light_pose = lovr.math.newMat4()
	light_view = lovr.math.newMat4()
	light_projection = lovr.math.newMat4():perspective( math.rad( (25 * 4) ), 1, 0.01 )
	light_target = lovr.math.newVec3()
	light_origin = lovr.math.newVec3()

	light2_pose = lovr.math.newMat4()
	light2_view = lovr.math.newMat4()
	light2_projection = lovr.math.newMat4():perspective( math.rad( (25 * 4) ), 1, 0.01 )
	light2_target = lovr.math.newVec3()
	light2_origin = lovr.math.newVec3()

	depthBufferSize = 1024 * 2

	local depthTexOptions = { format = 'd32f', mipmaps = false, usage = { 'render', 'sample' } }

	depthtex = lovr.graphics.newTexture( depthBufferSize, depthBufferSize, depthTexOptions )
	depthtex2 = lovr.graphics.newTexture( depthBufferSize, depthBufferSize, depthTexOptions )

	lightDepthTexArray = lovr.graphics.newTexture( depthBufferSize, depthBufferSize, 2, depthTexOptions )
	lightDepthTexArray_Views = { lightDepthTexArray:newView('array', 1, 1, 1, 1), lightDepthTexArray:newView('array', 2, 1, 1, 1) }
end

--# Helper Functions for rendering
function drawBox( pass, box )
	local x, y, z = box:getPosition()
	pass:cube( lovr.math.mat4():translate( x, y, z ):rotate( box:getOrientation() ):scale( box:getDimensions() ) )
end

local function drawScene( pass, proj, pose )
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

function drawFull( pass )
	pass:setViewPose( 1, lovr.headset.getPose() )

	-- Draw
	pass:send( 'diffuseMap', tvDiffuseMap )
	pass:send( 'specularMap', tvSpecularMap )
	pass:send( 'normalMap', tvNormalMap )
	pass:draw( box2Model, lovr.math.mat4():translate( box2:getPosition() ):rotate( box2:getOrientation() ):translate( 0, 0, 0 ):scale( 1.25, 1.25, 1.25 ) )

	pass:setViewPose( 1, lovr.headset.getPose() )

	local m1, m2, m3, m4,
	m5, m6, m7, m8,
	m9, m10, m11, m12,
	m13, m14, m15, m16 = lovr.math.mat4():scale( 5.0, 5.0, 5.0 ):unpack( true )

	local relativePosString = tostring( m1 ..
		", " ..
		m2 .. ", " .. m3 ..
		", " .. m4 .. ", \n" .. m5 .. ", " .. m6 .. ", " .. m7 .. ", " .. m8 ..
		", \n" .. m9 .. ", " .. m10 .. ", " .. m11 .. ", " .. m12 .. ", \n" .. m13 .. ", " .. m14 .. ", " .. m15 .. ", " .. m16 ) -- Used for debugging purposes!

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
	world:update( 1 / 60 )

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
	light_target = lovr.math.vec3( 0, -1.0, 0 )
	light_origin = lovr.math.vec3( pos, 2.5, -pos )

	light2_target = lovr.math.vec3( 0, -1.2, 0 )
	light2_origin = lovr.math.vec3( 0, 2.5, pos2 )

	light_pose:target( light_origin, light_target )
	light_view:set( light_pose ):invert()

	light2_pose:target( light2_origin, light2_target )
	light2_view:set( light2_pose ):invert()

	-- Render the depth buffers from the perspecive of each light
	local passDepth = lovr.graphics.getPass('render', { depth = lightDepthTexArray_Views[1], samples = 1 })
	passDepth:setCullMode( 'back' )
	passDepth:setProjection( 1, light_projection )
	passDepth:setViewPose( 1, light_pose )
	drawScene( passDepth, light_projection, light_pose )

	local pass2 = lovr.graphics.getPass('render', { depth = lightDepthTexArray_Views[2], samples = 1 })
	pass2:setCullMode( 'back' )
	pass2:setProjection( 1, light2_projection )
	pass2:setViewPose( 1, light2_pose )
	drawScene( pass2, light2_projection, light2_pose )

	-- Insert each pass into the passes array: These will be submitted in the draw function
	passes = {}
	table.insert( passes, passDepth )
	table.insert( passes, pass2 )
end

function lovr.draw( pass )
	-- Making sure that the shader settings are set back to defaults before rendering!
	pass:setCullMode( 'back' )
	pass:setViewPose( 1, lovr.headset.getPose() )

	-- Calculate the values for each light source!
	local light_space_matrix = light_projection * light_view
	local light2_space_matrix = light2_projection * light2_view

	local light_origin_vec4 = lovr.math.vec4(light_origin.x, light_origin.y, light_origin.z, 0)
	local light2_origin_vec4 = lovr.math.vec4(light2_origin.x, light2_origin.y, light2_origin.z, 0)

	local light_target_vec4 = lovr.math.vec4(light_target.x, light_target.y, light_target.z, 0)
	local light2_target_vec4 = lovr.math.vec4(light2_target.x, light2_target.y, light2_target.z, 0)

	local spotDir_vec4 = (light_target_vec4:sub( light_origin_vec4 )):normalize()
	local spotDir2_vec4 = (light2_target_vec4:sub( light2_origin_vec4 )):normalize()

	-- The final render shader
	pass:setShader( spotlightShader )

	-- Create and send buffers for each light source and it's settings. Each index in the array is the value for the lights index.
	liteColor_Buffer = lovr.graphics.getBuffer( { lovr.math.vec4( 0.25, 0.25, 0.25, 1.0 ), lovr.math.vec4( 0.5, 0.25, 0.25, 1.0 ) }, 'vec4' )
	lightPos_Buffer = lovr.graphics.getBuffer( { light_origin_vec4, light2_origin_vec4 }, 'vec4' )
	spotDir_Buffer = lovr.graphics.getBuffer( { spotDir_vec4, spotDir2_vec4 }, { 'vec4', layout = 'std140' } )
	LightSpaceMatrix_Buffer = lovr.graphics.getBuffer( { light_space_matrix, light2_space_matrix }, 'mat4' )
	cutOff_Buffer = lovr.graphics.getBuffer( { math.cos( math.rad( 5 ) ), math.cos( math.rad( 5 ) ) }, { 'float', layout = 'std140' } )
	range_Buffer = lovr.graphics.getBuffer( { 20.0, 15.0 }, { 'float', layout = 'std140' } )

	pass:send( 'liteColor_Buffer', liteColor_Buffer )
	pass:send( 'lightPos_Buffer', lightPos_Buffer )
	pass:send( 'spotDir_Buffer', spotDir_Buffer )
	pass:send( 'LightSpaceMatrix_Buffer', LightSpaceMatrix_Buffer )
	pass:send( 'cutOff_Buffer', cutOff_Buffer )
	pass:send( 'range_Buffer', range_Buffer )

	-- Set the shader constants!
	pass:send( 'numLights', 2 )

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

	pass:sphere( light_origin, 0.1 ) -- Represents light origin
	pass:sphere( light_target, 0.1 ) -- Represents light target

	pass:setColor( 1, 0, 0, 1 )
	pass:sphere( light2_origin, 0.1 ) -- Represents light2 origin
	pass:sphere( light2_target, 0.1 ) -- Represents light2 target
	
	-- Submit passes 
	table.insert( passes, pass )
	return lovr.graphics.submit( passes )
end

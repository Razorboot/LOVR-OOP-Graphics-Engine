--# Include
local Scene = require 'modules.scene'
local Node = require 'modules.node'
local Model = require 'modules.model'
local Light = require 'modules.light'


--# Reference Variables
local mainScene

local testNode
local testModel
local groundModel
local testLight


--# Misc Variables
local assets = 'assets/'

--# Core Functions
function lovr.load()
    -- Create the scene we'll use for this script
    mainScene = Scene()

    -- Create some nodes for the scene
    testNode = Node({
        node_scene = mainScene,
        node_name = "TestNode"
    })

    -- Models and Lights are called attachments. These instances can be inserted into nodes!
    -- Keep in mind the final transform of a model is offset from the transform of the node itself.
        -- This doesn't apply to physics objects - they will move freely independent of the node transform.
    testModel = Model(
        testNode, -- The node that the model will be inserted into
        -- The array below represents parameters that your model will have
        {
            model_name = "TV",
            model_filepath = assets..'models/tv_centered.glb',
            diffuseMap_filepath = assets..'textures/Television_01_diff_1k.jpg',
            specularMap_filepath = assets..'textures/Television_01_roughness_1k.jpg',
            normalMap_filepath = assets..'textures/Television_01_nor_gl_1k.jpg'
        }
    )

    groundModel = Model(
        testNode, -- The node that the model will be inserted into
        -- The array below represents parameters that your model will have
        {
            model_name = "Ground",
            model_filepath = assets..'models/box.obj'
        }
    )
    -- Transform:setMatrix() function allows you to set any property of the transformation matrix.
        -- Doing so will consequently update all properties of the transformation.
        -- Ex: Modifying the mat4 will update the position vector, scale vector, and rotation quaternion.
        -- Ex 2: Modifying the pos vector, scale vector, or rotation quaternion will update the mat4.
    groundModel.offsetTransform:setMatrix({pos = lovr.math.vec3(0, -2.5, 0)})

    -- Insert a light into a node
    testLight = Light(
        testNode,
        {
            light_name = "TestLight",
            light_type = "spotLight",
            light_hasShadows = true
        }
    )
    testLight.offsetTransform:setMatrix({mat4 = lovr.math.mat4():translate(0, 2, 0):scale(0.25, 0.25, 0.25) })

    -- Special note!
    -- Attachments such as models and lights can easily be acquired by name using Node:getModel(name) or Node:getLight(name)
end

function lovr.update(dt)
    -- Simple update for core scene stuff ^^
    mainScene:update(dt)

    -- Move the model and light cause why not
    testModel.offsetTransform:setMatrix({
        pos = lovr.math.vec3(math.sin(mainScene.timer), -1, 0), 
        rot = lovr.math.vec4(math.sin(mainScene.timer), 1, 1, 0)
    })
    testLight.offsetTransform:setMatrix({
        pos = lovr.math.vec3(math.sin(mainScene.timer), 0.5, 0),
        rot = lovr.math.vec4(math.rad(90), 1, math.sin(-mainScene.timer), 0)
    })

    -- Update the transformation of all models in the scene
    mainScene:updateModels()
    -- Update the shadowmap depth buffers and transformation of all lights in the scene
    mainScene:updateLights()
end

function lovr.draw(pass)
    -- Drawing some shapes to represent the light source :p
    pass:cone(testLight.offsetTransform.matrix)
    pass:sphere(testLight:getTarget(), 0.05)

    -- Finally, draw the whole scene
    return mainScene:drawFull(pass)
end

local angleNum = 30
function lovr.keypressed(key)
    if key == 'f' then
        testLight:setShadows(not testLight.hasShadows)
    end
    if key == 'o' then
        angleNum = angleNum + 1
        testLight:setAngle(angleNum)
    end
end
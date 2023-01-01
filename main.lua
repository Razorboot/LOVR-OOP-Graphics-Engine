--# Include
local LGE = require "lovr_graphics_engine.include"
--[[local Scene = require 'modules.scene'
local Node = require 'modules.node'
local Model = require 'modules.model'
local Light = require 'modules.light'
local Body = require 'modules.body']]


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
    mainScene = LGE.Scene()

    -- Create some nodes for the scene
    testNode = LGE.Node({
        node_scene = mainScene,
        node_name = "TestNode"
    })
    testNode.transform:setMatrix({
        pos = lovr.math.vec3( math.sin(mainScene.timer), 0, 0 ), 
        rot = lovr.math.vec4(math.rad(25), 1, 0, 1)
    })

    -- Models and Lights are called attachments. These instances can be inserted into nodes!
    -- Keep in mind the final transform of a model is offset from the transform of the node itself.
        -- This doesn't apply to physics objects - they will move freely independent of the node transform.
    testModel = LGE.Model(
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

    groundModel = LGE.Model(
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
    groundModel.offsetTransform:setMatrix({pos = lovr.math.vec3(0, -2.5, 0), scale = lovr.math.vec3(1, 1, 1)})
    groundModel:updateGlobalTransform()

    -- Create a new collider and set it as a kinematic, meaning it's basically a solid collider
    -- An affixer will automatically lock the model transform to a new collider
    groundModel.affixer = LGE.Body(testNode, {collider_type = "box", use_dimensions = true, model = groundModel.modelInstance, transform = groundModel.globalTransform})
    groundModel.affixer:setKinematic(true)

    -- Set the offset transform back to (0, 0, 0) so the collisions don't appear strange
    groundModel.offsetTransform:setMatrix({pos = lovr.math.vec3(0, 0, 0), scale = lovr.math.vec3(1, 1, 1)})
    groundModel:updateGlobalTransform()

    -- Insert a light into a node
    testLight = LGE.Light(
        testNode,
        {
            light_name = "TestLight",
            light_type = "spotLight",
            light_hasShadows = false
        }
    )
    testLight.offsetTransform:setMatrix({mat4 = lovr.math.mat4():translate(0, 2, 0):scale(0.25, 0.25, 0.25) })
    testLight:setAffixer(testModel)

    -- Special note!
    -- Attachments such as models and lights can easily be acquired by name using Node:getLGE.Model(name) or Node:getLGE.Light(name)
end

function lovr.update(dt)
    -- Simple update for core scene stuff ^^
    mainScene:update(dt)

    -- Move the model and light cause why not
    testLight.offsetTransform:setMatrix({
        pos = lovr.math.vec3(0, 1 + math.sin(mainScene.timer*4)*0.25, 0),
        rot = lovr.math.vec4(math.rad(90), 1, 0, 0)
    })

    -- Move the entire node around
    --[[testNode.transform:setMatrix({
        pos = lovr.math.vec3( math.sin(mainScene.timer), 0, 0 ), 
        rot = lovr.math.vec4(math.rad(25), 1, 0, math.sin(-mainScene.timer))
    })]]

    -- Update the transformation of all bodies in the scene
    mainScene:updateBodies()
    -- Update the transformation of all models in the scene
    mainScene:updateModels()
    -- Update the shadowmap depth buffers and transformation of all lights in the scene
    mainScene:updateLights()

    --print(tostring(groundModel.offsetTransform.scale.x)..", "..tostring(groundModel.offsetTransform.scale.y)..", "..tostring(groundModel.offsetTransform.scale.z))
end

function lovr.draw(pass)
    -- Drawing some shapes to represent the light source :p
    pass:cone(testLight.globalTransform.matrix)
    pass:sphere(testLight:getTarget(), 0.05)

    if groundModel.affixer then
        pass:cube(groundModel.affixer.transform.matrix)
    end

    -- Finally, draw the whole scene
    return mainScene:drawFull(pass)
end

local angleNum = 30
function lovr.keypressed(key)
    -- Disable and enable shadows
    if key == 'f' then
        testLight:setShadows(not testLight.hasShadows)
    end
    -- Increase or decrease the light angle
    if key == 'o' then
        angleNum = angleNum + 1
        testLight:setAngle(angleNum)
    end
    if key == 'p' then
        angleNum = angleNum - 1
        testLight:setAngle(angleNum)
    end
    -- Create a new collider out of testNode
    if key == "c" then
        --groundModel.affixer:setKinematic(not groundModel.affixer.collider:isKinematic())

        if not testModel.affixer then
            testModel.affixer = LGE.Body(testNode, {collider_type = "box", use_dimensions = true, model = testModel.modelInstance, transform = testModel.globalTransform})
        else
            testNode:destroyAttachment(testModel.affixer)
            testModel.affixer = nil
        end
    end
end
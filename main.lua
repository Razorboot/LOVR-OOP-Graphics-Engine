--# Include
local Serpent = require "lovr_graphics_engine.libs.serpent"
local LGE = require "lovr_graphics_engine.include"

--# Reference Variables
local mainScene
local testNode
local testModel
local groundModel
local testLight
local groundBody
local tvBody
local testParticle

--# Misc Variables
local assets = 'assets/'

--# Core Functions
function lovr.load()
    -- Create the scene we'll use for this script
    mainScene = LGE.Scene()

    -- Create some nodes for the scene
    testNode = LGE.Node({
        scene = mainScene,
        name = "TestNode"
    })
    -- testNode is now the root node of the scene
    mainScene.root = testNode

    -- Keep in mind the final transform of a model is offset from the transform of the node itself.
        -- This doesn't apply to physics objects - they will move freely independent of the node transform.
    testModel = LGE.Model(
        -- The array below represents parameters that your model will have
        {
            scene = mainScene,
            parent = testNode,

            name = "TV",
            filepath = assets..'models/tv_centered.glb',
            diffuseMap_filepath = assets..'textures/Television_01_diff_1k.jpg',
            specularMap_filepath = assets..'textures/Television_01_roughness_1k.jpg',
            normalMap_filepath = assets..'textures/Television_01_nor_gl_1k.jpg'
        }
    )

    groundModel = LGE.Model(
        -- The array below represents parameters that your model will have
        {
            scene = mainScene,
            parent = testNode,

            name = "Ground",
            filepath = assets..'models/box.obj',
            texture_mode = "Tile"
        }
    )

    testParticle = LGE.Particle({
        scene = mainScene,
        parent = testNode,

        name = "TestParticle",
        diffuseMap_filepath = assets..'textures/smoke.png'
    })
    testParticle.incrementTime = 0.07
    testParticle.hasCollisions = true

    testParticle.brightness = 3
    testParticle:setScaleRangeIndex(0, lovr.math.newVec3(0, 0, 0))
    testParticle:setScaleRangeIndex(0.3, lovr.math.newVec3(1, 1, 1))
    testParticle:setScaleRangeIndex(1, lovr.math.newVec3(0.5, 0.5, 0.5))

    testParticle:setAlphaRangeIndex(0, 0)
    testParticle:setAlphaRangeIndex(0.3, 1)
    testParticle:setAlphaRangeIndex(1, 0)

    -- Create a new collider and set it as a kinematic, meaning it's basically a solid collider
    groundModel:setScale(lovr.math.vec3(20, 1, 20))
    groundBody = LGE.Body({
        scene = mainScene, 
        parent = testNode, 
        collider_type = "box", 
        use_dimensions = true, 
        model = groundModel.modelInstance, 
        scale = groundModel.localTransform.scale}
    )
    groundBody:setKinematic(true)
    groundBody:setLocalPosition(0, -3, 0)
    groundModel:setParent(groundBody)

    -- Set the local transform back to (0, 0, 0) so the collisions don't appear strange
    groundModel:setLocalPosition(lovr.math.vec3(0, 0, 0))
    groundModel:setLocalRotation(lovr.math.vec4(0, 0, 0, 0))

    -- Insert a light into a node
    testLight = LGE.Light(
        {
            scene = mainScene,
            parent = testModel,

            name = "TestLight",
            type = "SpotLight",
            hasShadows = false
        }
    )
    testLight:setScale(lovr.math.vec3(0.25, 0.25, 0.25))
end

function lovr.update(dt)
    -- Move the light cause why not
    testLight:setLocalPosition(lovr.math.vec3(math.sin(mainScene.timer), 1, -2))
    testLight:lookAt(testModel.globalTransform.position)

    --[[ Move the entire node around - can you guess what will happen to all of the child Nodes?
    testNode:setGlobalRotation(lovr.math.quat(math.rad(25), 1, 0, math.sin(-mainScene.timer)))
    testNode:setGlobalPosition(lovr.math.vec3(math.sin(mainScene.timer*4) + 10, testNode.globalTransform.position.y, testNode.globalTransform.position.z))]]

    local scaleFactor = 20-- + math.sin(mainScene.timer)
    --groundModel.tileScale:set(scaleFactor, scaleFactor, scaleFactor)
    --groundBody:setGlobalPosition(lovr.math.vec3(math.sin(mainScene.timer), -3, 0))
    --groundModel:setScale(lovr.math.vec3(scaleFactor, 1, scaleFactor))

    -- Simple update for core scene stuff ^^
    mainScene:update(dt)
end

function lovr.draw(pass)
    -- Debug draw the light source
    if getmetatable(testLight) then
        testLight:drawDebug(pass)
    end
    
    -- Finally, draw the whole scene
    return mainScene:drawFull(pass)
end

function lovr.keypressed(key)
    -- Disable and enable shadows
    if key == 'f' then
        testLight:setShadows(not testLight.hasShadows)
    end
    -- Increase or decrease the light angle
    if key == 'o' then
        testLight:setAngle(testLight:getAngle() + 1)
    end
    if key == 'p' then
        testLight:setAngle(testLight:getAngle() - 1)
    end
    if key == 'k' then
        testParticle.hasShadowCastings = not testParticle.hasShadowCastings
    end

    -- Save the scene to a file!
    if key == 'x' then
        mainScene:saveToFile("scenes/demo_scene")
    end

    -- Create a new collider out of testNode
    if key == "c" then
        groundBody:setKinematic(not groundBody.collider:isKinematic())

        --[[if not getmetatable(tvBody) then
            tvBody = LGE.Body({scene = mainScene, parent = testNode, collider_type = "box", use_dimensions = true, model = testModel.modelInstance, scale = testModel.globalTransform.scale})
            tvBody:setGlobalTransformMatrix(testModel.globalTransform.matrix)
            if getmetatable(testModel) then
                testModel:setParent(tvBody)
            end
        else
            testModel:setParent(testNode)
            tvBody:destroy()
        end]]
    end
end
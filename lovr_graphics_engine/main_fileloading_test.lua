--# Include
local LGE = require "lovr_graphics_engine.include"

--# Reference Variables
local mainScene
local testLight
local sillyLight
local ground

--# Core Functions
function lovr.load()
    mainScene = LGE.Scene.createFromFile('testSave.lua')
    testLight = mainScene.root:findFirstDescendant("TestLight")
    ground = mainScene.root:findFirstDescendant("Ground")
    sillyLight = LGE.Light({
        scene = mainScene,
        parent = mainScene.root,

        name = "NewLight",
        type = "SpotLight",
        color = lovr.math.vec3(1, 0, 0),
        hasShadows = false
    })

    ground:setGlobalPosition(lovr.math.vec3(0, -1, 0))
    ground:setGlobalRotation(lovr.math.vec4(0, 0, 0, 0))
    ground:setScale(ground.localTransform.scale + lovr.math.vec3(20, 0.5, 20))
end

function lovr.update(dt)
    -- Simple update for core scene stuff ^^
    mainScene:update(dt)

    sillyLight:setGlobalPosition(lovr.math.vec3(0, 3, math.sin(mainScene.timer*4) * 10))
    ground:setGlobalPosition(lovr.math.vec3(0, -5 + math.sin(mainScene.timer*4), 0))
    --sillyLight:setGlobalRotation(lovr.math.vec4(1, math.rad(45), 0, 0))
    sillyLight:lookAt(lovr.math.vec3(0, -5, 0))

    -- Update the transformation of all bodies in the scene
    mainScene:updateBodies()
    -- Update the transformation of all models in the scene
    mainScene:updateModels()
    -- Update the shadowmap depth buffers and transformation of all lights in the scene
    mainScene:updateLights()
end

function lovr.draw(pass)
    --pass:cube(mainScene.root.globalTransform.matrix)
    testLight:drawDebug(pass)
    sillyLight:drawDebug(pass)

    -- Draw the whole scene
    return mainScene:drawFull(pass)
end

function lovr.keypressed(key)
    -- Disable and enable shadows
    if key == 'f' then
        testLight:setShadows(not testLight.hasShadows)
        sillyLight:setShadows(not sillyLight.hasShadows)
    end
end
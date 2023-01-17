--# Include
local Node = require "lovr_graphics_engine.modules.node"
local Transform = require "lovr_graphics_engine.modules.transform"


--# Point
local Particle = Node:extend()


--# Functions
function lerp(a, b, t)
    return a + (b - a) * t
end

function lerpVec3(a, b, t)
    return lovr.math.newVec3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t)
end

local function clamp(num, min, max)
    if num > max then return max end
    if num < min then return min end
    return num
end

local function getNextAndPrevVal(curTime, tb, lastNextManifold, timer)
    local orderedTable = {}
    
    local newTable = {}
    for i, val in pairs(tb) do
        table.insert(newTable, {i, val})
    end
    table.sort(newTable, function(a, b)
        return a[1] < b[1]
    end)

    for i, manifold in pairs(newTable) do
        orderedTable[i] = {time = manifold[1], value = manifold[2], int = i}
    end

    local nextManifold, prevManifold
    local nextI = 0
    local prevTimer

    if curTime >= tonumber(lastNextManifold.time) then
        prevTimer = timer
        if orderedTable[lastNextManifold.int + 1] then
            nextManifold = orderedTable[lastNextManifold.int + 1]
            nextI = lastNextManifold.int + 1
        else
            nextManifold = orderedTable[lastNextManifold.int]
            nextI = lastNextManifold.int
        end
    else
        nextManifold = lastNextManifold
        nextI = lastNextManifold.int
    end

    if orderedTable[nextI - 1] then
        prevManifold = orderedTable[nextI - 1]
    else
        prevManifold = nextManifold
    end

    return nextManifold, prevManifold, prevTimer
end

local function normalizeTime(curTime, lifeTime, multiplier)
    local tAlphaMultiplier = tonumber(multiplier) * lifeTime
    return clamp(1 - ((tAlphaMultiplier - curTime)/tAlphaMultiplier), 0, 1)
end

function copyTable(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

--# Methods
function Particle:new(info)
    Node.newDefault(self, info)

    -- General
    self.diffuseMap_filepath = info.diffuseMap_filepath
    self.diffuseMap = lovr.graphics.newTexture(self.diffuseMap_filepath)
    self.type = "Particle"

    -- Specifics
    self.enabled = true
    self.faceCamera = true
    self.hasDepthTest = true
    self.hasShadowCastings = true
    self.brightness = 1

    -- Phys Variables
    self.gravity = 30
    self.friction = 0.98
    self.timeStep = 3
    self.hasCollisions = false
    self.collisionDist = 0.15
    self.incrementTime = 2
    self.lifeTime = 2
    self.edgeSmooth = 0.15
    self.useLookVector = true

    -- Ranges
    self.directionalForceRange = {xRange = lovr.math.newVec2(-10, 10), yRange = lovr.math.newVec2(50, 50), zRange = lovr.math.newVec2(-10, 10)}
    self.alphaRange = {}
    self.scaleRange = {}
    self:setAlphaRangeIndex(0, 1)
    self:setAlphaRangeIndex(1, 0)
    self:setScaleRangeIndex(0, lovr.math.newVec3(1, 1, 1))
    self:setScaleRangeIndex(1, lovr.math.newVec3(0, 0, 0))

    -- Misc
    self.previousTime = 0
    self.particleManifolds = {}

    --[[ Functions
    self.scene.physWorld:raycast(a, b, function(shape, x, y, z, nx, ny, nz)
        --print('Collision detected!', shape, x, y, z, nx, ny, nz)
    end)]]

    return self
end


--# Helper Methods
function Particle:setAlphaRangeIndex(time, value)
    self.alphaRange[tostring(time)] = value
end

function Particle:setScaleRangeIndex(time, value)
    self.scaleRange[tostring(time)] = value
end

function Particle:setDirectionalForceIndex(axis, vec)
    self.directionalForceRange[axis] = lovr.math.newVec2(vec.x, vec.y)
end


--# Update Methods
function Particle:update(dt)
    --[[ No need to continue if there was no change in:
        1.) local transform
        2.) global transform
        3.) global transform of the parent
    ]]
    if self.localTransform.changed == false and self.globalTransform.changed == false and self.parent.globalTransform.changed == false then return false end

    -- Local transform is set manually, this means we only need to update the global transform to reflect changes in local transform
    self:updateGlobalTransform()
    
    if (self.scene.timer - self.previousTime) > self.incrementTime then
        self.previousTime = self.scene.timer

        if self.enabled == true then
            newDirectionalForce = lovr.math.newVec3(
                lovr.math.random(self.directionalForceRange.xRange.x, self.directionalForceRange.xRange.y),
                lovr.math.random(self.directionalForceRange.yRange.x, self.directionalForceRange.yRange.y),
                lovr.math.random(self.directionalForceRange.zRange.x, self.directionalForceRange.zRange.y)
            )
            if self.useLookVector == true then
                local lookVector = self:getLookVector()
                newDirectionalForce:set(lookVector.x + newDirectionalForce.x, lookVector.y + newDirectionalForce.y, lookVector.z + newDirectionalForce.z)
            end

            table.insert(self.particleManifolds,
            {
                directionalForce = newDirectionalForce,
                velocity = lovr.math.newVec3(0, 0, 0),
                position = lovr.math.newVec3(self.globalTransform.position.x, self.globalTransform.position.y, self.globalTransform.position.z),
                prevPosition = lovr.math.newVec3(self.globalTransform.position.x, self.globalTransform.position.y, self.globalTransform.position.z),
                matrix = lovr.math.newMat4(),
                prevTime = self.scene.timer,
                camDist = 0,

                reflectionPush = lovr.math.newVec3(),

                prevHitNorm = lovr.math.newVec3(),

                -- Copy all ranges in case values are changed mid-animation
                currentAlphaRange = copyTable(self.alphaRange),
                currentScaleRange = copyTable(self.scaleRange),

                -- Initial range values
                scale = lovr.math.newVec3(self.scaleRange["0"].x, self.scaleRange["0"].y, self.scaleRange["0"].z),
                lastNextScaleManifold = {time = "0", value = self.scaleRange["0"], int = 1},
                scalePrevTime = self.scene.timer,

                alpha = self.alphaRange["0"],
                lastNextAlphaManifold = {time = "0", value = self.alphaRange["0"], int = 1},
                alphaPrevTime = self.scene.timer
            })
        end
    end
    local newDt = self.timeStep * dt

    for i, manifold in pairs(self.particleManifolds) do
        if self.scene.timer - manifold.prevTime > self.lifeTime then
            table.remove(self.particleManifolds, i)
        end
    end

    for i, manifold in pairs(self.particleManifolds) do
        -- Physics force calculations
        local force = lovr.math.vec3(0, -self.gravity, 0);
        manifold.directionalForce.x = manifold.directionalForce.x * self.friction
        manifold.directionalForce.y = manifold.directionalForce.y * self.friction
        manifold.directionalForce.z = manifold.directionalForce.z * self.friction

        local acceleration = lovr.math.vec3(manifold.directionalForce.x, force.y + manifold.directionalForce.y, manifold.directionalForce.z)
        manifold.velocity.x = acceleration.x + manifold.velocity.x
        manifold.velocity.z = acceleration.z + manifold.velocity.z
        manifold.velocity.y = acceleration.y + manifold.velocity.y

        --manifold.reflectionPush:set(0, 0, 0)

        if self.hasCollisions == true then
            local finalOffset = lovr.math.vec3()
            local newVel = lovr.math.vec3(manifold.velocity.x, manifold.velocity.y, manifold.velocity.z)
            local direction = (newVel:normalize()* (newVel:length()*self.collisionDist) )
            local target = (manifold.position + direction)

            self.scene.physWorld:raycast(manifold.position, target, function(shape, x, y, z, nx, ny, nz)
                manifold.velocity:set(manifold.velocity.x * (1 - nx), manifold.velocity.y * (1 - ny), manifold.velocity.z * (1 - nz))
            end)
        end

        manifold.velocity.x = manifold.velocity.x * newDt
        manifold.velocity.z = manifold.velocity.z * newDt
        manifold.velocity.y = manifold.velocity.y * newDt


        --manifold.velocity:set(manifold.velocity.x * (1 - manifold.prevHitNorm.x), manifold.velocity.y * (1 - manifold.prevHitNorm.y), manifold.velocity.z * (1 - manifold.prevHitNorm.z))

        manifold.position.x = manifold.position.x + manifold.velocity.x * newDt
        manifold.position.y = manifold.position.y + manifold.velocity.y * newDt
        manifold.position.z = manifold.position.z + manifold.velocity.z * newDt

        --manifold.position:set(manifold.position.x + finalOffset.x, manifold.position.y + finalOffset.y, manifold.position.z + finalOffset.z)

        -- Collision calculations
        --[[local direction = acceleration:normalize()
        local target = manifold.position + direction]]

        --[[manifold.prevHitNorm:set(0, 0, 0)
        if (manifold.position - manifold.prevPosition):length() > 0 then
            self.scene.physWorld:raycast(manifold.position, target, function(shape, x, y, z, nx, ny, nz)
                local offsetDirection = lovr.math.vec3(nx, ny, nz) * 0.25
                manifold.prevHitNorm:set(nx, ny, nz)
                manifold.velocity:set(manifold.velocity.x * (1 - nx), manifold.velocity.y * (1 - ny), manifold.velocity.z * (1 - nz))
                manifold.position:set(x + offsetDirection.x, y + offsetDirection.y, z + offsetDirection.z)
            end)
        end]]

        manifold.prevPosition:set(manifold.position.x, manifold.position.y, manifold.position.z)

        -- Transform matrix calculations
        local newRot
        local x, y, z, angle, ax, ay, az = lovr.headset.getPose()
        if self.faceCamera == true then
            local normPos = lovr.math.vec3(x, y, z) - manifold.position
            newRot = lovr.math.quat(normPos:normalize())
        else
            newRot = lovr.math.quat(self.globalTransform.rotation.x, self.globalTransform.rotation.y, self.globalTransform.rotation.z, self.globalTransform.rotation.w)
        end

        manifold.matrix = lovr.math.newMat4():translate(manifold.position):rotate(newRot)
        manifold.camDist = (lovr.math.vec3(manifold.position.x, manifold.position.y, manifold.position.z) - lovr.math.vec3(x, y, z)):length()

        -- Number Range calculations (This was a pain in the ass)
        local curTime = self.scene.timer - manifold.prevTime

        -- Alpha number range
        local nextAlphaManifold, prevAlphaManifold, prevAlphaTime = getNextAndPrevVal(normalizeTime(curTime, self.lifeTime, 1.0), manifold.currentAlphaRange, manifold.lastNextAlphaManifold, self.scene.timer)
        if prevAlphaTime then
            manifold.alphaPrevTime = prevAlphaTime
        end
        manifold.lastNextAlphaManifold = nextAlphaManifold

        local alphaCurTime = self.scene.timer - manifold.alphaPrevTime
        local tAlphaMultiplier = tonumber(nextAlphaManifold.time - prevAlphaManifold.time) * self.lifeTime
        local alphaT = clamp(1 - ((tAlphaMultiplier - alphaCurTime)/tAlphaMultiplier), 0, 1)
        manifold.alpha = lerp(prevAlphaManifold.value, nextAlphaManifold.value, alphaT)

        -- Scale number range
        local nextScaleManifold, prevScaleManifold, prevScaleTime = getNextAndPrevVal(normalizeTime(curTime, self.lifeTime, 1.0), manifold.currentScaleRange, manifold.lastNextScaleManifold, self.scene.timer)
        if prevScaleTime then
            manifold.scalePrevTime = prevScaleTime
        end
        manifold.lastNextScaleManifold = nextScaleManifold

        local scaleCurTime = self.scene.timer - manifold.scalePrevTime
        local tScaleMultiplier = tonumber(nextScaleManifold.time - prevScaleManifold.time) * self.lifeTime
        local scaleT = clamp(1 - ((tScaleMultiplier - scaleCurTime)/tScaleMultiplier), 0, 1)

        local lerpedScale = lerpVec3(prevScaleManifold.value, nextScaleManifold.value, scaleT)
        manifold.scale:set(lerpedScale.x, lerpedScale.y, lerpedScale.z)
        
        -- Finalize
        self.particleManifolds[i] = manifold
    end

    -- Z-sort all particles
    table.sort(self.particleManifolds, function(a, b)
        return a.camDist > b.camDist
    end)
end

function Particle:draw(pass, mode)
    if mode ~= "depth" then
        if self.faceCamera == false then
            pass:setCullMode('none')
        else
            pass:setCullMode('front')
        end
        if self.hasDepthTest == false then 
            pass:setDepthTest("none")
        end

        local x, y, z, angle, ax, ay, az = lovr.headset.getPose()
        pass:send('PositionCam', lovr.math.vec3(x, y, z))

        local near, far = lovr.headset.getClipDistance()
        pass:send('near', near)
        pass:send('edgeSmooth', self.edgeSmooth)
        pass:send('resolution', lovr.math.vec2(lovr.headset.getDisplayWidth(), lovr.headset.getDisplayHeight()))
        pass:send('brightness', self.brightness)

        pass:send('diffuseMap', self.diffuseMap)
        pass:send('depthMap', self.scene.camera.depthTexture)

        pass:send('hasDepthTest', self.hasDepthTest)
        pass:send('hasShadowCastings', self.hasShadowCastings)

        for _, manifold in pairs(self.particleManifolds) do
            pass:send('alpha', manifold.alpha)

            --[[pass:setViewPose( 1, lovr.headset.getPose() )
            pass:setProjection( 1, self.scene.camera.proj )]]

            pass:plane(manifold.matrix:scale(self.localTransform.scale.x * manifold.scale.x, self.localTransform.scale.y * manifold.scale.y, self.localTransform.scale.z * manifold.scale.z))
        end

        pass:setCullMode('back')
        pass:setDepthTest()
    else
        pass:setCullMode('none')
        for _, manifold in pairs(self.particleManifolds) do
            pass:plane(manifold.matrix:scale(self.localTransform.scale.x * manifold.scale.x, self.localTransform.scale.y * manifold.scale.y, self.localTransform.scale.z * manifold.scale.z))
        end
        pass:setCullMode('back')
        pass:setDepthTest()
    end
end


--# Finalize
return Particle
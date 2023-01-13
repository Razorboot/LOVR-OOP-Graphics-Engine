--# Include
local Node = require "lovr_graphics_engine.modules.node"
local Transform = require "lovr_graphics_engine.modules.transform"


--# Point
local Light = Node:extend()


--# Variables
local defaults = {
    color = lovr.math.newVec3(1.0, 1.0, 1.0),
    depthSize = 1024*1.5,
    range = 15.0,
    angle = 30
}


--# Creation Methods
function Light:new(info)
    Node.newDefault(self, info)

    -- General
    self.name = info.name or "MyLight"
    info.color = info.color or defaults.color

    -- General light vars
    self.type = info.type or "PointLight"

    self.color = lovr.math.newVec3(info.color.x, info.color.y, info.color.z)
    self.range = info.range or defaults.range

    -- Specific light settings
    if self.type == "SpotLight" then
        self.angle = 0
        self:setAngle(info.angle or defaults.angle)
    elseif self.type == "PointLight" then
        
    end

    -- Shadow settings
    self.hasShadows = info.hasShadows or false
    self.hasShadowsChanged = true
    if self.type == "PointLight" then self.hasShadows = false end
    self:setShadows(self.hasShadows)
end

--# Update Methods
function Light:update()
    --[[ No need to continue if there was no change in:
        1.) local transform
        2.) global transform
        3.) global transform of the parent
    ]]
    if self.localTransform.changed == false and self.globalTransform.changed == false and self.parent.globalTransform.changed == false then return false end

    -- Local transform is set manually, this means we only need to update the global transform to reflect changes in local transform
    self:updateGlobalTransform()

    if self.type == "SpotLight" then
        if self.hasShadows == true then
            local targetPos = self:getTarget()

            self.pose:target( self.globalTransform.position, targetPos)
            self.view:set( self.pose ):invert()
        end

        self.hasShadowsChanged = false
    end
end


--# Draw Methods
function Light:drawDebug(pass, color)
    local colx, coly, colz, colw = 1, 1, 1, 1
    if color then
        colx, coly, colz = color.x, color.y, color.z
        if color.w then colw = color.w end
    end
    pass:setColor(colx, coly, colz, colw)
    pass:setWireframe(true)

    local newTransformMat = lovr.math.mat4(self.globalTransform.matrix:unpack(true)):scale(0.75, 0.75, 0.75)
    
    if self.type == "SpotLight" then
        pass:cone(newTransformMat, 8)
        --pass:cylinder(lovr.math.mat4():translate( self:getTarget() ):rotate( Transform.getRotationFromMat4(newTransformMat):scale( Transform.getScaleFromMat4(newTransformMat) ) ), true)
        pass:cylinder(self.globalTransform.position, self:getTarget(), 0.02, true, nil, nil, 8)
    else
        pass:sphere(newTransformMat:scale(0.5, 0.5, 0.5))
        --pass:cylinder(self.globalTransform.position, lovr.math.vec3(0, 0, 0), 0.02, true, nil, nil, 8)
    end

    pass:setWireframe(false)
    pass:setColor(1, 1, 1, 1)
end


--# Helper Methods
function Light:setAngle(num)
    num = math.min(num, 90)
    num = 90 - num
    self.angle = math.rad(num)
end

function Light:setShadows(bool)
    if self.type == "SpotLight" then
        self.hasShadows = bool or false

        if bool == true then
            -- Depth buffer
            local depthBufferSize = self.scene.defaults.light_depthSize
            self.depthTex = lovr.graphics.newTexture(depthBufferSize, depthBufferSize, {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})

            -- Projection settings for the depth buffer
            self.pose = lovr.math.newMat4()
            self.view = lovr.math.newMat4()
            self.projection = lovr.math.newMat4():perspective( math.rad(90), 1, 0.01 )
        else
            self.depthTex, self.pose, self.view, self.projection = nil
        end

        self.scene:resetShadows()
    end
end

function Light:getDirection()
    return lovr.math.quat(self.globalTransform.rotation.x, self.globalTransform.rotation.y, self.globalTransform.rotation.z, self.globalTransform.rotation.w):direction()
end

function Light:getTarget()
    local targetPos = self.globalTransform.position - self:getDirection()
    return targetPos
end


--# Finalize
return Light
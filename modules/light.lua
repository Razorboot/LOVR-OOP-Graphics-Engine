--# Include
local Object = require "libs.classic"
local Transform = require "modules.transform"


--# Point
local Light = Object:extend()


--# Variables
local defaults = {
    light_color = lovr.math.newVec3(1.0, 1.0, 1.0),
    light_depthSize = 1024*1.5,
    light_range = 15.0,
    light_angle = 30
}


--# Core Functions
function Light:new(node, info)
    -- Presets
    self.node = node
    self.name = info.light_name or tostring("Light ("..tostring(#node.attachments.lights + 1)..")")
    info.light_color = info.light_color or defaults.light_color

    -- General light vars
    self.offsetTransform = Transform()
    self.type = info.light_type or "pointLight"

    self.color = lovr.math.newVec3(info.light_color.x or defaults.light_color.x, info.light_color.y or defaults.light_color.y, info.light_color.z or defaults.light_color.z)
    --lightManifold.origin = info.light_origin
    self.range = info.light_range or defaults.light_range

    -- Specific light settings
    if self.type == "spotLight" then
        --lightManifold.dir = info.spot_dir
        --self.angle = math.cos( math.rad( info.light_angle or defaults.light_angle ))
        self.angle = 0
        self:setAngle(info.light_angle or defaults.light_angle)
    elseif self.type == "pointLight" then
        
    end

    -- Insert the instance into the node lights array
    table.insert(node.attachments.lights, self)

    -- Shadow settings
    self.hasShadows = info.light_hasShadows or false
    self.hasShadowsChanged = true
    if self.type == "pointLight" then self.hasShadows = false end
    self:setShadows(self.hasShadows)
end

function Light:update()
    --self.offsetTransform:updatePrevMatrix()

    if self.type == "spotLight" then
        --[[if self.prevAngle ~= self.angle or self.hasShadowsChanged == true then
            self.prevAngle = self.angle
            if self.projection ~= nil then
                self.projection = self.projection:perspective( self.angle, 1, 0.01 )
            end
        end]]

        if self.hasShadows == true then
            --[[if self.offsetTransform.changed == true or self.hasShadowsChanged == true then
                local targetPos = self:getTarget()

                self.pose:target( self.offsetTransform.position, targetPos)
		        self.view:set( self.pose ):invert()
            end]]
            local targetPos = self:getTarget()

            self.pose:target( self.offsetTransform.position, targetPos)
            self.view:set( self.pose ):invert()
        end

        self.hasShadowsChanged = false
    end
end


--# Misc Functions
function Light:setAngle(num)
    print(num)
    num = math.min(num, 90)
    num = 90 - num
    self.angle = math.rad(num)
end

function Light:setShadows(bool)
    if self.type == "spotLight" then
        self.hasShadows = bool or false

        if bool == true then
            -- Depth buffer
            local depthBufferSize = self.node.scene.defaults.light_depthSize
            self.depthTex = lovr.graphics.newTexture(depthBufferSize, depthBufferSize, {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})

            -- Projection settings for the depth buffer
            self.pose = lovr.math.newMat4()
            self.view = lovr.math.newMat4()
            self.projection = lovr.math.newMat4():perspective( math.rad(90), 1, 0.01 )

            --[[ Implement a shadowmap into the global scene shadowmap system
            self.depthTexViewArray = self.node.scene.lightDepthTexArray:newView('array', #self.node.scene.lightDepthTexArray_Views + 1, 1, 1, 1)
            table.insert(self.node.scene.lightDepthTexArray_Views, self.depthTexViewArray)]]
        else
            self.depthTex, self.pose, self.view, self.projection = nil
        end

        self.node.scene:resetShadows()
    end
end

function Light:getTarget()
    local targetDir = lovr.math.quat(self.offsetTransform.rotation.x, self.offsetTransform.rotation.y, self.offsetTransform.rotation.z, self.offsetTransform.rotation.w):direction()
    local targetPos = self.offsetTransform.position - targetDir
    return targetPos
end


--# Finalize
return Light
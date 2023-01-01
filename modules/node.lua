--# Include
local Object = require "libs.classic"
local Transform = require "modules.transform"


--# Variables
assets = 'assets/'


--# Point
local Node = Object:extend()


--# Variables
local defaults = {
    node_name = "NodeNew",
}


--# Creation Functions
function Node:new(info)
    -- Base attachments: Attachments are different attributes a node can have, like a model, lightsource, etc.
    self.scene = info.node_scene
    self.type = "node"
    self.name = info.node_name or tostring("Node ("..tostring(#info.node_scene.nodes + 1)..")") or "NodeNew"
    self.attachments = {}
    self.attachments.models = {}
    self.attachments.lights = {}
    self.attachments.bodies = {}

    -- Transform: Transform matrix using my transform class.
    self.transform = Transform({scale = lovr.math.vec3(0, 0, 0)})

    -- Add node to the scene nodes array
    table.insert(self.scene.nodes, self)
end

function Node:destroy()
    for i, scanNode in pairs(self.scene.nodes) do
        if scanNode == self then
            table.remove(self.scene.nodes, i)
            self = nil
            return nil
        end
    end
end

function Node:destroyAttachment(attachment)
    if attachment.type == "spotLight" or attachment.type == "pointLight" then
        for i, scanAttachment in pairs(self.attachments.lights) do
            if scanAttachment == attachment then
                table.remove(self.attachments.lights, i)
                attachment = nil
                return nil
            end
        end
    elseif attachment.type == "model" then
        for i, scanAttachment in pairs(self.attachments.models) do
            if scanAttachment == attachment then
                table.remove(self.attachments.models, i)
                attachment = nil
                return nil
            end
        end
    elseif attachment.type == "body" then
        for i, scanAttachment in pairs(self.attachments.bodies) do
            if scanAttachment == attachment then
                table.remove(self.attachments.bodies, i)
                if attachment.collider then attachment.collider:destroy() end
                attachment = nil
                return nil
            end
        end
    end
end


--# Helper Functions
function Node:getModel(name)
    for _, model in pairs(self.attachments.models) do
        if model.name == name then return model end
    end
end

function Node:getLight(name)
    for _, light in pairs(self.attachments.lights) do
        if light.name == name then return light end
    end
end


--# Finalize
return Node
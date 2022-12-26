--# Include
local Object = require "libs.classic"


--# Point
local Scene = Object:extend()


--# Methods
function Scene:new(nodes)
    -- All the nodes in the scene
    self.nodes = {}

    -- Node attachments that will be passed to the renderer
    self.allAttachments = {}
    self.allLights = {}
    self.allModels = {}
end

function scene:addNode(node)
    table.insert(self.nodes, node)
end

function scene:removeNode(nodeToRemove, name)
    for i, node in pairs(self.nodes) do
        if node == nodeToRemove or node.name == name then
            table.remove(self.nodes, i)
            return nil
        end
    end
end

function scene:update()
    
end
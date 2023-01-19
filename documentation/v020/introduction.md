## Version 0.2.0

# Object Classes
* [Scenes](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/scene)
* [Transforms](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/transform)
* [Nodes](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/node)
* [Lights](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/light)
* [Models](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/model)
* [Bodies](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/body)
* [Particles](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/particle)

# Getting Started (WIP)
* Note: This project is designed to be used with or without VR, there's no preference! I'm planning to prioritize non-vr users in future updates though.
* If you're unfamiliar with LOVR, take a look at the [Getting Started Tutorial](https://lovr.org/docs/Getting_Started) for how to create your first project!
* Make sure that you're using the [Nightly Build](https://lovr.org/downloads) of LOVR for the latest features and support!

# Creating Your First Project
* Make sure you read the Getting Started Tutorial on the LOVR website to get started! The steps below will be a summary of the steps above but specifically for LGE.
* Create a new file called ``main.lua`` in your project folder.
* You can install LGE (LOVR Graphics Library) into your lovr project by inserting ``lovr_graphics_engine`` from the repo into your project folder.
* LGE can then be included in ``main.lua`` or any other script using:
```lua
local LGE = require "lovr_graphics_engine.include"
```
* Make sure your default ``main.lua`` script includes LGE and has the default LOVR functions.
```lua
--# Include
local LGE = require "lovr_graphics_engine.include"

--# Primary Functions
function lovr.load()
  -- This is called once on load.
  -- You can use it to load assets and set everything up.
end

function lovr.update(dt)
  -- This is called continuously and is passed the "delta time" as dt, which
  -- is the number of seconds elapsed since the last update.
  -- You can use it to simulate physics or update game logic.
end

function lovr.draw(pass)
  -- This is called once every frame.
  -- You can call functions on the pass to render graphics.
end
```
* In the ``lovr.load()`` function, you can create a new Scene.
* A [Scene](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/scene) is a container that contains everything you see in your game. It also includes essential variables and properties that you can modify to affect your game.
```lua
local myScene

function lovr.load()
  -- Create a new Scene object
  myScene = LGE.Scene()
end
```
* After creating a new [Scene](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/scene), a ``root`` must be set to it. The ``root`` is the primary [Node](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/node) object of the Scene! All other Node objects added should be descendants of the root Node.
```lua
local myScene

function lovr.load()
  -- Create a new Scene object
  myScene = LGE.Scene()
  -- Create the root Node of the scene. root.name is an optional parameter available across all nodes.
  myScene.root = LGE.Node() 
  myScene.root.name = "RootNode"
end
```
* Other Node objects such as [Nodes](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/node), [Models](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/model), [Lights](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/light), and more can also be created in the ``lovr.load()`` function. All of these special Node objects are extensions of regular [Nodes](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/node), meaning they have the same properties that Node objects do. They also have their own functions and properties.
* All Node objects can also have a ``parent``. When thinking of children and parents in programming, think of a file inside a folder. The file is the child of the folder, and folder is the parent. Node objects function in a similar manner, where an Object can be a child of a parent Object.
```lua
local myScene
local myModel
local myLight

function lovr.load()
  -- Create a new Scene object
  myScene = LGE.Scene()
  -- Create the root Node of the scene. root.name is an optional parameter available across all nodes.
  -- Root nodes do not have parents.
  myScene.root = LGE.Node() 
  myScene.root.name = "RootNode"
  -- Create a new Model that is a child of the root node.
  -- All Node objects that aren't root nodes should have a parent.
  myModel = LGE.Model({parent = myScene.root})
  -- Create a new point light that is a child of myModel.
  -- Check the link above for Light objects to learn more about types!
  myLight = LGE.Light({type = "pointLight"})
end
```
* TBC...

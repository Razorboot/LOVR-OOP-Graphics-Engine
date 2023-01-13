# Scene Class

## Description
* A ``Scene`` object is a container that contains everything that you see in your game!
* A ``Scene`` object is designed to contain ``Node`` objects.

## Properties of a Scene object
* ``root`` *Node object*: This is the primary ``Node`` object of the Scene! All other ``Node`` objects added should be descendants of the root Node.
* ``defaults`` *array*: Values that the Scene uses when other objects are created or rendered given the Scene.
* ``defauts.Light_depthSize`` *number*: Size of the depth buffer used in shadowmapping for ``Light`` objects in the Scene.
* ``defaults.depthTexOptions`` *array*: Depth texture options used in shadowmapping for ``Light`` objects in the Scene.
* ``Lighting`` *array*: Default Lighting values that are used during rendering.
* ``Lighting.ambience`` *vector3*: Ambient color used when rendering objects in the Scene.
* ``timer`` *number*: The time passed since the Scene was created.
* ``passes`` *array*: LOVR rendering passes that the Scene uses.

## Creating a Scene object
* A ``Scene`` object can easily be created by typing in ``LGE.Scene()`` in the default ``lovr.load()`` function.

## Scene saving and loading
* A ``Scene`` object can easily be saved to a lua file in the default file directory for LOVR.
* More information on the default file directory can be found at the bottom of [this page](https://lovr.org/docs/lovr.filesystem)
```lua
Scene:saveToFile(filename [string])
```
* A ``Scene`` object can also be reconstructed from a save file from any directory!
```lua
local myScene = Scene.createFromFile(filepath [string])
```

## General Methods
* Returns all the Models in the Scene.
```lua
Scene:getModels()
```
* Returns all the Lights in the Scene.
```lua
Scene:getLights()
```
* Returns all the models in the Scene.
```lua
Scene:getModels()
```
* Returns all the bodies in the Scene.
```lua
Scene:getBodies()
```
* Resets all shadowmap depth texture buffer information for every Light in the Scene.
* This is always called whenever a new ``Light`` object is added to the Scene.
```lua
Scene:resetShadows()
```

## Update Methods
* Update Scene physics, timer, camera, and other essential variables.
* ``dt`` should be the lovr default in the ``lovr.update(dt)`` function.
```lua
Scene:update(dt [number])
```
* Render shadowmaps and update transform information of all Lights in the Scene.
```lua
Scene:updateLight()
```
* Update transform information of all models in the Scene.
```lua
Scene:updateModels()
```
* Update transform information of all bodies in the Scene.
```lua
Scene:updateBodies()
```

## Drawing Methods
* Draw only the shadowmap depth texture information of a spotLight.
```lua
Scene:drawDepth(pass [lovr pass], proj [mat4], pose [mat4])
```
* Draw the entire Scene.
* ``pass`` should be the default pass in the ``lovr.load(pass)`` function.
```lua
Scene:drawFull(pass [lovr pass])
```
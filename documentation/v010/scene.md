# Scene Class

## Description
* A ``scene`` object is a container that contains everything that you see in your game!
* A ``scene`` object is designed to contain ``node`` objects.

## Properties of a Scene object
* ``nodes`` *array*: Contains all of the ``node`` objects in the scene.
* ``defaults`` *array*: Values that the scene uses when other objects are created or rendered given the scene.
* ``defauts.light_depthSize`` *number*: Size of the depth buffer used in shadowmapping for ``light`` objects in the scene.
* ``defaults.depthTexOptions`` *array*: Depth texture options used in shadowmapping for ``light`` objects in the scene.
* ``lighting`` *array*: Default lighting values that are used during rendering.
* ``lighting.ambience`` *vector3*: Ambient color used when rendering objects in the scene.
* ``timer`` *number*: The time passed since the scene was created.
* ``passes`` *array*: LOVR rendering passes that the scene uses.

## Creating a Scene object
* A ``scene`` object can easily be created by typing in ``LGE.Scene()`` in the default ``lovr.load()`` function.

## General Methods
* Returns all the Models in the scene.
```lua
Scene:getModels()
```
* Returns all the Lights in the scene.
```lua
Scene:getLights()
```
* Returns all the models in the scene.
```lua
Scene:getModels()
```
* Returns all the bodies in the scene.
```lua
Scene:getBodies()
```
* Returns a node given a name.
```lua
Scene:getNode(name [string])
```
* Resets all shadowmap depth texture buffer information for every light in the scene.
* This is always called whenever a new ``light`` object is added to the scene.
```lua
Scene:resetShadows()
```

## Update Methods
* Update scene physics, timer, camera, and other essential variables.
* ``dt`` should be the lovr default in the ``lovr.update(dt)`` function.
```lua
Scene:update(dt [number])
```
* Render shadowmaps and update transform information of all lights in the scene.
```lua
Scene:updateLight()
```
* Update transform information of all models in the scene.
```lua
Scene:updateModels()
```
* Update transform information of all bodies in the scene.
```lua
Scene:updateBodies()
```

## Drawing Methods
* Draw only the shadowmap depth texture information of a spotLight.
```lua
Scene:drawDepth(pass [lovr pass], proj [mat4], pose [mat4])
```
* Draw the entire scene.
* ``pass`` should be the default pass in the ``lovr.load(pass)`` function.
```lua
Scene:drawFull(pass [lovr pass])
```
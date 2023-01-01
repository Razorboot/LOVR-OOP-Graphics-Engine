# Scene Class

## Description
* A ``scene`` object is a is a container that contains everything that you see in your game!
* A ``scene`` object is designed to contain ``node`` objects.

## Properties of a Scene object
* ``nodes``: An array that contains all of the ``node`` objects in the scene.
* ``defaults``: An array representing values that the scene uses when other objects are created or rendered given the scene.
* ``defauts.light_depthSize``: The size of the depth buffer used in shadowmapping for ``light`` objects in the scene.
* ``defaults.depthTexOptions``: The depth texture options used in shadowmapping for ``light`` objects in the scene.
* ``lighting``: An array representing default lighting values that are used during rendering.
* ``lighting.ambience``: A vector3 representing the ambient color used when rendering objects in the scene.
* ``timer``: A number representing the time passed since the scene was created.
* ``passes``: LOVR rendering passes that the scene uses.

## Creating a Scene object
* Creating a new ``scene`` object is easily done by passing in an array.
```lua
Scene({

})
```

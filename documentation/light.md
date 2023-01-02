# Light Class

## Description
* Currently, LGE supports point lights and spot lights.
* point lights currently don't support shadows yet, but this is being worked on.
* ``light`` objects can be fixed to ``model`` or ``body`` objects. This makes the ``globalTransform`` of the ``light`` object the affixer transform multiplied by the ``offsetTransform`` of the ``light`` object.
* If the ``light`` object is not fixed to an object, then the initial transform will be the parent ``node`` object tranform.

## Properties of a Light object
* ``type`` *string*: The class type of the object. A light will either have this be ``"pointLight"`` or ``"spotLight"``.
* ``node`` *node object*: The parent node of the light.
* ``name`` *string*: The name of the light.
* ``offsetTransform`` *transform object*: The local transform of the light.
* ``globalTransform`` *transform object*: The final transform of the light.
* ``range`` *number*: How far the light will be visible.
* ``affixer`` *model or body object*: The object that the light is locked to.
* ``hasShadows`` *bool*: Whether shadows are enabled or disabled for the light.
* ``angle`` *number*: The angular range of the light.
* ``color`` *vector3*: The color of the light.

## Creating a Light object
* Creating a new ``light`` object is done by passing in a ``node`` object and an array.
```lua
LGE.Light(
    myNode,
    {
        light_name = myName, [string]  -- Optional
        light_color = myColor, [vector3] -- Optional, defaulted to (1, 1, 1)
        light_range = myRange, [number] -- Optional, defaulted to 15
        light_angle = myAngle, [number] -- Optional, defaulted to 30
        light_type = myType, [string] -- Optional, can either be "spotLight" or "pointLight", defaulted to "pointLight"
        light_hasShadows = shadowsEnabled [bool] -- Optional, defaulted to false
    }
)
```

## General Methods
* Set the object that the light will be fixed to.
```lua
Light:setAffixer(attachment [model or body object])
```
* Set the anglular range of the light.
```lua
Light:setAngle(number [number])
```
* Change whether the light has shadows enabled or disabled.
* Executing this function will reset all shadow maps of the parent scene.
```lua
Light:setShadows(bool [bool])
```
* Get the position as a ``vector3`` that the light is rotated toward.
```lua
Light:getTarget()
```

## Update Methods
* Update the ``globalTransform``, ``pose``, and ``view`` information of the light for use in shadowmapping.
```lua
Light:update()
```
* Update the ``globalTransform`` of the light.
```lua
Light:updateGlobalTransform()
```

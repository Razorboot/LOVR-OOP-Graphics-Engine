# Light Class

## Description
* Currently, LGE supports point lights and spot lights.
* Point lights currently don't support shadows yet, but this is being worked on.

## Properties of a Light object
* ``type`` *string*: The class type of the object. A light will either have this be ``"pointLight"`` or ``"spotLight"``.
* ``range`` *number*: How far the light will be visible.
* ``hasShadows`` *bool*: Whether shadows are enabled or disabled for the light.
* ``angle`` *number*: The angular range of the light.
* ``color`` *vector3*: The color of the light.

## Creating a Light object
* Creating a new ``light`` object is done by passing in a ``node`` object and an array.
```lua
LGE.Light(
    {
        -- In addition to the options supported in "LGE.Node"...
        color = myColor, [vector3] -- Optional, defaulted to (1, 1, 1)
        range = myRange, [number] -- Optional, defaulted to 15
        angle = myAngle, [number] -- Optional, defaulted to 30
        type = myType, [string] -- Optional, can either be "spotLight" or "pointLight", defaulted to "pointLight"
        hasShadows = shadowsEnabled [bool] -- Optional, defaulted to false
    }
)
```

## General Methods
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
* Update the ``globalTransform`` information of the Light.
* ``localTransform`` is not updated since it is always set manually.
```lua
Light:update()
```

## Draw Methods
* Draw the light in debug mode.
* Debug mode means the light is rendered using a wireframe mesh.
```lua
Light:drawDebug(pass, [lovr pass] color [optional vector3 or vector4])
```
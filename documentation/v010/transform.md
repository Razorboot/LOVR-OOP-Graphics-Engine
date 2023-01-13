# Transform Class

## Description
* A ``transform`` object represents a position, rotation, and scale.
* ``transform`` objects are automatically applied to ``node``, ``light``, ``model``, and ``body`` objects.
* Transformations can be rather confusing, but so much is possible using them. If you're unfamiliar with transformation matrices, I suggest taking a look at [this](https://learnopengl.com/Getting-started/Transformations) explanation.

## Properties of a Transform object
* ``matrix`` *mat4*: A transformation matrix.
* ``position`` *vector3*: The position applied to the matrix.
* ``scale`` *vector3*: The scale applied to the matrix.
* ``rotation`` *vector4*: The rotation applied to the matrix. Though this is a vector4, the ``x, y, z, w`` components map to a quaternion's ``angle, ax, ay, az`` components.
* ``prevMatrix`` *mat4*: Used when detecting if the transform has been changed.
* ``changed`` *bool*: Whether the transform has been changed since the last ``Transform:updatePrevMatrix()`` call.

## Creating a Transform object
* Passing in an optional array with a ``mat4``, ``pos``, ``rot``, and/or ``scale`` will automatically set the ``transform`` object to include these values.
```lua
-- Create a new transform object at position (1, 1, 1)
LGE.Transform({
    pos = lovr.math.vec3(1, 1, 1)
})
-- Create a transform object with all values set to (0, 0, 0)
LGE.Transform()
```

## General Methods
* Create a new transformation matrix with the values of the matrix of the current ``transform`` object.
```lua
Transform:cloneMatrix()
```
* Change any value(s) of the ``transform`` object.
```lua
Transform:setMatrix(info [array])
-- Example:
Transform:setMatrix({
    rot = lovr.math.vec4(math.rad(25), 1, 0, 0)
})
```
* Update ``prevMatrix`` and ``changed`` a change in the position, rotation, scale, or matrix of the ``transform`` object.
```lua
Transform:updatePevMatrix()
```

## Helper Functions
* Extract position components ``x, y, z`` from a transformation matrix.
```lua
LGE.Transform.getPositionFromMat4(mat4 [mat4])
```
* Extract rotation components ``angle, ax, ay, az`` from a transformation matrix.
```lua
LGE.Transform.getRotationFromMat4(mat4 [mat4])
```
* Extract scale components ``x, y, z`` from a transformation matrix.
```lua
LGE.Transform.getScaleFromMat4(mat4 [mat4])
```
* Extract position and rotation components ``x, y, z, angle, ax, ay, az`` from a transformation matrix.
```lua
LGE.Transform.getPose(mat4 [mat4])
```
* Convert a matrix to a transformation matrix.
```lua
LGE.Transform.getTransformMatFromMat4(mat4 [mat4])
```
* Extract a string from a matrix.
```lua
LGE.Transform.getStringFromMat4(mat4 [mat4])
```
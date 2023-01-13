# Body Class

## Description
* ``Body`` objects are an extension of lovr colliders and ``Node`` objects.
* ``Body`` objects with a ``collider`` that is not kinematic and is free moving will not have their transform behave like a regular ``Node`` object. Otherwise, the ``globalTransform`` will always behave on the basis of global physics.

## Properties of a Body object
* ``type`` *string*: The class type of the object. This will always be ``"Body"``.
* ``collider`` *lovr collider*: The collider of the Body.

## Creating a Body object
* Creating a new ``Body`` object is done by passing in a ``node`` object and an array.
* ``collider_type`` can either be ``"box"``, ``"capsule"``, ``"cylinder"``, ``"sphere"``, or ``"mesh"``.
* If a ``radius`` and/or ``length`` is not passed into the array, then LGE will use the width, height and depth dimensions instead.
```lua
LGE.Body(
    myNode,
    {
        collider_type = myColliderType, [string] -- Optional, defaulted to a collider with no shape applied, If set to "mesh", the mesh information of the model argument will be used
        model = myModel, [model instance] -- Optional
        use_dimensions = myBool, [bool] -- Optional, whether the dimensions of the model argument are used to set the size of the collider
        dimensions = myScale [vector3] -- Optional, uses the values of the vector instead of the dimensions of the model or the default dimensions.
    }
)
```

## General Methods
* Whether the ``collider`` of the Body is kinematic or not.
* When using a Body, this should always be used instead of lovr's ``collider:setKinematic(bool [bool])``.
```lua
Body:setKinematic(bool [bool])
```


## Update Methods
* Update the ``globalTransform`` and ``localTransform`` information of the Body.
* ``localTransform`` is updated if the ``collider`` is kinematic, because this means that ``Body`` is behaving relative to physics and not relative to the ``globalTransform`` of the parent Node.
```lua
Body:update()
```
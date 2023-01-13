# Body Class

## Description
* ``body`` objects are an extension of lovr colliders with the added support of a ``transform`` object.
* ``body`` objects with a ``collider`` that is not kinematic and is free moving will not have their tranform influenced by the parent ``node`` object.

## Properties of a Body object
* ``type`` *string*: The class type of the object. This will always be ``"body"``.
* ``node`` *node object*: The parent node of the body.
* ``name`` *string*: The name of the body.
* ``transfom`` *transform object*: The final transform of the body.
* ``collider`` *lovr collider*: The collider of the body.

## Creating a Body object
* Creating a new ``body`` object is done by passing in a ``node`` object and an array.
* ``collider_type`` can either be ``"box"``, ``"capsule"``, ``"cylinder"``, ``"sphere"``, or ``"mesh"``.
* If a ``radius`` and/or ``length`` is not passed into the array, then LGE will use the width, height and depth dimensions instead.
```lua
LGE.Body(
    myNode,
    {
        body_name = myName, [string]  -- Optional
        transform = myTransform, [transform object] -- Optional
        collider_type = myColliderType, [string] -- Optional, defaulted to a collider with no shape applied
        model = myModel, [model instance] -- Optional
        use_dimensions = myBool, [bool] -- Optional, whether the dimensions of the model argument are used to set the size of the collider

        radius = myNumber, [number] -- Optional, this is only used for capsule, cylinder, and sphere collider_types
        length = myNumber [number] -- Optional, this is only used for capsule, cylinder, and sphere collider_types
    }
)
```

## General Methods
* Whether the ``collider`` of the body is kinematic or not.
* When using a body, this should always be used instead of lovr's ``collider:setKinematic(bool [bool])``.
```lua
Body:setKinematic(bool [bool])
```


## Update Methods
* Update the final ``transform`` information of the body.
```lua
Body:update()
```
* Update the local ``transform`` information of the body.
```lua
Body:updateTransform()
```
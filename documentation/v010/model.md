# Model Class

## Description
* ``model`` objects function similary to lovr models with the added support of ``transform`` objects and different material options.
* ``model`` objects can be fixed to ``body`` objects. This makes the ``globalTransform`` of the ``model`` object the affixer transform multiplied by the ``offsetTransform`` of the ``model`` object.
* If the ``model`` object is not fixed to an object, then the initial transform will be the parent ``node`` object tranform.

## Properties of a Model object
* ``type`` *string*: The class type of the object. This will always be ``"model"``.
* ``node`` *node object*: The parent node of the model.
* ``name`` *string*: The name of the model.
* ``offsetTransform`` *transform object*: The local transform of the model.
* ``globalTransform`` *transform object*: The final transform of the model.
* ``modelInstance`` *lovr model*: A lovr model instance.
* ``diffuseMap`` *lovr texture*: The diffuse texture for the model.
* ``normalMap`` *lovr texture*: The normal texture for the model.
* ``specularMap`` *lovr texture*: The specular texture for the model.
* ``textureMode`` *string*: The mode that changes how the textures are rendered for the model. Can either be ``"UV"`` or ``"Tile"``.
* ``affixer`` *body object*: The object that the model is fixed to.

## Creating a Model object
* Creating a new ``body`` object is done by passing in a ``node`` object and an array.
```lua
LGE.Model(
    myNode,
    {
        model_name = myName, [string]  -- Optional
        model_filepath = FilepathToModel, [string] -- Necessary, this is the filepath to the model
        diffuseMap_filepath = diffusePath, [string] -- Optional, defaulted to brick texture in assets_default
        normalMap_filepath = normalPath, [string] -- Optional, defaulted to brick texture in assets_default
        specularMap_filepath = specularPath, [string] -- Optional, defaulted to brick texture in assets_default
        texture_mode = textureMode [string] -- Optional, defaulted to "UV"
    }
)
```

## Update Methods
* Update the ``globalTransform`` information of the model.
```lua
Model:update()
```
* Update the ``globalTransform`` of the model.
```lua
Model:updateGlobalTransform()
```

## Draw Methods
* Draw the model to a lovr ``pass``.
* ``model`` can either be ``"depth"`` or ``"full"``.
* Rendering the model in ``"full"`` mode should be done during the ``lovr.draw(pass)`` function.
```lua
Model:draw(pass, mode)
```
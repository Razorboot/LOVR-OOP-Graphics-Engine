# Model Class

## Description
* ``Model`` objects function similary to lovr Models with the added support of specific texture files and the options supported by ``Node`` objects.

## Properties of a Model object - Extended from the Node class
* ``type`` *string*: The class type of the object. This will always be ``"Model"``.
* ``ModelInstance`` *lovr Model*: A lovr Model instance.
* ``diffuseMap`` *lovr texture*: The diffuse texture for the Model.
* ``normalMap`` *lovr texture*: The normal texture for the Model.
* ``specularMap`` *lovr texture*: The specular texture for the Model.
* ``textureMode`` *string*: The mode that changes how the textures are rendered for the Model. Can either be ``"UV"`` or ``"Tile"``.
* ``tileScale`` *vector3*: This stretches the texture on each side of the model by a scale factor if the ``textureMode`` is set to ``Tile``.

## Creating a Model object
* Creating a new ``Model`` object is done by passing in a table.
```lua
LGE.Model(
    {
        -- In addition to the options supported in "LGE.Node"...
        filepath = FilepathToModel, [string] -- Necessary, this is the filepath to the Model
        diffuseMap_filepath = diffusePath, [string] -- Optional, defaulted to brick texture in assets_default
        normalMap_filepath = normalPath, [string] -- Optional, defaulted to brick texture in assets_default
        specularMap_filepath = specularPath, [string] -- Optional, defaulted to brick texture in assets_default
        texture_mode = textureMode [string], -- Optional, defaulted to "UV"
        tile_scale = vector [vector3] -- Optional, defaulted to (1.0, 1.0, 1.0)
    }
)
```

## Update Methods
* Update the ``globalTransform`` information of the Model.
* ``localTransform`` is not updated since it is always set manually.
```lua
Model:update()
```

## Draw Methods
* Draw the Model to a lovr ``pass``.
* ``mode`` can either be ``"depth"`` or ``"full"``.
* Rendering the Model in ``"full"`` mode should be done during the ``lovr.draw(pass)`` function.
```lua
Model:draw(pass [lovr pass], mode [string])
```
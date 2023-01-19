# Particle Class

## Description
* ``Particle`` objects act as a fixed point where soft particles are emitted from given a velocity. Emitted particles behave as they would in the normal world, meaning they act as physical points affected by gravity and optional collisions. Furthermore, ``Particle`` objects have options for how long they last, a wait time for how long to wait before spawning a new particle, and how their transparency and size changes over time, soft/volumetric light options, and more. More information on the soft particle system can be found [here](http://blog.wolfire.com/2010/04/Soft-Particles).

## Understanding Alpha and Scale Range:
* Each ``Particle`` object has a set of interesting options for modifying the appearance of emitted particles over time. 
* The ``alphaRange`` of a ``Particle`` object represents how the opacity of emitted particles changes over it's lifetime. The best way to think about a number range is as graph with an x and y axis.
* ![alpha_range_graph](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/images/alpha_range_graph.png)
* The x axis represents the lifetime of the particle represented as a percent, while the y axis represents the property being modified, which in this case is the opacity of the particle.
* Notice the dots placed on the graph. As the current lifetime moves along these graphs, the final opacity of the particle will follow the lines between these dots. In this particular graph, the opacity of the particle will start at 0, then as it gets to 75% of the lifetime of the particle, it will increase slightly, then move up to 1.0 as the lifetime reaches 100%.
* You can set an ``alphaRange`` number using ``setAlphaRangeIndex(time [number], value [number])``, where ``time`` is a number from 0 to 1 representing the lifetime, and ``value`` represents another number from 0 to 1 representing the opacity at that current lifetime number.
* This same property applies to ``setScaleRangeIndex(time [number], value [vector3])``, where ``value`` is a ``lovr vector3`` instead of a number.
* Keep in mind that the values for lifetime 0 for both ``alphaRange`` and ``scaleRange`` are automatically set to 1 and (1, 1, 1), and for lifetime 1, 0 and (0, 0, 0). So by default every emitted particle will scale down and become more transparent over time.

## Understanding Directional Force Range:
* When a new particle is emitted, it will automatically have an initial force applied to it. This force is dictated by ``directionalForceRange``, which represents a random directional force the particle will be sent in.
* ``directionalForceRange`` is a table that includes variables ``xRange``, ``yRange``, and ``zRange``. All of these variables are ``lovr vector2``'s.
* When a new particle is emitted, it's initial directional force will pick a random number between the x and y value of each xyz range. So for example, if I have ``xRange`` equal to a ``lovr vector2`` with (-20, 20), every new particle will have it's x initial directional force be a random number between -20 and 20.
* If ``useLookVector`` of the ``Particle`` object is set to true, then this initial directional force will be based on the rotation of the ``Particle`` object.
* Keep in mind that the directional force for each emitted particle is affected by the ``friction`` of the ``Particle`` object!

## Properties of a Model object - Extended from the Node class
* ``type`` *string [default = "Particle"]*: The class type of the object.
### Appearance Properties:
* ``diffuseMap`` *lovr texture*: The diffuse texture for the Model.
* ``enabled`` *bool [default = true]*: Whether new particles are created on each update call.
* ``faceCamera`` *bool [default = true]*: Whether particles are always oriented to face the camera.
* ``hasDepthTest`` *bool [default = true]*: Whether particles appear in front of objects blocking them.
* ``hasShadowCastings`` *bool [default = true]*: Whether shadows from a light source can be casted onto particles.
* ``brightness`` *number [default = 1]*: How bright the particle is when being rendered.
### Physics Properties:
* ``gravity`` *number [default = 30]*: The force of gravity enacted on the particle.
* ``friction`` *number [default = 0.99]*: The amount of friction that dampens the ``directionalForceRange`` of each particle.
* ``timeStep`` *number [default = 3]*: The speed of the particle simulation.
* ``hasCollision`` *bool [default = false]*: Whether particles collide with surfaces.
* ``collisionDist`` *number [default = 0.15]*: The distance that collided particles will be from the surface they collide with.
* ``incrementTime`` *number [default = 2]*: The time between emitting a new particle.
* ``edgeSmooth``: *number [default 0.2]*: The smoothness a particle will have when intersecting a surface. Setting this to -1.0 will disable soft particles entirely.
### Range Properties:
* ``useLookVector``: *bool [default = true]*: Whether emitted particles have their initial velocity based on the ``globalTransform`` orientation of the node.
* ``directionalForceRange`` *table*: When emitting particles, a random value is picked from ``directionalForceRange.xRange``, ``directionalForceRange.yRange``, and ``directionalForceRange.zRange`` to determine the initial velocity of the particle. These values are all ``Vector2``'s where the random value is picked between the x and y value.
* ``alphaRange`` *table*: When emitting particles, There needs to be an initial transparency and final transparency. The ``alphaRange`` represents how the transparency changes over the lifetime of a particle.
* ``scaleRange`` *table*: Functions exactly the same as ``alphaRange`` except this determines how the scale of a particle changes over time. The final scale is the current scale range number multiplied by ``localTransform.scale``.

## Creating a Particle object
* Creating a new ``Particle`` object is done by passing in a table.
```lua
LGE.Particle(
    {
        -- In addition to the options supported in "LGE.Node"...
        diffuseMap_filepath = filepathToTexture, [string] -- Necessary, this is the filepath to the texture the node will use
    }
)
```

## General Methods
* Set the vector for the any axis of ``directionalForceRange``.
* ``axis`` should be ``"xRange"``, ``"yRange"``, or ``"zRange"``.
* More information about this can be found in *Understanding Directional Force Range*.
```lua
Particle:setDirectionalForceIndex(axis [string], vec [vector2])
```
* Set the alpha value for the current lifetime of every emitted particle.
* ``time`` and ``value`` should be a number from 0 to 1.
* More information about this can be found in *Understanding Alpha and Scale Range*.
```lua
Particle:setAlphaRangeIndex(time [number], value [number])
```
* Set the scale value for the current lifetime of every emitted particle.
* ``time`` should be a number from 0 to 1.
* ``value`` can be any ``vector3``.
* More information about this can be found in *Understanding Alpha and Scale Range*.
```lua
Particle:setScaleRangeIndex(time [number], value [vector3])
```

## Update Methods
* Update the ``globalTransform`` information of the Particle.
* ``localTransform`` is not updated since it is always set manually.
* Update the physics of each emitted particle.
```lua
Model:update(dt [number])
```

## Draw Methods
* Draw the Particle to a lovr ``pass``.
* ``mode`` can either be ``"depth"`` or ``"full"``.
* Rendering the Particle in ``"full"`` mode should be done during the ``lovr.draw(pass)`` function.
```lua
Particle:draw(pass [lovr pass], mode [string])
```
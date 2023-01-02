# Node Class

## Description
* A ``node`` object is a container with a ``transform`` applied to it.
* Each node has ``attachments`` which can be either ``model`` objects or ``light`` objects.

## Properties of a Node object
* ``type`` *string*: The class type of the object. A node will always have this defaulted to ``"node"``.
* ``scene`` *scene object*: The ``scene`` object that the node will be parented to.
* ``name`` *string*: The name of the node.
* ``transform`` *array*: The ``transform`` object representing the position and rotation of a node.
* ``attachments`` *array*: The attachment categories the ``node`` object can have.
* ``attachments.models`` *array*: The ``model`` objects attached to the node.
* ``attachments.lights`` *array*: The ``light`` objects attached to a node.
* ``attachments.bodies`` *body object*: The ``body`` objects attached to a node.

## Creating a Node object
* Creating a new ``node`` object is easily done by passing in an array.
```lua
LGE.Node({
    scene = myScene,
    name = "myNode"
})
```

## Methods
* Deletes the node from the scene.
```lua
Node:destroy()
```
* Deletes an attachment from the node.
```lua
Node:destroyAttachment(attachment [object])
```
* Returns a model attached to a node given a name.
```lua
Node:getModel(name [string])
```
* Returns a light attached to a node given a name.
```lua
Node:getLight(name [string])
```
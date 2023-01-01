# Node Class

## Description
* A ``node`` object is a container with a ``transform`` applied to it.
* Each node has ``attachments`` which can be either ``model`` objects or ``light`` objects.

## Properties of a Node object
* ``type``: The object type as a string. A node will always have this defaulted to ``"node"``.
* ``scene``: The ``scene`` object that the node will be parented to.
* ``name``: A string representing the name of the node.
* ``transform``: The ``transform`` object representing the position and rotation of a node.
* ``attachments``: A table representing the attachment categories a node can have.
* ``attachments.models``: The ``model`` objects attached to the node.
* ``attachments.lights``: The ``light`` objects attached to a node.
* ``attachments.bodies``: The ``body`` objects attached to a node.

## Creating a Node object
* Creating a new ``node`` object is easily done by passing in an array.
```lua
Node({
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
Node:destroyAttachment(attachment)
```
* Returns a model attached to a node given a name.
```lua
Node:getModel(name)
```
* Returns a light attached to a node given a name.
```lua
Node:getLight(name)
```
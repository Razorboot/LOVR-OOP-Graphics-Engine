# Node Class

## Description
* A ``node`` object is a container with a ``transform`` applied to it.
* Each node has ``attachments`` which can be either ``model`` objects or ``light`` objects.

## Creating a Node object
* Creating a new ``node`` object is easily done by passing in a table.
```lua
Node({
    scene = -- The parent scene that the node will be a part of.
})
```

## Methods
```lua
Node:destroy()
```
* Deletes the node from the scene.
```lua
Node:destroyAttachment(attachment)
```
* Deletes an attachment from the node.
```lua
Node:getModel(name)
```
* Returns a model attached to an attachment given a name.
```lua
Node:getLight(name)
```
* Returns a node attached to an attachment given a name.
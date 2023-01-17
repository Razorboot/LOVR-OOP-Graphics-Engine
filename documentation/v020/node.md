# Node Class

## Description
* A ``Node`` object is a container with a ``Transform`` applied to it.
* ``Node`` objects are object-oriented and are the basis for all objects within LGE. This means that all ``Light``, ``Model``, and ``Body`` objects are extensions of a ``Node`` object.
* Every ``Node`` is 100% object-oriented and includes a reference to a parent Node, and for child Nodes.
* Every ``Node`` object includes a ``localTransform`` and a ``globalTransform``. The ``globalTransform`` represents the transform of the ``Node`` in global space, and ``localTransform`` represents the transform of the ``Node`` relative to the parent ``Node``.

## Properties of a Node object
* ``type`` *string*: The class type of the object. A Node will always have this defaulted to ``"Node"``.
* ``scene`` *Scene object*: The ``Scene`` object that the Node will be parented to.
* ``parent`` *Node object*: The ``Node`` that the Node is attached to/is a child of.
* ``name`` *string*: The name of the Node.
* ``visible`` *bool*: Whether the Node is visible or not for rendering. This is applicable to ``Model``, ``Light``, and ``Particle`` objects mainly.
* ``localTransform`` *Transform object*: The ``Transform`` object representing the position and rotation of the Node relative to the parent. This also includes the scale but it is independant from the parent.
* ``globalTransform`` *Transform object*: The ``Transform`` object representing the position and rotation of the Node relative to the origin of the world (0, 0, 0). This also includes the ``localTransform`` scale.

## Creating a Node object
* Creating a new ``Node`` object is easily done by passing in a table.
```lua
LGE.Node({
    scene = myScene [string], -- Necessary, this is the Scene object that the Node will be a member of
    parent = myNode [Node object], -- Optional, this is the parent object that the Node will be attached to. The Node must either be a descendant of the "root" Node of the scene, otherwise it will not be considered a member of the scene.
    name = "myNode" [string], -- Optional, this gets passed to the .name property and is highly recommended to distinguish Nodes from one another.
})
```

## Checking if a Node exists
* Though ``myNode ~= nil`` might first come to mind, the use of metatables for object oriented systems makes things a tiny bit complicated.
* In this case, ``getmetatable(myNode)`` should be used instead of ``myNode ~= nil``.

## Methods
* Deletes the Node from the scene and from the children of the parent Node.
```lua
Node:destroy()
```
* Set the parent of a Node.
```lua
Node:setParent(newParent [Node object])
```
* Returns a direct child of a Node from the ``.children`` variable given a name.
```lua
Node:findFirstChild(name [string])
```
* Returns the parent of the Node.
* If a name is passed, the Scene Graph will be traversed upward starting from the current parent of the Node until the Node matching the name is found and returned.
```lua
Node:getParent(name [optional string])
```
* Returns the scene root Node of the current Node.
* If the root Node of the Scene is not set, then the Scene Graph will be traversed upward until a Node with no parent set is found.
```lua
Node:getRoot()
```
* Recursively scans through every child of the Node to return a table of all Nodes under the current Node.
```lua
Node:getDescendants()
```
* Scans through the table returned by ``Node:getDescendants()`` to find a Node with a given name.
```lua
Node:findFirstDescendant()
```

## Transform Methods
* Sets the global position of the Node.
```lua
Node:setGlobalPosition(position [vector3])
```
* Sets the global rotation of the Node.
* Though the rotation is a ``vector4``, a ``quaternion`` can be unpacked into a ``vector4`` and it will behave the same way.
```lua
Node:setGlobalRotation(rotation [vector4])
```
* Sets the global position, rotation, and scale of the Node given a 4x4 transformation matrix.
```lua
Node:setGlobalTransformMatrix(matrix [mat4])
```
* Sets the position of the Node relative to the parent Node.
```lua
Node:setLocalPosition(position [vector3])
```
* Sets the rotation of the Node relative to the parent Node.
* Though the rotation is a ``vector4``, a ``quaternion`` can be unpacked into a ``vector4`` and it will behave the same way.
```lua
Node:setLocalRotation(rotation [vector4])
```
* Set the scale of the Node.
* This acts independantly of the parent Node.
```lua
Node:setScale(position [vector3])
```
* Make the Node rotate toward a position in global space.
```lua
Node:lookAt(position [vector3])
```
* Make the Node rotate in a direction in global space.
```lua
Node:lookToward(direction [vector3])
```

## Update Methods
* Keep in mind update methods usually don't have to be done manually. LGE takes care of this whenever necessary!

* Updates the ``localTransform`` of the Node if it has been modified or the parent Node has had it's ``globalTransform`` modified since the last update.
```lua
Node:updateLocalTransform()
```
* Updates the ``globalTransform`` of the Node if it has been modified or the parent Node has had it's ``globalTransform`` modified since the last update.
```lua
Node:updateGlobalTransform()
```
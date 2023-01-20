# Version Documentation

# [Latest Release 0.2.2](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/introduction)
### Release Notes v0.2.2 (1/19/23)
* Additions and Changes:
	* Scene files can now be saved to any directory inside of your project instead of the default LOVR save directory.
	* Every Object in a scene now has a ``selectionCollider`` applied to it. This is a lovr box collider that is always locked to the pose of the parent node. This change doesn't have much of a use yet but will come in handy when I begin working on the level editor, allowing users to highlight their mouse over objects to click and select them.
	* PCF filtering for shadowmaps has been smoothed even further using [this method](https://developer.nvidia.com/gpugems/gpugems2/part-ii-shading-lighting-and-shadows/chapter-17-efficient-soft-edged-shadows-using) by Nvidia. Here's a comparison of the old and new method:
	* ![022_shadows_comparison](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/images/022_shadows_comparison.png)
	* There are some drawbacks with this method though, such as slight shadow grain, but this can be iterated on in future versions.
* Bug Fixes:
	* Bodies had their global and local transform calculations set incorrectly in previous versions. This has been fully fixed to my knowledge, but may require further testing.
	* When a parent Node has it's transform updated, all child Nodes now also have their transforms updated. Though this is also done in the ``Scene:update()`` method, this new change ended up being necessary for dynamically transforming Objects.<br>
### Release Notes v0.2.1 (1/17/23)
* Particle objects have been added!
	* Particle objects are rendered using a soft particle system by comparing depth buffers.
	* Particle objects have a multitude of options, meaning their appearance can be highly customized.
* Changes to the Node Class:
	* ``visible`` has been added as a property to all nodes, meaning they can be toggled on and off during rendering.
	* Model objects now have ``canCastShadows`` as a property.<br>
### Release Notes v0.2.0 (1/12/23):
* Scene Graph system has been completely rewritten!
	* Objects now have child and parent relationships.
	* Models now include texturing modes for either tiling textures along the surface of a model or simply applying a UV map.
* Transform Class and system has been massively improved:
	* Objects include a globalTransform and localTransform. localTransform is offset from the parent globalTransform.
	* Objects now have methods for easily setting their Global and Local transform matrix, position, rotation (including looking at a target or toward a direction), or scale.
* Scene saving and loading is implemented!
	* Scene Objects can now be saved to lua files with the aid of the serpent library.
	* These scenes can be easily loaded from any filepath as well.<br>

# [Release 0.1.0](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v010/introduction)
### Release Notes (12/22/22):
* Initial release of the engine!

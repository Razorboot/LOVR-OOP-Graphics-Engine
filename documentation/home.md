# Version Documentation

## [Release 0.1.0](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v010/introduction)
Release Notes (12/22/22):
* Initial release of the engine!

## [Release 0.2.1](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/v020/introduction)
### Release Notes v0.2.1 (1/17/23)**
* Particle objects have been added!
	* Particle objects are rendered using a soft particle system by comparing depth buffers.
	* Particle objects have a multitude of options, meaning their appearance can be highly customized.
* Changes to the Node Class:
	* *visible* has been added as a property to all nodes, meaning they can be toggled on and off during rendering.
	* Model objects now have *canCastShadows* as a property.
### Release Notes v0.2.0 (1/12/23):**
* Scene Graph system has been completely rewritten!
	* Objects now have child and parent relationships.
	* Models now include texturing modes for either tiling textures along the surface of a model or simply applying a UV map.
* Transform Class and system has been massively improved:
	* Objects include a globalTransform and localTransform. localTransform is offset from the parent globalTransform.
	* Objects now have methods for easily setting their Global and Local transform matrix, position, rotation (including looking at a target or toward a direction), or scale.
* Scene saving and loading is implemented!
	* Scene Objects can now be saved to lua files with the aid of the serpent library.
	* These scenes can be easily loaded from any filepath as well.

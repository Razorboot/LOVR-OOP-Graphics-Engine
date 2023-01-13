# LOVR Object-Oriented Graphics Engine

## Features
* Custom graphics engine for LOVR using Object Oriented Programming. This is inspired by OGRE3D's transformation system and Godot scene graphs.
* Supports point lights and spot lights with smooth shadowmaps.
* Supports normalmapped textures for models.
* Supports child and parent object relationships in the form of Nodes.
* Includes a complex Transform class with the ability to set Global and Local transform information of Nodes.
* Supports scene saving and loading.

## Other Notes
* [Documentation](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/home) is a WIP.
* Keep in mind as of the current date, this is meant to be executed using LOVR nightly builds, you will unfortunately encounter bugs in other versions.
* This project is designed to be used with or without VR, there's no preference! I'm planning to prioritize non-vr users in future updates though.
* This project wouldn't have been possible without bjornbytes, j_miskov, and immortalx!

## Release Notes (1/12/23):
* Scene Graph system has been completely rewritten!
	* Objects now have child and parent relationships.
	* Models now include texturing modes for either tiling textures along the surface of a model or simply applying a UV map.
* Transform Class and system has been massively improved:
	* Objects include a globalTransform and localTransform. localTransform is offset from the parent globalTransform.
	* Objects now have methods for easily setting their Global and Local transform matrix, position, rotation (including looking at a target or toward a direction), or scale.
* Scene saving and loading is implemented!
	* Scene Objects can now be saved to lua files with the aid of the serpent library.
	* These scenes can be easily loaded from any filepath as well.
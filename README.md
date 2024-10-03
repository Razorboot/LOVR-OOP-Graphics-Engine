# LOVR Object-Oriented Graphics Engine

## Introduction and Documentaton hosted [here](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/home).

## Notes
* This is an experimental project I started in December of 2022! After experimenting with LOVR and Love2D, I got inspired by how easy these engines are to create simple games with, but I also noticed the lack of features available in these frameworks for creating complex 3D games. This gave me the push to create my own high-level game engine that's simple to use for end-users with Lua while also having features common 3D game engines have. I also wanted to ensure all of the rendering and under the hood aspects such as physics, lighting, particle simulations, and more are handled behind the scenes so end users don't have to worry about these aspects. The result of this project led to a custom game engine for LOVR using Object Oriented Programming that is heavily inspired by OGRE3D's transformation system and Godot scene graphs.
* If you would like to contribute to this engine, I'll be working on documentation for developers in the near future! For the time being feel free to create any pull requests or post suggestions. Feel free to contact me at Susumo211@gmail.com or my Discord if you want to talk 1:1.

## Features
* Supports full LOVR physics integration.
* Supports point lights and spot lights with smooth shadowmaps.
* Supports normalmapped textures for models.
* Supports child and parent object relationships in the form of Nodes.
* Includes a complex Transform class with the ability to set Global and Local transform information of Nodes.
* Supports Scene saving and loading.
* Supports complex soft-particles with collisions.

## Screenshots/Showcase
* Video Showcase: PBR Lighting, Variance Shadowmaps, Transformation System
* ![pbrlighting](https://drive.google.com/file/d/1XIgNe6pKZhoQrOGgCvA7iyC5mNeceRk9/view?usp=sharing)
* Soft particles with lighting:
* ![softparticle](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/images/softparticle.PNG)
* Multiple spotlight sources with soft shadowmaps:
* ![lights](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/images/lights.PNG)
* Diffuse lighting, normal maps, and specular maps:
* ![diffnormspecshowcase](https://razorboot.github.io/LOVR-OOP-Graphics-Engine/documentation/images/diffnormspecshowcase.PNG)

## Other Notes
* Keep in mind as of the current date, this is meant to be executed using LOVR nightly builds, you will unfortunately encounter bugs in other versions.
* This project is designed to be used with or without VR, there's no preference! I'm planning to prioritize non-vr users in future updates though.
* This project wouldn't have been possible without bjornbytes, j_miskov, and immortalx!

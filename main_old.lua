--local Meshpart = require "meshpart"
lovr.mouse = require 'lovr-mouse'
spotlightShader = require 'shaders.spotlight_arrays'

function lovr.load()
    -- Filepath specification
    assets = 'assets/'

    -- Initialize our model 
    model = lovr.graphics.newModel(assets..'models/treasure_chest_1k.gltf')
    diffuseMap = lovr.graphics.newTexture(assets..'textures/treasure_chest_diff_1k.jpg')
    specularMap = lovr.graphics.newTexture(assets..'textures/treasure_chest_rough_1k.jpg')
    normalMap = lovr.graphics.newTexture(assets..'textures/treasure_chest_nor_gl_1k.jpg')

    defaultDiffuseMap = lovr.graphics.newTexture(assets..'textures/brick_diff.png')
    defaultSpecularMap = lovr.graphics.newTexture(assets..'textures/brick_spec.png')
    defaultNormalMap = lovr.graphics.newTexture(assets..'textures/brick_norm.png')

    tvDiffuseMap = lovr.graphics.newTexture(assets..'textures/Television_01_diff_1k.jpg')
    tvSpecularMap = lovr.graphics.newTexture(assets..'textures/Television_01_roughness_1k.jpg')
    tvNormalMap = lovr.graphics.newTexture(assets..'textures/Television_01_nor_gl_1k.jpg')

    -- Create Physics World
    world = lovr.physics.newWorld(nil, nil, nil, false)
    world:setLinearDamping(.01)
    world:setAngularDamping(.005)

    -- Create boxes!
    boxes = {}

    -- Create the ground
    ground = world:newBoxCollider(0, -3.5, 0, 10, .05, 10)
    ground:setFriction(0.1)
    ground:setKinematic(true)
    table.insert(boxes, ground)

    box2Model = lovr.graphics.newModel(assets..'models/tv_centered.glb')
    local b2w, b2h, b2d = box2Model:getDimensions()
    box2 = world:newBoxCollider(0, -2.5, 0, b2w + 0.15, b2h + 0.05, b2d + 0.05)
    box2:setFriction(1.5)
    table.insert(boxes, box2)

    width, height, depth = model:getDimensions()
    chestBox = world:newBoxCollider(0, 0, 0, width, height, depth)
    chestBox:setFriction(1)
    chestBox:applyTorque(10, 0, 0)
    chestBox:applyForce(8, 10.0, 0.0)

    -- Start Timer
    lovr.timer.step() -- Reset the timer before the first update

    -- Variables
    hx, hy, hz = 0.0, 0.0, 0.0
    mx, my = lovr.mouse.getX(), lovr.mouse.getY()

    pos = 0
    timer = 0

    --# Light Matrix
    --[[lightPersective = lovr.math.newMat4():perspective(70.0, 1024/1024, 0.5, 1000.0)
    lightView = lovr.math.newMat4():lookAt(lovr.math.vec3(0, 0, 0), lovr.math.vec3(0, -1.0, 0), lovr.math.vec3(0, 1.0, 0))
    lightProjection = lightPersective:mul(lightView)]]
    light_pose = lovr.math.newMat4()
    light_view = lovr.math.newMat4()
    light_projection = lovr.math.newMat4():perspective(math.rad( (25*4) ), 1, 0.01)
    light_target = lovr.math.vec3()
    light_origin = lovr.math.vec3()

    light2_pose = lovr.math.newMat4()
    light2_view = lovr.math.newMat4()
    light2_projection = lovr.math.newMat4():perspective(math.rad( (25*4) ), 1, 0.01)
    light2_target = lovr.math.vec3()
    light2_origin = lovr.math.vec3()

    depthBufferSize = 1024*2
    depthtex = lovr.graphics.newTexture(depthBufferSize, depthBufferSize, {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})
    depthtex2 = lovr.graphics.newTexture(depthBufferSize, depthBufferSize, {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})

    pass1Tex = lovr.graphics.newTexture(900, 900) -- Screen resolution texture

    local screenShader = lovr.graphics.newShader('fill')

    -- Set up shader
    colorShader = lovr.graphics.newShader(
    [[
        vec4 lovrmain() {
            return Projection * View * Transform * VertexPosition;
        }
        ]],
        [[
        layout(set = 2, binding = 0) uniform texture2D passTexture;

        vec4 lovrmain() {
            float pixelXPos = gl_FragCoord.x;
            float pixelYPos = gl_FragCoord.y;
            vec4 finalColor = getPixel(passTexture, UV);

            return finalColor;
        }
    ]]
    )

    debugShader = lovr.graphics.newShader(
        [[
        vec4 lovrmain() {
            return Projection * View * Transform * VertexPosition;
        }
        ]],
        [[
        layout(set = 2, binding = 0) uniform texture2D lightTexture;

        vec4 lovrmain() {
            vec4 lightColor = getPixel(lightTexture, UV);

            return vec4(lightColor.xyz, 1.0); // It's automatically set to black. Does this mean the Tangent vector is automatically set to 0, 0, 0? Why?
        }
        ]]
    )
    shadowMapShader = lovr.graphics.newShader(
        [[
        vec4 lovrmain() {
            return Projection * View * Transform * VertexPosition;
        };
        ]],
        [[
        //layout(set = 2, binding = 0) uniform texture2D lightTexture;

        vec4 lovrmain() {
            //vec4 lightColor = getPixel(lightTexture, UV); 
            //lightColor.z = gl_FragCoord.z;

            return vec4(vec3(gl_FragCoord.z), 1.0);
        };
        ]]
    )
    mainShaderSpotLight = lovr.graphics.newShader([[
        Constants {
            vec3 viewPos;
            vec4 ambience;
            
            vec4 liteColor;
            vec3 lightPos;
            vec3 spotDir;

            float specularStrength;
            float metallic;
            float texelSize;

            mat4 LightSpaceMatrix;
        };

        out vec4 VertPos;
        out mat4 fullTransform;

        vec4 lovrmain() {
            VertPos = VertexPosition;
            fullTransform = Transform;

            return Projection * View * Transform * VertexPosition;
        }
    ]], [[
        Constants {
            vec3 viewPos;
            vec4 ambience;
            
            vec4 liteColor;
            vec3 lightPos;
            vec3 spotDir;

            float specularStrength;
            float metallic;
            float texelSize;

            mat4 LightSpaceMatrix;
        };
        
        in vec4 VertPos;
        in mat4 fullTransform;

        layout(set = 2, binding = 0) uniform texture2D diffuseMap;
        layout(set = 2, binding = 1) uniform texture2D specularMap;
        layout(set = 2, binding = 2) uniform texture2D normalMap;

        layout(set = 2, binding = 3) uniform texture2D DepthBuffer;
        
        float acneBias = 0.025;
        vec4 finalShading;
        
        vec4 lovrmain() 
        {    
            vec4 diffuseColor = getPixel(diffuseMap, UV); 
            vec4 specularColor = getPixel(specularMap, UV);
            vec4 normalColor = getPixel(normalMap, UV);

            // Normal Mapping
            vec3 norm = normalColor.rgb * 2.0 - 0.5;
            norm.x *= -1.0;
            norm = normalize(TangentMatrix * norm);

            // Get light
            mat4 savedLightSpaceMatrix = LightSpaceMatrix;
            vec4 PositionLight = LightSpaceMatrix * fullTransform * vec4(VertPos.xyz, 1.f); // Avoid doing this in frag shader in future.

            //diffuse
            vec3 lightDir = normalize(lightPos - PositionWorld);
            float diff = max(dot(norm, lightDir), 0.0);
            vec4 diffuse = diff * liteColor;
            
            //specular
            vec3 viewDir = normalize(viewPos - PositionWorld);
            vec3 reflectDir = reflect(-lightDir, norm);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
            vec4 specular = (specularStrength * (1.0-specularColor.g) ) * spec * liteColor;

            // Shadowmapping
            vec2 projCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            
            float visibility = 0.0;
            for (int x = -2; x <= 2; x++) {
                for (int y = -2; y <= 2; y++) {
                    vec2 tempProjCoords = projCoords.xy + (vec2(x, y) * texelSize);

                    float closestDepth;
                    if ((tempProjCoords.x > 0.) && (tempProjCoords.x < 1.) &&
                        (tempProjCoords.y > 0.) && (tempProjCoords.y < 1.))
                        closestDepth = getPixel(DepthBuffer, tempProjCoords).r;
                    else
                        closestDepth = 0.;
                    float currentDepth = PositionLight.z / PositionLight.w;
                    float currentDepth_biased = currentDepth + 0.00001;

                    visibility += (currentDepth_biased < 0. || closestDepth < currentDepth_biased) ? 1.0 : 0.0;
                }
            }

            float shadow = visibility/25.0;

            // Color calculation
            vec4 shading = (diffuse + specular) * shadow;

            float innerCutOff = cos(radians(35));
            float outerCutOff = cos(radians(50));

            float theta = dot(lightDir, normalize(-spotDir));
            float epsilon = innerCutOff - outerCutOff;
            float intensity = clamp((theta - outerCutOff ) / epsilon, 0.0, 1.0);    

            shading *= intensity;

            // Finalize
            finalShading += shading;

            // AFTER
            return vec4(diffuseColor.xyz, 1.0) * (ambience + finalShading );
        }
    ]], { flags = {vertexTangents = false } })

    mainShaderSpotLight_OLD = lovr.graphics.newShader([[
        Constants {
            int numLights;

            vec4 liteColor;
            vec4 ambience;
            vec3 lightPos;
            vec3 spotDir;

            vec3 viewPos;
            float specularStrength;
            float metallic;
            float texelSize;

            mat4 LightSpaceMatrix;
        };

        mat4 savedLightSpaceMatrix = LightSpaceMatrix;
        out vec4 LightPositions[50];

        vec4 lovrmain() {
            LightPositions[0] = savedLightSpaceMatrix * Transform * vec4(VertexPosition.xyz, 1.f);
            return Projection * View * Transform * VertexPosition;
        }
    ]], [[
        Constants {
            int numLights;

            vec4 liteColor;
            vec4 ambience;
            vec3 lightPos;
            vec3 spotDir;

            vec3 viewPos;
            float specularStrength;
            float metallic;
            float texelSize;

            mat4 LightSpaceMatrix;
        };
        
        //in vec4 PositionLight; // fragment position inside the light-space
        in vec4 LightPositions[50];

        layout(set = 2, binding = 0) uniform texture2D diffuseMap;
        layout(set = 2, binding = 1) uniform texture2D specularMap;
        layout(set = 2, binding = 2) uniform texture2D normalMap;

        layout(set = 2, binding = 3) uniform texture2D DepthBuffer;
        
        float acneBias = 0.025;

        vec4 lovrmain() 
        {    
            vec4 diffuseColor = getPixel(diffuseMap, UV); 
            vec4 specularColor = getPixel(specularMap, UV);
            vec4 normalColor = getPixel(normalMap, UV);

            // Normal Mapping
            vec3 norm = normalColor.rgb * 2.0 - 0.5;
            norm.x *= -1.0;
            norm = normalize(TangentMatrix * norm);

            //diffuse
            vec3 lightDir = normalize(lightPos - PositionWorld);
            float diff = max(dot(norm, lightDir), 0.0);
            vec4 diffuse = diff * liteColor;
            
            //specular
            vec3 viewDir = normalize(viewPos - PositionWorld);
            vec3 reflectDir = reflect(-lightDir, norm);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
            vec4 specular = (specularStrength * (1.0-specularColor.g) ) * spec * liteColor;

            // Shadowmapping
            //vec4 PositionLight = LightSpaceMatrix * newTransform * vec4(vertPos.xyz, 1.f);
            vec4 PositionLight = LightPositions[0];
            vec2 projCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            
            float visibility = 0.0;
            for (int x = -2; x <= 2; x++) {
                for (int y = -2; y <= 2; y++) {
                    vec2 tempProjCoords = projCoords.xy + (vec2(x, y) * texelSize);

                    float closestDepth;
                    if ((tempProjCoords.x > 0.) && (tempProjCoords.x < 1.) &&
                        (tempProjCoords.y > 0.) && (tempProjCoords.y < 1.))
                        closestDepth = getPixel(DepthBuffer, tempProjCoords).r;
                    else
                        closestDepth = 0.;
                    float currentDepth = PositionLight.z / PositionLight.w;
                    float currentDepth_biased = currentDepth + 0.0000125;

                    visibility += (currentDepth_biased < 0.0 || closestDepth < currentDepth_biased) ? 1.0 : 0.0;
                }
            }

            float shadow = visibility/25.0;

            // Color calculation
            vec4 shading = (diffuse + specular) * shadow;

            float innerCutOff = cos(radians(35));
            float outerCutOff = cos(radians(50));

            float theta = dot(lightDir, normalize(-spotDir));
            float epsilon = innerCutOff - outerCutOff;
            float intensity = clamp((theta - outerCutOff ) / epsilon, 0.0, 1.0);    

            shading *= intensity;

            return vec4(diffuseColor.xyz, 1.0) * (ambience + shading );
        }
    ]], { flags = {vertexTangents = false } })
end

-- A helper function for drawing boxes
function drawBox(pass, box)
    local x, y, z = box:getPosition()
    pass:cube(lovr.math.mat4():translate(x, y, z):rotate(box:getOrientation()):scale(box:getDimensions() ))
end

local function drawScene(pass, proj, pose)
    -- Draw
    pass:setProjection(1, proj)
    pass:setViewPose(1, pose)
    pass:draw(box2Model, lovr.math.mat4():translate(box2:getPosition()):rotate(box2:getOrientation()):translate(0, 0, 0):scale(1.25, 1.25, 1.25 ))

    --local relativePosString = tostring(m1..", "..m2..", "..m3..", "..m4..", "..m5..", "..m6..", "..m7..", "..m8..", "..m9..", "..m10..", "..m11..", "..m12..", "..m13..", "..m14..", "..m15..", "..m16)

    --chestBox:setPosition(m13, m14, m15)
    pass:setProjection(1, proj)
    pass:setViewPose(1, pose)

    local x, y, z = chestBox:getPosition()
    local angle, ax, ay, az = chestBox:getOrientation()

    pass:setProjection(1, proj)
    pass:setViewPose(1, pose)
    pass:draw(model, lovr.math.mat4():translate(x, y, z):rotate(angle, ax, ay, az):translate(0.0, -0.3, 0))

    pass:setProjection(1, proj)
    pass:setViewPose(1, pose)
    pass:cube(lovr.math.mat4():translate(ground:getPosition()):rotate(ground:getOrientation()):scale(20, 0.05, 20 ))
end

function drawFull(pass)
    pass:setViewPose(1, lovr.headset.getPose())

    -- Draw
    pass:send('diffuseMap', tvDiffuseMap)
    pass:send('specularMap', tvSpecularMap)
    pass:send('normalMap', tvNormalMap)

    pass:setViewPose(1, lovr.headset.getPose())
    pass:draw(box2Model, lovr.math.mat4():translate(box2:getPosition()):rotate(box2:getOrientation()):translate(0, 0, 0):scale(1.25, 1.25, 1.25 ))

    pass:setViewPose(1, lovr.headset.getPose())
    
    local m1, m2, m3, m4,
    m5, m6, m7, m8,
    m9, m10, m11, m12,
    m13, m14, m15, m16 = lovr.math.mat4():scale(5.0, 5.0, 5.0):unpack(true)

    local relativePosString = tostring(m1..", "..m2..", "..m3..", "..m4..", \n"..m5..", "..m6..", "..m7..", "..m8..", \n"..m9..", "..m10..", "..m11..", "..m12..", \n"..m13..", "..m14..", "..m15..", "..m16)

    local x, y, z = chestBox:getPosition()
    local angle, ax, ay, az = chestBox:getOrientation()

    pass:send('diffuseMap', diffuseMap)
    pass:send('specularMap', specularMap)
    pass:send('normalMap', normalMap)

    pass:setViewPose(1, lovr.headset.getPose())
    pass:draw(model, lovr.math.mat4():translate(x, y, z):rotate(angle, ax, ay, az):translate(0.0, -0.3, 0))

    -- ground
    pass:send('diffuseMap', defaultDiffuseMap)
    pass:send('specularMap', defaultSpecularMap)
    pass:send('normalMap', defaultNormalMap)

    pass:setViewPose(1, lovr.headset.getPose())
    pass:cube(lovr.math.mat4():translate(ground:getPosition()):rotate(ground:getOrientation()):scale(20, 0.05, 20 ))
end

function lovr.keypressed(key, scancode, repeating)
    if key == "up" then mx = mx + 5.0 end
    if key == "down" then mx = mx - 5.0 end
end

local function fullScreenDraw(source)
    local pass = lovr.graphics.getPass('render', { 1, depth = false, samples = 1 })
    pass:setShader(screenShader)
    pass:send('passTexture', pass1Tex)
    pass:fill()
    return pass
end

function lovr.update(dT)
    -- Update the physics simulation
    world:update(1 / 60)

    -- Adjust light position
    timer = timer + dT
    pos = math.sin(timer)*2

    pos2 = math.sin(timer * 1.2)*-6

    -- Phys update
    local rmbDown = lovr.mouse.isDown(2)

    local deltaX = lovr.mouse.getX() - mx
    local deltaY = lovr.mouse.getY() - my

    mx, my = lovr.mouse.getX(), lovr.mouse.getY()

    local ha, hrx, hry, hrz = lovr.headset.getOrientation('head')
    local relativePos = lovr.math.mat4():rotate(lovr.headset.getOrientation('head')):translate(deltaX, -deltaY, 0)--[[:rotate(lovr.headset.getOrientation('head'))]]
    local m1, m2, m3, m4, -- Rotation vector?
        m5, m6, m7, m8, -- Rotation vector?
        m9, m10, m11, m12, -- Rotation vector?
        m13, m14, m15, m16 = relativePos:unpack(true) -- x, y, z, w

    if tostring(rmbDown) == "true" then
        chestBox:applyForce(m13, m14, m15)
    end

    -- Adjust head position (for specular)
    if lovr.headset then 
        hx, hy, hz = lovr.headset.getPosition()
    end

    -- Set light matrix for the shadowmap
    light_target = lovr.math.vec3(0, -1.0, 0)
    light_origin = lovr.math.vec3(pos, 2.5, -pos)

    light2_target = lovr.math.vec3(0, -0.8, 0)
    light2_origin = lovr.math.vec3(0, 2.5, pos2)

    light_pose:target(light_origin, light_target)
    light_view:set(light_pose):invert()

    light2_pose:target(light2_origin, light2_target)
    light2_view:set(light2_pose):invert()

    --local light_space_matrix = light_projection * light_view
    
    -- render to depth buffer from first light perspective
    passDepth = lovr.graphics.getPass('render', {depth = {texture=depthtex}, samples = 1})
    passDepth:setCullMode('back')
    passDepth:setProjection(1, light_projection)
    passDepth:setViewPose(1, light_pose)
    drawScene(passDepth, light_projection, light_pose)
    --lovr.graphics.submit(passDepth)

    -- render to depth buffer from the second light perspective
    pass2 = lovr.graphics.getPass('render', {depth = {texture=depthtex2}, samples = 1})
    pass2:setCullMode('back')
    pass2:setProjection(1, light2_projection)
    pass2:setViewPose(1, light2_pose)
    drawScene(pass2, light2_projection, light2_pose)
    
    --lovr.graphics.submit({passDepth, pass2})

    --[[local newpass = lovr.graphics.getPass('render', pass1Tex)
    newpass:setShader(spotlightShader)
    newpass:setViewPose(1, lovr.headset.getPose())
    newpass:send('passTexture', pass1Tex)
    newpass:send('passTexture', pass1Tex)
    newpass:send('liteColor_0', {1.0, 1.0, 1.0, 1.0})
    newpass:send('lightPos_0', light_origin)
    newpass:send('spotDir_0', (light_target:sub(light_origin)):normalize() )
    newpass:send('LightSpaceMatrix_0', light_space_matrix)
    newpass:send('cutOff_0', math.cos(math.rad(15)))
    newpass:fill()
    lovr.graphics.submit(newpass)]]

    --[[ Render light passes texture(s)
    local light_space_matrix = light_projection * light_view
    
    local pass = lovr.graphics.getPass('render', pass1Tex)
    pass:setViewPose(1, lovr.headset.getPose())
    pass:setShader(spotlightShader)
    pass:setCullMode('back')

    pass:send('passTexture', pass1Tex)
    pass:send('liteColor_0', {1.0, 1.0, 1.0, 1.0})
    pass:send('lightPos_0', light_origin)
    pass:send('spotDir_0', (light_target:sub(light_origin)):normalize() )
    pass:send('LightSpaceMatrix_0', light_space_matrix)
    pass:send('cutOff_0', math.cos(math.rad(15)))

    drawFull(pass)
    lovr.graphics.submit(pass)]]

    --[[ Render light passes texture(s)
    pass = lovr.graphics.getPass('render', pass1Tex)
    pass:setCullMode('back')

    pass:send('liteColor_0', {1.0, 1.0, 1.0, 1.0})
    pass:send('lightPos_0', light2_origin)
    pass:send('spotDir_0', (light2_target:sub(light2_origin)):normalize() )
    pass:send('LightSpaceMatrix_0', light2_space_matrix)
    pass:send('cutOff_0', math.cos(math.rad(10)))
    
    drawFull(pass)
    lovr.graphics.submit(pass)]]
end

function lovr.draw(pass)
    --pass:setBlendMode()
    pass:setCullMode('back')

    --pass:setShader()
    --pass:setShader(colorShader)

    --[[Constants {
        // Individual Constants
        int numLights;
        vec4 ambience;
        vec3 viewPos;
        float metallic;
        float texelSize;
        float specularStrength;
        
        // INCREDIBLY DUMB way to do multiple lights, but LOVR doesn't have proper support for arrays in constants yet, so my current solution is variables for different lights.
        
        // Light 1
        bool hasShadow_1;

        vec4 liteColor_1;
        vec3 lightPos_1;
        vec3 spotDir_1;
        mat4 LightSpaceMatrix_1;
        float cutOff_1;
    };]]
    
    local light_space_matrix = light_projection * light_view
    local light2_space_matrix = light2_projection * light2_view
    --pass:send('DepthBuffer', depthtex)

    --local newpass = lovr.graphics.getPass('render', pass1Tex)

    --[[local newpass = lovr.graphics.getPass('render', pass1Tex)
    newpass:setShader(spotlightShader)
    newpass:setViewPose(1, lovr.headset.getPose())
    newpass:send('passTexture', pass1Tex)
    newpass:send('passTexture', pass1Tex)
    newpass:send('liteColor_0', {1.0, 1.0, 1.0, 1.0})
    newpass:send('lightPos_0', light_origin)
    newpass:send('spotDir_0', (light_target:sub(light_origin)):normalize() )
    newpass:send('LightSpaceMatrix_0', light_space_matrix)
    newpass:send('cutOff_0', math.cos(math.rad(15)))
    newpass:fill()
    lovr.graphics.submit(newpass)]]

    --[[local scene = lovr.graphics.getPass('render', pass1Tex)

    scene:setViewPose(1, lovr.headset.getPose())
    scene:setCullMode('back')]]

    --scene:send('passTexture', pass1Tex)
    pass:setShader(spotlightShader)
    pass:setViewPose(1, lovr.headset.getPose())

    --[[vec4 liteColor;
    vec3 lightPos;
    vec3 spotDir;
    mat4 LightSpaceMatrix;
    float cutOff;]]

    pass:setViewPose(1, lovr.headset.getPose())
    liteColor_Buffer = lovr.graphics.getBuffer({ lovr.math.vec4(0.25, 0.25, 0.25, 1.0), lovr.math.vec4(0.5, 0.25, 0.25, 1.0) }, 'vec4')
    lightPos_Buffer = lovr.graphics.getBuffer({ light_origin, light2_origin }, 'vec3')
    spotDir_Buffer = lovr.graphics.getBuffer({ (light_target:sub(light_origin)):normalize(), (light2_target:sub(light2_origin)):normalize() }, 'vec3')
    LightSpaceMatrix_Buffer = lovr.graphics.getBuffer({ light_space_matrix, light2_space_matrix }, 'mat4')
    cutOff_Buffer = lovr.graphics.getBuffer({ math.cos(math.rad(5)), math.cos(math.rad(5)) }, 'float')

    pass:setViewPose(1, lovr.headset.getPose())
    pass:send('liteColor_Buffer', liteColor_Buffer)
    pass:send('lightPos_Buffer', lightPos_Buffer)
    pass:send('spotDir_Buffer', spotDir_Buffer)
    pass:send('LightSpaceMatrix_Buffer', LightSpaceMatrix_Buffer)
    pass:send('cutOff_Buffer', cutOff_Buffer)

    --[[pass:send('light[0].LightSpaceMatrix', light_space_matrix)
    pass:setViewPose(1, lovr.headset.getPose())
    pass:send('light[1].LightSpaceMatrix', light2_space_matrix)

    pass:send('light[0].liteColor', {0.25, 0.25, 0.25, 1.0})
    pass:send('light[0].lightPos', light_origin)
    pass:send('light[0].spotDir', (light_target:sub(light_origin)):normalize() )
    pass:send('light[0].cutOff', math.cos(math.rad(5)))

    pass:send('light[1].liteColor', {0.5, 0.25, 0.25, 1.0})
    pass:send('light[1].lightPos', light2_origin)
    pass:send('light[1].spotDir', (light2_target:sub(light2_origin)):normalize() )
    pass:send('light[1].cutOff', math.cos(math.rad(5)))]]

    -- Set default shader values
    pass:send('numLights', 2)

    pass:send('viewPos', {hx, hy, hz})
    pass:send('ambience', {0.0, 0.0, 0.0, 1.0})

    pass:send('specularStrength', 3.0)
    pass:send('metallic', 32.0)

    pass:send('texelSize', 1.0/depthBufferSize)

    --pass:send('padding', 1)

    pass:send('DepthBuffer', depthtex)
    pass:send('DepthBuffer2', depthtex2)

    drawFull(pass)

    --[[ Individual Lights

    -- Draw
    drawFull(pass)]]

    --[[pass:send('liteColor_0', {1.0, 1.0, 1.0, 1.0})
    pass:send('lightPos_0', light2_origin)
    pass:send('spotDir_0', (light2_target:sub(light2_origin)):normalize() )
    pass:send('LightSpaceMatrix_0', light2_space_matrix)
    pass:send('cutOff_0', math.cos(math.rad(10)))]]

    --drawFull(pass)

    --[[ Regular shader
    pass:setShader(colorShader)
    pass:send('passTexture', pass1Tex)
    pass:setViewPose(1, lovr.headset.getPose())

    drawScene(pass)]]

    --pass:setShader(colorShader) -- Reset to default/unlit
    --drawScene(pass)
    --pass:send('passTexture', depthtex)
    --pass:fill(depthtex)
    lovr.graphics.submit({passDepth, pass2, pass})
    
    pass:setShader()
    --pass:text(relativePosString, 0, 1.7, -3, .5)
    pass:sphere(light_origin, 0.1) -- Represents light
    pass:sphere(light_target, 0.1) -- Represents light

    pass:setColor(1, 0, 0, 1)
    pass:sphere(light2_origin, 0.1) -- Represents light
    pass:sphere(light2_target, 0.1) -- Represents light

    --lovr.graphics.submit({passDepth, pass2, pass})
end
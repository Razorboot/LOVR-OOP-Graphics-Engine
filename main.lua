--local Meshpart = require "meshpart"
lovr.mouse = require 'lovr-mouse'

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
    light_projection = lovr.math.newMat4():perspective(math.rad(50*2), 1, 0.01)

    light_target = lovr.math.vec3()
    light_origin = lovr.math.vec3()

    depthBufferSize = 1024*2
    depthtex = lovr.graphics.newTexture(depthBufferSize, depthBufferSize, {format = 'd32f', mipmaps = false, usage = {'render', 'sample'}})

    -- Set up shader
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
    mainShaderPointLight = lovr.graphics.newShader([[
        Constants {
            vec4 liteColor;
            vec4 ambience;
            vec3 lightPos;

            vec3 viewPos;
            float specularStrength;
            float metallic;
            float texelSize;

            mat4 LightSpaceMatrix;
        };

        mat4 savedLightSpaceMatrix = LightSpaceMatrix;

        //layout(location = 1) out vec4 PositionLight;
        out vec4 PositionLight;

        vec4 lovrmain() {
            PositionLight = savedLightSpaceMatrix * Transform * vec4(VertexPosition.xyz, 1.f);
            return Projection * View * Transform * VertexPosition;
        }
    ]], [[
        //in mat4 viewMatrix;

        Constants {
            vec4 liteColor;
            vec4 ambience;
            vec3 lightPos;

            vec3 viewPos;
            float specularStrength;
            float metallic;
            float texelSize;

            mat4 LightSpaceMatrix;
        };
        
        in vec4 PositionLight; // fragment position inside the light-space

        layout(set = 2, binding = 0) uniform texture2D diffuseMap;
        layout(set = 2, binding = 1) uniform texture2D specularMap;
        layout(set = 2, binding = 2) uniform texture2D normalMap;

        layout(set = 2, binding = 3) uniform texture2D DepthBuffer;
        
        float acneBias = 0.025;
        
        float getAverageVisibility(vec2 shadowMapCoords, float currentDepth) {
            float visibility = 0.0;
            for (int x = -2; x <= 2; x++) {
                for (int y = -2; y <= 2; y++) {
                //float closestDepth = getPixel(DepthBuffer, shadowMapCoords.xy + (vec2(x, y) * texelSize)).z;
                //visibility += (currentDepth < 0. || closestDepth < currentDepth) ? 1.0 : 0.3;

                vec2 projCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            
                float closestDepth;
                if ((projCoords.x > 0.) && (projCoords.x < 1.) &&
                    (projCoords.y > 0.) && (projCoords.y < 1.))
                    closestDepth = getPixel(DepthBuffer, projCoords).r;
                else
                    closestDepth = 0.;
                float currentDepth = PositionLight.z / PositionLight.w;
                float currentDepth_biased = currentDepth + 0.00001;

                //float shadow = (currentDepth_biased < 0. || closestDepth < currentDepth_biased) ? 1.0 : 0.3;
                visibility += currentDepth - acneBias > closestDepth ? 0.0 : 1.0;

                }
            }
            return visibility / 25.0;
        }

        vec4 lovrmain() 
        {    
            vec4 diffuseColor = getPixel(diffuseMap, UV); 
            vec4 specularColor = getPixel(specularMap, UV);
            vec4 normalColor = getPixel(normalMap, UV);

            // To TS
            vec3 LightPosTS = TangentMatrix * lightPos;
            vec3 ViewPosTS = TangentMatrix * viewPos;
            vec3 PositionWorldTS = TangentMatrix * PositionWorld;

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

            /* Smooth Shadowmapping
            vec2 shadowMapCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            float currentDepth = PositionLight.z / PositionLight.w;
            float currentDepth_biased = currentDepth + 0.0001;

            float shadow = getAverageVisibility(shadowMapCoords, currentDepth);*/

            // Color calculation
            vec4 shading = (diffuse + specular) * shadow;
            return vec4(diffuseColor.xyz, 1.0) * (ambience + shading );
            //return vec4(shadow, shadow, shadow, 1.0);
        }
    ]], { flags = {vertexTangents = false } })

    mainShaderSpotLight = lovr.graphics.newShader([[
        Constants {
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

        //layout(location = 1) out vec4 PositionLight;
        out vec4 PositionLight;

        vec4 lovrmain() {
            PositionLight = savedLightSpaceMatrix * Transform * vec4(VertexPosition.xyz, 1.f);
            return Projection * View * Transform * VertexPosition;
        }
    ]], [[
        //in mat4 viewMatrix;

        Constants {
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
        
        in vec4 PositionLight; // fragment position inside the light-space

        layout(set = 2, binding = 0) uniform texture2D diffuseMap;
        layout(set = 2, binding = 1) uniform texture2D specularMap;
        layout(set = 2, binding = 2) uniform texture2D normalMap;

        layout(set = 2, binding = 3) uniform texture2D DepthBuffer;
        
        float acneBias = 0.025;
        
        float getAverageVisibility(vec2 shadowMapCoords, float currentDepth) {
            float visibility = 0.0;
            for (int x = -2; x <= 2; x++) {
                for (int y = -2; y <= 2; y++) {
                //float closestDepth = getPixel(DepthBuffer, shadowMapCoords.xy + (vec2(x, y) * texelSize)).z;
                //visibility += (currentDepth < 0. || closestDepth < currentDepth) ? 1.0 : 0.3;

                vec2 projCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            
                float closestDepth;
                if ((projCoords.x > 0.) && (projCoords.x < 1.) &&
                    (projCoords.y > 0.) && (projCoords.y < 1.))
                    closestDepth = getPixel(DepthBuffer, projCoords).r;
                else
                    closestDepth = 0.;
                float currentDepth = PositionLight.z / PositionLight.w;
                float currentDepth_biased = currentDepth + 0.00001;

                //float shadow = (currentDepth_biased < 0. || closestDepth < currentDepth_biased) ? 1.0 : 0.3;
                visibility += currentDepth - acneBias > closestDepth ? 0.0 : 1.0;

                }
            }
            return visibility / 25.0;
        }

        vec4 lovrmain() 
        {    
            vec4 diffuseColor = getPixel(diffuseMap, UV); 
            vec4 specularColor = getPixel(specularMap, UV);
            vec4 normalColor = getPixel(normalMap, UV);

            // To TS
            vec3 LightPosTS = TangentMatrix * lightPos;
            vec3 ViewPosTS = TangentMatrix * viewPos;
            vec3 PositionWorldTS = TangentMatrix * PositionWorld;

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

            /* Smooth Shadowmapping
            vec2 shadowMapCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            float currentDepth = PositionLight.z / PositionLight.w;
            float currentDepth_biased = currentDepth + 0.0001;

            float shadow = getAverageVisibility(shadowMapCoords, currentDepth);*/

            // Color calculation
            vec4 shading = (diffuse + specular) * shadow;

            float innerCutOff = cos(radians(35));
            float outerCutOff = cos(radians(50));

            float theta = dot(lightDir, normalize(-spotDir));
            float epsilon = innerCutOff - outerCutOff;
            float intensity = clamp((theta - outerCutOff ) / epsilon, 0.0, 1.0);    

            /*if(theta <= innerCutOff )
            {       
                shading = vec4(0, 0, 0, 1.0);
            }*/

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

local function drawScene(pass)
    -- Draw
    pass:cube(lovr.math.mat4():translate(ground:getPosition()):rotate(ground:getOrientation()):scale(10, 0.05, 10 ))
    pass:draw(box2Model, lovr.math.mat4():translate(box2:getPosition()):rotate(box2:getOrientation()):translate(0, 0, 0):scale(1.25, 1.25, 1.25 ))

    --local relativePosString = tostring(m1..", "..m2..", "..m3..", "..m4..", "..m5..", "..m6..", "..m7..", "..m8..", "..m9..", "..m10..", "..m11..", "..m12..", "..m13..", "..m14..", "..m15..", "..m16)

    --chestBox:setPosition(m13, m14, m15)
    local x, y, z = chestBox:getPosition()
    local angle, ax, ay, az = chestBox:getOrientation()

    pass:draw(model, lovr.math.mat4():translate(x, y, z):rotate(angle, ax, ay, az):translate(0.0, -0.3, 0))
end

function lovr.keypressed(key, scancode, repeating)
    if key == "up" then mx = mx + 5.0 end
    if key == "down" then mx = mx - 5.0 end
end

function lovr.update(dT)
    -- Update the physics simulation
    world:update(1 / 60)

    -- Adjust light position
    timer = timer + dT
    pos = math.sin(timer)*2

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

    light_pose:target(light_origin, light_target)
    light_view:set(light_pose):invert()
    -- render to depth buffer from light perspective
    local pass = lovr.graphics.getPass('render', {depth = {texture=depthtex}, samples = 1})
    pass:setCullMode('back')
    pass:setProjection(1, light_projection)
    pass:setViewPose(1, light_pose)
    drawScene(pass)
    lovr.graphics.submit(pass)
end

function lovr.draw(pass) 
    pass:setCullMode('back')

    -- Regular shader
    pass:setViewPose(1, lovr.headset.getPose())

    --pass:setShader()
    pass:setShader(mainShaderSpotLight)
    
    local light_space_matrix = light_projection * light_view
    pass:send('LightSpaceMatrix', light_space_matrix)
    pass:send('DepthBuffer', depthtex)

    -- Set shader attributes
    pass:send('diffuseMap', defaultDiffuseMap)
    pass:send('specularMap', defaultSpecularMap)
    pass:send('normalMap', defaultNormalMap)

    -- Set default shader values
    pass:send('liteColor', {1.0, 1.0, 1.0, 1.0})
    pass:send('ambience', {0.02, 0.02, 0.02, 1.0})
    pass:send('lightPos', light_origin)
    pass:send('spotDir', (light_target:sub(light_origin)):normalize() )
    pass:send('viewPos', {hx, hy, hz})
    pass:send('specularStrength', 3.0)
    pass:send('metallic', 32.0)

    pass:send('texelSize', 1.0/depthBufferSize)

    -- Draw
    pass:cube(lovr.math.mat4():translate(ground:getPosition()):rotate(ground:getOrientation()):scale(10, 0.05, 10 ))

    pass:send('diffuseMap', tvDiffuseMap)
    pass:send('specularMap', tvSpecularMap)
    pass:send('normalMap', tvNormalMap)

    pass:draw(box2Model, lovr.math.mat4():translate(box2:getPosition()):rotate(box2:getOrientation()):translate(0, 0, 0):scale(1.25, 1.25, 1.25 ))

    local m1, m2, m3, m4,
    m5, m6, m7, m8,
    m9, m10, m11, m12,
    m13, m14, m15, m16 = lovr.math.mat4():scale(5.0, 5.0, 5.0):unpack(true)

    local relativePosString = tostring(m1..", "..m2..", "..m3..", "..m4..", \n"..m5..", "..m6..", "..m7..", "..m8..", \n"..m9..", "..m10..", "..m11..", "..m12..", \n"..m13..", "..m14..", "..m15..", "..m16)

    --chestBox:setPosition(m13, m14, m15)
    local x, y, z = chestBox:getPosition()
    local angle, ax, ay, az = chestBox:getOrientation()

    pass:send('diffuseMap', diffuseMap)
    pass:send('specularMap', specularMap)
    pass:send('normalMap', normalMap)

    pass:draw(model, lovr.math.mat4():translate(x, y, z):rotate(angle, ax, ay, az):translate(0.0, -0.3, 0))

    pass:setShader() -- Reset to default/unlit
    pass:text(relativePosString, 0, 1.7, -3, .5)
    pass:sphere(pos, 2.5, -pos, 0.1) -- Represents light
end
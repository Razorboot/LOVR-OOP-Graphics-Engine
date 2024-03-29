forwardShader = lovr.graphics.newShader([[
    #define NR_SPOT_LIGHTS 10 

    Constants {
        // Individual Constants
        int numLights;
        vec4 ambience;
        float metallic;
        float texelSize;
        float specularStrength;
        int textureMode;
        vec3 objPos;
        vec3 objScale;
        vec3 objTileScale;
        mat4 inverseNormalMatrix;
    };

    layout(set = 2, binding = 7) uniform LightSpaceMatrix_Buffer {
        mat4 LightSpaceMatrices[NR_SPOT_LIGHTS];
    };

    layout(location = 0) out vec4 lightPositions[NR_SPOT_LIGHTS];

    vec4 lovrmain() {
        for (int i = 0; i < numLights; i++) {
            lightPositions[i] = LightSpaceMatrices[i] * Transform * vec4(VertexPosition.xyz, 1.0);
        }

        return DefaultPosition;
    }
]], [[
    #define NR_SPOT_LIGHTS 10 

    Constants {
        // Individual Constants
        int numLights;
        vec4 ambience;
        float metallic;
        float texelSize;
        float specularStrength;
        int textureMode;
        vec3 objPos;
        vec3 objScale;
        vec3 objTileScale;
        mat4 inverseNormalMatrix;
    };
    
    // Passed in from vertex shader
    layout(location = 0) in vec4 lightPositions[NR_SPOT_LIGHTS];

    // Passed in texture2Ds
    layout(set = 2, binding = 0) uniform texture2D diffuseMap;
    layout(set = 2, binding = 1) uniform texture2D specularMap;
    layout(set = 2, binding = 2) uniform texture2D normalMap;
    layout(set = 2, binding = 3) uniform texture2DArray depthBuffers;

    layout(set = 2, binding = 4) uniform liteColor_Buffer {
        vec4 liteColors[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 5) uniform lightPos_Buffer {
        vec4 lightPoses[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 6) uniform spotDir_Buffer {
        vec4 spotDirs[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 7) uniform LightSpaceMatrix_Buffer {
        mat4 LightSpaceMatrices[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 8) uniform cutOff_Buffer {
        float cutOffs[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 9) uniform range_Buffer {
        float ranges[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 10) uniform lightType_Buffer {
        int lightTypes[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 11) uniform lightHasShadows_Buffer {
        int hasShadows[NR_SPOT_LIGHTS];
    };
    layout(set = 2, binding = 12) uniform lightVisible_Buffer {
        int lightVisibles[NR_SPOT_LIGHTS];
    };
    
    // Misc Variables
    vec4 getShading(int lightIndex, vec3 norm, float cutOff, vec3 spotDir, vec4 specularColor, vec3 lightPos, vec4 liteColor, vec4 PositionLight, vec3 PosWorld)
    {
        //diffuse
        vec3 lightDir = normalize(lightPos - PosWorld);
        float diff = max(dot(norm, lightDir), 0.0);
        vec4 diffuse = diff * liteColor;
        
        //specular
        vec3 viewDir = normalize(CameraPositionWorld - PosWorld);
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
        vec4 specular = (specularStrength * (1.0-specularColor.g) ) * spec * liteColor;

        // Shadowmapping
        float shadow = 1.0;
        
        if (hasShadows[lightIndex] == 1)
        {
            vec2 projCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            int pcfIndex = 4;
            
            float visibility = 0.0;
            for (int x = -pcfIndex; x <= pcfIndex; x++) {
                for (int y = -pcfIndex; y <= pcfIndex; y++) {
                    vec2 newProjCoords = projCoords.xy + (vec2(x, y));
                    //float rand1 = 0.5 + 0.5 * fract(sin(dot(newProjCoords.xy, vec2(12.9898, 78.233)))* 43758.5453);
                    //float rand2 = 0.5 + 0.5 * fract(sin(dot(newProjCoords.yx, vec2(12.9898, 78.233)))* 43758.5453);

                    vec2 K1 = vec2(
                        23.14069263277926, // e^pi (Gelfond's constant)
                        2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
                    );
                    float rand1 = fract( cos( dot(newProjCoords.xy, K1) ) * 12345.6789 );
                    float rand2 = fract( cos( dot(newProjCoords.yx, K1) ) * 12345.6789 );

                    float u = rand1;
                    float v = rand2;
                    float newX = sqrt(v) * cos(2*PI*u);
                    float newY = sqrt(v) * sin(2*PI*u);
                    vec2 tempProjCoords = projCoords.xy + (vec2(x + newX, y + newY) * texelSize);

                    float closestDepth;
                    if ((tempProjCoords.x > 0.) && (tempProjCoords.x < 1.) &&
                        (tempProjCoords.y > 0.) && (tempProjCoords.y < 1.))
                        closestDepth = getPixel(depthBuffers, tempProjCoords, lightIndex).r;
                    else
                        closestDepth = 0.;
                    float currentDepth = PositionLight.z / PositionLight.w;
                    float bias = max(0.000005 * (1.0 - dot(norm, lightDir)), 0.0000125 );
                    float currentDepth_biased = currentDepth + 0.0000125;

                    visibility += (currentDepth_biased < 0.0 || closestDepth < currentDepth_biased) ? 1.0 : 0.0;
                }
            }

            // Final shadow color
            shadow = visibility/50.0;
        }

        // Color calculation
        vec4 shading = (diffuse + specular) * shadow;
        float intensity = 1.0;

        if (lightTypes[lightIndex] == 0)
        {
            float innerCutOff = cutOff;
            float outerCutOff = cutOff * 0.8;

            float theta = dot(lightDir, normalize(-spotDir));
            float epsilon = innerCutOff - outerCutOff;
            intensity = clamp((theta - outerCutOff ) / epsilon, 0.0, 1.0);
        }

        // Attenuation
        float att = clamp(1.0 - length(lightPos - PosWorld)/ranges[lightIndex], 0.0, 1.0);

        // Finalize
        shading = shading * intensity;
        return shading * att;
    }

    // Main Function
    vec4 lovrmain() 
    {   
        // Get texture colors
        vec4 diffuseColor;
        vec4 specularColor;
        vec4 normalColor;

        vec2 sampleCoords;

        if (textureMode == 0)
        {
            sampleCoords = UV;
        } else {
            vec3 subToCenter = Normal.xyz * mat3(inverseNormalMatrix);
            subToCenter = vec3(abs(subToCenter.x), abs(subToCenter.y), abs(subToCenter.z));

            if ((subToCenter.x > subToCenter.y) && (subToCenter.x > subToCenter.z)) {
                sampleCoords = vec2(UV.x * (objScale.y * objTileScale.y), UV.y * (objScale.z * objTileScale.z));
            } else if ((subToCenter.y > subToCenter.x) && (subToCenter.y > subToCenter.z)) {
                sampleCoords = vec2(UV.x * (objScale.x * objTileScale.x), UV.y * (objScale.z * objTileScale.z));
            } else if ((subToCenter.z > subToCenter.x) && (subToCenter.z > subToCenter.y)) {
                sampleCoords = vec2(UV.x * (objScale.y * objTileScale.y), UV.y * (objScale.x * objTileScale.x));
            }
        }

        diffuseColor = getPixel(diffuseMap, sampleCoords); 
        specularColor = getPixel(specularMap, sampleCoords);
        normalColor = getPixel(normalMap, sampleCoords);

        // Final color for the fragment
        vec4 finalShading = vec4(0, 0, 0, 1);

        // Normal Mapping
        vec3 norm = normalColor.rgb * 2.0 - 0.5;
        norm.x *= -1.0;
        norm = normalize(TangentMatrix * norm);

        // Shade the fragment
        for (int i = 0; i < numLights; i++) {
            if (lightVisibles[i] == 0)
            {
                finalShading += getShading(i, norm, cutOffs[i], spotDirs[i].xyz, specularColor, lightPoses[i].xyz, liteColors[i], lightPositions[i], PositionWorld);
            }
        }

        // Finalize
        float gamma = 1.0;
        vec4 finalColor = vec4(diffuseColor.xyz, 1.0) * (ambience + vec4(clamp(finalShading.x, 0.0, 1.0), clamp(finalShading.y, 0.0, 1.0), clamp(finalShading.z, 0.0, 1.0), 1.0) );
        finalColor.rgb = pow(finalColor.rgb, vec3(1.0/gamma));
        return finalColor;
    }
]], { flags = {vertexTangents = false } })


--# Finalize
return forwardShader
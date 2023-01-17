forwardParticleShader = lovr.graphics.newShader([[
    #define NR_SPOT_LIGHTS 10 

    Constants {
        vec3 PositionCam;
        vec2 resolution;
        float edgeSmooth;
        float alpha;
        float numLights;
        float texelSize;
        float near;
        float ambience;
        float brightness;
        bool hasDepthTest;
        bool hasShadowCastings;
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
        vec3 PositionCam;
        vec2 resolution;
        float edgeSmooth;
        float alpha;
        float numLights;
        float texelSize;
        float near;
        float ambience;
        float brightness;
        bool hasDepthTest;
        bool hasShadowCastings;
    };

    // Passed in from vertex shader
    layout(location = 0) in vec4 lightPositions[NR_SPOT_LIGHTS];

    // Passed in texture2Ds
    layout(set = 2, binding = 0) uniform texture2D diffuseMap;
    layout(set = 2, binding = 1) uniform texture2D depthMap;
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
    vec4 getShading(int lightIndex, vec3 norm, float cutOff, vec3 spotDir, vec3 lightPos, vec4 liteColor, vec4 PositionLight, vec3 PosWorld)
    {
        //diffused
        vec3 lightDir = normalize(lightPos - PosWorld);
        float diff = max(dot(lightDir, lightDir), 0.0);
        vec4 diffuse = diff * liteColor;

        // Shadowmapping
        float shadow = 1.0;

        if ((hasShadows[lightIndex] == 1) && (hasShadowCastings == true))
        {
            vec2 projCoords = PositionLight.xy / PositionLight.w * 0.5 + 0.5;
            int pcfIndex = 4;
            
            float visibility = 0.0;
            for (int x = -pcfIndex; x <= pcfIndex; x++) {
                for (int y = -pcfIndex; y <= pcfIndex; y++) {
                    vec2 tempProjCoords = projCoords.xy + (vec2(x, y) * texelSize);

                    float closestDepth;
                    if ((tempProjCoords.x > 0.) && (tempProjCoords.x < 1.) &&
                        (tempProjCoords.y > 0.) && (tempProjCoords.y < 1.))
                        closestDepth = getPixel(depthBuffers, tempProjCoords, lightIndex).r;
                    else
                        closestDepth = 0.;
                    float currentDepth = PositionLight.z / PositionLight.w;
                    float bias = max(0.000005 * (1.0 - dot(norm, lightDir)), 0.0000125 );
                    float currentDepth_biased = currentDepth;

                    visibility += (currentDepth_biased < 0.0 || closestDepth < currentDepth_biased) ? 1.0 : 0.0;
                }
            }

            // Final shadow color
            shadow = visibility/50.0;
        }

        // Color calculation
        vec4 shading = (diffuse) * shadow;
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

    // Main
    vec4 lovrmain() {
        vec4 diffuseColor = getPixel(diffuseMap, UV); 

        // Final color for the fragment
        vec4 finalShading = vec4(0, 0, 0, 1);

        // Calculate edge smoothing
        float diff;
        if (hasDepthTest == true)
        {
            if (edgeSmooth != -1.0) {
                vec4 depthColor = getPixel(depthMap, vec2(gl_FragCoord.x/resolution.x, gl_FragCoord.y/resolution.y)); 

                //float sceneDepth = GetDepth(vec2(gl_FragCoord.x/900, gl_FragCoord.y/900));
                float curDepth = gl_FragCoord.z;
                float multiplier = (near / length(PositionWorld.xyz - PositionCam.xyz)) * edgeSmooth;
                diff = clamp( (curDepth - depthColor.r) / (multiplier), 0.0, 1.0);
            } else {
                diff = 1.0;
            }
        } else {
            diff = 1.0;
        }
        diff *= alpha;

        // Shade the fragment
        for (int i = 0; i < numLights; i++) {
            if (lightVisibles[i] == 0)
            {
                finalShading += getShading(i, Normal, cutOffs[i], spotDirs[i].xyz, lightPoses[i].xyz, liteColors[i], lightPositions[i], PositionWorld);
            }
        }

        // Finalize
        float gamma = 1.0;
        vec4 finalColor = vec4(diffuseColor.xyz, 1.0) * ( (ambience * brightness) + vec4(clamp(finalShading.x, 0.0, 1.0), clamp(finalShading.y, 0.0, 1.0), clamp(finalShading.z, 0.0, 1.0), 1.0) );
        finalColor.rgb = pow(finalColor.rgb, vec3(1.0/gamma));
        return vec4(vec3(finalColor.rgb), diff * diffuseColor.w);
    }
]], { flags = {vertexTangents = false } })


--# Finalize
return forwardParticleShader
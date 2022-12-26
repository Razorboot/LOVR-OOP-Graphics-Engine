spotlightShader = lovr.graphics.newShader([[
    Constants {
        // Individual Constants
        int numLights;
        vec4 ambience;
        vec3 viewPos;
        float metallic;
        float texelSize;
        float specularStrength;
        
        // INCREDIBLY DUMB way to do multiple lights, but LOVR doesn't have proper support for arrays in constants yet, so my current solution is variables for different lights.
        
        // Light 0
        mat4 LightSpaceMatrix_0;
        mat4 LightSpaceMatrix_1;

        vec4 liteColor_0;
        vec3 lightPos_0;
        vec3 spotDir_0;
        float cutOff_0;

        // Light 1
        vec4 liteColor_1;
        vec3 lightPos_1;
        vec3 spotDir_1;
        float cutOff_1;
    };

    out vec4 lightPositions[5];

    vec4 getLightPos(mat4 lightmat, mat4 trans, vec4 vertPos)
    {
        return lightmat * trans * vec4(vertPos.xyz, 1.f);
    }

    vec4 lovrmain() {
        //lightPositions[0] = savedLightSpaceMatrix * Transform * vec4(VertexPosition.xyz, 1.f);
        //vec4 vertPos = vec4(VertexPosition.xyz, 1.f);

        if (numLights > 0) {
            lightPositions[0] = LightSpaceMatrix_0 * Transform * vec4(VertexPosition.xyz, 1.0);
        }
        if (numLights > 1) {
            lightPositions[1] = LightSpaceMatrix_1 * Transform * vec4(VertexPosition.xyz, 1.0);
        }

        return DefaultPosition;
    }
]], [[
    Constants {
        // Individual Constants
        int numLights;
        vec4 ambience;
        vec3 viewPos;
        float metallic;
        float texelSize;
        float specularStrength;
        
        // INCREDIBLY DUMB way to do multiple lights, but LOVR doesn't have proper support for arrays in constants yet, so my current solution is variables for different lights.
        
        // Light 0
        vec4 liteColor_0;
        vec3 lightPos_0;
        vec3 spotDir_0;
        mat4 LightSpaceMatrix_0;
        float cutOff_0;

        // Light 1
        vec4 liteColor_1;
        vec3 lightPos_1;
        vec3 spotDir_1;
        mat4 LightSpaceMatrix_1;
        float cutOff_1;
    };
    
    // Passed in from vertex shader
    in vec4 lightPositions[5];

    // Passed in texture2Ds
    layout(set = 2, binding = 0) uniform texture2D diffuseMap;
    layout(set = 2, binding = 1) uniform texture2D specularMap;
    layout(set = 2, binding = 2) uniform texture2D normalMap;

    layout(set = 2, binding = 3) uniform texture2D DepthBuffer;
    layout(set = 2, binding = 4) uniform texture2D DepthBuffer2;
    //layout(set = 2, binding = 3) uniform texture2D passTexture;
    
    // Misc Variables
    float acneBias = 0.025;

    // Helper Functions
    vec4 getShading(vec3 norm, float cutOff, vec3 spotDir, vec4 specularColor, vec3 lightPos, vec4 liteColor, vec4 PositionLight, texture2D curDepthBuffer, vec3 PosWorld)
    {
        //diffuse
        vec3 lightDir = normalize(lightPos - PosWorld);
        float diff = max(dot(norm, lightDir), 0.0);
        vec4 diffuse = diff * liteColor;
        
        //specular
        vec3 viewDir = normalize(viewPos - PosWorld);
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
                    closestDepth = getPixel(curDepthBuffer, tempProjCoords).r;
                else
                    closestDepth = 0.;
                float currentDepth = PositionLight.z / PositionLight.w;
                float currentDepth_biased = currentDepth + 0.0000125;

                visibility += (currentDepth_biased < 0.0 || closestDepth < currentDepth_biased) ? 1.0 : 0.0;
            }
        }

        //float shadow = visibility/25.0;
        float shadow = 1.0;

        // Color calculation
        vec4 shading = (diffuse + specular) * shadow;

        /*float innerCutOff = cutOff;
        float outerCutOff = cutOff - 0.25;

        float theta = dot(lightDir, normalize(-spotDir));
        float epsilon = innerCutOff - outerCutOff;
        float intensity = clamp((theta - outerCutOff ) / epsilon, 0.0, 1.0); 

        return shading * intensity;*/

        // Attenuation
        float att = clamp(1.0 - length(lightPos - PosWorld)/8.0, 0.0, 1.0);

        // Finalize
        return shading * att;
    }

    // Main Function
    vec4 lovrmain() 
    {   
        vec2 uvOffset = Resolution.xy;

        // Texture color coordinates
        vec4 diffuseColor = getPixel(diffuseMap, UV); 
        vec4 specularColor = getPixel(specularMap, UV);
        vec4 normalColor = getPixel(normalMap, UV);
        //vec4 passColor = getPixel(passTexture, UV);

        // Final color for the fragment
        vec4 finalShading = vec4(0, 0, 0, 1);

        // Normal Mapping
        vec3 norm = normalColor.rgb * 2.0 - 0.5;
        norm.x *= -1.0;
        norm = normalize(TangentMatrix * norm);

        // Do get Shading thing here
        if (numLights > 0) {
            finalShading += getShading(norm, cutOff_0, spotDir_0, specularColor, lightPos_0, liteColor_0, lightPositions[0], DepthBuffer, PositionWorld);
        }
        if (numLights > 1) {
            finalShading += getShading(norm, cutOff_1, spotDir_1, specularColor, lightPos_1, liteColor_1, lightPositions[1], DepthBuffer2, PositionWorld);
        }

        // Finalize
        //return vec4(liteColor_1, 1.0);
        return vec4(diffuseColor.xyz, 1.0) * (/*ambience +*/ vec4(clamp(finalShading.x, 0.0, 1.0), clamp(finalShading.y, 0.0, 1.0), clamp(finalShading.z, 0.0, 1.0), 1.0) );
    }
]], { flags = {vertexTangents = false } })


--# Finalize
return spotlightShader
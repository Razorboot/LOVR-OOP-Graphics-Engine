{
  root = {
    children = {
      {
        canCastShadows = true,
        children = {
          {
            angle = 1.0471975511965976,
            children = {} --[[table: 0x01f9f042a8d0]],
            color = {
              1,
              1,
              1
            } --[[table: 0x01f9f0429ce8]],
            globalTransform = {
              0.22706472873687744,
              -0.022936806082725525,
              0.10205641388893127,
              0,
              -0.022936806082725525,
              0.22706165909767151,
              0.10206324607133865,
              0,
              -0.10205641388893127,
              -0.10206324607133865,
              0.20412638783454895,
              0,
              0.99993300437927246,
              1,
              -2,
              1
            } --[[table: 0x01f9f0429d50]],
            hasShadows = false,
            hasShadowsChanged = false,
            id = 2,
            localTransform = {
              0.22706472873687744,
              -0.022936806082725525,
              0.10205641388893127,
              0,
              -0.022936806082725525,
              0.22706165909767151,
              0.10206324607133865,
              0,
              -0.10205641388893127,
              -0.10206324607133865,
              0.20412638783454895,
              0,
              0.99993300437927246,
              1,
              -2,
              1
            } --[[table: 0x01f9f04298e8]],
            name = "TestLight",
            range = 15,
            type = "SpotLight",
            visible = true
          } --[[table: 0x01f9f042a888]]
        } --[[table: 0x01f9efffe758]],
        diffuseMap_filepath = "assets/textures/Television_01_diff_1k.jpg",
        filepath = "assets/models/tv_centered.glb",
        globalTransform = {
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1
        } --[[table: 0x01f9f042a2b0]],
        id = 1,
        localTransform = {
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1
        } --[[table: 0x01f9efffe2d0]],
        name = "TV",
        normalMap_filepath = "assets/textures/Television_01_nor_gl_1k.jpg",
        specularMap_filepath = "assets/textures/Television_01_roughness_1k.jpg",
        textureMode = "UV",
        tileScale = {
          1,
          1,
          1
        } --[[table: 0x01f9efffe568]],
        type = "Model",
        visible = true
      } --[[table: 0x01f9efffe710]],
      {
        alphaRange = {
          ["0"] = 0,
          ["0.3"] = 1,
          ["1"] = 0
        } --[[table: 0x01f9f045c588]],
        brightness = 3,
        children = {} --[[table: 0x01f9f0429f08]],
        collisionDist = 0.14999999999999999,
        diffuseMap_filepath = "assets/textures/smoke.png",
        directionalForceRange = {
          xRange = {
            -10,
            10
          } --[[table: 0x01f9f045c168]],
          yRange = {
            45,
            45
          } --[[table: 0x01f9f045c200]],
          zRange = {
            -10,
            10
          } --[[table: 0x01f9f045c260]]
        } --[[table: 0x01f9f0429a98]],
        edgeSmooth = 0.20000000000000001,
        enabled = true,
        faceCamera = true,
        friction = 0.98999999999999999,
        globalTransform = {
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1
        } --[[table: 0x01f9f045bff8]],
        gravity = 30,
        hasCollisions = true,
        hasDepthTest = true,
        hasShadowCastings = true,
        id = 3,
        incrementTime = 0.070000000000000007,
        lifeTime = 4,
        localTransform = {
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1
        } --[[table: 0x01f9f042a0a0]],
        name = "TestParticle",
        previousTime = 0,
        scaleRange = {
          ["0"] = {
            0,
            0,
            0
          } --[[table: 0x01f9f045c4b8]],
          ["0.3"] = {
            1,
            1,
            1
          } --[[table: 0x01f9f045c450]],
          ["1"] = {
            0.5,
            0.5,
            0.5
          } --[[table: 0x01f9f045c3b0]]
        } --[[table: 0x01f9f045c368]],
        timeStep = 3,
        type = "Particle",
        useLookVector = true,
        visible = true
      } --[[table: 0x01f9f0429ec0]],
      {
        children = {
          {
            canCastShadows = true,
            children = {} --[[table: 0x01f9f04677f8]],
            diffuseMap_filepath = "lovr_graphics_engine/assets_default/textures/brick_diff.png",
            filepath = "assets/models/box.obj",
            globalTransform = {
              20,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              20,
              0,
              0,
              -3,
              0,
              1
            } --[[table: 0x01f9f0467bb8]],
            id = 5,
            localTransform = {
              20,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              20,
              0,
              0,
              0,
              0,
              1
            } --[[table: 0x01f9f0467990]],
            name = "Ground",
            normalMap_filepath = "lovr_graphics_engine/assets_default/textures/brick_norm.png",
            specularMap_filepath = "lovr_graphics_engine/assets_default/textures/brick_spec.png",
            textureMode = "Tile",
            tileScale = {
              1,
              1,
              1
            } --[[table: 0x01f9f0470cf8]],
            type = "Model",
            visible = true
          } --[[table: 0x01f9f04677b0]]
        } --[[table: 0x01f9f045bd68]],
        collider = {
          isKinematic = true,
          isMeshShape = false,
          pose = 0,
          shapes = {
            {
              dimensions = {
                40,
                2,
                40
              } --[[table: 0x01f9f045ba88]],
              shapeType = "BoxShape"
            } --[[table: 0x01f9f045ba40]]
          } --[[table: 0x01f9f045b958]]
        } --[[table: 0x01f9f045b8d8]],
        colliderType = "box",
        globalTransform = {
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          -3,
          0,
          1
        } --[[table: 0x01f9f045bb18]],
        id = 4,
        localTransform = {
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          -3,
          0,
          1
        } --[[table: 0x01f9f045bf88]],
        name = "MyBody",
        type = "Body",
        visible = true
      } --[[table: 0x01f9f045bd20]]
    } --[[table: 0x01f9efffe120]],
    globalTransform = {
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1
    } --[[table: 0x01f9efffe338]],
    localTransform = {
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1
    } --[[table: 0x01f9efffe470]],
    name = "TestNode",
    type = "Node",
    visible = true
  } --[[table: 0x01f9efffe0d8]],
  sceneProperties = {
    camera = {
      pose = {
        -2.0882201194763184,
        3.255805492401123,
        -1.0487378835678101,
        1,
        1,
        1.0000001192092896,
        1.930660605430603,
        -0.36698693037033081,
        -0.8218609094619751,
        -0.43573522567749023
      } --[[table: 0x01f9f0453f50]],
      proj = {
        0,
        0,
        0.0099999997764825821,
        1.3191577196121216,
        1.187241792678833,
        0,
        3.1415927410125732,
        0,
        0,
        0
      } --[[table: 0x01f9f0454df0]],
      view = {
        -2.0882201194763184,
        3.255805492401123,
        -1.0487378835678101,
        1,
        1,
        1.0000001192092896,
        1.930660605430603,
        -0.36698693037033081,
        -0.8218609094619751,
        -0.43573522567749023
      } --[[table: 0x01f9f0454f60]]
    } --[[table: 0x01f9f0454d38]],
    defaults = {} --[[table: 0x01f9f04543e0]],
    lightDepthTexArray_Views = {} --[[table: 0x01f9f04542b0]],
    lighting = {
      ambience = {
        0.0035294117406010628,
        0.0035294117406010628,
        0.0058823530562222004
      } --[[table: 0x01f9f04554f8]]
    } --[[table: 0x01f9f0455440]],
    passes = {} --[[table: 0x01f9f0454958]],
    root = {} --[[table: 0x01f9f0455640]],
    tempNodes = {} --[[table: 0x01f9f0454af0]],
    timer = 1.5758875000028638
  } --[[table: 0x01f9f0456378]]
} --[[table: 0x01f9f0456330]]
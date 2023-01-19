{
  root = {
    children = {
      {
        canCastShadows = true,
        children = {
          {
            angle = 1.0471975511965976,
            children = {} --[[table: 0x02ea27ccb258]],
            color = {
              1,
              1,
              1
            } --[[table: 0x02ea2782cc78]],
            globalTransform = {
              0.23791706562042236,
              -0.017168020829558372,
              0.07483799010515213,
              0,
              -0.017285531386733055,
              0.22543953359127045,
              0.10666874796152115,
              0,
              -0.074810929596424103,
              -0.10668771713972092,
              0.2133566290140152,
              0,
              0.70140361785888672,
              1.0000002384185791,
              -2,
              1
            } --[[table: 0x02ea27ccb568]],
            hasShadows = true,
            hasShadowsChanged = false,
            id = 2,
            localTransform = {
              0.23791706562042236,
              -0.017168020829558372,
              0.07483799010515213,
              0,
              -0.017285531386733055,
              0.22543953359127045,
              0.10666874796152115,
              0,
              -0.074810929596424103,
              -0.10668771713972092,
              0.2133566290140152,
              0,
              0.70140361785888672,
              1.0000002384185791,
              -2,
              1
            } --[[table: 0x02ea27ccb2d8]],
            name = "TestLight",
            pose = {
              0.70140361785888672,
              1.0000002384185791,
              -2,
              1,
              1.0000001192092896,
              1,
              2.8125865459442139,
              -0.037199739366769791,
              0.9751240611076355,
              0.21851600706577301
            } --[[table: 0x02ea2782cb50]],
            projection = {
              0,
              0,
              0.0099999997764825821,
              1,
              1,
              0,
              3.1415927410125732,
              0,
              0,
              0
            } --[[table: 0x02ea2782cd58]],
            range = 15,
            type = "SpotLight",
            view = {
              0.00012053901446051896,
              9.7681040642783046e-05,
              -2.3434944152832031,
              0.99999988079071045,
              0.99999982118606567,
              0.99999988079071045,
              2.8125865459442139,
              0.037199746817350388,
              -0.97512412071228027,
              -0.21851599216461182
            } --[[table: 0x02ea27ccb738]],
            visible = true
          } --[[table: 0x02ea27c93aa0]]
        } --[[table: 0x02ea27d19df8]],
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
        } --[[table: 0x02ea27c93948]],
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
        } --[[table: 0x02ea27d19bc8]],
        name = "TV",
        normalMap_filepath = "assets/textures/Television_01_nor_gl_1k.jpg",
        specularMap_filepath = "assets/textures/Television_01_roughness_1k.jpg",
        textureMode = "UV",
        tileScale = {
          1,
          1,
          1
        } --[[table: 0x02ea27c93c78]],
        type = "Model",
        visible = true
      } --[[table: 0x02ea27d19db0]],
      {
        alphaRange = {
          ["0"] = 0,
          ["0.3"] = 1,
          ["1"] = 0
        } --[[table: 0x02ea27c924c0]],
        brightness = 3,
        children = {} --[[table: 0x02ea27d0c888]],
        collisionDist = 0.14999999999999999,
        diffuseMap_filepath = "assets/textures/smoke.png",
        directionalForceRange = {
          xRange = {
            -10,
            10
          } --[[table: 0x02ea27c927a8]],
          yRange = {
            45,
            45
          } --[[table: 0x02ea27c92808]],
          zRange = {
            -10,
            10
          } --[[table: 0x02ea27c923e0]]
        } --[[table: 0x02ea27c92728]],
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
        } --[[table: 0x02ea2782c748]],
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
        } --[[table: 0x02ea2782ce58]],
        name = "TestParticle",
        previousTime = 0,
        scaleRange = {
          ["0"] = {
            0,
            0,
            0
          } --[[table: 0x02ea2782c5c0]],
          ["0.3"] = {
            1,
            1,
            1
          } --[[table: 0x02ea2782c4f0]],
          ["1"] = {
            0.5,
            0.5,
            0.5
          } --[[table: 0x02ea2782c558]]
        } --[[table: 0x02ea2782c4a8]],
        timeStep = 3,
        type = "Particle",
        useLookVector = true,
        visible = true
      } --[[table: 0x02ea27d0c840]],
      {
        children = {
          {
            canCastShadows = true,
            children = {} --[[table: 0x02ea2782c430]],
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
            } --[[table: 0x02ea27cd9140]],
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
            } --[[table: 0x02ea27d0daf8]],
            name = "Ground",
            normalMap_filepath = "lovr_graphics_engine/assets_default/textures/brick_norm.png",
            specularMap_filepath = "lovr_graphics_engine/assets_default/textures/brick_spec.png",
            textureMode = "Tile",
            tileScale = {
              1,
              1,
              1
            } --[[table: 0x02ea27ca50e8]],
            type = "Model",
            visible = true
          } --[[table: 0x02ea27d0dff8]]
        } --[[table: 0x02ea2782c2a0]],
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
              } --[[table: 0x02ea27d0ddb0]],
              shapeType = "BoxShape"
            } --[[table: 0x02ea27d0dd68]]
          } --[[table: 0x02ea27d0dc80]]
        } --[[table: 0x02ea27d0dc00]],
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
        } --[[table: 0x02ea27d0de10]],
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
        } --[[table: 0x02ea2782c3d0]],
        name = "MyBody",
        type = "Body",
        visible = true
      } --[[table: 0x02ea2782c258]]
    } --[[table: 0x02ea27ceebe0]],
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
    } --[[table: 0x02ea27ceed90]],
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
    } --[[table: 0x02ea27d19ad0]],
    name = "TestNode",
    type = "Node",
    visible = true
  } --[[table: 0x02ea27ceeb98]],
  sceneProperties = {
    camera = {
      pose = {
        0,
        1.7000000476837158,
        0,
        1,
        0.99999994039535522,
        1,
        2.8935310840606689,
        -0.054557215422391891,
        0.91475695371627808,
        0.40030393004417419
      } --[[table: 0x02ea27cfe1b8]],
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
      } --[[table: 0x02ea27cfe428]],
      view = {
        0,
        1.7000000476837158,
        0,
        1,
        0.99999994039535522,
        1,
        2.8935310840606689,
        -0.054557215422391891,
        0.91475695371627808,
        0.40030393004417419
      } --[[table: 0x02ea27cfe080]]
    } --[[table: 0x02ea2655a4a0]],
    defaults = {} --[[table: 0x02ea27cb6e48]],
    lightDepthTexArray_Views = {} --[[table: 0x02ea27cb7080]],
    lighting = {
      ambience = {
        0.0035294117406010628,
        0.0035294117406010628,
        0.0058823530562222004
      } --[[table: 0x02ea27caf0a0]]
    } --[[table: 0x02ea27caefe8]],
    passes = {} --[[table: 0x02ea27caf308]],
    root = {} --[[table: 0x02ea27ca21c0]],
    tempNodes = {} --[[table: 0x02ea2655a098]],
    timer = 2.3807065000000875
  } --[[table: 0x02ea2787a410]]
} --[[table: 0x02ea2787a3c8]]
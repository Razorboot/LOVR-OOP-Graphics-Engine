function lovr.conf(t)

  -- Set the project version and identity
  t.version = '0.16.0'
  t.identity = 'default'

  -- Set save directory precedence
  t.saveprecedence = true

  -- Enable or disable different modules
  t.modules.audio = true
  t.modules.data = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.headset = true
  t.modules.math = true
  t.modules.physics = true
  t.modules.system = true
  t.modules.thread = true
  t.modules.timer = true

  -- Audio
  t.audio.spatializer = nil
  t.audio.samplerate = 48000
  t.audio.start = true

  -- Graphics
  t.graphics.debug = false
  t.graphics.vsync = true
  t.graphics.stencil = false
  t.graphics.antialias = true
  t.graphics.shadercache = true

  -- Headset settings
  t.headset.drivers = { 'openxr', 'desktop' }
  t.headset.supersample = false
  t.headset.offset = 1.7
  t.headset.antialias = true
  t.headset.submitdepth = true
  t.headset.overlay = false

  -- Math settings
  t.math.globals = true

  -- Configure the desktop window
  t.window.width = 900
  t.window.height = 900
  t.window.fullscreen = false
  t.window.title = 'LÖVR'
  t.window.icon = nil
end
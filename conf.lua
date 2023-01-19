local Serpent = require "lovr_graphics_engine.libs.serpent"

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  local lines = {}
  local lines_str = ""
  for line in io.lines(file) do 
      lines[#lines + 1] = line
      lines_str = lines_str.." "..tostring(line)
  end
  return lines, lines_str
end

function lovr.conf(t)
  print(lovr.filesystem.getRealDirectory("main.lua").."/user_settings.lua")
  local lines_t, lines_str = lines_from(lovr.filesystem.getRealDirectory("main.lua").."/user_settings.lua")
  if #lines_t <= 0 then error("Save file either does not exist, is not a Lua file, or is empty.") return false end

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
  t.graphics.debug = true
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
  if lines_str and lines_str then
    t.window.width = lines_str.width
    t.window.height = lines_str.height
  else
    t.window.width = 900
    t.window.height = 900
  end
  t.window.fullscreen = false
  t.window.title = 'LÖVR'
  t.window.icon = nil
end
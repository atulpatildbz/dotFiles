dictate = require("dictate").start()

-- Reload automatically when a .lua file in ~/.hammerspoon changes.
configWatcher = hs.pathwatcher.new(hs.configdir, function(files)
  for _, f in ipairs(files) do
    if f:sub(-4) == ".lua" then return hs.reload() end
  end
end):start()

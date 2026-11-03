-- Offline dictation: ⌥Space to start, ⌥Space again to type what you said at the cursor.
-- Transcription runs in a resident helper (dictate-swift/) that keeps the model warm and
-- records the mic in-process, so a dictation costs only inference time. Engines match
-- superwhisper's offline models: Cohere Transcribe on MLX, Parakeet / Whisper on CoreML.

local M = {}

local HOME = os.getenv("HOME")
local BIN = HOME .. "/.hammerspoon/dictate-swift/bin/dictated"
local CACHE = HOME .. "/Library/Caches/qwen3-speech/models/"

-- Offline voice models, modelled on superwhisper's local model library.
-- speed / accuracy are 1-10 like superwhisper's catalog ratings.
-- keyFile marks a finished download inside the model's cache folder.
M.catalog = {
  {
    id = "aufklarer/Cohere-Transcribe-2B-MLX-5bit", name = "Cohere Transcribe",
    desc = "Cohere's 2B ASR model · 14 languages, state of the art accuracy, optimized for Apple Silicon.",
    speed = 8, accuracy = 10, size = 1.74e9, keyFile = "tokenizer.model",
  },
  {
    id = "aufklarer/Cohere-Transcribe-2B-MLX-8bit", name = "Cohere Transcribe (8-bit)",
    desc = "Same model at higher precision. Larger and a little slower, marginally more accurate.",
    speed = 7, accuracy = 10, size = 2.42e9, keyFile = "tokenizer.model",
  },
  {
    id = "aufklarer/Parakeet-TDT-v3-CoreML-INT8-30s", name = "Parakeet Multilanguage",
    desc = "Nvidia's speech recognition model with support for 25 languages (Parakeet V3).",
    speed = 10, accuracy = 8, size = 0.64e9, keyFile = "vocab.json",
  },
  {
    id = "aufklarer/Whisper-Large-v3-Turbo-CoreML", name = "Whisper Large v3 Turbo",
    desc = "Best Whisper accuracy, optimized for speed. 99 languages.",
    speed = 7, accuracy = 8, size = 1.64e9, keyFile = "tokenizer.json",
  },
}

local LANGUAGES = {
  { nil, "Auto (model default)" }, { "en", "English" }, { "de", "German" }, { "fr", "French" },
  { "es", "Spanish" }, { "it", "Italian" }, { "pt", "Portuguese" }, { "nl", "Dutch" },
  { "pl", "Polish" }, { "el", "Greek" }, { "ar", "Arabic" }, { "vi", "Vietnamese" },
  { "zh", "Chinese" }, { "ja", "Japanese" }, { "ko", "Korean" },
}

local function get(k, default)
  local v = hs.settings.get("dictate." .. k)
  if v == nil then return default end
  return v
end
local function set(k, v) hs.settings.set("dictate." .. k, v) end

local state = "idle"      -- idle | loading | recording | transcribing
local helper, menubar, escKey
local buffer = ""
local downloads = {}      -- model id -> percent
local loadedModel

local function byId(id)
  for _, m in ipairs(M.catalog) do if m.id == id then return m end end
end

local function isDownloaded(m)
  return downloads[m.id] == nil and hs.fs.attributes(CACHE .. m.id .. "/" .. m.keyFile) ~= nil
end

local function fmtSize(bytes)
  if bytes >= 1e9 then return string.format("%.1f GB", bytes / 1e9) end
  return string.format("%d MB", math.floor(bytes / 1e6 + 0.5))
end

local function dots(n) return string.rep("●", n // 2) .. string.rep("○", 5 - n // 2) end

local ICONS = { idle = "🎙", loading = "⏳", recording = "🔴", transcribing = "✍️" }

local function setState(s)
  state = s
  if menubar then menubar:setTitle(ICONS[state]) end
end

local function send(line)
  if helper and helper:isRunning() then helper:setInput(line .. "\n") end
end

local function play(name)
  local s = hs.sound.getByName(name)
  if s then s:volume(0.35):play() end
end

---------------------------------------------------------------------------
-- Helper process
---------------------------------------------------------------------------

local function loadSelected()
  local m = byId(get("model", M.catalog[1].id))
  if not m or not isDownloaded(m) then
    m = nil
    for _, candidate in ipairs(M.catalog) do
      if isDownloaded(candidate) then m = candidate; set("model", m.id); break end
    end
  end
  loadedModel = nil
  if not m then return setState("idle") end
  setState("loading")
  send("language " .. (get("language") or "auto"))
  send("load " .. m.id)
end

local function onEvent(ev)
  if ev.event == "ready" then
    loadSelected()
  elseif ev.event == "loaded" then
    loadedModel = ev.model
    if state == "loading" then setState("idle") end
    print(string.format("[dictate] loaded %s in %d ms", ev.model, ev.ms))
  elseif ev.event == "progress" then
    if downloads[ev.model] then downloads[ev.model] = ev.percent end
  elseif ev.event == "downloaded" then
    downloads[ev.model] = nil
    local m = byId(ev.model)
    hs.alert.show("Dictate: " .. (m and m.name or ev.model) .. " downloaded")
    if not loadedModel and state ~= "loading" then set("model", ev.model); loadSelected() end
  elseif ev.event == "text" then
    setState("idle")
    if ev.ms then print(string.format("[dictate] %.1fs audio -> %d ms", ev.audio_s, ev.ms)) end
    if ev.text and ev.text ~= "" then hs.eventtap.keyStrokes(ev.text) end
  elseif ev.event == "error" then
    print("[dictate] " .. ev.message)
    hs.alert.show("Dictate: " .. ev.message)
    for id in pairs(downloads) do
      if ev.message:find(id, 1, true) then downloads[id] = nil end
    end
    if state ~= "recording" then setState("idle") end
  end
end

local function startHelper()
  if not hs.fs.attributes(BIN) then
    hs.alert.show("Dictate: helper missing (see dictate-swift/build.sh)")
    return
  end
  buffer = ""
  helper = hs.task.new(BIN, function(code)
    print("[dictate] helper exited " .. tostring(code))
    helper, loadedModel, downloads = nil, nil, {}
    setState("idle")
  end, function(_, stdout, stderr)
    if stderr and #stderr > 0 then print("[dictate] " .. stderr) end
    buffer = buffer .. (stdout or "")
    while true do
      local line, rest = buffer:match("^(.-)\n(.*)$")
      if not line then break end
      buffer = rest
      local ok, ev = pcall(hs.json.decode, line)
      if ok and type(ev) == "table" then onEvent(ev) end
    end
    return true
  end)
  helper:start()
end

local function restartHelper()
  if helper then helper:terminate() end
  hs.timer.doAfter(0.5, startHelper)
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------

local function cancel()
  if state ~= "recording" then return end
  send("cancel")
  escKey:disable()
  setState("idle")
  play("Basso")
end

function M.toggle()
  if not helper or not helper:isRunning() then startHelper() end
  if state == "recording" then
    escKey:disable()
    setState("transcribing")
    send("stop")
    play("Pop")
  elseif state == "idle" then
    if not loadedModel then
      hs.alert.show("Dictate: download a voice model from the 🎙 menu")
      return
    end
    send("start " .. (get("deviceUID") or ""))
    setState("recording")
    escKey:enable()
    play("Tink")
  elseif state == "loading" then
    hs.alert.show("Dictate: model still loading…")
  end
end

---------------------------------------------------------------------------
-- Menu
---------------------------------------------------------------------------

local function modelMenu()
  local items = {}
  local selected = get("model")
  for _, m in ipairs(M.catalog) do
    local pct = downloads[m.id]
    local have = isDownloaded(m)
    local sub = {
      { title = m.desc, disabled = true },
      { title = "Speed " .. dots(m.speed) .. "   Accuracy " .. dots(m.accuracy), disabled = true },
      { title = "-" },
    }
    if pct then
      table.insert(sub, { title = "Cancel download", fn = function() downloads[m.id] = nil; restartHelper() end })
    elseif have then
      table.insert(sub, { title = "Use this model", disabled = selected == m.id, fn = function()
        set("model", m.id); loadSelected()
      end })
      table.insert(sub, { title = "Delete (" .. fmtSize(m.size) .. ")", fn = function()
        if selected == m.id then send("unload"); loadedModel = nil end
        hs.execute(string.format("rm -rf %q", CACHE .. m.id))
        if selected == m.id then loadSelected() end
      end })
    else
      table.insert(sub, { title = "Download (" .. fmtSize(m.size) .. ")", fn = function()
        if not helper or not helper:isRunning() then startHelper() end
        downloads[m.id] = 0
        send("download " .. m.id)
      end })
    end

    local suffix = ""
    if pct then suffix = string.format("  — downloading %d%%", pct)
    elseif not have then suffix = "  — " .. fmtSize(m.size) end
    table.insert(items, { title = m.name .. suffix, checked = have and selected == m.id, menu = sub })
  end
  return items
end

local function deviceMenu()
  local current = get("deviceUID")
  local default = hs.audiodevice.defaultInputDevice()
  local items = { {
    title = "System Default (" .. (default and default:name() or "none") .. ")",
    checked = current == nil,
    fn = function() set("deviceUID", nil); set("deviceName", nil) end,
  }, { title = "-" } }
  for _, dev in ipairs(hs.audiodevice.allInputDevices()) do
    local uid, name = dev:uid(), dev:name()
    table.insert(items, { title = name, checked = current == uid, fn = function()
      set("deviceUID", uid); set("deviceName", name)
    end })
  end
  return items
end

local function languageMenu()
  local current = get("language")
  local items = {}
  for _, l in ipairs(LANGUAGES) do
    table.insert(items, { title = l[2], checked = current == l[1], fn = function()
      set("language", l[1]); send("language " .. (l[1] or "auto"))
    end })
  end
  return items
end

local function buildMenu()
  local m = byId(get("model", ""))
  local status = ({
    idle = loadedModel and "Ready — ⌥Space to dictate" or "No model loaded",
    loading = "Loading " .. (m and m.name or "model") .. "…",
    recording = "Recording — ⌥Space to insert, Esc to cancel",
    transcribing = "Transcribing…",
  })[state]
  local lang = get("language")
  return {
    { title = status, disabled = true },
    { title = "-" },
    { title = "Voice Model: " .. (m and m.name or "none"), menu = modelMenu() },
    { title = "Input: " .. (get("deviceName") or "System Default"), menu = deviceMenu() },
    { title = "Language: " .. (lang or "Auto"), menu = languageMenu() },
    { title = "-" },
    { title = "Restart helper", fn = restartHelper },
  }
end

---------------------------------------------------------------------------

function M.start()
  menubar = hs.menubar.new()
  menubar:setMenu(buildMenu)
  setState("idle")
  escKey = hs.hotkey.new({}, "escape", cancel)
  hs.hotkey.bind({ "alt" }, "space", M.toggle)
  startHelper()
  return M
end

return M

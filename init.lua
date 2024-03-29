local _ = {
  hs.application,
  hs.caffeinate,
  hs.grid,
  hs.hotkey,
  hs.inspect,
  hs.json,
  hs.menubar,
  hs.task,
}
hs.loadSpoon("MiroWindowsManager")

local function get_caff_menu()
  if hs.caffeinate.get("displayIdle") then
    return {title = "caffeinate: on"}
  end
  return { title = "caffeinate: off" }
end
local mb = hs.menubar.new(true, "com.freemasen.hs-state")

local mem_usage = "??"
local function get_mem_usage()
  return {
    title = mem_usage,
  }
end

local page_size = 16384
hs.task.new("/usr/bin/vm_stat",
  function() print("EXITING!!!") end,
  function(task, std_out, std_err)
    local ps = string.match(std_out, "page size of (%d+) bytes")
    if ps then
      ps = tonumber(ps)
      if ps then
        print("updating page size from ", page_size, " to ", ps)
        page_size = ps
      else
        print("warning: ps wasn't a number!", ps)
      end
    end
    local results = {}
    for chunk in string.gmatch(std_out, "(%d+)") do
      table.insert(results, tonumber(chunk))
    end
    mem_usage = string.format("mem usage: %0.2f", (results[2] / (results[1] + results[2])) * 100) .. "%"
    return true
  end,
  {"10"}
):start()

mb:setTitle("hs.state")
mb:setMenu(function()
  local m = {
    get_caff_menu(),
    get_mem_usage(),
  }
  return m
end)

hs.hotkey.bind({"cmd"}, "T", function()
  hs.application.open("Terminal")
end)

hs.hotkey.bind({"cmd"}, "L", function()
  hs.caffeinate.lockScreen()
end)

hs.hotkey.bind({"cmd", "alt", "shift"}, "C", function()
  if hs.caffeinate.get("displayIdle") then
    hs.caffeinate.set("displayIdle", false)
  else
    hs.caffeinate.set("displayIdle", true)
  end
end)

local hyper = {"shift", "alt", "cmd"}


spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"},
})

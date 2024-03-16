local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'

local num = #LrApplication.developPresetFolders()
folders = LrApplication.developPresetFolders()

LrDialogs.message("Presets", "Found " .. num .. "presets", "info")
LrDialogs.message("Presets Values", LrApplication.developPresetFolders(), "info")
LrDialogs.message("LrApplication.developPresetManager()", LrApplication.developPresetManager(), "info")

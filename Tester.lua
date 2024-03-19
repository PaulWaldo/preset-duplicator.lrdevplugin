local Require = require "Require".path("/Users/paul/src/third-party/debuggingtoolkit.lrdevplugin").reload()
local Debug = require "Debug".init()
require "strict.lua"

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
local LrTasks = import 'LrTasks'

-- Function to get a list of available develop presets
local function getDevelopPresets()
    local folders = {}
    for _, folder in ipairs(LrApplication.developPresetFolders()) do
        local presets = {}
        local folderName = folder.getName()
        for _, preset in ipairs(folder.getDevelopPresets()) do
            folders[folderName] = folder.getDevelopPresets()
        end
    end
    return folders
end

-- Entry point of the plugin
LrTasks.startAsyncTask(Debug.showErrors(function()
    LrDialogs.message("getDevelopPresets", getDevelopPresets(), "info")
end))

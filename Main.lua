local Require = require "Require".path("/Users/paul/src/third-party/debuggingtoolkit.lrdevplugin").reload()
local Debug = require "Debug".init()
require "strict.lua"
-- Debug.pause()

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
-- local LrDevelopPresetFolder = import 'LrDevelopPresetFolder'
local LrTasks = import 'LrTasks'

-- Function to allow pretty-printing of a table
-- https://stackoverflow.com/a/6081639/1290460
local function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

-- Function to get a list of available develop presets
local function getDevelopPresets()
    local folders = {}
    for _, folder in ipairs(LrApplication.developPresetFolders()) do
        local presets = {}
        local folderName = folder:getName()
        for _, preset in ipairs(folder:getDevelopPresets()) do
            local folderData = {}
            folderData["name"] = preset:getName()
            folderData["uuid"] = preset:getUuid()
            folders[folderName] = folderData
        end
    end
    return folders
end

-- Function to prompt user to select presets
local function selectPresets()
    local presets = getDevelopPresets()

    -- Dialog UI definition
    local ui = {
        title = "Select Develop Presets",
        contents = {
            {
                type = "checkboxes",
                bind_to_object = "selectedPresets",
                title = "Select presets to apply:",
                items = presets
            }
        }
    }

    -- Show dialog
    local result = LrDialogs.presentModalDialog(ui)

    if result == "ok" then
        return selectedPresets
    else
        return nil
    end
end

-- Function to apply each preset to a new virtual copy
local function applyPresetsToVirtualCopies(selectedPresets, photo)
    local virtualCopies = {}

    for _, presetName in ipairs(selectedPresets) do
        local virtualCopy = photo:createVirtualCopy()
        LrDevelopController.applyDevelopPreset(presetName, virtualCopy)
        table.insert(virtualCopies, virtualCopy)
    end

    return virtualCopies
end

-- Function to group virtual copies into a stack
local function stackVirtualCopies(virtualCopies)
    if #virtualCopies < 2 then
        return
    end

    local stack = virtualCopies[1]:createPhotoStack()
    for i = 2, #virtualCopies do
        stack:addPhoto(virtualCopies[i])
    end
end

-- Main function to apply selected presets to the selected photo
local function applyPresetsToSelectedPhoto()
    local catalog = LrApplication.activeCatalog()
    Debug.pause()
    local targetPhoto = catalog:getTargetPhoto()

    if not targetPhoto then
        LrDialogs.showError("No photo selected.")
        return
    end

    local selectedPresets = selectPresets()

    if selectedPresets then
        local virtualCopies = applyPresetsToVirtualCopies(selectedPresets, targetPhoto)
        stackVirtualCopies(virtualCopies)
    end
end

-- Entry point of the plugin
LrTasks.startAsyncTask(Debug.showErrors(function()
    local x = getDevelopPresets()
    LrDialogs.message("getDevelopPresets", serializeTable(x), "info")
    -- Debug.pause()
    applyPresetsToSelectedPhoto()
end))

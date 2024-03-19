local Require = require "Require".path("/Users/paul/src/third-party/debuggingtoolkit.lrdevplugin").reload()
local Debug = require "Debug".init()
require "strict.lua"

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
local LrTasks = import 'LrTasks'

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

-- Entry point of the plugin
LrTasks.startAsyncTask(Debug.showErrors(function()
    local x = getDevelopPresets()
    LrDialogs.message("getDevelopPresets", serializeTable(x), "info")
end))

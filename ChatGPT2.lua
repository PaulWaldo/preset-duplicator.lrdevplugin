local Require = require "Require".path("/Users/paul/src/third-party/debuggingtoolkit.lrdevplugin").reload()
local Debug = require "Debug".init()
require "strict.lua"

-- Define Lightroom SDK
-- local Lr = import 'Lr'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrApplication = import 'LrApplication'
local LrView = import 'LrView'

-- Get active catalog
-- local catalog = LrApplication.activeCatalog()

-- Function to get all develop presets
local function getAllDevelopPresets()
    local presets = {}
    local presetFolders = LrApplication.developPresetFolders()

    for _, folder in ipairs(LrApplication.developPresetFolders()) do
        for _, preset in ipairs(folder:getDevelopPresets()) do
            table.insert(presets, { folder = folder, preset = preset })
        end
    end
    -- Debug.pause()
    -- for _, folder in ipairs(presetFolders) do
    --     local folderPresets = folder:getDevelopPresets()
    --     for _, preset in ipairs(folderPresets) do
    --         table.insert(presets, { folder = folder, preset = preset })
    --     end
    -- end

    return presets
end

-- Function to display UI and get user selection
local function showPresetSelectionDialog()
    local presets = getAllDevelopPresets()
    -- Debug.pause()

    if #presets == 0 then
        LrDialogs.message("No develop presets found.", "There are no develop presets available.", "info")
        return nil
    end

    local dialogSections = {}
    local currentSection = nil

    -- Group presets by folder
    for _, preset in ipairs(presets) do
        if not currentSection or currentSection.title ~= preset.folder:getName() then
            currentSection = { title = preset.folder:getName(), presets = {} }
            table.insert(dialogSections, currentSection)
        end
        table.insert(currentSection.presets, preset)
    end

    local f = LrView.osFactory()
    local contents = {}
    for _, section in ipairs(dialogSections) do
        table.insert(contents, {
            title = section.title,
            view = f:column(section.presets)
        })
    end
    -- local headers = {}
    -- for i = 1, 10 do
    --     table.insert(headers,
    --         f:static_text { title = "nbnbnnbnb" })
    -- end

    -- table.insert(contents, f:row {
    --     headers,
    -- })
    contents = f:column(headers)

    Debug.pause()
    local result = LrDialogs.presentModalDialog({
        title = "Select Develop Presets",
        -- contents = f:view(contents),
        contents = contents,
        buttons = {
            { title = "OK",     action = "ok" },
            { title = "Cancel", action = "cancel" }
        }
    })

    -- if result == "ok" then
    --     local selectedPresets = {}
    --     for _, section in ipairs(dialogSections) do
    --         for _, preset in ipairs(section.presets) do
    --             if preset.selected then
    --                 table.insert(selectedPresets, preset.preset)
    --             end
    --         end
    --     end
    --     return selectedPresets
    -- end

    return nil
end

-- Main function to run the plugin
local function main()
    local selectedPresets = showPresetSelectionDialog()

    if selectedPresets then
        -- Save selected presets or apply them to photos
        -- This part can be implemented according to the specific requirements
        -- For demonstration purposes, we are just printing the selected presets
        -- print("Selected presets:")
        for _, preset in ipairs(selectedPresets) do
            -- print(preset:getName())
        end
    else
        -- print("No presets selected.")
    end
end

-- Run the plugin
LrTasks.startAsyncTask(main)

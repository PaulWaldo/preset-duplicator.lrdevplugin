-- /usr/local/bin/code --goto {file}:{line} --reuse-window
-- open "{file}" -a TextEdit
local Require = require "Require".path("/Users/paul/src/third-party/debuggingtoolkit.lrdevplugin").reload()
local Debug = require "Debug".init()
require "strict.lua"

-- Define Lightroom SDK
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrApplication = import 'LrApplication'
local LrView = import 'LrView'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDevelopController = import 'LrDevelopController'
local bind = LrView.bind

-- Get active catalog
-- local catalog = LrApplication.activeCatalog()

-- Function to get all develop presets
local function getAllDevelopPresetsByFolder(folders)
    -- local folders = {}
    local numPresets = 0
    -- local folders = LrApplication.developPresetFolders()
    for i, folder in ipairs(LrApplication.developPresetFolders()) do
        numPresets = numPresets + #folder:getDevelopPresets()
        local folderPresets = {}
        Debug.lognpp("Preset Folder:", folder:getName())
        for _, preset in ipairs(folder:getDevelopPresets()) do
            Debug.lognpp("Preset:", preset:getName())
            table.insert(folderPresets, { selected = false, preset = preset })
        end
        table.insert(folder, { presets = folderPresets })
        folders[i] = { name = folder:getName(), folder = folder, presets = folderPresets }
    end
    -- Debug.pause()
    Debug.lognpp("All Presets", folders)
    return numPresets, folders
end

-- Debug.pause()
-- local numPresets, presetsByFolder = getAllDevelopPresetsByFolder()

-- Function to display UI and get user selection
local function showPresetSelectionDialog()
    LrFunctionContext.callWithContext("PresetSelection", function(context)
        local props = LrBinding.makePropertyTable(context)
        getAllDevelopPresetsByFolder(props)
        -- if numPresets == 0 then
        --     LrDialogs.message("No develop presets found.", "There are no develop presets available.", "info")
        --     return nil
        -- end

        local dialogSections = {}
        local currentSection = nil
        local f = LrView.osFactory()
        local contents = f:column {}
        Debug.pause()
        local presetsByFolder = props["< contents >"]
        for _, folder in ipairs(presetsByFolder) do
            local header = f:row { f:static_text { title = folder.name } }
            table.insert(contents, header)
            -- Debug.pause()
            for _, preset in ipairs(folder.presets) do
                table.insert(contents, f:row {
                    bind_to_object = preset,
                    f:static_text { title = preset.preset:getName() },
                    f:checkbox {
                        -- title = "Value will be string",
                        value = bind 'selected', -- bind to the key value
                        -- checked_value = true,          -- this is the initial state
                        -- unchecked_value = false,       -- when the user unchecks the box,
                    },
                })
            end
        end
        -- Debug.pause()

        local result = LrDialogs.presentModalDialog({
            title = "Select Develop Presets",
            -- contents = f:view(contents),
            contents = f:scrolled_view(contents),
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

        return presetsByFolder
    end)
end

local function applyPresetsToSelectedPhoto()
    LrTasks.startAsyncTask(function()
        local catalog = LrApplication.activeCatalog()
        local targetPhoto = catalog:getTargetPhoto()

        if not targetPhoto then
            LrDialogs.showError("No photo selected.")
            return
        end

        -- local selectedPresets = selectPresets()
        local selectedPresets = nil
        for i, folder in ipairs(LrApplication.developPresetFolders()) do
            if folder:getName() == "Style: Black & White" then
                selectedPresets = folder:getDevelopPresets()
            end
        end

        if selectedPresets then
            -- Apply each selected preset
            for _, preset in ipairs(selectedPresets) do
                local presetName = preset:getName()
                local virtualCopies = catalog:createVirtualCopies("Test:" .. presetName)
                -- Debug.pause()
                catalog:withWriteAccessDo("My Action", function(context)
                    for _, copy in ipairs(virtualCopies) do
                        copy:applyDevelopPreset(preset)
                    end
                end)
            end
        end
    end, "applyPresetsToSelectedPhoto")
end

-- Main function to run the plugin
local function main()
    -- local selectedPresets = showPresetSelectionDialog()
    -- Debug.logn("Selected presets:", selectedPresets)

    -- if selectedPresets then
    --     -- Save selected presets or apply them to photos
    --     -- This part can be implemented according to the specific requirements
    --     -- For demonstration purposes, we are just printing the selected presets
    --     -- print("Selected presets:")
    --     for _, preset in ipairs(selectedPresets) do
    --         -- print(preset:getName())
    --     end
    -- else
    --     -- print("No presets selected.")
    -- end
    applyPresetsToSelectedPhoto()
end

-- Run the plugin
LrTasks.startAsyncTask(main)

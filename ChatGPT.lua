local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
local LrTasks = import 'LrTasks'

-- Function to get a list of available develop presets
local function getDevelopPresets()
    local presets = {}
    for _, preset in ipairs(LrApplication.developPresetManager():getPresets()) do
        table.insert(presets, preset:getName())
    end
    return presets
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

-- Main function to apply selected presets to the selected photo
local function applyPresetsToSelectedPhoto()
    local catalog = LrApplication.activeCatalog()
    local targetPhoto = catalog:getTargetPhoto()

    if not targetPhoto then
        LrDialogs.showError("No photo selected.")
        return
    end

    local selectedPresets = selectPresets()

    if selectedPresets then
        -- Apply each selected preset
        for _, presetName in ipairs(selectedPresets) do
            LrDevelopController.applyDevelopPreset(presetName)
        end
    end
end

-- Entry point of the plugin
LrTasks.startAsyncTask(function()
    applyPresetsToSelectedPhoto()
end)

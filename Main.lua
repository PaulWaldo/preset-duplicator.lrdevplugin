local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
-- local LrDevelopPresetFolder = import 'LrDevelopPresetFolder'
local LrTasks = import 'LrTasks'

-- Function to get a list of available develop presets
local function getDevelopPresets()
    LrDialogs.message("LrDevelopPresetFolders()",
        LrApplication.LrDevelopPresetFolders(), "info")

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
LrTasks.startAsyncTask(function()
    applyPresetsToSelectedPhoto()
end)
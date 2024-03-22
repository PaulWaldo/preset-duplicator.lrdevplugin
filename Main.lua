-- open "{file}" -a TextEdit
local Require = require "Require".path("/Users/paul/src/third-party/debuggingtoolkit.lrdevplugin").reload()
local Debug = require "Debug".init()
require "strict.lua"
Debug.pauseIfAsked()

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
-- local LrDevelopPresetFolder = import 'LrDevelopPresetFolder'
local LrTasks = import 'LrTasks'
local LrFunctionContext = import 'LrFunctionContext'

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
    -- Debug.pause()
    for _, folder in ipairs(LrApplication.developPresetFolders()) do
        local a = folder:getName()
        local b = folder:getDevelopPresets()
        local c = { selected = false, presets = folder:getDevelopPresets() }
        folders[folder:getName()] = { selected = false, presets = folder:getDevelopPresets() }
        -- local presets = {}
        -- local folderName = folder:getName()
        -- for _, preset in ipairs(folder:getDevelopPresets()) do
        --     -- local folderData = {}
        --     -- folderData["name"] = preset:getName()
        --     -- folderData["uuid"] = preset:getUuid()
        --     folders[folderName] = folderData
        -- end
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
local function applyPresetsToSelectedPhoto(presetFolders)
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

local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrColor = import 'LrColor'

-- Create the logger and enable the print function.

-- local myLogger = LrLogger('libraryLogger')
-- myLogger:enable("print") -- Pass either a string or a table of actions.

-- Write trace information to the logger.

-- local function outputToLog(message)
--     myLogger:trace(message)
-- end
local presetFolders = getDevelopPresets()
Debug.pause()
--[[
	Demonstrates a custom dialog with a simple binding. The dialog has a text field
	that is used to update a value in an observable table.  The table has an observer
	attached that will be notified when a key value is updated.  The observer is
	only interested in the props.myObservedString.  When that value changes the
	observer will be notified.
]]
local function showCustomDialogWithObserver(presets)
    LrFunctionContext.callWithContext("showCustomDialogWithObserver", function(context)
        -- Create a bindable table.  Whenever a field in this table changes then notifications
        -- will be sent.  Note that we do NOT bind this to the UI.

        local props = LrBinding.makePropertyTable(context)
        props.selected = true

        local f = LrView.osFactory()

        -- Create the UI components like this so we can access the values as vars.
        Debug.pauseIfAsked()
        local c = {}
        Debug.pause()
        for k, presetsByFolder in pairs(presetFolders) do
            props.folder = presetsByFolder.name
            props.selected = presetsByFolder.selected
            -- local staticTextValue = f:static_text {
            --     title = props.myObservedString,
            -- }

            -- local updateField = f:edit_field {
            --     immediate = true,
            --     value = "Enter some text!!"
            -- }

            -- This is the function that will run when the value props.myString is changed.

            local function myCalledFunction()
                outputToLog("props.myObservedString has been updated.")
                staticTextValue.title = updateField.value
                staticTextValue.text_color = LrColor(1, 0, 0)
            end

            -- Add an observer to the property table.  We pass in the key and the function
            -- we want called when the value for the key changes.
            -- Note:  Only when the value changes will there be a notification sent which
            -- causes the function to be invoked.

            props:addObserver("myObservedString", myCalledFunction)

            -- Create the contents for the dialog.
            -- local c = f:row {}

            c = f:column {
                spacing = f:dialog_spacing(),
                f:row {
                    fill_horizontal = 1,
                    f:static_text {
                        alignment = "right",
                        width = LrView.share "label_width",
                        title = "Bound value: "
                    },
                    staticTextValue,
                }, -- end f:row

                f:row {
                    f:static_text {
                        alignment = "right",
                        width = LrView.share "label_width",
                        title = "New value: "
                    },
                    updateField,
                    f:push_button {
                        title = "Update",

                        -- When the 'Update' button is clicked.

                        action = function()
                            outputToLog("Update button clicked.")
                            staticTextValue.text_color = LrColor(0, 0, 0)

                            -- When this property is updated, the observer is notified.

                            props.myObservedString = updateField.value
                        end
                    },
                }, -- end row
            }      -- end column
        end

        LrDialogs.presentModalDialog {
            title = "Custom Dialog Observer",
            contents = c
        }
    end) -- end main function
end

-- Now display the dialogs.
Debug.pauseIfAsked()
showCustomDialogWithObserver()

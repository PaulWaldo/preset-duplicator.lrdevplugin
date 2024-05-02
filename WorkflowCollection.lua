local LrDialogs = import 'LrDialogs'
-- local LrTasks = import 'LrTasks'
local LrApplication = import 'LrApplication'
local LrView = import 'LrView'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
-- local LrDevelopController = import 'LrDevelopController'
-- local bind = LrView.bind

local function showDialog()
    LrFunctionContext.callWithContext("WorkflowCollection", function (context)
        local catalog = LrApplication.activeCatalog()
        local targetPhoto = catalog:getTargetPhoto()
        if not targetPhoto then
            LrDialogs.showError("No photo selected.")
            return
        end
        
        local f = LrView.osFactory()
        local props = LrBinding.makePropertyTable(context)
    end)
end

showDialog()

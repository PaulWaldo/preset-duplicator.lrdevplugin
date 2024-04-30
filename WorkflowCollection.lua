-- local LrDialogs = import 'LrDialogs'
-- local LrTasks = import 'LrTasks'
-- local LrApplication = import 'LrApplication'
-- local LrView = import 'LrView'
local LrFunctionContext = import 'LrFunctionContext'
-- local LrBinding = import 'LrBinding'
-- local LrDevelopController = import 'LrDevelopController'
-- local bind = LrView.bind

local function showDialog()
    LrFunctionContext.callWithContext("WorkflowCollection", function(context)
    end)
end

showDialog()

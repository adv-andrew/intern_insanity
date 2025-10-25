--!strict
-- Client initialization script

local CameraController = require(script.CameraController)
local TaskManager = require(script.TaskManager)

-- Start the top-down camera controller
CameraController.start()

-- Start the task system
task.spawn(function()
    TaskManager.start()
end)

--!strict
-- Client initialization script

local CameraController = require(script.CameraController)
local TaskManager = require(script.TaskManager)

print("Client initializing...")

-- Start the top-down camera controller
CameraController.start()

print("Top-down camera enabled!")

-- Start the task system (spawns tasks every 30 seconds)
task.spawn(function()
    TaskManager.start()
end)

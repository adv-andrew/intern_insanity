-- Server initialization
local TaskManager = require(script.TaskManager)

-- Start the task manager in a separate thread
task.spawn(function()
    TaskManager.start()
end)

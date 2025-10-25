-- Server initialization
print("[Server] Initializing...")

local TaskManager = require(script.TaskManager)

-- Start the task manager in a separate thread
task.spawn(function()
    TaskManager.start()
end)

print("[Server] Initialization complete!")

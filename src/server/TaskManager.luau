-- ServerScriptService/Server/TaskManager.luau
-- Server-side task manager that selects tasks and replicates to all clients

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules to load
local Shared = ReplicatedStorage:WaitForChild("Shared")
local TaskRegistry = require(Shared:WaitForChild("TaskRegistry"))
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

local TaskManager = {}

-- Configuration
local TASK_SPAWN_INTERVAL = 5 -- seconds between task spawns

-- Level 1 hardcoded task sequence
local LEVEL_1_TASKS = {
    "PrinterJam",
    "AWSOutage",
    "CoworkerConflict",
    "FixBugQuiz",
}

local taskCount = 0

-- Spawns a task and sends it to all clients
local function spawnTask()
    taskCount = taskCount + 1

    -- Get the task ID for this level
    local taskId = LEVEL_1_TASKS[taskCount]

    -- Get the task from registry
    local selectedTask = TaskRegistry.getTaskById(taskId)

    if selectedTask then
        -- Fire to all clients with task data
        RemoteEvents.SpawnTask:FireAllClients(selectedTask)
    else
        warn("[Server] Task not found:", taskId)
    end
end

function TaskManager.start()
    -- Spawn first task immediately
    spawnTask()

    -- Spawn remaining tasks with 5-second intervals
    for i = 2, #LEVEL_1_TASKS do
        task.wait(TASK_SPAWN_INTERVAL)
        spawnTask()
    end
end

return TaskManager

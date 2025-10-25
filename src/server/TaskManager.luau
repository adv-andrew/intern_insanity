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
local MAX_TASKS = 4 -- total number of tasks to spawn

local taskCount = 0

-- Spawns a task and sends it to all clients
local function spawnTask()
    taskCount = taskCount + 1

    -- Select a random task from the registry
    local selectedTask = TaskRegistry.getRandomTask()

    print(
        string.format(
            "[Server] Spawning task %d/%d: %s (%s)",
            taskCount,
            MAX_TASKS,
            selectedTask.name,
            selectedTask.category
        )
    )
    print("[Server] Task data:", selectedTask.id, selectedTask.emoji, selectedTask.description)
    print("[Server] RemoteEvent reference:", RemoteEvents.SpawnTask)

    -- Fire to all clients with task data
    RemoteEvents.SpawnTask:FireAllClients(selectedTask)
    print("[Server] ✓ Fired RemoteEvent to all clients")
end

function TaskManager.start()
    print("[Server] TaskManager starting - will spawn 4 tasks at 30-second intervals")

    -- Spawn first task immediately
    spawnTask()

    -- Spawn remaining 3 tasks with 30-second intervals
    for i = 2, MAX_TASKS do
        task.wait(TASK_SPAWN_INTERVAL)
        spawnTask()
    end

    print(
        string.format(
            "[Server] All %d tasks have been spawned. TaskManager complete.",
            MAX_TASKS
        )
    )
end

return TaskManager

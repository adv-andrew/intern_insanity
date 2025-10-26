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

-- Level 1 hardcoded task sequence (first 4 tasks spawn on timer, 5th spawns on completion)
local LEVEL_1_TASKS = {
    "PrinterJam",
    "AWSOutage",
    "CoworkerConflict",
    "FixBugQuiz",
}

local TASK_5_ID = "TalkToBoss" -- 5th task spawns only after task 4 completion

local taskCount = 0
local task5Spawned = false

-- Spawns a task and sends it to all clients
local function spawnTask(taskId: string)
    -- Get the task from registry
    local selectedTask = TaskRegistry.getTaskById(taskId)

    if selectedTask then
        -- Fire to all clients with task data
        RemoteEvents.SpawnTask:FireAllClients(selectedTask)
        print("[Server] Spawned task:", taskId)
    else
        warn("[Server] Task not found:", taskId)
    end
end

function TaskManager.start()
    -- Spawn first 4 tasks on a timer
    for i = 1, #LEVEL_1_TASKS do
        if i == 1 then
            -- Spawn first task immediately
            spawnTask(LEVEL_1_TASKS[i])
        else
            -- Spawn remaining tasks with 5-second intervals
            task.wait(TASK_SPAWN_INTERVAL)
            spawnTask(LEVEL_1_TASKS[i])
        end
    end

    -- Listen for task completion to spawn the 5th task
    RemoteEvents.TaskCompleted.OnServerEvent:Connect(function(player, completedTaskId)
        print("[Server] Task completed by", player.Name, ":", completedTaskId)

        -- Spawn task 5 only after task 4 (FixBugQuiz) is completed
        if completedTaskId == "FixBugQuiz" and not task5Spawned then
            task5Spawned = true
            task.wait(2) -- Small delay before spawning the final task
            spawnTask(TASK_5_ID)
        end
    end)
end

return TaskManager

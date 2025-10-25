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
local availableCategories = { "OfficeMovement", "MentalBreaks", "SocialTasks", "TechTasks" }
local shuffledCategories = {}

-- Shuffle the categories array for this game session
local function shuffleCategories()
    shuffledCategories = {}
    local tempCategories = { unpack(availableCategories) }

    while #tempCategories > 0 do
        local randomIndex = math.random(1, #tempCategories)
        table.insert(shuffledCategories, tempCategories[randomIndex])
        table.remove(tempCategories, randomIndex)
    end
end

-- Spawns a task and sends it to all clients
local function spawnTask()
    taskCount = taskCount + 1

    -- Get the category for this task (ensuring no duplicates)
    local category = shuffledCategories[taskCount]

    -- Select a random task from that category
    local selectedTask = TaskRegistry.getRandomTaskByCategory(category)

    -- Fire to all clients with task data
    RemoteEvents.SpawnTask:FireAllClients(selectedTask)
end

function TaskManager.start()
    -- Shuffle categories to ensure no duplicates
    shuffleCategories()

    -- Spawn first task immediately
    spawnTask()

    -- Spawn remaining 3 tasks with 5-second intervals
    for i = 2, MAX_TASKS do
        task.wait(TASK_SPAWN_INTERVAL)
        spawnTask()
    end
end

return TaskManager

--!strict
-- TaskManager: Spawns tasks every 30 seconds like Overcooked

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TaskManager = {}

local TASK_SPAWN_INTERVAL = 30 -- seconds
local currentTaskCount = 0

-- Spawn a new task frame
local function spawnTask()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Get references
    local mainGui = playerGui:WaitForChild("MainGui")
    local tasksContainer = mainGui:WaitForChild("Tasks")
    local taskTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("TaskFrame")

    -- Clone the task frame
    local newTask = taskTemplate:Clone()

    -- Increment layout order for each new task
    currentTaskCount = currentTaskCount + 1
    newTask.LayoutOrder = currentTaskCount

    -- Parent to the Tasks container
    newTask.Parent = tasksContainer

    print(`Task #{currentTaskCount} spawned!`)
end

-- Start the task spawning system
function TaskManager.start()
    print("TaskManager started - tasks will spawn every 30 seconds")

    -- Spawn first task immediately
    spawnTask()

    -- Then spawn a new task every 30 seconds
    while true do
        task.wait(TASK_SPAWN_INTERVAL)
        spawnTask()
    end
end

return TaskManager

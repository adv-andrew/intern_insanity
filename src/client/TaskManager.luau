--!strict
-- TaskManager: Client-side task receiver and display manager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local TaskRegistry = require(Shared:WaitForChild("TaskRegistry"))
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

local TaskManager = {}

local currentTaskCount = 0

-- Spawn and populate a task frame with server-provided task data
local function spawnTask(taskData: TaskRegistry.Task)
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
    newTask.Name = "Task_" .. currentTaskCount

    -- Populate task frame with data
    local titleLabel = newTask:FindFirstChild("TaskTitle") :: TextLabel
    local descLabel = newTask:FindFirstChild("TaskDescription") :: TextLabel

    if titleLabel then
        titleLabel.Text = string.format("%s %s", taskData.emoji, taskData.name)
    end

    if descLabel then
        descLabel.Text = string.format(
            "%s - %ds",
            taskData.description,
            taskData.timeToComplete
        )
    end

    -- Parent to the Tasks container
    newTask.Parent = tasksContainer
end

-- Start listening for server task spawns
function TaskManager.start()
    -- Listen for task spawn events from server
    RemoteEvents.SpawnTask.OnClientEvent:Connect(function(taskData: TaskRegistry.Task)
        spawnTask(taskData)
    end)
end

return TaskManager

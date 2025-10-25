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
    print("[Client] spawnTask() called with data:", taskData.name)

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    print("[Client] PlayerGui found:", playerGui)

    -- Get references
    local mainGui = playerGui:WaitForChild("MainGui")
    print("[Client] MainGui found:", mainGui)

    -- Debug: Print all children of MainGui
    print("[Client] MainGui children:")
    for _, child in ipairs(mainGui:GetChildren()) do
        print("  -", child.Name, child.ClassName)
    end

    local tasksContainer = mainGui:FindFirstChild("Tasks")
    if not tasksContainer then
        warn("[Client] ERROR: Tasks container not found in MainGui!")
        warn("[Client] Make sure Rojo has synced src/gui/MainGui.json properly")
        return
    end
    print("[Client] Tasks container found:", tasksContainer)

    local assets = ReplicatedStorage:WaitForChild("Assets")
    print("[Client] Assets folder found:", assets)

    local taskTemplate = assets:WaitForChild("TaskFrame")
    print("[Client] TaskFrame template found:", taskTemplate)

    -- Clone the task frame
    local newTask = taskTemplate:Clone()
    print("[Client] Cloned new task frame:", newTask)

    -- Increment layout order for each new task
    currentTaskCount = currentTaskCount + 1
    newTask.LayoutOrder = currentTaskCount
    newTask.Name = "Task_" .. currentTaskCount
    print("[Client] Set LayoutOrder to:", currentTaskCount)

    -- Populate task frame with data
    local titleLabel = newTask:FindFirstChild("TaskTitle") :: TextLabel
    local descLabel = newTask:FindFirstChild("TaskDescription") :: TextLabel

    print("[Client] TitleLabel found:", titleLabel)
    print("[Client] DescLabel found:", descLabel)

    if titleLabel then
        titleLabel.Text = string.format("%s %s", taskData.emoji, taskData.name)
        print("[Client] Set title to:", titleLabel.Text)
    else
        warn("[Client] TaskTitle not found in cloned frame!")
    end

    if descLabel then
        descLabel.Text = string.format(
            "%s - %ds",
            taskData.description,
            taskData.timeToComplete
        )
        print("[Client] Set description to:", descLabel.Text)
    else
        warn("[Client] TaskDescription not found in cloned frame!")
    end

    -- Parent to the Tasks container
    newTask.Parent = tasksContainer
    print("[Client] Parented task frame to Tasks container")

    print(
        string.format(
            "[Client] ✓ Task #%d successfully spawned: %s (%ds) - Visible: %s",
            currentTaskCount,
            taskData.name,
            taskData.timeToComplete,
            tostring(newTask.Visible)
        )
    )
end

-- Start listening for server task spawns
function TaskManager.start()
    print("[Client] TaskManager started - listening for server tasks")
    print("[Client] RemoteEvent reference:", RemoteEvents.SpawnTask)

    -- Listen for task spawn events from server
    RemoteEvents.SpawnTask.OnClientEvent:Connect(function(taskData: TaskRegistry.Task)
        print("[Client] ⚡ RemoteEvent fired! Received task data from server")
        print("[Client] Task ID:", taskData.id)
        print("[Client] Task Name:", taskData.name)
        print("[Client] Task Category:", taskData.category)

        spawnTask(taskData)
    end)

    print("[Client] RemoteEvent listener connected successfully")
end

return TaskManager

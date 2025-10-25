--!strict
-- TaskManager: Client-side task receiver and display manager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local TaskRegistry = require(Shared:WaitForChild("TaskRegistry"))
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

local DoorHighlight = require(script.Parent.DoorHighlight)
local RoomDetection = require(script.Parent.RoomDetection)

local TaskManager = {}

local currentTaskCount = 0
local selectedTask = nil -- Track currently selected task
local selectedTaskData = nil -- Track the task data of selected task
local allTaskFrames = {} -- Store all task frames for unselecting
local taskFrameToData = {} -- Map task frames to their task data

-- Colors
local SELECTED_COLOR = Color3.fromRGB(52, 152, 219) -- Blue
local DEFAULT_TASK_COLOR = Color3.fromRGB(255, 255, 255) -- Default dark gray
local DEFAULT_ICON_COLOR = Color3.fromRGB(255, 255, 255) -- Default icon background

-- Auto-select a task
local function autoSelectTask(taskFrame, taskData)
    local icon = taskFrame:FindFirstChild("Icon")

    -- Unselect all tasks first
    for _, frame in ipairs(allTaskFrames) do
        frame.BackgroundColor3 = DEFAULT_TASK_COLOR
        local frameIcon = frame:FindFirstChild("Icon")
        if frameIcon then
            frameIcon.BackgroundColor3 = DEFAULT_ICON_COLOR
        end
    end

    -- Select this task
    taskFrame.BackgroundColor3 = SELECTED_COLOR
    if icon then
        icon.BackgroundColor3 = SELECTED_COLOR
    end

    selectedTask = taskFrame
    selectedTaskData = taskData

    -- Update door highlighting based on first objective
    if taskData.objectives and #taskData.objectives > 0 then
        local firstObjective = taskData.objectives[1]
        DoorHighlight.updateHighlight(firstObjective.room, firstObjective.objectModel)
    else
        DoorHighlight.clear()
    end
end

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
    local container = newTask:FindFirstChild("Container")
    local icon = newTask:FindFirstChild("Icon")

    if container then
        local descLabel = container:FindFirstChild("TextLabel") :: TextLabel
        if descLabel then
            descLabel.Text = taskData.description
        end
    end

    if icon then
        local emojiLabel = icon:FindFirstChild("Emoji") :: TextLabel
        if emojiLabel then
            emojiLabel.Text = taskData.emoji
        end
    end

    -- Parent to the Tasks container
    newTask.Parent = tasksContainer

    -- Store task frame reference
    table.insert(allTaskFrames, newTask)
    taskFrameToData[newTask] = taskData

    -- Auto-select if this is the first task and no task is currently selected
    if currentTaskCount == 1 and not selectedTask then
        autoSelectTask(newTask, taskData)
    end

    -- Setup selection button
    local selectButton = newTask:FindFirstChild("SelectButton")
    if selectButton then
        selectButton.Activated:Connect(function()
            autoSelectTask(newTask, taskData)
        end)
    end

    -- Start the timer for this task
    local timeRemaining = taskData.timeToComplete
    local totalTime = taskData.timeToComplete

    task.spawn(function()
        local timeBar = newTask:FindFirstChild("TimeBar")
        local bar = timeBar and timeBar:FindFirstChild("Bar") :: Frame

        -- Define colors for the gradient
        local greenColor = Color3.fromRGB(51, 255, 136) -- Green
        local yellowColor = Color3.fromRGB(241, 196, 15) -- Yellow
        local redColor = Color3.fromRGB(231, 76, 60) -- Red

        while timeRemaining > 0 do
            task.wait(0.1) -- Update every 0.1 seconds
            timeRemaining = timeRemaining - 0.1

            if bar then
                -- Update bar size based on time remaining
                local progress = math.max(0, timeRemaining / totalTime)
                bar.Size = UDim2.new(progress, 0, 1, 0)

                -- Update bar color based on progress
                local barColor
                if progress > 0.5 then
                    -- Interpolate between green and yellow (100% to 50%)
                    local t = (progress - 0.5) / 0.5 -- Normalize to 0-1 range
                    barColor = yellowColor:Lerp(greenColor, t)
                else
                    -- Interpolate between red and yellow (50% to 0%)
                    local t = progress / 0.5 -- Normalize to 0-1 range
                    barColor = redColor:Lerp(yellowColor, t)
                end

                bar.BackgroundColor3 = barColor
            end
        end

        -- Task time expired
        if bar then
            bar.Size = UDim2.new(0, 0, 1, 0)
            bar.BackgroundColor3 = redColor
        end
    end)
end

-- Start listening for server task spawns
function TaskManager.start()
    -- Listen for task spawn events from server
    RemoteEvents.SpawnTask.OnClientEvent:Connect(function(taskData: TaskRegistry.Task)
        spawnTask(taskData)
    end)

    -- Update door highlighting when room changes
    RunService.Heartbeat:Connect(function()
        if selectedTaskData and selectedTaskData.objectives and #selectedTaskData.objectives > 0 then
            local firstObjective = selectedTaskData.objectives[1]
            DoorHighlight.updateHighlight(firstObjective.room, firstObjective.objectModel)
        end
    end)
end

-- Get the currently selected task frame
function TaskManager.getSelectedTask()
    return selectedTask
end

return TaskManager

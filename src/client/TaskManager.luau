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
local TaskBehaviors = require(script.Parent.TaskBehaviors)
local FadeController = require(script.Parent.FadeController)

local TaskManager = {}

local currentTaskCount = 0
local selectedTask = nil -- Track currently selected task
local selectedTaskData = nil -- Track the task data of selected task
local allTaskFrames = {} -- Store all task frames for unselecting
local taskFrameToData = {} -- Map task frames to their task data
local taskFrameToTimeState = {} -- Map task frames to their time state
local currentObjectiveIndex = 1 -- Track which objective the player is on
local playerPassed = true -- Track if player has passed all tasks (fails if any wrong answer)

-- Colors
local SELECTED_COLOR = Color3.fromRGB(52, 152, 219) -- Blue
local DEFAULT_TASK_COLOR = Color3.fromRGB(255, 255, 255) -- Default dark gray
local DEFAULT_ICON_COLOR = Color3.fromRGB(255, 255, 255) -- Default icon background

-- Update the objective description UI
local function updateObjectiveDescription()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local mainGui = playerGui:WaitForChild("MainGui")
    local descriptionLabel = mainGui:FindFirstChild("Description")

    if descriptionLabel then
        if selectedTaskData and selectedTaskData.objectives and currentObjectiveIndex <= #selectedTaskData.objectives then
            local currentObjective = selectedTaskData.objectives[currentObjectiveIndex]
            descriptionLabel.Text = currentObjective.description
        else
            descriptionLabel.Text = ""
        end
    end
end

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
    currentObjectiveIndex = 1 -- Reset to first objective

    -- Update door highlighting based on first objective
    if taskData.objectives and #taskData.objectives > 0 then
        local firstObjective = taskData.objectives[1]
        DoorHighlight.updateHighlight(firstObjective.room, firstObjective.objectModel)
    else
        DoorHighlight.clear()
    end

    -- Update objective description
    updateObjectiveDescription()
end

-- Handle objective completion
function TaskManager.completeObjective()
    if not selectedTaskData or not selectedTaskData.objectives then
        return
    end

    -- Check if this was the last objective
    if currentObjectiveIndex >= #selectedTaskData.objectives then
        print("[TaskManager] Task completed:", selectedTaskData.name)

        -- Play green flash animation
        FadeController.greenFlash()

        -- Store the completed task ID before clearing
        local completedTaskId = selectedTaskData.id

        -- Store reference to completed task before removing
        local completedTask = selectedTask

        -- Remove the task frame
        if selectedTask then
            selectedTask:Destroy()
            -- Remove from tracking
            for i, frame in ipairs(allTaskFrames) do
                if frame == completedTask then
                    table.remove(allTaskFrames, i)
                    break
                end
            end
            taskFrameToData[completedTask] = nil
            taskFrameToTimeState[completedTask] = nil
        end

        selectedTask = nil
        selectedTaskData = nil
        currentObjectiveIndex = 1
        DoorHighlight.clear()
        updateObjectiveDescription()

        -- Notify server that task was completed
        RemoteEvents.TaskCompleted:FireServer(completedTaskId)

        -- Auto-select next task if available
        if #allTaskFrames > 0 then
            local nextTaskFrame = allTaskFrames[1]
            local nextTaskData = taskFrameToData[nextTaskFrame]
            if nextTaskFrame and nextTaskData then
                autoSelectTask(nextTaskFrame, nextTaskData)
            end
        end
    else
        -- Move to next objective
        currentObjectiveIndex = currentObjectiveIndex + 1
        local nextObjective = selectedTaskData.objectives[currentObjectiveIndex]
        print("[TaskManager] Moving to next objective:", nextObjective.description)
        DoorHighlight.updateHighlight(nextObjective.room, nextObjective.objectModel)
        updateObjectiveDescription()
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
    -- OR if this is the TalkToBoss task (see manager)
    if (currentTaskCount == 1 and not selectedTask) or taskData.id == "TalkToBoss" then
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
    local timeState = {
        timeRemaining = taskData.timeToComplete,
        totalTime = taskData.timeToComplete
    }
    taskFrameToTimeState[newTask] = timeState

    task.spawn(function()
        local timeBar = newTask:FindFirstChild("TimeBar")
        local bar = timeBar and timeBar:FindFirstChild("Bar") :: Frame

        -- Define colors for the gradient
        local greenColor = Color3.fromRGB(51, 255, 136) -- Green
        local yellowColor = Color3.fromRGB(241, 196, 15) -- Yellow
        local redColor = Color3.fromRGB(231, 76, 60) -- Red

        while timeState.timeRemaining > 0 do
            task.wait(0.1) -- Update every 0.1 seconds
            timeState.timeRemaining = timeState.timeRemaining - 0.1

            if bar then
                -- Update bar size based on time remaining
                local progress = math.max(0, timeState.timeRemaining / timeState.totalTime)
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
    -- Set TaskManager reference in DoorHighlight and TaskBehaviors to avoid circular dependency
    DoorHighlight.setTaskManager(TaskManager)
    TaskBehaviors.setTaskManager(TaskManager)

    -- Listen for task spawn events from server
    RemoteEvents.SpawnTask.OnClientEvent:Connect(function(taskData: TaskRegistry.Task)
        spawnTask(taskData)
    end)

    -- Update door highlighting when room changes
    RunService.Heartbeat:Connect(function()
        if selectedTaskData and selectedTaskData.objectives and currentObjectiveIndex <= #selectedTaskData.objectives then
            local currentObjective = selectedTaskData.objectives[currentObjectiveIndex]
            DoorHighlight.updateHighlight(currentObjective.room, currentObjective.objectModel)
        end
    end)
end

-- Get current objective index
function TaskManager.getCurrentObjectiveIndex(): number
    return currentObjectiveIndex
end

-- Get selected task data
function TaskManager.getSelectedTaskData()
    return selectedTaskData
end

-- Get the currently selected task frame
function TaskManager.getSelectedTask()
    return selectedTask
end

-- Reduce time on the currently selected task by a percentage
function TaskManager.reduceCurrentTaskTime(percentage: number)
    if selectedTask then
        local timeState = taskFrameToTimeState[selectedTask]
        if timeState then
            local reduction = timeState.timeRemaining * (percentage / 100)
            timeState.timeRemaining = math.max(0, timeState.timeRemaining - reduction)
        end
    end
end

-- Mark player as failed (called when wrong answer is selected)
function TaskManager.markPlayerFailed()
    if playerPassed then
        playerPassed = false
        print("[TaskManager] ❌ Player marked as FAILED - this is PERMANENT")
    else
        print("[TaskManager] ❌ Player already failed (attempted to fail again)")
    end
end

-- Get whether player has passed
function TaskManager.hasPlayerPassed(): boolean
    print("[TaskManager] Checking pass status:", playerPassed and "✅ PASSED" or "❌ FAILED")
    return playerPassed
end

return TaskManager

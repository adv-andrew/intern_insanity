-- Client/DoorHighlight.luau
-- Highlights doors and objectives based on selected task objectives and current room

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoomDetection = require(script.Parent.RoomDetection)
local TaskManager = nil -- Will be set via setTaskManager to avoid circular dependency

local DoorHighlight = {}

-- Set TaskManager reference (called from TaskManager to avoid circular dependency)
function DoorHighlight.setTaskManager(taskManagerModule)
    TaskManager = taskManagerModule
end

local player = Players.LocalPlayer

-- Get doors folder
local Doors = Workspace:WaitForChild("Doors")

-- Get ArrowBeam template and ProximityPrompt
local Assets = ReplicatedStorage:WaitForChild("Assets")
local ArrowBeamTemplate = Assets:WaitForChild("ArrowBeam")
local ProximityPromptTemplate = Assets:WaitForChild("ProximityPrompt")

-- Mapping of current room + target room to door name
local doorRoutes = {
    Office = {
        Conference = "OfficeToConference",
        Manager = "OfficeToManager",
        Server = "OfficeToServer",
    },
    Conference = {
        Office = "ConferenceToOffice",
    },
    Manager = {
        Office = "ManagerToOffice",
    },
    Server = {
        Office = "ServerToOffice",
    },
}

local currentHighlight = nil
local currentArrowBeam = nil
local playerAttachment = nil
local targetAttachment = nil
local currentHighlightedDoor = nil -- Track which door is currently highlighted
local currentHighlightedObject = nil -- Track which object is currently highlighted
local currentProximityPrompt = nil -- Track current proximity prompt

-- Remove existing arrow beam
local function removeArrowBeam()
    if currentArrowBeam then
        currentArrowBeam:Destroy()
        currentArrowBeam = nil
    end
    if playerAttachment then
        playerAttachment:Destroy()
        playerAttachment = nil
    end
    if targetAttachment then
        targetAttachment:Destroy()
        targetAttachment = nil
    end
end

-- Remove existing proximity prompt
local function removeProximityPrompt()
    if currentProximityPrompt then
        currentProximityPrompt:Destroy()
        currentProximityPrompt = nil
    end
end

-- Remove existing highlight
local function removeHighlight()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
    removeArrowBeam()
    removeProximityPrompt()
    currentHighlightedDoor = nil
    currentHighlightedObject = nil
end

-- Add highlight to a door
local function highlightDoor(doorName: string)
    -- Check if this door is already highlighted
    if currentHighlightedDoor == doorName then
        return -- Don't recreate, just keep existing highlight
    end

    removeHighlight()

    local door = Doors:FindFirstChild(doorName)
    if not door then
        warn("[DoorHighlight] Door not found:", doorName)
        return
    end

    -- Create Highlight instance
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0) -- Orange-yellow
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = door

    currentHighlight = highlight

    -- Create ArrowBeam from player to door
    local character = player.Character
    if not character then
        return
    end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end

    -- Create attachment in player's HumanoidRootPart
    local playerAttach = Instance.new("Attachment")
    playerAttach.Name = "ArrowBeamStart"
    playerAttach.Parent = humanoidRootPart
    playerAttachment = playerAttach

    -- Create attachment in door
    local targetAttach = Instance.new("Attachment")
    targetAttach.Name = "ArrowBeamEnd"
    targetAttach.Parent = door
    targetAttachment = targetAttach

    -- Clone ArrowBeam
    local arrowBeam = ArrowBeamTemplate:Clone()
    arrowBeam.Attachment0 = playerAttach
    arrowBeam.Attachment1 = targetAttach
    arrowBeam.Parent = humanoidRootPart

    currentArrowBeam = arrowBeam
    currentHighlightedDoor = doorName
end

-- Add highlight to an objective object in the room
local function highlightObject(objectPath: string)
    -- Check if this object is already highlighted
    if currentHighlightedObject == objectPath then
        return -- Don't recreate, just keep existing highlight
    end

    removeHighlight()

    -- Find the object in Workspace
    local objectModel = Workspace
    for _, pathSegment in ipairs(string.split(objectPath, ".")) do
        objectModel = objectModel:FindFirstChild(pathSegment)
        if not objectModel then
            warn("[DoorHighlight] Object not found:", objectPath)
            return
        end
    end

    -- Create Highlight instance
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0) -- Orange-yellow
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = objectModel

    currentHighlight = highlight

    -- Create ArrowBeam from player to object
    local character = player.Character
    if not character then
        return
    end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end

    -- Create attachment in player's HumanoidRootPart
    local playerAttach = Instance.new("Attachment")
    playerAttach.Name = "ArrowBeamStart"
    playerAttach.Parent = humanoidRootPart
    playerAttachment = playerAttach

    -- Create attachment in object
    local targetAttach = Instance.new("Attachment")
    targetAttach.Name = "ArrowBeamEnd"
    targetAttach.Parent = objectModel
    targetAttachment = targetAttach

    -- Clone ArrowBeam
    local arrowBeam = ArrowBeamTemplate:Clone()
    arrowBeam.Attachment0 = playerAttach
    arrowBeam.Attachment1 = targetAttach
    arrowBeam.Parent = humanoidRootPart

    currentArrowBeam = arrowBeam
    currentHighlightedObject = objectPath

    -- Add ProximityPrompt to the object
    -- ProximityPrompt must be parented to a BasePart or MeshPart
    local targetPart = nil
    if objectModel:IsA("BasePart") or objectModel:IsA("MeshPart") then
        targetPart = objectModel
    else
        -- Find first BasePart/MeshPart child in the model
        for _, child in ipairs(objectModel:GetDescendants()) do
            if child:IsA("BasePart") or child:IsA("MeshPart") then
                targetPart = child
                break
            end
        end
    end

    if targetPart then
        local proximityPrompt = ProximityPromptTemplate:Clone()
        proximityPrompt.Parent = targetPart
        currentProximityPrompt = proximityPrompt

        -- Connect to proximity prompt triggered event
        proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
            print("[DoorHighlight] Player interacted with:", objectPath)

            -- Handle task-specific behavior
            if TaskManager then
                local taskData = TaskManager.getSelectedTaskData()
                local objectiveIndex = TaskManager.getCurrentObjectiveIndex()
                local TaskBehaviors = require(script.Parent.TaskBehaviors)

                if taskData and taskData.id == "PrinterJam" then
                    local success = TaskBehaviors.handlePrinterJamInteraction(objectPath, objectiveIndex)

                    if success then
                        -- Complete the objective
                        TaskManager.completeObjective()
                    end
                elseif taskData and taskData.id == "AWSOutage" then
                    -- Pass a completion callback for when the minigame is finished
                    local success = TaskBehaviors.handleAWSOutageInteraction(
                        objectPath,
                        objectiveIndex,
                        function()
                            -- Called when minigame is completed
                            TaskManager.completeObjective()
                        end
                    )

                    if success then
                        -- Complete the objective immediately
                        TaskManager.completeObjective()
                    end
                elseif taskData and taskData.id == "CoworkerConflict" then
                    -- Pass a completion callback for when the player makes a choice
                    local success = TaskBehaviors.handleCoworkerConflictInteraction(
                        objectPath,
                        objectiveIndex,
                        function()
                            -- Called when player selects B (correct answer)
                            TaskManager.completeObjective()
                        end
                    )

                    if success then
                        -- Complete the objective immediately (won't happen - task waits for choice)
                        TaskManager.completeObjective()
                    end
                elseif taskData and taskData.id == "FixBugQuiz" then
                    -- Pass a completion callback for when the player fixes the bug
                    local success = TaskBehaviors.handleFixBugQuizInteraction(
                        objectPath,
                        objectiveIndex,
                        function()
                            -- Called when player completes the bug fix
                            TaskManager.completeObjective()
                        end
                    )

                    if success then
                        -- Complete the objective immediately (won't happen - task waits for bug fix)
                        TaskManager.completeObjective()
                    end
                end
            end
        end)
    else
        warn("[DoorHighlight] No BasePart/MeshPart found in object:", objectPath)
    end
end

-- Update door highlight based on current room, target room, and optional object
function DoorHighlight.updateHighlight(targetRoom: string, objectPath: string?)
    local currentRoom = RoomDetection.getCurrentRoom()

    -- If not in a room, remove highlight
    if not currentRoom then
        removeHighlight()
        return
    end

    -- If already in target room and there's an object, highlight the object
    if currentRoom == targetRoom then
        if objectPath then
            highlightObject(objectPath)
        else
            removeHighlight()
        end
        return
    end

    -- Find the door to highlight
    local routes = doorRoutes[currentRoom]
    if not routes then
        removeHighlight()
        return
    end

    local doorToHighlight = routes[targetRoom]
    if doorToHighlight then
        highlightDoor(doorToHighlight)
    else
        -- No direct route, player needs to go to Office first
        if targetRoom ~= "Office" and routes.Office then
            highlightDoor(routes.Office)
        else
            removeHighlight()
        end
    end
end

-- Clear all highlights
function DoorHighlight.clear()
    removeHighlight()
end

return DoorHighlight

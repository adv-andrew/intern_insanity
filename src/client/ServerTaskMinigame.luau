-- Client/ServerTaskMinigame.luau
-- Handles the AWS Server Task minigame (toggle nodes puzzle)

local Players = game:GetService("Players")

local ServerTaskMinigame = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("MainGui")
local serverTask = mainGui:WaitForChild("ServerTask")
local container = serverTask:WaitForChild("Container")

-- Node states (true = filled/X, false = empty/O)
local nodes = { true, false, true, false } -- Starting pattern: X O X O

-- Colors
local FILLED_COLOR = Color3.fromRGB(0, 255, 0) -- Green
local EMPTY_COLOR = Color3.fromRGB(255, 255, 255) -- White

-- References to Select frames
local selectFrames = {}

-- Callback for when puzzle is completed
local onComplete = nil

-- Update the UI to match the current node states
local function updateUI()
    for i = 1, 4 do
        local selectFrame = selectFrames[i]
        if selectFrame then
            if nodes[i] then
                selectFrame.BackgroundColor3 = FILLED_COLOR
            else
                selectFrame.BackgroundColor3 = EMPTY_COLOR
            end
        end
    end
end

-- Check if all nodes are filled
local function checkWinCondition()
    for i = 1, 4 do
        if not nodes[i] then
            return false -- At least one node is empty
        end
    end

    -- All nodes are filled!
    print("[ServerTaskMinigame] Puzzle completed!")

    -- Hide the ServerTask GUI
    serverTask.Visible = false

    -- Call completion callback
    if onComplete then
        onComplete()
    end

    return true
end

-- Toggle a node and its adjacent nodes
local function toggleNode(index: number)
    -- Toggle the clicked node
    nodes[index] = not nodes[index]

    -- Toggle left adjacent node (if exists)
    if index > 1 then
        nodes[index - 1] = not nodes[index - 1]
    end

    -- Toggle right adjacent node (if exists)
    if index < 4 then
        nodes[index + 1] = not nodes[index + 1]
    end

    -- Update the UI
    updateUI()

    -- Check for win condition
    checkWinCondition()
end

-- Initialize the minigame
function ServerTaskMinigame.start(completionCallback)
    print("[ServerTaskMinigame] Starting minigame")

    onComplete = completionCallback

    -- Reset to starting state
    nodes = { true, false, true, false }

    -- Find all Select frames by LayoutOrder
    for i = 0, 3 do
        for _, child in ipairs(container:GetChildren()) do
            if child.Name == "Select" and child.LayoutOrder == i then
                selectFrames[i + 1] = child -- Store as 1-indexed
                break
            end
        end
    end

    -- Set up click handlers for each Select frame
    for i = 1, 4 do
        local selectFrame = selectFrames[i]
        if selectFrame then
            local selectButton = selectFrame:FindFirstChild("SelectButton")
            if selectButton then
                selectButton.Activated:Connect(function()
                    print("[ServerTaskMinigame] Node", i, "clicked")
                    toggleNode(i)
                end)
            else
                warn("[ServerTaskMinigame] SelectButton not found in Select frame", i)
            end
        else
            warn("[ServerTaskMinigame] Select frame not found for index", i)
        end
    end

    -- Initialize UI
    updateUI()

    -- Check if already complete (shouldn't happen with starting state)
    checkWinCondition()
end

return ServerTaskMinigame

--!strict
-- Client initialization script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CameraController = require(script.CameraController)
local TaskManager = require(script.TaskManager)
local FadeController = require(script.FadeController)
local RoomDetection = require(script.RoomDetection)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for Start screen
local startScreen = playerGui:WaitForChild("Start")
local startButton = startScreen:WaitForChild("StartButton")

-- Enable the Start screen when player loads in
startScreen.Enabled = true

-- Set camera to cutscene view on game start
local cutscenePart = Workspace:WaitForChild("CutscenePart", 10)
if cutscenePart then
    -- Create opening cutscene camera
    local openingCamera = Instance.new("Camera")
    openingCamera.Name = "OpeningCutsceneCamera"
    openingCamera.CFrame = cutscenePart.CFrame
    openingCamera.Focus = CFrame.new(cutscenePart.Position)
    openingCamera.Parent = cutscenePart

    -- Set as current camera
    Workspace.CurrentCamera = openingCamera
    print("[Client Init] Opening cutscene camera set")
else
    warn("[Client Init] CutscenePart not found - skipping opening cutscene")
end

-- Start the fade controller (listens for teleport events)
FadeController.start()

-- Start room detection
RoomDetection.start()

-- Wait for player to click Start button
startButton.Activated:Connect(function()
    print("[Client Init] Start button clicked - starting fade transition")

    -- Fade to black, switch camera at midpoint, then fade back
    FadeController.fadeToBlackWithCallback(function()
        print("[Client Init] Fade midpoint - switching to gameplay camera")

        -- Hide start screen
        startScreen.Enabled = false

        -- Enable MainGui
        local mainGui = playerGui:WaitForChild("MainGui")
        mainGui.Enabled = true

        -- Get RemoteEvents
        local Shared = ReplicatedStorage:WaitForChild("Shared")
        local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

        -- Signal server that player is ready
        RemoteEvents.PlayerReady:FireServer()

        -- Start the top-down camera controller (this will handle the camera)
        CameraController.start()

        -- Start the task system
        task.spawn(function()
            TaskManager.start()
        end)

        print("[Client Init] Switched to gameplay camera")
    end)
end)

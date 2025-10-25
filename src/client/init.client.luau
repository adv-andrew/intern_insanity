--!strict
-- Client initialization script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Start the fade controller (listens for teleport events)
FadeController.start()

-- Start room detection
RoomDetection.start()

-- Wait for player to click Start button
startButton.Activated:Connect(function()
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

    -- Start the top-down camera controller
    CameraController.start()

    -- Start the task system
    task.spawn(function()
        TaskManager.start()
    end)
end)

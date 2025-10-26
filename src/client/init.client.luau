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
local startButton = startScreen:WaitForChild("Button"):WaitForChild("Top"):WaitForChild("Button")

-- Enable the Start screen when player loads in
startScreen.Enabled = true

-- Start the fade controller (listens for teleport events)
FadeController.start()

-- Start room detection
RoomDetection.start()

-- Set up cutscene camera on player join
-- Wait for character to load
local character = player.Character or player.CharacterAdded:Wait()
print("[Init] Character loaded, setting up cutscene camera")

local cutscenePart = Workspace:WaitForChild("CutscenePart")
if cutscenePart then
    print("[Init] Found CutscenePart, switching camera view")

    -- Get the current camera
    local camera = Workspace.CurrentCamera

    -- Set camera to Scriptable mode so we can control it
    camera.CameraType = Enum.CameraType.Scriptable

    -- Set camera CFrame to match CutscenePart's CFrame, offset back 10 studs
    camera.CFrame = cutscenePart.CFrame * CFrame.new(0, 0, 10)

    print("[Init] Camera set to CutscenePart view at position:", cutscenePart.CFrame.Position)

    -- Play animation on Intern during beginning cutscene
    local cutsceneArea = Workspace:FindFirstChild("CutsceneArea")
    if cutsceneArea then
        local intern = cutsceneArea:FindFirstChild("Intern")
        if intern and intern:IsA("Model") then
            local humanoid = intern:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local success, err = pcall(function()
                    local animator = humanoid:FindFirstChildOfClass("Animator")
                    if not animator then
                        animator = Instance.new("Animator")
                        animator.Parent = humanoid
                    end

                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://507770239"
                    local animationTrack = animator:LoadAnimation(anim)
                    animationTrack.Looped = true
                    animationTrack:Play()
                    print("[Init] Playing beginning cutscene animation on Intern NPC")
                end)
                if not success then
                    warn("[Init] Failed to load beginning cutscene animation:", err)
                end
            else
                warn("[Init] Intern has no Humanoid")
            end
        else
            warn("[Init] Intern not found in CutsceneArea")
        end
    else
        warn("[Init] CutsceneArea not found in Workspace")
    end
else
    warn("[Init] CutscenePart not found in Workspace")
end

-- Wait for player to click Start button
startButton.Activated:Connect(function()
    -- Hide start screen
    startScreen.Enabled = false

    -- Switch back to normal player camera
    print("[Init] Switching from cutscene camera to player camera")
    local camera = Workspace.CurrentCamera
    local humanoid = character:WaitForChild("Humanoid")

    -- Reset camera to follow the player
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    print("[Init] Camera reset to player character")

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

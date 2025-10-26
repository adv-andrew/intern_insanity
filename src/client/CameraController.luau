--!strict
-- CameraController: Top-down camera that follows the player

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CameraController = {}

-- Camera configuration
local CAMERA_HEIGHT = 18 -- Height above the character
local CAMERA_ANGLE = 60 -- Angle in degrees (70 = slightly angled top-down)

local currentConnection: RBXScriptConnection? = nil
local camera = Workspace.CurrentCamera

-- Clean up existing camera connection
local function cleanup()
    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end
end

-- Set up camera for a character
local function setupCamera(character: Model)
    cleanup()

    -- Lock camera to Scriptable mode (prevents player control)
    camera.CameraType = Enum.CameraType.Scriptable

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

    -- Update camera position every frame
    currentConnection = RunService.RenderStepped:Connect(function()
        if not character or not character.Parent then
            cleanup()
            return
        end

        local rootPosition = humanoidRootPart.Position

        -- Calculate camera offset using angle
        local angleRad = math.rad(CAMERA_ANGLE)
        local horizontalDist = CAMERA_HEIGHT / math.tan(angleRad)

        -- Position camera above and behind the character
        local cameraOffset = Vector3.new(0, CAMERA_HEIGHT, horizontalDist)
        camera.CFrame = CFrame.new(rootPosition + cameraOffset, rootPosition)
    end)
end

-- Initialize the camera controller
function CameraController.start()
    local player = Players.LocalPlayer

    -- Set up camera for current character
    if player.Character then
        setupCamera(player.Character)
    end

    -- Set up camera for future character spawns
    player.CharacterAdded:Connect(function(character)
        setupCamera(character)
    end)

    -- Clean up when player is removing
    player.CharacterRemoving:Connect(function()
        cleanup()
    end)
end

-- Stop the camera controller and restore default camera
function CameraController.stop()
    cleanup()
    camera.CameraType = Enum.CameraType.Custom
end

return CameraController

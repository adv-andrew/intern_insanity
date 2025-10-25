-- Client/FadeController.luau
-- Handles screen fade transitions for door teleportation

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

local FadeController = {}

-- Fade the screen to black and then back
function FadeController.fadeTransition()
    local fadeGui = playerGui:WaitForChild("FadeGui")
    local fadeBackground = fadeGui:WaitForChild("FadeBackground")

    -- Tween info for fade in (0.5 seconds)
    local fadeInInfo = TweenInfo.new(
        0.2, -- Duration
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    -- Tween info for fade out (0.5 seconds)
    local fadeOutInfo = TweenInfo.new(
        0.2, -- Duration
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    -- Fade in (transparent to opaque)
    local fadeInTween = TweenService:Create(
        fadeBackground,
        fadeInInfo,
        { BackgroundTransparency = 0 }
    )

    fadeInTween:Play()
    fadeInTween.Completed:Wait()

    -- At this point, server will teleport the player

    -- Fade out (opaque to transparent)
    local fadeOutTween = TweenService:Create(
        fadeBackground,
        fadeOutInfo,
        { BackgroundTransparency = 1 }
    )

    fadeOutTween:Play()
end

-- Listen for door teleport events from server
function FadeController.start()
    RemoteEvents.DoorTeleport.OnClientEvent:Connect(function(destinationCFrame)
        FadeController.fadeTransition()
    end)
end

return FadeController

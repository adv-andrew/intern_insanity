-- Client/FadeController.luau
-- Handles screen fade transitions for door teleportation and task completion

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

local FadeController = {}

-- Get fade GUI elements
local fadeGui = playerGui:WaitForChild("FadeGui")
local greenFadeBackground = fadeGui:WaitForChild("GreenFadeBackground")

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

-- Green fade animation for task completion
function FadeController.greenFlash()
    -- Tween info for fade in and out (0.5 seconds each)
    local fadeInInfo = TweenInfo.new(
        0.5, -- Duration
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    local fadeOutInfo = TweenInfo.new(
        0.5, -- Duration
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    -- Get all children of GreenFadeBackground
    local children = greenFadeBackground:GetChildren()
    local fadeInTweens = {}
    local fadeOutTweens = {}

    -- Create tweens for all children
    for _, child in ipairs(children) do
        if child:IsA("Frame") or child:IsA("GuiObject") then
            -- Ensure starting at transparent
            child.BackgroundTransparency = 1

            -- Fade in tween (1 -> 0)
            local fadeIn = TweenService:Create(
                child,
                fadeInInfo,
                { BackgroundTransparency = 0 }
            )
            table.insert(fadeInTweens, fadeIn)

            -- Fade out tween (0 -> 1)
            local fadeOut = TweenService:Create(
                child,
                fadeOutInfo,
                { BackgroundTransparency = 1 }
            )
            table.insert(fadeOutTweens, fadeOut)
        end
    end

    -- Play all fade in tweens
    for _, tween in ipairs(fadeInTweens) do
        tween:Play()
    end

    -- Wait for first tween to complete
    if #fadeInTweens > 0 then
        fadeInTweens[1].Completed:Wait()
    end

    -- Play all fade out tweens
    for _, tween in ipairs(fadeOutTweens) do
        tween:Play()
    end
end

-- Listen for door teleport events from server
function FadeController.start()
    RemoteEvents.DoorTeleport.OnClientEvent:Connect(function(destinationCFrame)
        FadeController.fadeTransition()
    end)
end

return FadeController

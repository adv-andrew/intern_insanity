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

-- Fade the screen to black and then back
function FadeController.fadeTransition()
    local fadeGui = playerGui:FindFirstChild("FadeGui")
    if not fadeGui then
        return
    end

    local fadeBackground = fadeGui:FindFirstChild("FadeBackground")
    if not fadeBackground then
        return
    end

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
    -- Get GreenFadeBackground when needed
    local fadeGui = playerGui:FindFirstChild("FadeGui")
    if not fadeGui then
        return
    end

    local greenFadeBackground = fadeGui:FindFirstChild("GreenFadeBackground")
    if not greenFadeBackground then
        return
    end

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

-- Red fade animation for task failure
function FadeController.redFlash()
    -- Get FadeGui when needed
    local fadeGui = playerGui:FindFirstChild("FadeGui")
    if not fadeGui then
        return
    end

    -- Get RedFadeBackground when needed
    local redFadeBackground = fadeGui:FindFirstChild("RedFadeBackground")
    if not redFadeBackground then
        return
    end

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

    -- Get all children of RedFadeBackground
    local children = redFadeBackground:GetChildren()
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

-- Fade to black with callback at midpoint, then fade back
function FadeController.fadeToBlackWithCallback(midpointCallback: () -> ())
    print("[FadeController] fadeToBlackWithCallback called")
    local fadeGui = playerGui:FindFirstChild("FadeGui")
    if not fadeGui then
        warn("[FadeController] FadeGui not found in PlayerGui")
        -- Print all children for debugging
        print("[FadeController] PlayerGui children:", playerGui:GetChildren())
        return
    end

    print("[FadeController] FadeGui found")
    local fadeBackground = fadeGui:FindFirstChild("FadeBackground")
    if not fadeBackground then
        warn("[FadeController] FadeBackground not found in FadeGui")
        -- Print all children for debugging
        print("[FadeController] FadeGui children:", fadeGui:GetChildren())
        return
    end

    print("[FadeController] FadeBackground found, starting fade")

    -- Tween info for fade in (1 second to black)
    local fadeInInfo = TweenInfo.new(
        1, -- Duration
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    -- Tween info for fade out (1 second back to transparent)
    local fadeOutInfo = TweenInfo.new(
        1, -- Duration
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    -- Ensure starting transparency
    print("[FadeController] Starting transparency:", fadeBackground.BackgroundTransparency)

    -- Fade in (transparent to opaque)
    local fadeInTween = TweenService:Create(
        fadeBackground,
        fadeInInfo,
        { BackgroundTransparency = 0 }
    )

    print("[FadeController] Playing fade IN tween (to black)")
    fadeInTween:Play()
    fadeInTween.Completed:Wait()
    print("[FadeController] Fade IN complete - screen should be black now")

    -- At midpoint - call the callback (e.g., switch camera)
    if midpointCallback then
        print("[FadeController] Calling midpoint callback")
        midpointCallback()
        print("[FadeController] Midpoint callback complete")
    end

    -- Fade out (opaque to transparent)
    local fadeOutTween = TweenService:Create(
        fadeBackground,
        fadeOutInfo,
        { BackgroundTransparency = 1 }
    )

    print("[FadeController] Playing fade OUT tween (to transparent)")
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()
    print("[FadeController] Fade OUT complete - transition finished")
end

-- Listen for door teleport events from server
function FadeController.start()
    RemoteEvents.DoorTeleport.OnClientEvent:Connect(function(destinationCFrame)
        FadeController.fadeTransition()
    end)
end

return FadeController

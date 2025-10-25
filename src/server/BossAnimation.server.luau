--!strict
-- BossAnimation.server.luau
-- Applies animation to Boss NPC when game starts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = require(ReplicatedStorage.Shared.RemoteEvents)

local BOSS_ANIMATION_ID = "rbxassetid://99900072134466"

local function applyBossAnimation()
    -- Wait for Workspace structure to load
    local bossRoom = Workspace:WaitForChild("BossRoom", 5)
    if not bossRoom then
        warn("BossRoom not found in Workspace")
        return
    end

    local boss = bossRoom:FindFirstChild("Boss")
    if not boss then
        warn("Boss not found in BossRoom")
        return
    end

    -- Apply animation to Boss
    if boss:IsA("Model") then
        local humanoid = boss:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Create and load the animation
            local anim = Instance.new("Animation")
            anim.AnimationId = BOSS_ANIMATION_ID

            local animationTrack = humanoid:LoadAnimation(anim)
            animationTrack.Looped = true
            animationTrack:Play()

            print(`Applied animation to Boss`)
        else
            warn("Boss has no Humanoid")
        end
    else
        warn("Boss is not a Model")
    end
end

-- Wait for player to click Start button
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    print(`Player {player.Name} is ready - applying Boss animation`)
    applyBossAnimation()
end)

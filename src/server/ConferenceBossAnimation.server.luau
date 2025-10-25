--!strict
-- ConferenceBossAnimation.server.luau
-- Applies animation to Boss NPC in Conference room when game starts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = require(ReplicatedStorage.Shared.RemoteEvents)

local CONFERENCE_BOSS_ANIMATION_ID = "rbxassetid://105452528680062"

local function applyConferenceBossAnimation()
    -- Wait for Workspace structure to load
    local conference = Workspace:WaitForChild("Conference", 5)
    if not conference then
        warn("Conference not found in Workspace")
        return
    end

    local npcs = conference:FindFirstChild("npcs")
    if not npcs then
        warn("npcs folder not found in Conference")
        return
    end

    local boss = npcs:FindFirstChild("Boss")
    if not boss then
        warn("Boss not found in Conference npcs")
        return
    end

    -- Apply animation to Boss
    if boss:IsA("Model") then
        local humanoid = boss:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Create and load the animation
            local anim = Instance.new("Animation")
            anim.AnimationId = CONFERENCE_BOSS_ANIMATION_ID

            local animationTrack = humanoid:LoadAnimation(anim)
            animationTrack.Looped = true
            animationTrack:Play()

            print(`Applied animation to Conference Boss`)
        else
            warn("Conference Boss has no Humanoid")
        end
    else
        warn("Conference Boss is not a Model")
    end
end

-- Wait for player to click Start button
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    print(`Player {player.Name} is ready - applying Conference Boss animation`)
    applyConferenceBossAnimation()
end)

--!strict
-- ConferenceNPCAnimations.server.luau
-- Applies animations to NPCs in Conference top and bottom folders when game starts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = require(ReplicatedStorage.Shared.RemoteEvents)

local TOP_ANIMATION_ID = "rbxassetid://86090279957289"
local BOTTOM_ANIMATION_ID = "rbxassetid://79222368568968"

local function applyConferenceNPCAnimations()
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

    -- Apply animation to all NPCs in top folder
    local topFolder = npcs:FindFirstChild("top")
    if topFolder then
        for _, npc in ipairs(topFolder:GetChildren()) do
            if npc:IsA("Model") then
                local humanoid = npc:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Create and load the animation
                    local anim = Instance.new("Animation")
                    anim.AnimationId = TOP_ANIMATION_ID

                    local animationTrack = humanoid:LoadAnimation(anim)
                    animationTrack.Looped = true
                    animationTrack:Play()

                    print(`Applied top animation to {npc.Name}`)
                else
                    warn(`NPC {npc.Name} in top folder has no Humanoid`)
                end
            end
        end
    else
        warn("top folder not found in Conference npcs")
    end

    -- Apply animation to all NPCs in bottom folder
    local bottomFolder = npcs:FindFirstChild("bottom")
    if bottomFolder then
        for _, npc in ipairs(bottomFolder:GetChildren()) do
            if npc:IsA("Model") then
                local humanoid = npc:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Create and load the animation
                    local anim = Instance.new("Animation")
                    anim.AnimationId = BOTTOM_ANIMATION_ID

                    local animationTrack = humanoid:LoadAnimation(anim)
                    animationTrack.Looped = true
                    animationTrack:Play()

                    print(`Applied bottom animation to {npc.Name}`)
                else
                    warn(`NPC {npc.Name} in bottom folder has no Humanoid`)
                end
            end
        end
    else
        warn("bottom folder not found in Conference npcs")
    end

    print("Conference NPC animations applied")
end

-- Wait for player to click Start button
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    print(`Player {player.Name} is ready - applying Conference NPC animations`)
    applyConferenceNPCAnimations()
end)

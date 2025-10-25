--!strict
-- NPCAnimations.server.luau
-- Applies animations to NPCs in the office when game starts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = require(ReplicatedStorage.Shared.RemoteEvents)

local TYPING_ANIMATION_ID = "rbxassetid://103167424199925"

local function applyTypingAnimation()
    -- Wait for Workspace structure to load
    local office = Workspace:WaitForChild("Office", 5)
    if not office then
        warn("Office not found in Workspace")
        return
    end

    local npcs = office:FindFirstChild("npcs")
    if not npcs then
        warn("npcs folder not found in Office")
        return
    end

    local typingFolder = npcs:FindFirstChild("typing")
    if not typingFolder then
        warn("typing folder not found in npcs")
        return
    end

    -- Apply animation to all NPCs in typing folder
    for _, npc in ipairs(typingFolder:GetChildren()) do
        if npc:IsA("Model") then
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Create and load the animation
                local anim = Instance.new("Animation")
                anim.AnimationId = TYPING_ANIMATION_ID

                local animationTrack = humanoid:LoadAnimation(anim)
                animationTrack.Looped = true
                animationTrack:Play()

                print(`Applied typing animation to NPC: {npc.Name}`)
            else
                warn(`NPC {npc.Name} has no Humanoid`)
            end
        end
    end

    print("Typing animations applied to all NPCs")
end

-- Wait for player to click Start button
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    print(`Player {player.Name} is ready - applying NPC animations`)
    applyTypingAnimation()
end)

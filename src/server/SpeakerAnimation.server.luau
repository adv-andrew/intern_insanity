--!strict
-- SpeakerAnimation.server.luau
-- Applies animation to Speaker1 and Speaker2 NPCs when game starts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = require(ReplicatedStorage.Shared.RemoteEvents)

local SPEAKER_ANIMATION_ID = "rbxassetid://71805997029700"

local function applySpeakerAnimation()
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

    -- Apply animation to Speaker1 and Speaker2 inside CoWorkers model, and Speaker3
    local coWorkers = npcs:FindFirstChild("CoWorkers")
    if coWorkers and coWorkers:IsA("Model") then
        -- Apply to Speaker1 and Speaker2 inside CoWorkers
        for _, speakerName in ipairs({"Speaker1", "Speaker2"}) do
            local speaker = coWorkers:FindFirstChild(speakerName)
            if speaker and speaker:IsA("Model") then
                local humanoid = speaker:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Create and load the animation
                    local anim = Instance.new("Animation")
                    anim.AnimationId = SPEAKER_ANIMATION_ID

                    local animationTrack = humanoid:LoadAnimation(anim)
                    animationTrack.Looped = true
                    animationTrack:Play()

                    print(`Applied animation to {speakerName} (inside CoWorkers)`)
                else
                    warn(`{speakerName} has no Humanoid`)
                end
            else
                warn(`{speakerName} not found in CoWorkers`)
            end
        end
    else
        warn("CoWorkers model not found in npcs")
    end

    -- Apply animation to Speaker3 (same level as CoWorkers)
    local speaker3 = npcs:FindFirstChild("Speaker3")
    if speaker3 and speaker3:IsA("Model") then
        local humanoid = speaker3:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Create and load the animation
            local anim = Instance.new("Animation")
            anim.AnimationId = SPEAKER_ANIMATION_ID

            local animationTrack = humanoid:LoadAnimation(anim)
            animationTrack.Looped = true
            animationTrack:Play()

            print(`Applied animation to Speaker3`)
        else
            warn("Speaker3 has no Humanoid")
        end
    else
        warn("Speaker3 not found in npcs")
    end
end

-- Wait for player to click Start button
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    print(`Player {player.Name} is ready - applying Speaker animations`)
    applySpeakerAnimation()
end)

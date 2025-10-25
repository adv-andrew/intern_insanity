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

    -- Apply animation to both Speaker1 and Speaker2
    local speakers = {"Speaker1", "Speaker2"}

    for _, speakerName in ipairs(speakers) do
        local speaker = npcs:FindFirstChild(speakerName)
        if speaker then
            if speaker:IsA("Model") then
                local humanoid = speaker:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Create and load the animation
                    local anim = Instance.new("Animation")
                    anim.AnimationId = SPEAKER_ANIMATION_ID

                    local animationTrack = humanoid:LoadAnimation(anim)
                    animationTrack.Looped = true
                    animationTrack:Play()

                    print(`Applied animation to {speakerName}`)
                else
                    warn(`{speakerName} has no Humanoid`)
                end
            else
                warn(`{speakerName} is not a Model`)
            end
        else
            warn(`{speakerName} not found in npcs`)
        end
    end
end

-- Wait for player to click Start button
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    print(`Player {player.Name} is ready - applying Speaker animations`)
    applySpeakerAnimation()
end)

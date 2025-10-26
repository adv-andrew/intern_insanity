--!strict
-- SpeechBubble.luau
-- Creates speech bubbles above NPCs

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local SpeechBubble = {}

-- Show a sequence of speech bubbles above a character
function SpeechBubble.showSequence(characterModel: Model, messages: {string}, delayBetween: number?)
    local delay = delayBetween or 2 -- Default 2 seconds between messages

    -- Find the character's head or primary part
    local head = characterModel:FindFirstChild("Head")
    if not head then
        warn("[SpeechBubble] No Head found in character:", characterModel.Name)
        return
    end

    -- Create BillboardGui above the character
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "SpeechBubble"
    billboardGui.Size = UDim2.new(0, 300, 0, 100)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Float above head
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = head

    -- Create background frame
    local frame = Instance.new("Frame")
    frame.Name = "Background"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui

    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    -- Add stroke/outline
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 3
    stroke.Parent = frame

    -- Create text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -20, 1, -20)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 24
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.TextScaled = true
    textLabel.Parent = frame

    -- Add text size constraint
    local textSizeConstraint = Instance.new("UITextSizeConstraint")
    textSizeConstraint.MaxTextSize = 24
    textSizeConstraint.Parent = textLabel

    -- Tween info for pop-in/pop-out
    local popInTween = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local popOutTween = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    -- Show each message in sequence
    for i, message in ipairs(messages) do
        -- Set the text
        textLabel.Text = message

        -- Start small
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.AnchorPoint = Vector2.new(0.5, 0.5)

        -- Pop in animation
        local popIn = TweenService:Create(frame, popInTween, {
            Size = UDim2.new(1, 0, 1, 0),
        })
        popIn:Play()
        popIn.Completed:Wait()

        -- Wait for delay
        task.wait(delay)

        -- Pop out animation (except for last message - let it stay)
        if i < #messages then
            local popOut = TweenService:Create(frame, popOutTween, {
                Size = UDim2.new(0, 0, 0, 0),
            })
            popOut:Play()
            popOut.Completed:Wait()
            task.wait(0.3) -- Small delay before next message
        end
    end

    -- Return the billboard so caller can destroy it when needed
    return billboardGui
end

return SpeechBubble

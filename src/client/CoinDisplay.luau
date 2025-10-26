--!strict
-- CoinDisplay.luau
-- Updates the coin display UI when player's coins change

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local CoinDisplay = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Animation configuration
local FLASH_COLOR = Color3.fromRGB(51, 255, 136) -- Bright green
local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255) -- White
local SHAKE_INTENSITY = 15 -- Pixels to shake
local SHAKE_DURATION = 0.4 -- Total shake time
local FLASH_DURATION = 0.3
local SCALE_INTENSITY = 1.3 -- How much to grow
local ROTATION_DEGREES = 10 -- Rotation wobble

-- Store original position for shake reset
local originalPosition: UDim2?

-- Perform the epic coin update animation
local function animateCoinUpdate(moneyLabel: TextLabel, coinsFrame: Frame, newValue: number, oldValue: number)
	-- Only animate if coins increased
	if newValue <= oldValue then
		moneyLabel.Text = tostring(newValue)
		return
	end

	local coinsAdded = newValue - oldValue

	-- Create a floating +coins indicator
	local floatingText = Instance.new("TextLabel")
	floatingText.Text = "+" .. tostring(coinsAdded)
	floatingText.TextColor3 = FLASH_COLOR
	floatingText.Font = Enum.Font.GothamBold
	floatingText.TextSize = 24
	floatingText.BackgroundTransparency = 1
	floatingText.Size = UDim2.new(0, 100, 0, 30)
	floatingText.Position = UDim2.new(0.5, 0, 0.5, 0)
	floatingText.AnchorPoint = Vector2.new(0.5, 0.5)
	floatingText.TextStrokeTransparency = 0.5
	floatingText.ZIndex = 10
	floatingText.Parent = coinsFrame

	-- Float up and fade out
	local floatTween = TweenService:Create(floatingText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, -0.5, 0),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	floatTween:Play()
	floatTween.Completed:Connect(function()
		floatingText:Destroy()
	end)

	-- Update the text with counting animation
	local startValue = oldValue
	local duration = 0.5
	local elapsed = 0
	local connection: RBXScriptConnection?

	connection = game:GetService("RunService").RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		local progress = math.min(elapsed / duration, 1)

		-- Ease out cubic
		local easedProgress = 1 - math.pow(1 - progress, 3)

		local currentValue = math.floor(startValue + (newValue - startValue) * easedProgress)
		moneyLabel.Text = tostring(currentValue)

		if progress >= 1 then
			if connection then
				connection:Disconnect()
			end
			moneyLabel.Text = tostring(newValue)
		end
	end)

	-- GREEN FLASH EFFECT
	local originalColor = moneyLabel.TextColor3
	moneyLabel.TextColor3 = FLASH_COLOR

	local flashTween = TweenService:Create(moneyLabel, TweenInfo.new(FLASH_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextColor3 = originalColor
	})
	flashTween:Play()

	-- SCALE POP EFFECT
	local originalSize = moneyLabel.TextSize
	moneyLabel.TextSize = originalSize * SCALE_INTENSITY

	local scaleTween = TweenService:Create(moneyLabel, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		TextSize = originalSize
	})
	scaleTween:Play()

	-- SHAKE EFFECT
	if not originalPosition then
		originalPosition = coinsFrame.Position
	end

	local shakeCount = 8 -- Number of shakes
	local shakeInterval = SHAKE_DURATION / shakeCount

	for i = 1, shakeCount do
		task.wait(shakeInterval)

		-- Alternate shake direction and decrease intensity
		local intensity = SHAKE_INTENSITY * (1 - i / shakeCount)
		local direction = if i % 2 == 0 then 1 else -1

		coinsFrame.Position = UDim2.new(
			originalPosition.X.Scale,
			originalPosition.X.Offset + (direction * intensity),
			originalPosition.Y.Scale,
			originalPosition.Y.Offset
		)
	end

	-- Reset position smoothly
	local resetTween = TweenService:Create(coinsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = originalPosition
	})
	resetTween:Play()

	-- ROTATION WOBBLE
	local originalRotation = coinsFrame.Rotation

	local wobbleSequence = {
		{rotation = ROTATION_DEGREES, duration = 0.1},
		{rotation = -ROTATION_DEGREES, duration = 0.15},
		{rotation = ROTATION_DEGREES / 2, duration = 0.1},
		{rotation = -ROTATION_DEGREES / 2, duration = 0.1},
		{rotation = 0, duration = 0.15}
	}

	task.spawn(function()
		for _, wobble in ipairs(wobbleSequence) do
			local rotateTween = TweenService:Create(coinsFrame, TweenInfo.new(wobble.duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Rotation = originalRotation + wobble.rotation
			})
			rotateTween:Play()
			task.wait(wobble.duration)
		end
	end)

	-- GLOW EFFECT (create temporary glow)
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.BackgroundTransparency = 1
	glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	glow.ImageColor3 = FLASH_COLOR
	glow.ImageTransparency = 0.3
	glow.Size = UDim2.new(1.5, 0, 1.5, 0)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.ZIndex = coinsFrame.ZIndex - 1
	glow.Parent = coinsFrame

	-- Fade out and scale up the glow
	local glowTween = TweenService:Create(glow, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1,
		Size = UDim2.new(2.5, 0, 2.5, 0)
	})
	glowTween:Play()
	glowTween.Completed:Connect(function()
		glow:Destroy()
	end)

	print(`[CoinDisplay] 💰 Animated +{coinsAdded} coins! Total: {newValue}`)
end

-- Start listening for coin changes and update UI
function CoinDisplay.start()
	-- Wait for MainGui and Coins display
	local mainGui = playerGui:WaitForChild("MainGui")
	local coinsFrame = mainGui:WaitForChild("Coins")
	local moneyLabel = coinsFrame:WaitForChild("Money") :: TextLabel

	-- Store original position
	originalPosition = coinsFrame.Position

	-- Wait for player leaderstats to load
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Coins") :: IntValue

	-- Update display immediately
	moneyLabel.Text = tostring(coins.Value)
	print("[CoinDisplay] Initial coins:", coins.Value)

	-- Track previous value for animation
	local previousValue = coins.Value

	-- Listen for changes to coins value
	coins.Changed:Connect(function(newValue)
		animateCoinUpdate(moneyLabel, coinsFrame, newValue, previousValue)
		previousValue = newValue
	end)

	print("[CoinDisplay] Started coin display updater with epic animations! 🎉")
end

return CoinDisplay

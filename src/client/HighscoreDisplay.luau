--!strict
-- HighscoreDisplay.luau
-- Displays and updates the player's highscore in the UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local HighscoreDisplay = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Animation configuration
local FLASH_COLOR = Color3.fromRGB(255, 215, 0) -- Gold
local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255) -- White

-- Perform animation when highscore is beaten
local function animateNewHighscore(highscoreLabel: TextLabel, newValue: number)
	print(`[HighscoreDisplay] 🏆 NEW HIGHSCORE: {newValue}!`)

	-- GOLD FLASH EFFECT
	local originalColor = highscoreLabel.TextColor3
	highscoreLabel.TextColor3 = FLASH_COLOR

	local flashTween = TweenService:Create(highscoreLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextColor3 = originalColor
	})
	flashTween:Play()

	-- SCALE POP EFFECT
	local originalSize = highscoreLabel.TextSize
	highscoreLabel.TextSize = originalSize * 1.5

	local scaleTween = TweenService:Create(highscoreLabel, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		TextSize = originalSize
	})
	scaleTween:Play()
end

-- Start listening for highscore changes and update UI
function HighscoreDisplay.start()
	-- Wait for MainGui (if you have a highscore display there)
	-- For now, we'll just track it via leaderstats which is visible in player list

	-- Wait for player leaderstats to load
	local leaderstats = player:WaitForChild("leaderstats")
	local highscore = leaderstats:WaitForChild("Highscore") :: IntValue

	print(`[HighscoreDisplay] Initial highscore: {highscore.Value}`)

	-- Track previous value for animation
	local previousValue = highscore.Value

	-- Listen for changes to highscore value
	highscore.Changed:Connect(function(newValue)
		-- Only animate if highscore increased
		if newValue > previousValue then
			-- You can add UI update here if you create a highscore label in MainGui
			-- For example: highscoreLabel.Text = "Best: " .. tostring(newValue)

			print(`[HighscoreDisplay] 🏆 NEW HIGHSCORE! {previousValue} → {newValue}`)
		end
		previousValue = newValue
	end)

	print("[HighscoreDisplay] Highscore display system started")
end

return HighscoreDisplay

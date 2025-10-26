--!strict
-- TimeDisplay.luau
-- Manages the 5-minute countdown timer with color-shifting bar

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TimeDisplay = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Timer configuration
local TOTAL_TIME = 300 -- 5 minutes in seconds
local timeRemaining = TOTAL_TIME

-- Color configuration for gradient
local GREEN_COLOR = Color3.fromRGB(51, 255, 136)
local YELLOW_COLOR = Color3.fromRGB(241, 196, 15)
local RED_COLOR = Color3.fromRGB(231, 76, 60)

-- Format seconds into MM:SS
local function formatTime(seconds: number): string
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d", mins, secs)
end

-- Get color based on time percentage
local function getColorForPercentage(percentage: number): Color3
	if percentage > 0.5 then
		-- Interpolate between green and yellow (100% to 50%)
		local t = (percentage - 0.5) / 0.5 -- Normalize to 0-1 range
		return YELLOW_COLOR:Lerp(GREEN_COLOR, t)
	else
		-- Interpolate between red and yellow (50% to 0%)
		local t = percentage / 0.5 -- Normalize to 0-1 range
		return RED_COLOR:Lerp(YELLOW_COLOR, t)
	end
end

-- Update the time display and bar
local function updateTimeDisplay(timeText: TextLabel, timeBar: Frame)
	-- Update text
	timeText.Text = formatTime(timeRemaining)

	-- Calculate percentage
	local percentage = timeRemaining / TOTAL_TIME

	-- Update bar size
	timeBar.Size = UDim2.new(percentage, 0, 1, 0)

	-- Update bar color with gradient
	local barColor = getColorForPercentage(percentage)
	timeBar.BackgroundColor3 = barColor
end

-- Start the countdown timer
function TimeDisplay.start()
	-- Wait for MainGui and Time display
	local mainGui = playerGui:WaitForChild("MainGui")
	local timeFrame = mainGui:WaitForChild("Time")
	local timeText = timeFrame:WaitForChild("TimeText") :: TextLabel
	local barContainer = timeFrame:WaitForChild("Bar") :: Frame
	local timeBar = barContainer:WaitForChild("Time") :: Frame

	-- Reset timer to 5 minutes
	timeRemaining = TOTAL_TIME

	-- Set initial display
	updateTimeDisplay(timeText, timeBar)

	print("[TimeDisplay] Started 5-minute countdown timer")

	-- Start countdown loop
	local updateConnection: RBXScriptConnection?

	updateConnection = RunService.RenderStepped:Connect(function(dt)
		-- Decrement time
		timeRemaining = math.max(0, timeRemaining - dt)

		-- Update display every frame for smooth bar animation
		updateTimeDisplay(timeText, timeBar)

		-- Optional: Stop at 0 (though you said no logic needed)
		if timeRemaining <= 0 then
			if updateConnection then
				updateConnection:Disconnect()
			end
			print("[TimeDisplay] ⏰ Timer reached 00:00")
		end
	end)
end

-- Get remaining time (useful for other systems)
function TimeDisplay.getTimeRemaining(): number
	return timeRemaining
end

-- Reset timer (for replayability)
function TimeDisplay.reset()
	timeRemaining = TOTAL_TIME
	print("[TimeDisplay] Timer reset to 5 minutes")
end

return TimeDisplay

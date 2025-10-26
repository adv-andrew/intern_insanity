--!strict
-- CoinDisplay.luau
-- Updates the coin display UI when player's coins change

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CoinDisplay = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Start listening for coin changes and update UI
function CoinDisplay.start()
	-- Wait for MainGui and Coins display
	local mainGui = playerGui:WaitForChild("MainGui")
	local coinsFrame = mainGui:WaitForChild("Coins")
	local moneyLabel = coinsFrame:WaitForChild("Money") :: TextLabel

	-- Wait for player leaderstats to load
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Coins") :: IntValue

	-- Update display immediately
	moneyLabel.Text = tostring(coins.Value)
	print("[CoinDisplay] Initial coins:", coins.Value)

	-- Listen for changes to coins value
	coins.Changed:Connect(function(newValue)
		moneyLabel.Text = tostring(newValue)
		print("[CoinDisplay] Coins updated to:", newValue)
	end)

	print("[CoinDisplay] Started coin display updater")
end

return CoinDisplay

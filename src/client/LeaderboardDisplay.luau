--!strict
-- LeaderboardDisplay.luau
-- Displays the leaderboard at the end of the round

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardDisplay = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Show the leaderboard with data from the server
function LeaderboardDisplay.show()
	-- Get shared modules
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

	-- Request leaderboard data from server
	print("[LeaderboardDisplay] Requesting leaderboard data...")
	local leaderboardData = RemoteEvents.GetLeaderboard:InvokeServer()

	if not leaderboardData then
		warn("[LeaderboardDisplay] Failed to get leaderboard data")
		return
	end

	print(`[LeaderboardDisplay] Received leaderboard data: {#leaderboardData.TopPlayers} top players`)

	-- Get UI references
	local endGui = playerGui:WaitForChild("EndGui")
	local leaderboard = endGui:WaitForChild("Leaderboard")
	local container = leaderboard:WaitForChild("Container")
	local youContainer = leaderboard:WaitForChild("YouContainer")
	local youFrame = youContainer:WaitForChild("YouFrame")

	-- Get the leaderboard frame template
	local assets = ReplicatedStorage:WaitForChild("Assets")
	local leaderboardFrameTemplate = assets:WaitForChild("LeaderboardFrame")

	-- Clear existing frames
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Populate top 9 players
	for _, playerData in ipairs(leaderboardData.TopPlayers) do
		local frame = leaderboardFrameTemplate:Clone()
		frame.LayoutOrder = playerData.Position

		-- Set text labels
		local positionLabel = frame:FindFirstChild("Position") :: TextLabel
		local moneyLabel = frame:FindFirstChild("Money") :: TextLabel
		local nameLabel = frame:FindFirstChild("Name") :: TextLabel

		if positionLabel then
			positionLabel.Text = `#{playerData.Position}`
		end

		if moneyLabel then
			moneyLabel.Text = tostring(playerData.Highscore)
		end

		if nameLabel then
			nameLabel.Text = playerData.Name
		end

		frame.Parent = container
		print(`[LeaderboardDisplay] Added {playerData.Name} at position {playerData.Position} with {playerData.Highscore} coins`)
	end

	-- Populate player's own frame
	local yourData = leaderboardData.YourData
	local yourPosition = youFrame:FindFirstChild("Position") :: TextLabel
	local yourMoney = youFrame:FindFirstChild("Money") :: TextLabel
	local yourName = youFrame:FindFirstChild("Name") :: TextLabel

	if yourPosition then
		yourPosition.Text = `#{yourData.Position}`
	end

	if yourMoney then
		yourMoney.Text = tostring(yourData.Coins)
	end

	if yourName then
		yourName.Text = yourData.Name
	end

	print(`[LeaderboardDisplay] Your position: #{yourData.Position} with {yourData.Coins} coins`)

	-- Enable the EndGui
	endGui.Enabled = true
	print("[LeaderboardDisplay] EndGui enabled - leaderboard displayed!")
end

return LeaderboardDisplay

--!strict
-- Leaderstats.server.luau
-- Manages player leaderstats and coins

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

-- Create leaderstats when player joins
Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	print(`[Leaderstats] Created leaderstats for {player.Name}`)
end)

-- Handle coin awarding from client
RemoteEvents.AwardCoins.OnServerEvent:Connect(function(player, coinsToAward: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + coinsToAward
			print(`[Leaderstats] Awarded {coinsToAward} coins to {player.Name}. Total: {coins.Value}`)
		end
	end
end)

-- Handle coin reset from client
RemoteEvents.ResetCoins.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = 0
			print(`[Leaderstats] Reset coins for {player.Name}`)
		end
	end
end)

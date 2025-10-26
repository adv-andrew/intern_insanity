--!strict
-- DataStoreService.luau
-- Manages player data persistence (highscores)

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataStore = {}

-- DataStore configuration
local DATASTORE_NAME = "PlayerHighscores_v1"
local highscoreDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)

-- Cache for player highscores (in-memory)
local playerHighscores: {[Player]: number} = {}

-- Get a player's highscore key
local function getPlayerKey(player: Player): string
	return "Player_" .. player.UserId
end

-- Load player's highscore from DataStore
function DataStore.loadPlayerHighscore(player: Player): number
	local key = getPlayerKey(player)
	local success, highscore = pcall(function()
		return highscoreDataStore:GetAsync(key)
	end)

	if success then
		local score = highscore or 0
		playerHighscores[player] = score
		print(`[DataStore] Loaded highscore for {player.Name}: {score}`)
		return score
	else
		warn(`[DataStore] Failed to load highscore for {player.Name}: {highscore}`)
		playerHighscores[player] = 0
		return 0
	end
end

-- Save player's highscore to DataStore
function DataStore.savePlayerHighscore(player: Player, newScore: number): boolean
	local key = getPlayerKey(player)

	-- Get current highscore
	local currentHighscore = playerHighscores[player] or 0

	-- Only save if new score is higher
	if newScore <= currentHighscore then
		print(`[DataStore] Score {newScore} is not higher than current highscore {currentHighscore} for {player.Name}`)
		return false
	end

	-- Save to DataStore
	local success, errorMessage = pcall(function()
		highscoreDataStore:SetAsync(key, newScore)
	end)

	if success then
		playerHighscores[player] = newScore
		print(`[DataStore] ✅ NEW HIGHSCORE for {player.Name}: {newScore} (previous: {currentHighscore})`)
		return true
	else
		warn(`[DataStore] Failed to save highscore for {player.Name}: {errorMessage}`)
		return false
	end
end

-- Get player's cached highscore (no DataStore call)
function DataStore.getPlayerHighscore(player: Player): number
	return playerHighscores[player] or 0
end

-- Get top players by highscore (returns array of {Name, Highscore, Position})
function DataStore.getTopPlayers(count: number): {{Name: string, Highscore: number, Position: number}}
	local playerList = {}

	-- Gather all players and their highscores
	for player, highscore in pairs(playerHighscores) do
		table.insert(playerList, {
			Player = player,
			Name = player.Name,
			Highscore = highscore
		})
	end

	-- Sort by highscore descending
	table.sort(playerList, function(a, b)
		return a.Highscore > b.Highscore
	end)

	-- Build top N list with positions
	local topPlayers = {}
	for i = 1, math.min(count, #playerList) do
		table.insert(topPlayers, {
			Name = playerList[i].Name,
			Highscore = playerList[i].Highscore,
			Position = i
		})
	end

	return topPlayers
end

-- Get player's leaderboard position
function DataStore.getPlayerPosition(targetPlayer: Player): number
	local playerList = {}

	-- Gather all players and their highscores
	for player, highscore in pairs(playerHighscores) do
		table.insert(playerList, {
			Player = player,
			Highscore = highscore
		})
	end

	-- Sort by highscore descending
	table.sort(playerList, function(a, b)
		return a.Highscore > b.Highscore
	end)

	-- Find position
	for i, data in ipairs(playerList) do
		if data.Player == targetPlayer then
			return i
		end
	end

	return #playerList -- Default to last position
end

-- Update highscore if new score is higher (called at end of round)
function DataStore.updateHighscore(player: Player, newScore: number): boolean
	local currentHighscore = playerHighscores[player] or 0

	if newScore > currentHighscore then
		return DataStore.savePlayerHighscore(player, newScore)
	else
		print(`[DataStore] Score {newScore} did not beat highscore {currentHighscore} for {player.Name}`)
		return false
	end
end

-- Initialize DataStore system
function DataStore.init()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

	-- Load highscore when player joins
	Players.PlayerAdded:Connect(function(player)
		-- Load highscore from DataStore
		DataStore.loadPlayerHighscore(player)

		-- Create a Highscore value in leaderstats for easy access
		local leaderstats = player:WaitForChild("leaderstats")
		local highscoreValue = Instance.new("IntValue")
		highscoreValue.Name = "Highscore"
		highscoreValue.Value = playerHighscores[player] or 0
		highscoreValue.Parent = leaderstats

		print(`[DataStore] Created Highscore stat for {player.Name}`)
	end)

	-- Save highscore when player leaves
	Players.PlayerRemoving:Connect(function(player)
		local currentScore = 0
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins then
				currentScore = coins.Value
			end
		end

		-- Try to update highscore one last time before leaving
		DataStore.updateHighscore(player, currentScore)

		-- Clean up cache
		playerHighscores[player] = nil
		print(`[DataStore] Cleaned up data for {player.Name}`)
	end)

	-- Handle highscore update requests from client (at end of round)
	RemoteEvents.UpdateHighscore.OnServerEvent:Connect(function(player)
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins then
				local newScore = coins.Value
				local wasNewHighscore = DataStore.updateHighscore(player, newScore)

				-- Update the Highscore value in leaderstats
				if wasNewHighscore then
					local highscoreValue = leaderstats:FindFirstChild("Highscore")
					if highscoreValue then
						highscoreValue.Value = newScore
					end
				end
			end
		end
	end)

	-- Handle leaderboard data requests from client
	RemoteEvents.GetLeaderboard.OnServerInvoke = function(player)
		-- Get top 9 players
		local topPlayers = DataStore.getTopPlayers(9)

		-- Get the requesting player's data
		local playerPosition = DataStore.getPlayerPosition(player)
		local playerHighscore = DataStore.getPlayerHighscore(player)
		local playerCoins = 0

		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins then
				playerCoins = coins.Value
			end
		end

		local leaderboardData = {
			TopPlayers = topPlayers,
			YourData = {
				Name = player.Name,
				Position = playerPosition,
				Highscore = playerHighscore,
				Coins = playerCoins
			}
		}

		print(`[DataStore] Sent leaderboard data to {player.Name}`)
		return leaderboardData
	end

	print("[DataStore] DataStore system initialized")
end

return DataStore

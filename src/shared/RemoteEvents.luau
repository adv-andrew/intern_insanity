-- RemoteEvents.luau
-- Centralized remote event management for client-server task communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteEvents = {}

-- Find or create RemoteEvent for spawning tasks on clients
local spawnTaskEvent = ReplicatedStorage:FindFirstChild("SpawnTaskEvent")

if not spawnTaskEvent then
    -- Only create on server side
    if RunService:IsServer() then
        spawnTaskEvent = Instance.new("RemoteEvent")
        spawnTaskEvent.Name = "SpawnTaskEvent"
        spawnTaskEvent.Parent = ReplicatedStorage
    else
        -- Client waits for server to create it
        spawnTaskEvent = ReplicatedStorage:WaitForChild("SpawnTaskEvent", 10)
    end
end

RemoteEvents.SpawnTask = spawnTaskEvent

-- Find or create RemoteEvent for player ready signal
local playerReadyEvent = ReplicatedStorage:FindFirstChild("PlayerReadyEvent")

if not playerReadyEvent then
    if RunService:IsServer() then
        playerReadyEvent = Instance.new("RemoteEvent")
        playerReadyEvent.Name = "PlayerReadyEvent"
        playerReadyEvent.Parent = ReplicatedStorage
    else
        playerReadyEvent = ReplicatedStorage:WaitForChild("PlayerReadyEvent", 10)
    end
end

RemoteEvents.PlayerReady = playerReadyEvent

-- Find or create RemoteEvent for door teleportation
local doorTeleportEvent = ReplicatedStorage:FindFirstChild("DoorTeleportEvent")

if not doorTeleportEvent then
    if RunService:IsServer() then
        doorTeleportEvent = Instance.new("RemoteEvent")
        doorTeleportEvent.Name = "DoorTeleportEvent"
        doorTeleportEvent.Parent = ReplicatedStorage
    else
        doorTeleportEvent = ReplicatedStorage:WaitForChild("DoorTeleportEvent", 10)
    end
end

RemoteEvents.DoorTeleport = doorTeleportEvent

-- Find or create RemoteEvent for task completion signal
local taskCompletedEvent = ReplicatedStorage:FindFirstChild("TaskCompletedEvent")

if not taskCompletedEvent then
    if RunService:IsServer() then
        taskCompletedEvent = Instance.new("RemoteEvent")
        taskCompletedEvent.Name = "TaskCompletedEvent"
        taskCompletedEvent.Parent = ReplicatedStorage
    else
        taskCompletedEvent = ReplicatedStorage:WaitForChild("TaskCompletedEvent", 10)
    end
end

RemoteEvents.TaskCompleted = taskCompletedEvent

-- Find or create RemoteEvent for awarding coins
local awardCoinsEvent = ReplicatedStorage:FindFirstChild("AwardCoinsEvent")

if not awardCoinsEvent then
	if RunService:IsServer() then
		awardCoinsEvent = Instance.new("RemoteEvent")
		awardCoinsEvent.Name = "AwardCoinsEvent"
		awardCoinsEvent.Parent = ReplicatedStorage
	else
		awardCoinsEvent = ReplicatedStorage:WaitForChild("AwardCoinsEvent", 10)
	end
end

RemoteEvents.AwardCoins = awardCoinsEvent

-- Find or create RemoteEvent for resetting coins
local resetCoinsEvent = ReplicatedStorage:FindFirstChild("ResetCoinsEvent")

if not resetCoinsEvent then
	if RunService:IsServer() then
		resetCoinsEvent = Instance.new("RemoteEvent")
		resetCoinsEvent.Name = "ResetCoinsEvent"
		resetCoinsEvent.Parent = ReplicatedStorage
	else
		resetCoinsEvent = ReplicatedStorage:WaitForChild("ResetCoinsEvent", 10)
	end
end

RemoteEvents.ResetCoins = resetCoinsEvent

-- Find or create RemoteEvent for updating highscore at end of round
local updateHighscoreEvent = ReplicatedStorage:FindFirstChild("UpdateHighscoreEvent")

if not updateHighscoreEvent then
	if RunService:IsServer() then
		updateHighscoreEvent = Instance.new("RemoteEvent")
		updateHighscoreEvent.Name = "UpdateHighscoreEvent"
		updateHighscoreEvent.Parent = ReplicatedStorage
	else
		updateHighscoreEvent = ReplicatedStorage:WaitForChild("UpdateHighscoreEvent", 10)
	end
end

RemoteEvents.UpdateHighscore = updateHighscoreEvent

-- Find or create RemoteFunction for getting leaderboard data
local getLeaderboardFunction = ReplicatedStorage:FindFirstChild("GetLeaderboardFunction")

if not getLeaderboardFunction then
	if RunService:IsServer() then
		getLeaderboardFunction = Instance.new("RemoteFunction")
		getLeaderboardFunction.Name = "GetLeaderboardFunction"
		getLeaderboardFunction.Parent = ReplicatedStorage
	else
		getLeaderboardFunction = ReplicatedStorage:WaitForChild("GetLeaderboardFunction", 10)
	end
end

RemoteEvents.GetLeaderboard = getLeaderboardFunction

return RemoteEvents

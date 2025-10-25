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

return RemoteEvents

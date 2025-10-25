-- Server initialization
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TaskManager = require(script.TaskManager)

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

local gameStarted = false

-- Listen for player ready signals
RemoteEvents.PlayerReady.OnServerEvent:Connect(function(player)
    -- Start the game when first player is ready
    if not gameStarted then
        gameStarted = true

        -- Start the task manager in a separate thread
        task.spawn(function()
            TaskManager.start()
        end)
    end
end)

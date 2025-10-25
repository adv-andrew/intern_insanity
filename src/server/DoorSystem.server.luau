-- ServerScriptService/Server/DoorSystem.server.luau
-- Handles door teleportation between office and rooms

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get doors folder
local Doors = Workspace:WaitForChild("Doors")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = require(Shared:WaitForChild("RemoteEvents"))

-- Door mappings: when player touches TP of key, teleport to Entrance of value
local doorMappings = {
    OfficeToServer = "ServerToOffice",
    OfficeToManager = "ManagerToOffice",
    OfficeToConference = "ConferenceToOffice",
    ServerToOffice = "OfficeToServer",
    ManagerToOffice = "OfficeToManager",
    ConferenceToOffice = "OfficeToConference",
}

-- Debounce table to prevent rapid teleportation
local debounce = {}

-- Setup a door's TP part to teleport to the destination door's Entrance
local function setupDoor(doorName: string, destinationName: string)
    local door = Doors:FindFirstChild(doorName)
    local destinationDoor = Doors:FindFirstChild(destinationName)

    if not door then
        warn("[DoorSystem] Door not found:", doorName)
        return
    end

    if not destinationDoor then
        warn("[DoorSystem] Destination door not found:", destinationName)
        return
    end

    local tpPart = door:FindFirstChild("TP")
    local entrancePart = destinationDoor:FindFirstChild("Entrance")

    if not tpPart then
        warn("[DoorSystem] TP part not found in:", doorName)
        return
    end

    if not entrancePart then
        warn("[DoorSystem] Entrance part not found in:", destinationName)
        return
    end

    -- Setup touch event
    tpPart.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if not humanoid then
            return
        end

        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if not player then
            return
        end

        -- Debounce check
        if debounce[player] then
            return
        end

        debounce[player] = true

        -- Signal client to start fade
        RemoteEvents.DoorTeleport:FireClient(player, entrancePart.CFrame)

        -- Wait for fade in animation (0.5 seconds)
        task.wait(0.2)

        -- Teleport player
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if rootPart then
            rootPart.CFrame = entrancePart.CFrame
        end

        -- Wait for fade out animation to complete
        task.wait(0.2)

        debounce[player] = nil
    end)
end

-- Initialize all doors
for doorName, destinationName in pairs(doorMappings) do
    setupDoor(doorName, destinationName)
end

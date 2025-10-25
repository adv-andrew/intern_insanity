-- Client/RoomDetection.luau
-- Detects which room the player is currently in

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RoomDetection = {}

local player = Players.LocalPlayer
local currentRoom = nil

-- Get hitboxes folder
local Hitboxes = Workspace:WaitForChild("Hitbox")

-- Get all room hitboxes
local roomHitboxes = {
    Conference = Hitboxes:WaitForChild("Conference"),
    Manager = Hitboxes:WaitForChild("Manager"),
    Office = Hitboxes:WaitForChild("Office"),
    Server = Hitboxes:WaitForChild("Server"),
}

-- Check if a point is within a part's bounds (X and Z only, ignoring Y)
local function isPointInPartXZ(point: Vector3, part: BasePart): boolean
    local partPos = part.Position
    local partSize = part.Size

    local halfSizeX = partSize.X / 2
    local halfSizeZ = partSize.Z / 2

    local minX = partPos.X - halfSizeX
    local maxX = partPos.X + halfSizeX
    local minZ = partPos.Z - halfSizeZ
    local maxZ = partPos.Z + halfSizeZ

    return point.X >= minX and point.X <= maxX and point.Z >= minZ and point.Z <= maxZ
end

-- Detect which room the player is in based on their position
local function detectRoom(position: Vector3): string?
    for roomName, hitbox in pairs(roomHitboxes) do
        if isPointInPartXZ(position, hitbox) then
            return roomName
        end
    end
    return nil
end

-- Start room detection
function RoomDetection.start()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Check room every frame
    RunService.Heartbeat:Connect(function()
        if not humanoidRootPart or not humanoidRootPart.Parent then
            return
        end

        local playerPosition = humanoidRootPart.Position
        local detectedRoom = detectRoom(playerPosition)

        -- Only print when room changes
        if detectedRoom ~= currentRoom then
            currentRoom = detectedRoom
        end
    end)

    -- Handle character respawns
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        currentRoom = nil
    end)
end

-- Get the current room the player is in
function RoomDetection.getCurrentRoom(): string?
    return currentRoom
end

return RoomDetection

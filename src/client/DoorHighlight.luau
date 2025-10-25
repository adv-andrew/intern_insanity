-- Client/DoorHighlight.luau
-- Highlights doors based on selected task objectives and current room

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local RoomDetection = require(script.Parent.RoomDetection)

local DoorHighlight = {}

-- Get doors folder
local Doors = Workspace:WaitForChild("Doors")

-- Mapping of current room + target room to door name
local doorRoutes = {
    Office = {
        Conference = "OfficeToConference",
        Manager = "OfficeToManager",
        Server = "OfficeToServer",
    },
    Conference = {
        Office = "ConferenceToOffice",
    },
    Manager = {
        Office = "ManagerToOffice",
    },
    Server = {
        Office = "ServerToOffice",
    },
}

local currentHighlight = nil

-- Remove existing highlight
local function removeHighlight()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

-- Add highlight to a door
local function highlightDoor(doorName: string)
    removeHighlight()

    local door = Doors:FindFirstChild(doorName)
    if not door then
        warn("[DoorHighlight] Door not found:", doorName)
        return
    end

    -- Create Highlight instance
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0) -- Orange-yellow
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = door

    currentHighlight = highlight
end

-- Update door highlight based on current room and target room
function DoorHighlight.updateHighlight(targetRoom: string)
    local currentRoom = RoomDetection.getCurrentRoom()

    -- If not in a room, remove highlight
    if not currentRoom then
        removeHighlight()
        return
    end

    -- If already in target room, remove highlight
    if currentRoom == targetRoom then
        removeHighlight()
        return
    end

    -- Find the door to highlight
    local routes = doorRoutes[currentRoom]
    if not routes then
        removeHighlight()
        return
    end

    local doorToHighlight = routes[targetRoom]
    if doorToHighlight then
        highlightDoor(doorToHighlight)
    else
        -- No direct route, player needs to go to Office first
        if targetRoom ~= "Office" and routes.Office then
            highlightDoor(routes.Office)
        else
            removeHighlight()
        end
    end
end

-- Clear all highlights
function DoorHighlight.clear()
    removeHighlight()
end

return DoorHighlight

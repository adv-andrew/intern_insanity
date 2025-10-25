-- Client/TaskBehaviors.luau
-- Handles task-specific behaviors and objective completion

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ServerTaskMinigame = require(script.Parent.ServerTaskMinigame)

local TaskBehaviors = {}

local player = Players.LocalPlayer

-- PrinterJam task state
local hasPapers = false

-- AWSOutage task state
local awsTaskCompletionCallback = nil

-- Handle PrinterJam task interactions
function TaskBehaviors.handlePrinterJamInteraction(objectPath: string, currentObjectiveIndex: number)
    if objectPath == "Conference.PaperStack" and currentObjectiveIndex == 1 then
        -- First objective: Pick up papers
        hasPapers = true
        print("[TaskBehaviors] Player picked up papers")
        return true -- Objective completed
    elseif objectPath == "Office.Printer" and currentObjectiveIndex == 2 then
        -- Second objective: Deliver papers to printer
        if hasPapers then
            hasPapers = false
            print("[TaskBehaviors] Papers delivered")
            return true -- Objective completed and task finished
        else
            warn("[TaskBehaviors] Cannot deliver papers - you don't have them!")
            return false
        end
    end
    return false
end

-- Handle AWSOutage task interactions
function TaskBehaviors.handleAWSOutageInteraction(objectPath: string, currentObjectiveIndex: number, completionCallback)
    if objectPath == "ServerRoom.ServerMain" and currentObjectiveIndex == 1 then
        -- Open the ServerTask GUI
        local playerGui = player:WaitForChild("PlayerGui")
        local mainGui = playerGui:WaitForChild("MainGui")
        local serverTask = mainGui:FindFirstChild("ServerTask")

        if serverTask then
            serverTask.Visible = true
            print("[TaskBehaviors] ServerTask GUI opened")

            -- Store the completion callback
            awsTaskCompletionCallback = completionCallback

            -- Start the minigame with a callback for when it's completed
            ServerTaskMinigame.start(function()
                print("[TaskBehaviors] Server minigame completed!")
                if awsTaskCompletionCallback then
                    awsTaskCompletionCallback()
                    awsTaskCompletionCallback = nil
                end
            end)

            -- Return false because task is not completed yet (player needs to complete the server task)
            return false
        else
            warn("[TaskBehaviors] ServerTask GUI not found!")
            return false
        end
    end
    return false
end

-- Get if player has papers
function TaskBehaviors.hasPapers(): boolean
    return hasPapers
end

return TaskBehaviors

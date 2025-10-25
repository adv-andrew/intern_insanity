-- Client/TaskBehaviors.luau
-- Handles task-specific behaviors and objective completion

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local TaskBehaviors = {}

local player = Players.LocalPlayer

-- PrinterJam task state
local hasPapers = false

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

-- Get if player has papers
function TaskBehaviors.hasPapers(): boolean
    return hasPapers
end

return TaskBehaviors

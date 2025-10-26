-- Client/TaskBehaviors.luau
-- Handles task-specific behaviors and objective completion

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ServerTaskMinigame = require(script.Parent.ServerTaskMinigame)
local FadeController = require(script.Parent.FadeController)
local SpeechBubble = require(script.Parent.SpeechBubble)

local TaskBehaviors = {}

local player = Players.LocalPlayer
local TaskManager = nil -- Will be set via setTaskManager to avoid circular dependency

-- Set TaskManager reference (called from TaskManager to avoid circular dependency)
function TaskBehaviors.setTaskManager(taskManagerModule)
    TaskManager = taskManagerModule
end

-- PrinterJam task state
local hasPapers = false

-- AWSOutage task state
local awsTaskCompletionCallback = nil

-- CoworkerConflict task state
local coworkerTaskCompletionCallback = nil

-- FixBugQuiz task state
local bugTaskCompletionCallback = nil

-- TalkToBoss task state
local bossTaskCompletionCallback = nil

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

-- Handle CoworkerConflict task interactions
function TaskBehaviors.handleCoworkerConflictInteraction(objectPath: string, currentObjectiveIndex: number, completionCallback)
    if objectPath == "Office.npcs.CoWorkers" and currentObjectiveIndex == 1 then
        -- Open the CoworkerTask GUI
        local playerGui = player:WaitForChild("PlayerGui")
        local mainGui = playerGui:WaitForChild("MainGui")
        local coworkerTask = mainGui:FindFirstChild("CoworkerTask")

        if coworkerTask then
            coworkerTask.Visible = true

            -- Store the completion callback
            coworkerTaskCompletionCallback = completionCallback

            -- Find the A, B, and C choice buttons
            local choiceA = coworkerTask:FindFirstChild("A")
            local choiceB = coworkerTask:FindFirstChild("B")
            local choiceC = coworkerTask:FindFirstChild("C")

            -- Connect choice A (incorrect)
            if choiceA then
                local selectButtonA = choiceA:FindFirstChild("SelectButton")
                if selectButtonA then
                    selectButtonA.Activated:Connect(function()
                        FadeController.redFlash()
                        if TaskManager then
                            TaskManager.reduceCurrentTaskTime(20) -- Lose 20% of remaining time
                            TaskManager.markPlayerFailed() -- Mark as failed for wrong answer
                        end
                    end)
                end
            end

            -- Connect choice B (correct)
            if choiceB then
                local selectButtonB = choiceB:FindFirstChild("SelectButton")
                if selectButtonB then
                    selectButtonB.Activated:Connect(function()
                        FadeController.greenFlash()
                        coworkerTask.Visible = false

                        -- Complete task (success)
                        if coworkerTaskCompletionCallback then
                            coworkerTaskCompletionCallback()
                            coworkerTaskCompletionCallback = nil
                        end
                    end)
                end
            end

            -- Connect choice C (incorrect)
            if choiceC then
                local selectButtonC = choiceC:FindFirstChild("SelectButton")
                if selectButtonC then
                    selectButtonC.Activated:Connect(function()
                        FadeController.redFlash()
                        if TaskManager then
                            TaskManager.reduceCurrentTaskTime(20) -- Lose 20% of remaining time
                            TaskManager.markPlayerFailed() -- Mark as failed for wrong answer
                        end
                    end)
                end
            end

            -- Task is not completed yet - waiting for player choice
            return false
        else
            warn("[TaskBehaviors] CoworkerTask GUI not found!")
            return false
        end
    end
    return false
end

-- Handle FixBugQuiz task interactions
function TaskBehaviors.handleFixBugQuizInteraction(objectPath: string, currentObjectiveIndex: number, completionCallback)
    if objectPath == "Office.PlayerDesk" and currentObjectiveIndex == 1 then
        -- Open the BugTask GUI
        local playerGui = player:WaitForChild("PlayerGui")
        local mainGui = playerGui:WaitForChild("MainGui")
        local bugTask = mainGui:FindFirstChild("BugTask")

        if bugTask then
            bugTask.Visible = true

            -- Store the completion callback
            bugTaskCompletionCallback = completionCallback

            -- Get the Code container
            local codeContainer = bugTask:FindFirstChild("Code")
            if not codeContainer then
                warn("[TaskBehaviors] BugTask.Code not found!")
                return false
            end

            -- Get TweenService for hover effects
            local TweenService = game:GetService("TweenService")
            local hoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            -- Setup line selection for lines 1-6
            for lineNumber = 1, 6 do
                local lineLabel = codeContainer:FindFirstChild(tostring(lineNumber))
                if lineLabel and lineLabel:IsA("TextLabel") then
                    local selectButton = lineLabel:FindFirstChild("SelectButton")

                    if selectButton and selectButton:IsA("TextButton") then
                        -- Setup hover effects
                        selectButton.MouseEnter:Connect(function()
                            local hoverTween = TweenService:Create(
                                lineLabel,
                                hoverTweenInfo,
                                { BackgroundTransparency = 0.95 }
                            )
                            hoverTween:Play()
                        end)

                        selectButton.MouseLeave:Connect(function()
                            local unhoverTween = TweenService:Create(
                                lineLabel,
                                hoverTweenInfo,
                                { BackgroundTransparency = 1 }
                            )
                            unhoverTween:Play()
                        end)

                        -- Setup click handler
                        if lineNumber == 5 then
                            -- Line 5 is correct
                            selectButton.Activated:Connect(function()
                                FadeController.greenFlash()
                                bugTask.Visible = false

                                -- Complete task (success)
                                if bugTaskCompletionCallback then
                                    bugTaskCompletionCallback()
                                    bugTaskCompletionCallback = nil
                                end
                            end)
                        else
                            -- Lines 1, 2, 3, 4, 6 are incorrect
                            selectButton.Activated:Connect(function()
                                FadeController.redFlash()
                                if TaskManager then
                                    TaskManager.reduceCurrentTaskTime(20) -- Lose 20% of remaining time
                                    TaskManager.markPlayerFailed() -- Mark as failed for wrong answer
                                end
                            end)
                        end
                    end
                end
            end

            -- Task is not completed yet - waiting for player to fix the bug
            return false
        else
            warn("[TaskBehaviors] BugTask GUI not found!")
            return false
        end
    end
    return false
end

-- Handle TalkToBoss task interactions
function TaskBehaviors.handleTalkToBossInteraction(objectPath: string, currentObjectiveIndex: number, completionCallback)
    print("[TaskBehaviors] handleTalkToBossInteraction called with objectPath:", objectPath, "objectiveIndex:", currentObjectiveIndex)

    if objectPath == "BossRoom.Boss" and currentObjectiveIndex == 1 then
        print("[TaskBehaviors] Matched BossRoom.Boss interaction")
        -- Find the Boss NPC in BossRoom
        local bossRoom = Workspace:FindFirstChild("BossRoom")
        if not bossRoom then
            warn("[TaskBehaviors] BossRoom not found in Workspace")
            return false
        end

        local boss = bossRoom:FindFirstChild("Boss")
        if not boss then
            warn("[TaskBehaviors] Boss not found in BossRoom")
            return false
        end

        -- Check if player passed or failed (NO default fallback - must have TaskManager)
        if not TaskManager then
            warn("[TaskBehaviors] TaskManager not available")
            return false
        end

        local playerPassed = TaskManager.hasPlayerPassed()
        print("[TaskBehaviors] Player pass status:", playerPassed)

        -- Show speech bubble sequence based on pass/fail
        task.spawn(function()
            if playerPassed then
                print("[TaskBehaviors] Player PASSED - showing success sequence")
                -- Player passed - return offer
                SpeechBubble.showSequence(boss, {
                    "HEY INTERN!",
                    "BASED ON YOUR PERFORMANCE...",
                    "I WILL GIVE YOU A RETURN OFFER!"
                }, 2.5)

                -- Wait for speech bubbles to finish (3 messages * 2.5 seconds each)
                task.wait(7.5)

                -- Complete the task
                if bossTaskCompletionCallback then
                    bossTaskCompletionCallback()
                    bossTaskCompletionCallback = nil
                end
            else
                print("[TaskBehaviors] Player FAILED - showing fired sequence")
                -- Player failed - fired
                SpeechBubble.showSequence(boss, {
                    "HEY INTERN!",
                    "BASED ON YOUR PERFORMANCE...",
                    "YOU'RE FIRED!"
                }, 2.5)

                print("[TaskBehaviors] Speech bubbles started, waiting 7.5 seconds...")
                -- Wait for speech bubbles to finish (3 messages * 2.5 seconds each)
                task.wait(7.5)

                print("[TaskBehaviors] Speech bubbles finished, waiting 5 more seconds...")
                -- Wait 5 more seconds after "YOU'RE FIRED"
                task.wait(5)
                print("[TaskBehaviors] 5 second wait complete, starting cutscene...")

                -- Trigger fade to black with camera switch at midpoint
                print("[TaskBehaviors] Starting fade transition...")
                FadeController.fadeToBlackWithCallback(function()
                    print("[TaskBehaviors] Fade midpoint reached - switching camera")

                    -- At midpoint (screen is fully black), switch camera to cutscene
                    local cutscenePart = Workspace:FindFirstChild("CutscenePart")
                    if not cutscenePart then
                        warn("[TaskBehaviors] CutscenePart not found in Workspace")
                        return
                    end

                    print("[TaskBehaviors] Found CutscenePart at:", cutscenePart.CFrame)

                    -- Set player's camera to scriptable mode and position it
                    local currentCamera = Workspace.CurrentCamera
                    if currentCamera then
                        print("[TaskBehaviors] Setting camera type to Scriptable")
                        currentCamera.CameraType = Enum.CameraType.Scriptable
                        currentCamera.CFrame = cutscenePart.CFrame
                        print("[TaskBehaviors] Camera CFrame set to:", currentCamera.CFrame)
                    else
                        warn("[TaskBehaviors] CurrentCamera not found")
                    end

                    print("[TaskBehaviors] Switched camera to CutscenePart")
                end)
                print("[TaskBehaviors] Fade transition complete")

                -- Complete the task after cutscene
                if bossTaskCompletionCallback then
                    bossTaskCompletionCallback()
                    bossTaskCompletionCallback = nil
                end
            end
        end)

        -- Task is not completed yet - waiting for speech bubbles to finish
        return false
    end
    return false
end

-- Get if player has papers
function TaskBehaviors.hasPapers(): boolean
    return hasPapers
end

return TaskBehaviors

--!strict
-- TaskRegistry: Central data bank for all tasks in the intern simulation

export type TaskCategory = "OfficeMovement" | "MentalBreaks" | "SocialTasks" | "TechTasks"

export type TaskObjective = {
    description: string,
    room: string, -- Room where objective must be completed
    objectModel: string?, -- Optional: Workspace path to the objective model (e.g., "Office.Printer")
}

export type Task = {
    id: string,
    name: string,
    description: string,
    emoji: string,
    timeToComplete: number, -- in seconds
    category: TaskCategory,
    objectives: { TaskObjective }?, -- Optional list of objectives
}

local TaskRegistry = {}

-- All available tasks in the game
TaskRegistry.Tasks = {
    -- ☕ Office Movement Tasks (movement-based)
    CoffeeRun = {
        id = "CoffeeRun",
        name = "Coffee Run",
        description = "Get coffee from the break room without spilling it",
        emoji = "☕",
        timeToComplete = 45,
        category = "OfficeMovement",
    } :: Task,

    DeliverPaperwork = {
        id = "DeliverPaperwork",
        name = "Deliver Paperwork",
        description = "Take these documents to the top floor",
        emoji = "📄",
        timeToComplete = 40,
        category = "OfficeMovement",
    } :: Task,

    -- 🧠 Mental Break / Distraction Tasks
    CheckSlackMemes = {
        id = "CheckSlackMemes",
        name = "Check Slack Memes",
        description = "Browse the #random channel for exactly 30 seconds",
        emoji = "😂",
        timeToComplete = 30,
        category = "MentalBreaks",
    } :: Task,

    ReplyToEmail = {
        id = "ReplyToEmail",
        name = "Reply to Email",
        description = "Send a quick email... don't hit Reply All!",
        emoji = "📧",
        timeToComplete = 25,
        category = "MentalBreaks",
    } :: Task,

    AttendStandUp = {
        id = "AttendStandUp",
        name = "Attend Stand-Up Meeting",
        description = "Stand silently while everyone shares updates",
        emoji = "🧍",
        timeToComplete = 60,
        category = "MentalBreaks",
    } :: Task,

    PeerCodeReview = {
        id = "PeerCodeReview",
        name = "Peer Code Review",
        description = "Review your colleague's messy code and approve it",
        emoji = "👀",
        timeToComplete = 50,
        category = "SocialTasks",
    } :: Task,

    OfficeGossip = {
        id = "OfficeGossip",
        name = "Office Gossip",
        description = "Listen to the latest drama by the water cooler",
        emoji = "🗣️",
        timeToComplete = 20,
        category = "SocialTasks",
    } :: Task,

    -- ⚙️ Silly Tech Tasks
    PushToGitHub = {
        id = "PushToGitHub",
        name = "Push to GitHub",
        description = "Push your code... hopefully not to main",
        emoji = "🚀",
        timeToComplete = 30,
        category = "TechTasks",
    } :: Task,

    RebootServer = {
        id = "RebootServer",
        name = "Reboot the Server",
        description = "Turn it off and on again. What could go wrong?",
        emoji = "🖥️",
        timeToComplete = 40,
        category = "TechTasks",
    } :: Task,

    RunUnitTests = {
        id = "RunUnitTests",
        name = "Run Unit Tests",
        description = "Execute the test suite and pray they all pass",
        emoji = "🧪",
        timeToComplete = 35,
        category = "TechTasks",
    } :: Task,

    PrinterJam = {
        id = "PrinterJam",
        name = "Printer Jam",
        description = "Fix the jammed printer before the boss notices",
        emoji = "🖨️",
        timeToComplete = 40,
        category = "OfficeMovement",
        objectives = {
            {
                description = "Get paper from Conference room",
                room = "Conference",
                objectModel = "Conference.PaperStack",
            },
            {
                description = "Deliver paper to Office printer",
                room = "Office",
                objectModel = "Office.Printer",
            },
        },
    } :: Task,

    AWSOutage = {
        id = "AWSOutage",
        name = "AWS Outage: Servers on Fire",
        description = "The servers are down! Fix it before anyone notices",
        emoji = "🔥",
        timeToComplete = 45,
        category = "TechTasks",
        objectives = {
            {
                description = "Go to Server room and reboot servers",
                room = "Server",
                objectModel = "ServerRoom.ServerMain",
            },
        },
    } :: Task,

        -- 👥 Coworker / Social Tasks
        CoworkerConflict = {
            id = "CoworkerConflict",
            name = "Coworker Conflict",
            description = "Two coworkers are arguing. Pick a side or stay neutral",
            emoji = "😠",
            timeToComplete = 35,
            category = "SocialTasks",
            objectives = {
                {
                    description = "Go talk to your co-workers",
                    room = "Office",
                    objectModel = "Office.npcs.CoWorkers",
                },
            },
        } :: Task,
    

    FixBugQuiz = {
        id = "FixBugQuiz",
        name = "Fix Bug Quiz",
        description = "Debug this code and prove your coding skills",
        emoji = "🐛",
        timeToComplete = 50,
        category = "TechTasks",
        objectives = {
            { description = "Go to Office and fix the code", room = "Office" },
        },
    } :: Task,
}

-- Get all tasks as an array
function TaskRegistry.getAllTasks(): { Task }
    local tasks = {}
    for _, task in TaskRegistry.Tasks do
        table.insert(tasks, task)
    end
    return tasks
end

-- Get tasks by category
function TaskRegistry.getTasksByCategory(category: TaskCategory): { Task }
    local tasks = {}
    for _, task in TaskRegistry.Tasks do
        if task.category == category then
            table.insert(tasks, task)
        end
    end
    return tasks
end

-- Get a random task
function TaskRegistry.getRandomTask(): Task
    local allTasks = TaskRegistry.getAllTasks()
    local randomIndex = math.random(1, #allTasks)
    return allTasks[randomIndex]
end

-- Get a random task from a specific category
function TaskRegistry.getRandomTaskByCategory(category: TaskCategory): Task
    local categoryTasks = TaskRegistry.getTasksByCategory(category)
    local randomIndex = math.random(1, #categoryTasks)
    return categoryTasks[randomIndex]
end

-- Get a task by ID
function TaskRegistry.getTaskById(taskId: string): Task?
    return TaskRegistry.Tasks[taskId]
end

return TaskRegistry

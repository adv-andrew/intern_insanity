--!strict
-- Client initialization script

local CameraController = require(script.CameraController)

print("Client initializing...")

-- Start the top-down camera controller
CameraController.start()

print("Top-down camera enabled!")

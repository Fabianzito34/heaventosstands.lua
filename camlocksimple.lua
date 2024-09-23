-- Camlock Script for Roblox with Prediction, Smoothness, and Movable Persistent "snorlax.lol" Button
-- This script locks the camera onto a target player's character.
-- It includes prediction, smooth movement, and the button stays on screen after death and can be dragged.

-- Variables
local camlockEnabled = false
local targetPlayer = nil
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = localPlayer:GetMouse()
local userInput = game:GetService("UserInputService")

-- Prediction and smoothness settings
local predictionStrength = 0.1 -- Adjust prediction strength for target movement
local smoothness = 0.2 -- Adjust smoothness for camlock transitions

-- Create the "snorlax.lol" button
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui -- Parent the GUI to CoreGui so it persists after death
ScreenGui.ResetOnSpawn = false

Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(0, 0, 0)
Button.Size = UDim2.new(0, 200, 0, 50) -- Button size
Button.Position = UDim2.new(0.5, -100, 0, 50) -- Initial position (center-top)
Button.Text = "snorlax.lol"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true
Button.Draggable = true -- Make sure the button is draggable
Button.Active = true -- Set the button to active to ensure proper dragging

-- Detect when the player starts dragging the button
Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local startPos = Button.Position
        local dragStart = input.Position

        local function update(input)
            local delta = input.Position - dragStart
            Button.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        local moveConnection
        local releaseConnection

        -- Listen for dragging movement
        moveConnection = userInput.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)

        -- Stop dragging when the mouse button is released
        releaseConnection = userInput.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConnection:Disconnect()
                releaseConnection:Disconnect()
            end
        end)
    end
end)

-- Function to get the target player
local function getTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = player.Character.HumanoidRootPart.Position
            local screenPos = camera:WorldToScreenPoint(playerPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

-- Function to predict target movement based on velocity
local function predictTargetPosition(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local velocity = target.Character.HumanoidRootPart.Velocity
        local predictedPosition = target.Character.HumanoidRootPart.Position + (velocity * predictionStrength)
        return predictedPosition
    end
    return nil
end

-- Main function to lock the camera with smooth transitions
local function lockCamera()
    if camlockEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local predictedPosition = predictTargetPosition(targetPlayer)
        if predictedPosition then
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
            -- Smoothly transition the camera to the predicted target position
            camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothness)
        end
    end
end

-- Button click event to toggle camlock
Button.MouseButton1Click:Connect(function()
    camlockEnabled = not camlockEnabled
    
    if camlockEnabled then
        targetPlayer = getTarget()
        Button.Text = "Camlock ON"
        print("Camlock Enabled on:", targetPlayer and targetPlayer.Name or "No Target")
    else
        targetPlayer = nil
        Button.Text = "snorlax.lol"
        print("Camlock Disabled")
    end
end)

-- Update the camera lock in every frame
game:GetService("RunService").RenderStepped:Connect(function()
    lockCamera()
end)
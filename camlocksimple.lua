-- Camlock Script for Roblox with "snorlax.lol" Button
-- This script locks the camera onto a target player's character.
-- A button is added to the screen to toggle camlock on/off.

-- Variables
local camlockEnabled = false
local targetPlayer = nil
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = localPlayer:GetMouse()
local userInput = game:GetService("UserInputService")

-- Create the "snorlax.lol" button
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(0, 0, 0)
Button.Size = UDim2.new(0, 200, 0, 50) -- Button size
Button.Position = UDim2.new(0.5, -100, 0, 50) -- Position in the center-top
Button.Text = "snorlax.lol"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true

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

-- Main function to lock the camera
local function lockCamera()
    if camlockEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = targetPlayer.Character.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
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
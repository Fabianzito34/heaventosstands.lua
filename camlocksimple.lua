-- Camlock Script for Roblox with Prediction, Smoothness, Movable Persistent "snorlax.lol" Button, and ESP with Health & Armor Indicators

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

-- Variables to store ESP elements
local espBox = nil
local healthLabel = nil
local armorLabel = nil

-- Function to create ESP for the camlock target
local function createESP(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        -- Create the ESP box
        espBox = Instance.new("BoxHandleAdornment")
        espBox.Name = "ESP"
        espBox.Adornee = target.Character.HumanoidRootPart
        espBox.Size = Vector3.new(4, 6, 0)
        espBox.Transparency = 0.5
        espBox.Color3 = Color3.fromRGB(255, 0, 0)
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 10
        espBox.Parent = camera

        -- Create health indicator
        healthLabel = Instance.new("BillboardGui", target.Character.HumanoidRootPart)
        healthLabel.Size = UDim2.new(0, 100, 0, 40)
        healthLabel.Adornee = target.Character.HumanoidRootPart
        healthLabel.StudsOffset = Vector3.new(0, 4, 0)

        local healthText = Instance.new("TextLabel", healthLabel)
        healthText.Size = UDim2.new(1, 0, 1, 0)
        healthText.BackgroundTransparency = 1
        healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthText.TextScaled = true
        healthText.Text = "Health: " .. tostring(target.Character:FindFirstChild("Humanoid").Health)

        
    end
end

-- Function to remove ESP elements
local function removeESP()
    if espBox then espBox:Destroy() end
    if healthLabel then healthLabel:Destroy() end
    if armorLabel then armorLabel:Destroy() end
end

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

-- Main function to lock the camera with smooth transitions and ESP
local function lockCamera()
    if camlockEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local predictedPosition = predictTargetPosition(targetPlayer)
        if predictedPosition then
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
            -- Smoothly transition the camera to the predicted target position
            camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothness)

            -- Update health and armor indicators
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                healthLabel.TextLabel.Text = "Health: " .. tostring(math.floor(targetPlayer.Character.Humanoid.Health))
                armorLabel.TextLabel.Text = "Armor: " .. tostring(math.floor(targetPlayer.Character.Humanoid.MaxHealth))
            end
        end
    end
end

-- Button click event to toggle camlock
Button.MouseButton1Click:Connect(function()
    camlockEnabled = not camlockEnabled
    
    if camlockEnabled then
        targetPlayer = getTarget()
        if targetPlayer then
            createESP(targetPlayer)
        end
        Button.Text = "Camlock ON"
        print("Camlock Enabled on:", targetPlayer and targetPlayer.Name or "No Target")
    else
        targetPlayer = nil
        removeESP()
        Button.Text = "snorlax.lol"
        print("Camlock Disabled")
    end
end)

-- Update the camera lock in every frame
game:GetService("RunService").RenderStepped:Connect(function()
    lockCamera()
end)
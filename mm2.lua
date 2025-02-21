local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Enable teleportation and noclip by default
local teleportEnabled = false
local noclipEnabled = true  -- Auto-enabled

-- Function to enable Noclip
local function enableNoclip()
    RunService.Stepped:Connect(function()
        if noclipEnabled and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end
enableNoclip()  -- Start Noclip immediately

-- Function to find the CoinContainer
local function findCoinContainer()
    for _, child in pairs(workspace:GetChildren()) do
        local coinContainer = child:FindFirstChild("CoinContainer")
        if coinContainer then
            return coinContainer
        end
    end
    return nil
end

-- Function to find the nearest coin (Infinite radius)
local function findNearestCoin()
    local coinContainer = findCoinContainer()
    if not coinContainer then return nil end

    local nearestCoin = nil
    local nearestDistance = math.huge

    for _, coin in pairs(coinContainer:GetChildren()) do
        local distance = (coin.Position - humanoidRootPart.Position).Magnitude
        if distance < nearestDistance then
            nearestCoin = coin
            nearestDistance = distance
        end
    end
    return nearestCoin
end

-- Function to teleport to a coin
local function teleportToCoin(coin)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = coin.CFrame})
    tween:Play()
    return tween
end

-- Function to teleport continuously to coins
local function teleportToCoinLoop()
    if not teleportEnabled then return end

    local nearestCoin = findNearestCoin()
    if nearestCoin then
        local tween = teleportToCoin(nearestCoin)
        tween.Completed:Wait()
    end
end

-- Function to create GUI
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2CandyAutoFarmGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:FindFirstChildOfClass("PlayerGui") or player.PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 150)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "MM2 Candy Auto Farm"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame

    -- Teleport Toggle Button
    local TeleportButton = Instance.new("TextButton")
    TeleportButton.Size = UDim2.new(0.8, 0, 0, 40)
    TeleportButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    TeleportButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    TeleportButton.Text = "Teleport OFF"
    TeleportButton.TextColor3 = Color3.new(1, 1, 1)
    TeleportButton.TextSize = 14
    TeleportButton.Font = Enum.Font.SourceSansBold
    TeleportButton.Parent = Frame

    -- Noclip Toggle Button
    local NoclipButton = Instance.new("TextButton")
    NoclipButton.Size = UDim2.new(0.8, 0, 0, 40)
    NoclipButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    NoclipButton.Text = "Noclip ON"  -- Always on by default
    NoclipButton.TextColor3 = Color3.new(1, 1, 1)
    NoclipButton.TextSize = 14
    NoclipButton.Font = Enum.Font.SourceSansBold
    NoclipButton.Parent = Frame

    -- Ensure Teleport Button is Always Clickable
    TeleportButton.MouseButton1Click:Connect(function()
        teleportEnabled = not teleportEnabled
        if teleportEnabled then
            TeleportButton.Text = "Teleport ON"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            TeleportButton.Text = "Teleport OFF"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end)

    -- Prevent Button from Becoming Unclickable
    TeleportButton.Parent = Frame
    NoclipButton.Parent = Frame

    return ScreenGui
end

-- Create GUI
local gui = createGUI()

-- Ensure GUI is Always Created on Respawn
local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if not player.PlayerGui:FindFirstChild("MM2CandyAutoFarmGUI") then
        gui = createGUI()
    end

    -- Ensure noclip stays on after respawn
    enableNoclip()
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Auto-Teleport Loop
RunService.Heartbeat:Connect(function()
    if teleportEnabled and character and character:FindFirstChild("HumanoidRootPart") then
        teleportToCoinLoop()
    end
end)

print("MM2 Candy Auto Farm with Auto-Noclip and Fixed Teleport Button loaded.")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Enable teleportation and noclip by default
local teleportEnabled = false
local noclipEnabled = true  -- Auto-enabled
local tweenSpeed = 0.3      -- Default movement speed
local pickupDelay = 0       -- Default delay between coin pickups

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

-- Function to smoothly move to a coin with floating effect
local function tweenToCoin(coin)
    if not coin then return end
    local targetCFrame = coin.CFrame + Vector3.new(0, 3, 0)  -- Slightly above the coin for floating effect

    local tweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    -- Wait for tween to complete before moving to the next coin (optional)
    task.wait(tweenSpeed + pickupDelay)
end

-- Function to teleport continuously to coins
local function teleportToCoinLoop()
    while teleportEnabled do
        local nearestCoin = findNearestCoin()
        if nearestCoin then
            tweenToCoin(nearestCoin)
        end
        task.wait(pickupDelay)  -- Wait before teleporting again
    end
end

-- Function to create GUI
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2CandyAutoFarmGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:FindFirstChildOfClass("PlayerGui") or player.PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 200)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -100)
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
    TeleportButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    TeleportButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    TeleportButton.Text = "Teleport OFF"
    TeleportButton.TextColor3 = Color3.new(1, 1, 1)
    TeleportButton.TextSize = 14
    TeleportButton.Font = Enum.Font.SourceSansBold
    TeleportButton.Parent = Frame

    -- Speed Input Box
    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(0.8, 0, 0, 30)
    SpeedBox.Position = UDim2.new(0.1, 0, 0.5, 0)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SpeedBox.Text = tostring(tweenSpeed)
    SpeedBox.TextColor3 = Color3.new(1, 1, 1)
    SpeedBox.TextSize = 14
    SpeedBox.Parent = Frame

    -- Delay Input Box
    local DelayBox = Instance.new("TextBox")
    DelayBox.Size = UDim2.new(0.8, 0, 0, 30)
    DelayBox.Position = UDim2.new(0.1, 0, 0.7, 0)
    DelayBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    DelayBox.Text = tostring(pickupDelay)
    DelayBox.TextColor3 = Color3.new(1, 1, 1)
    DelayBox.TextSize = 14
    DelayBox.Parent = Frame

    -- Ensure Teleport Button is Always Clickable
    TeleportButton.MouseButton1Click:Connect(function()
        teleportEnabled = not teleportEnabled
        if teleportEnabled then
            TeleportButton.Text = "Teleport ON"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            teleportToCoinLoop()
        else
            TeleportButton.Text = "Teleport OFF"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end)

    -- Speed Input Box Changes
    SpeedBox.FocusLost:Connect(function()
        local speedValue = tonumber(SpeedBox.Text)
        if speedValue and speedValue > 0 then
            tweenSpeed = speedValue
        else
            SpeedBox.Text = tostring(tweenSpeed)  -- Reset to previous valid value
        end
    end)

    -- Delay Input Box Changes
    DelayBox.FocusLost:Connect(function()
        local delayValue = tonumber(DelayBox.Text)
        if delayValue and delayValue >= 0 then
            pickupDelay = delayValue
        else
            DelayBox.Text = tostring(pickupDelay)  -- Reset to previous valid value
        end
    end)

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

print("MM2 Candy Auto Farm with Speed & Delay Controls loaded.")

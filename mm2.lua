local Players = game:GetService("Players") local TweenService = game:GetService("TweenService") local RunService = game:GetService("RunService")

local player = Players.LocalPlayer local character = player.Character or player.CharacterAdded:Wait() local root = character:WaitForChild("HumanoidRootPart")

local speed = 50 -- Adjustable Speed local delayBetweenMoves = 0.1 -- Adjustable Delay local teleportEnabled = true

-- GUI Creation local ScreenGui = Instance.new("ScreenGui", player.PlayerGui) local ToggleButton = Instance.new("TextButton", ScreenGui) ToggleButton.Size = UDim2.new(0, 150, 0, 50) ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0) ToggleButton.Text = "Toggle Auto-Farm" ToggleButton.MouseButton1Click:Connect(function() teleportEnabled = not teleportEnabled ToggleButton.Text = teleportEnabled and "Auto-Farm: ON" or "Auto-Farm: OFF" end)

-- Function to Find Nearest Coin local function getNearestCoin() local coinContainer = workspace:FindFirstChild("CoinContainer") if not coinContainer then return nil end

local closestCoin = nil
local minDistance = math.huge

for _, coin in pairs(coinContainer:GetChildren()) do
    if coin:IsA("BasePart") then
        local distance = (root.Position - coin.Position).magnitude
        if distance < minDistance then
            minDistance = distance
            closestCoin = coin
        end
    end
end

return closestCoin

end

-- Function to Move to Coin Smoothly local function moveToCoin(coin) if not coin then return end

local goal = {Position = coin.Position + Vector3.new(0, 2, 0)} -- Floating effect
local tweenInfo = TweenInfo.new((root.Position - coin.Position).magnitude / speed, Enum.EasingStyle.Linear)
local tween = TweenService:Create(root, tweenInfo, goal)
tween:Play()

tween.Completed:Wait()

end

-- Auto-Farm Loop spawn(function() while true do if teleportEnabled then local coin = getNearestCoin() if coin then moveToCoin(coin) end end wait(delayBetweenMoves) end end)


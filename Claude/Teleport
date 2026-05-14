-- Teleport Save Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local savedPosition = nil
local autoEnabled = false
local autoThread = nil

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 210, 0, 130)
Frame.Position = UDim2.new(0, 10, 0.5, -65)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "✦ Position Teleporter"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Fix title bottom corners bleeding through
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

-- ─── ROW 1: Save Pos | Teleport ───────────────────────
local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0, 93, 0, 38)
SaveButton.Position = UDim2.new(0, 8, 0, 36)
SaveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Text = "Save Pos"
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 13
SaveButton.BorderSizePixel = 0
SaveButton.Parent = Frame

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 7)
SaveCorner.Parent = SaveButton

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0, 93, 0, 38)
TeleportButton.Position = UDim2.new(0, 109, 0, 36)
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 175, 80)
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.Text = "Teleport"
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.TextSize = 13
TeleportButton.BorderSizePixel = 0
TeleportButton.Parent = Frame

local TeleportCorner = Instance.new("UICorner")
TeleportCorner.CornerRadius = UDim.new(0, 7)
TeleportCorner.Parent = TeleportButton

-- ─── ROW 2: Auto Toggle | Delay TextBox ───────────────
local AutoButton = Instance.new("TextButton")
AutoButton.Size = UDim2.new(0, 93, 0, 34)
AutoButton.Position = UDim2.new(0, 8, 0, 84)
AutoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoButton.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoButton.Text = "Auto: OFF"
AutoButton.Font = Enum.Font.GothamBold
AutoButton.TextSize = 13
AutoButton.BorderSizePixel = 0
AutoButton.Parent = Frame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 7)
AutoCorner.Parent = AutoButton

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0, 93, 0, 34)
DelayBox.Position = UDim2.new(0, 109, 0, 84)
DelayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.PlaceholderText = "Delay (s)"
DelayBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
DelayBox.Text = "1"
DelayBox.Font = Enum.Font.GothamBold
DelayBox.TextSize = 13
DelayBox.BorderSizePixel = 0
DelayBox.ClearTextOnFocus = false
DelayBox.Parent = Frame

local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0, 7)
DelayCorner.Parent = DelayBox

-- Only allow numbers and decimals
DelayBox:GetPropertyChangedSignal("Text"):Connect(function()
    DelayBox.Text = DelayBox.Text:gsub("[^%d%.]", "")
end)

-- ─── Helper: stop auto loop ───────────────────────────
local function stopAuto()
    if autoThread then
        task.cancel(autoThread)
        autoThread = nil
    end
end

-- ─── Helper: do a single teleport ─────────────────────
local function doTeleport()
    Character = LocalPlayer.Character
    if savedPosition and Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = savedPosition
        return true
    end
    return false
end

-- ─── Save Button ──────────────────────────────────────
SaveButton.MouseButton1Click:Connect(function()
    Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = Character.HumanoidRootPart.CFrame
        local pos = savedPosition.Position
        SaveButton.Text = string.format("%.0f,%.0f,%.0f", pos.X, pos.Y, pos.Z)
        SaveButton.BackgroundColor3 = Color3.fromRGB(0, 90, 170)
        task.delay(2, function()
            SaveButton.Text = "Save Pos"
            SaveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        end)
    end
end)

-- ─── Teleport Button ──────────────────────────────────
TeleportButton.MouseButton1Click:Connect(function()
    if not doTeleport() then
        TeleportButton.Text = "No Pos!"
        TeleportButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        task.delay(1.5, function()
            TeleportButton.Text = "Teleport"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 175, 80)
        end)
    end
end)

-- ─── Auto Toggle ──────────────────────────────────────
AutoButton.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled

    if autoEnabled then
        AutoButton.Text = "Auto: ON"
        AutoButton.BackgroundColor3 = Color3.fromRGB(180, 120, 0)

        autoThread = task.spawn(function()
            while autoEnabled do
                doTeleport()
                local delay = tonumber(DelayBox.Text) or 1
                if delay < 0.05 then delay = 0.05 end
                task.wait(delay)
            end
        end)
    else
        stopAuto()
        AutoButton.Text = "Auto: OFF"
        AutoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        AutoButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

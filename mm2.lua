local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Tp Player",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = { Enabled = true, FolderName = "RayfieldConfig" },
    KeySystem = false
})

local Tab = Window:CreateTab("Misc", 4483345998) -- Using an icon
local Section = Tab:CreateSection("Teleport")

local players = {}
local playerMap = {}

for _, v in pairs(game:GetService("Players"):GetChildren()) do
   table.insert(players, v.DisplayName)
   playerMap[v.DisplayName] = v.Name -- Store mapping of DisplayName to Username
end

local Select
Section:CreateDropdown({
    Name = "Select Player",
    Options = players,
    Callback = function(selected)
        Select = playerMap[selected] -- Convert display name back to username
    end
})

local rootpart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

Section:CreateButton({
    Name = "Refresh",
    Callback = function()
        table.clear(players)
        table.clear(playerMap)
        for _, v in ipairs(game.Players:GetChildren()) do
            table.insert(players, v.DisplayName)
            playerMap[v.DisplayName] = v.Name
        end
    end
})

Section:CreateButton({
    Name = "Teleport",
    Callback = function()
        if Select then
            local targetPlayer = game:GetService("Players"):FindFirstChild(Select)
            if targetPlayer and targetPlayer.Character then
                local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootpart and targetRootPart then
                    rootpart.CFrame = targetRootPart.CFrame
                end
            end
        end
    end
})

Section:CreateInput({
    Name = "TP to Player",
    PlaceholderText = "Enter Player Name",
    RemoveTextAfterFocusLost = true,
    Callback = function(name)
        local plr
        for _, player in ipairs(game.Players:GetPlayers()) do
            if string.sub(player.DisplayName:lower(), 1, #name) == name:lower() or
               string.sub(player.Name:lower(), 1, #name) == name:lower() then
                plr = player
                break 
            end
        end

        if plr then
            local plrootpart = plr.Character:FindFirstChild("HumanoidRootPart")
            if rootpart and plrootpart then
                rootpart.CFrame = plrootpart.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
})

-- Toggle Button (Movable)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Show UI"

-- Make Button Draggable
local UIS = game:GetService("UserInputService")
local dragging, dragInput, startPos, startMousePos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = ToggleButton.Position
        startMousePos = input.Position
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - startMousePos
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button Functionality to Show/Hide UI
local uiVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    if uiVisible then
        Rayfield:Notify({Title = "UI", Content = "UI Opened", Duration = 2})
        Window:SetVisibility(true)
        ToggleButton.Text = "Hide UI"
    else
        Rayfield:Notify({Title = "UI", Content = "UI Closed", Duration = 2})
        Window:SetVisibility(false)
        ToggleButton.Text = "Show UI"
    end
end)

Rayfield:LoadConfiguration()

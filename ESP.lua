-- Modern ESP with Draggable Toggle Menu
-- Fixed version with working toggle button

assert(Drawing, "Exploit not supported - Drawing API required")

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Utility functions
local function V2New(x, y) return Vector2.new(x, y) end
local function V3New(x, y, z) return Vector3.new(x, y, z) end
local function WorldToViewport(point) return Camera:WorldToViewportPoint(point) end
local function GetMouseLocation() return UserInputService:GetMouseLocation() end

-- Configuration
local ESPConfig = {
    Enabled = true,
    ShowTeam = true,
    ShowNames = true,
    ShowDistance = true,
    ShowBoxes = true,
    ShowTracers = true,
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    MaxDistance = 2000,
    TextSize = 14
}

-- Menu state
local Menu = {
    Open = false,
    Position = V2New(100, 100),
    Size = V2New(250, 300),
    Dragging = false,
    DragOffset = V2New(0, 0),
    ToggleButton = {
        Position = V2New(20, 20),
        Size = V2New(40, 40),
        Dragging = false,
        DragOffset = V2New(0, 0)
    }
}

-- Create menu elements
local MenuElements = {}
local ToggleButtonElements = {}

-- Initialize menu
local function InitializeMenu()
    -- Toggle button
    ToggleButtonElements.Background = Drawing.new("Square")
    ToggleButtonElements.Background.Visible = true
    ToggleButtonElements.Background.Filled = true
    ToggleButtonElements.Background.Color = Color3.fromRGB(60, 60, 60)
    ToggleButtonElements.Background.Transparency = 0.2
    ToggleButtonElements.Background.Thickness = 2
    ToggleButtonElements.Background.Size = Menu.ToggleButton.Size
    ToggleButtonElements.Background.Position = Menu.ToggleButton.Position
    
    ToggleButtonElements.Icon = Drawing.new("Text")
    ToggleButtonElements.Icon.Text = "≡"
    ToggleButtonElements.Icon.Size = 20
    ToggleButtonElements.Icon.Position = Menu.ToggleButton.Position + V2New(10, 8)
    ToggleButtonElements.Icon.Color = Color3.fromRGB(255, 255, 255)
    ToggleButtonElements.Icon.Visible = true
    ToggleButtonElements.Icon.Center = false
    ToggleButtonElements.Icon.Outline = true
    
    -- Menu background
    MenuElements.Background = Drawing.new("Square")
    MenuElements.Background.Visible = Menu.Open
    MenuElements.Background.Filled = true
    MenuElements.Background.Color = Color3.fromRGB(35, 35, 40)
    MenuElements.Background.Transparency = 0.1
    MenuElements.Background.Thickness = 2
    MenuElements.Background.Size = Menu.Size
    MenuElements.Background.Position = Menu.Position
    
    -- Menu header
    MenuElements.Header = Drawing.new("Square")
    MenuElements.Header.Visible = Menu.Open
    MenuElements.Header.Filled = true
    MenuElements.Header.Color = Color3.fromRGB(25, 25, 30)
    MenuElements.Header.Transparency = 0.2
    MenuElements.Header.Thickness = 0
    MenuElements.Header.Size = V2New(Menu.Size.X, 30)
    MenuElements.Header.Position = Menu.Position
    
    -- Menu title
    MenuElements.Title = Drawing.new("Text")
    MenuElements.Title.Text = "ESP SETTINGS"
    MenuElements.Title.Size = 18
    MenuElements.Title.Position = Menu.Position + V2New(10, 5)
    MenuElements.Title.Color = Color3.fromRGB(220, 220, 220)
    MenuElements.Title.Visible = Menu.Open
    MenuElements.Title.Center = false
    MenuElements.Title.Outline = true
    
    -- Close button
    MenuElements.CloseButton = Drawing.new("Text")
    MenuElements.CloseButton.Text = "×"
    MenuElements.CloseButton.Size = 20
    MenuElements.CloseButton.Position = Menu.Position + V2New(Menu.Size.X - 25, 5)
    MenuElements.CloseButton.Color = Color3.fromRGB(220, 220, 220)
    MenuElements.CloseButton.Visible = Menu.Open
    MenuElements.CloseButton.Center = false
    
    -- Options
    local options = {
        {text = "ESP Enabled", value = ESPConfig.Enabled, key = "Enabled"},
        {text = "Show Names", value = ESPConfig.ShowNames, key = "ShowNames"},
        {text = "Show Boxes", value = ESPConfig.ShowBoxes, key = "ShowBoxes"},
        {text = "Show Tracers", value = ESPConfig.ShowTracers, key = "ShowTracers"},
        {text = "Show Team", value = ESPConfig.ShowTeam, key = "ShowTeam"},
        {text = "Show Distance", value = ESPConfig.ShowDistance, key = "ShowDistance"}
    }
    
    MenuElements.Options = {}
    
    for i, option in ipairs(options) do
        -- Option text
        local text = Drawing.new("Text")
        text.Text = option.text
        text.Size = 16
        text.Position = Menu.Position + V2New(20, 40 + (i * 30))
        text.Color = Color3.fromRGB(220, 220, 220)
        text.Visible = Menu.Open
        text.Center = false
        
        -- Toggle box
        local toggleBox = Drawing.new("Square")
        toggleBox.Visible = Menu.Open
        toggleBox.Filled = true
        toggleBox.Color = option.value and ESPConfig.TeamColor or Color3.fromRGB(80, 80, 80)
        toggleBox.Transparency = 0.2
        toggleBox.Thickness = 1
        toggleBox.Size = V2New(30, 15)
        toggleBox.Position = Menu.Position + V2New(Menu.Size.X - 50, 40 + (i * 30))
        
        -- Toggle indicator
        local toggleIndicator = Drawing.new("Circle")
        toggleIndicator.Visible = Menu.Open
        toggleIndicator.Filled = true
        toggleIndicator.Color = Color3.fromRGB(255, 255, 255)
        toggleIndicator.Transparency = 0
        toggleIndicator.Thickness = 0
        toggleIndicator.Radius = 5
        toggleIndicator.NumSides = 12
        toggleIndicator.Position = option.value and 
            (Menu.Position + V2New(Menu.Size.X - 35, 40 + (i * 30) + 7)) or 
            (Menu.Position + V2New(Menu.Size.X - 50, 40 + (i * 30) + 7))
        
        MenuElements.Options[option.key] = {
            Text = text,
            Box = toggleBox,
            Indicator = toggleIndicator,
            Value = option.value
        }
    end
end

-- Toggle menu visibility
local function ToggleMenu()
    Menu.Open = not Menu.Open
    
    -- Update menu elements visibility
    for _, element in pairs(MenuElements) do
        if element.Visible ~= nil then
            element.Visible = Menu.Open
        end
    end
    
    -- Update options visibility
    for _, option in pairs(MenuElements.Options) do
        option.Text.Visible = Menu.Open
        option.Box.Visible = Menu.Open
        option.Indicator.Visible = Menu.Open
    end
    
    -- Update toggle button icon
    ToggleButtonElements.Icon.Text = Menu.Open and "×" or "≡"
end

-- Update menu position
local function UpdateMenuPosition()
    MenuElements.Background.Position = Menu.Position
    MenuElements.Header.Position = Menu.Position
    MenuElements.Title.Position = Menu.Position + V2New(10, 5)
    MenuElements.CloseButton.Position = Menu.Position + V2New(Menu.Size.X - 25, 5)
    
    local i = 0
    for key, option in pairs(MenuElements.Options) do
        i = i + 1
        option.Text.Position = Menu.Position + V2New(20, 40 + (i * 30))
        option.Box.Position = Menu.Position + V2New(Menu.Size.X - 50, 40 + (i * 30))
        option.Indicator.Position = option.Value and 
            (Menu.Position + V2New(Menu.Size.X - 35, 40 + (i * 30) + 7)) or 
            (Menu.Position + V2New(Menu.Size.X - 50, 40 + (i * 30) + 7))
    end
end

-- Update toggle button position
local function UpdateToggleButtonPosition()
    ToggleButtonElements.Background.Position = Menu.ToggleButton.Position
    ToggleButtonElements.Icon.Position = Menu.ToggleButton.Position + V2New(10, 8)
end

-- Toggle an option
local function ToggleOption(optionKey)
    local option = MenuElements.Options[optionKey]
    if option then
        option.Value = not option.Value
        ESPConfig[optionKey] = option.Value
        
        -- Update visual state
        option.Box.Color = option.Value and ESPConfig.TeamColor or Color3.fromRGB(80, 80, 80)
        
        -- Adjust Y position based on option index
        local index = 0
        for i, key in pairs(MenuElements.Options) do
            index = index + 1
            if key == optionKey then
                break
            end
        end
        
        option.Indicator.Position = option.Value and 
            (Menu.Position + V2New(Menu.Size.X - 35, 40 + (index * 30) + 7)) or 
            (Menu.Position + V2New(Menu.Size.X - 50, 40 + (index * 30) + 7))
    end
end

-- Check if mouse is in bounds
local function IsMouseInBounds(position, size)
    local mousePos = GetMouseLocation()
    return mousePos.X >= position.X and mousePos.Y >= position.Y and 
           mousePos.X <= position.X + size.X and mousePos.Y <= position.Y + size.Y
end

-- Input handlers
local function SetupInputHandlers()
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = GetMouseLocation()
            
            -- Check if clicking toggle button
            if IsMouseInBounds(Menu.ToggleButton.Position, Menu.ToggleButton.Size) then
                Menu.ToggleButton.Dragging = true
                Menu.ToggleButton.DragOffset = mousePos - Menu.ToggleButton.Position
                return
            end
            
            -- Check if clicking menu header for dragging
            if Menu.Open and IsMouseInBounds(Menu.Position, V2New(Menu.Size.X, 30)) then
                Menu.Dragging = true
                Menu.DragOffset = mousePos - Menu.Position
                return
            end
            
            -- Check if clicking close button
            if Menu.Open and IsMouseInBounds(Menu.Position + V2New(Menu.Size.X - 25, 5), V2New(20, 20)) then
                ToggleMenu()
                return
            end
            
            -- Check if clicking options
            if Menu.Open then
                for key, option in pairs(MenuElements.Options) do
                    if IsMouseInBounds(option.Box.Position, option.Box.Size) then
                        ToggleOption(key)
                        return
                    end
                end
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = GetMouseLocation()
            
            -- Handle toggle button dragging
            if Menu.ToggleButton.Dragging then
                Menu.ToggleButton.Position = mousePos - Menu.ToggleButton.DragOffset
                UpdateToggleButtonPosition()
                
                -- Move menu with toggle button if it's open
                if Menu.Open then
                    Menu.Position = Menu.ToggleButton.Position + V2New(50, 0)
                    UpdateMenuPosition()
                end
            end
            
            -- Handle menu dragging
            if Menu.Dragging then
                Menu.Position = mousePos - Menu.DragOffset
                UpdateMenuPosition()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Check if this was a click (not drag) on toggle button
            if Menu.ToggleButton.Dragging then
                local dragDistance = (mousePos - (Menu.ToggleButton.Position + Menu.ToggleButton.DragOffset)).Magnitude
                
                -- If minimal movement, treat as click
                if dragDistance < 5 then
                    ToggleMenu()
                end
                
                Menu.ToggleButton.Dragging = false
            end
            
            Menu.Dragging = false
        end
    end)
end

-- ESP Functions
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    ESPObjects[player] = {
        Box = Drawing.new("Quad"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    local esp = ESPObjects[player]
    
    -- Configure ESP objects
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false
    
    esp.Name.Size = ESPConfig.TextSize
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Distance.Size = ESPConfig.TextSize
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Visible = false
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    if not ESPConfig.Enabled then
        for player, esp in pairs(ESPObjects) do
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
        end
        return
    end
    
    for player, esp in pairs(ESPObjects) do
        local character = player.Character
        if not character then
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            continue
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not humanoidRootPart or not humanoid or not head or humanoid.Health <= 0 then
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            continue
        end
        
        -- Check distance
        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
            (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
        
        if distance > ESPConfig.MaxDistance then
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            continue
        end
        
        -- Determine color based on team
        local color
        if ESPConfig.ShowTeam and player.Team == LocalPlayer.Team then
            color = ESPConfig.TeamColor
        else
            color = ESPConfig.EnemyColor
        end
        
        -- Update ESP objects
        local headPos, headVis = WorldToViewport(head.Position)
        
        if headVis then
            -- Box
            if ESPConfig.ShowBoxes then
                local height = 5
                local width = 2.5
                
                local topFrontLeft = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(-width, height, -width)).Position)
                local topFrontRight = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(width, height, -width)).Position)
                local topBackLeft = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(-width, height, width)).Position)
                local topBackRight = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(width, height, width)).Position)
                
                local bottomFrontLeft = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(-width, -height, -width)).Position)
                local bottomFrontRight = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(width, -height, -width)).Position)
                local bottomBackLeft = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(-width, -height, width)).Position)
                local bottomBackRight = WorldToViewport((humanoidRootPart.CFrame * CFrame.new(width, -height, width)).Position)
                
                esp.Box.PointA = V2New(topFrontLeft.X, topFrontLeft.Y)
                esp.Box.PointB = V2New(topFrontRight.X, topFrontRight.Y)
                esp.Box.PointC = V2New(bottomFrontRight.X, bottomFrontRight.Y)
                esp.Box.PointD = V2New(bottomFrontLeft.X, bottomFrontLeft.Y)
                esp.Box.Color = color
                esp.Box.Visible = true
            else
                esp.Box.Visible = false
            end
            
            -- Tracer
            if ESPConfig.ShowTracers then
                local rootPos = WorldToViewport(humanoidRootPart.Position)
                esp.Tracer.From = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = V2New(rootPos.X, rootPos.Y)
                esp.Tracer.Color = color
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
            
            -- Name and distance
            if ESPConfig.ShowNames then
                esp.Name.Text = player.Name
                esp.Name.Position = V2New(headPos.X, headPos.Y - 30)
                esp.Name.Color = color
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            if ESPConfig.ShowDistance then
                esp.Distance.Text = string.format("[%d studs]", math.floor(distance))
                esp.Distance.Position = V2New(headPos.X, headPos.Y - 15)
                esp.Distance.Color = color
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
        end
    end
end

-- Player handlers
local function SetupPlayerHandlers()
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)

    -- Initialize ESP for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end

-- Main initialization
local function Main()
    -- Initialize the menu
    InitializeMenu()
    
    -- Setup input handlers
    SetupInputHandlers()
    
    -- Setup player handlers
    SetupPlayerHandlers()
    
    -- Main loop
    RunService.RenderStepped:Connect(function()
        UpdateESP()
    end)
    
    print("Modern ESP loaded! Use the toggle button to open/close the menu.")
end

-- Start the script
Main()

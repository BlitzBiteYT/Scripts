--[[
    GridLib v1.0
    A standalone Roblox Lua UI library with a grid-based layout,
    inspired by Rayfield/Arrayfield design language.
    
    Features:
    - Draggable window with customizable title & size
    - Responsive grid layout (configurable columns, ColSpan per element)
    - Full Rayfield Dark theme matching (colors, strokes, fonts, animations)
    - Components: Button, Toggle, Slider, Input, Label, Section (collapsible)
    - Each component includes :Set(), :Lock(), :Unlock(), :Destroy()
    - Flag system for global state access
    - No external dependencies, pure Roblox instances & TweenService
]]

local GridLib = {}
GridLib.Flags = {} -- Global flag storage for external reads

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme colors (Rayfield Default Dark)
local Theme = {
    WindowBg = Color3.fromHex("#191919"),
    TopbarBg = Color3.fromHex("#222222"),
    ElementBg = Color3.fromHex("#232323"),
    ElementHover = Color3.fromHex("#282828"),
    ElementStroke = Color3.fromHex("#323232"),
    TextColor = Color3.fromHex("#F0F0F0"),
    ButtonBg = Color3.fromHex("#232323"),
    ButtonHover = Color3.fromHex("#282828"),
    ToggleBg = Color3.fromHex("#1E1E1E"),
    ToggleEnabled = Color3.fromHex("#0092D6"),
    ToggleDisabled = Color3.fromHex("#646464"),
    SliderBg = Color3.fromHex("#2B699F"),
    SliderProgress = Color3.fromHex("#2B699F"),
    SliderStroke = Color3.fromHex("#307799"),
    InputBg = Color3.fromHex("#1E1E1E"),
    InputStroke = Color3.fromHex("#141414"),
    ErrorBg = Color3.fromHex("#550000"),
    LockOverlayBg = Color3.fromHex("#000000"),
    SectionHeaderBg = Color3.fromHex("#232323"),
}

-- Utility functions
local function CreateCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

local function CreateStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = instance
    return stroke
end

local function FadeIn(instance, duration)
    instance.BackgroundTransparency = 1
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        instance.TextTransparency = 1
    end
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("ImageLabel") then
            child.ImageTransparency = 1
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextTransparency = 1
        elseif child:IsA("Frame") and child ~= instance then
            FadeIn(child, duration)
        end
    end
    local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 0,
    })
    tween:Play()
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local t2 = TweenService:Create(child, TweenInfo.new(duration, Enum.EasingStyle.Quint), { TextTransparency = 0 })
            t2:Play()
        elseif child:IsA("ImageLabel") then
            local t2 = TweenService:Create(child, TweenInfo.new(duration, Enum.EasingStyle.Quint), { ImageTransparency = 0 })
            t2:Play()
        elseif child:IsA("Frame") and child ~= instance then
            local t2 = TweenService:Create(child, TweenInfo.new(duration, Enum.EasingStyle.Quint), { BackgroundTransparency = 0 })
            t2:Play()
        end
    end
end

-- Draggable logic
local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Lock overlay helper
local function AddLockOverlay(parent, reason)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Theme.LockOverlayBg
    overlay.BackgroundTransparency = 0.6
    overlay.BorderSizePixel = 0
    overlay.Parent = parent
    
    local corner = CreateCorner(overlay, 7)
    
    local lockIcon = Instance.new("ImageLabel")
    lockIcon.Size = UDim2.new(0, 20, 0, 20)
    lockIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
    lockIcon.BackgroundTransparency = 1
    lockIcon.Image = "rbxassetid://6031098405" -- lock icon
    lockIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    lockIcon.Parent = overlay
    
    local reasonText = Instance.new("TextLabel")
    reasonText.Size = UDim2.new(1, 0, 0, 20)
    reasonText.Position = UDim2.new(0, 0, 1, -20)
    reasonText.BackgroundTransparency = 1
    reasonText.Text = reason or "Locked"
    reasonText.TextColor3 = Theme.TextColor
    reasonText.TextSize = 11
    reasonText.Font = Enum.Font.GothamBold
    reasonText.TextXAlignment = Enum.TextXAlignment.Center
    reasonText.Parent = overlay
    
    return overlay
end

-- Base Component class
local Component = {}
Component.__index = Component

function Component.new(parent, typeName, settings)
    local self = setmetatable({}, Component)
    self.Parent = parent
    self.Type = typeName
    self.Settings = settings or {}
    self.Locked = false
    self.LockReason = nil
    self.Overlay = nil
    self.Root = nil
    return self
end

function Component:Lock(reason)
    if self.Locked then return end
    self.Locked = true
    self.LockReason = reason or "Locked"
    if self.Root and not self.Overlay then
        self.Overlay = AddLockOverlay(self.Root, self.LockReason)
        -- Disable interactive children
        for _, child in ipairs(self.Root:GetDescendants()) do
            if child:IsA("TextButton") or child:IsA("TextBox") or child:IsA("ImageButton") then
                child.Active = false
                child.Selectable = false
                child.AutoButtonColor = false
            end
        end
    end
end

function Component:Unlock()
    if not self.Locked then return end
    self.Locked = false
    if self.Overlay then
        self.Overlay:Destroy()
        self.Overlay = nil
    end
    for _, child in ipairs(self.Root:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("TextBox") or child:IsA("ImageButton") then
            child.Active = true
            child.Selectable = true
            child.AutoButtonColor = true
        end
    end
end

function Component:Destroy()
    if self.Root then
        self.Root:Destroy()
    end
    if self.Parent and self.Parent.RemoveElement then
        self.Parent:RemoveElement(self)
    end
end

-- Button component
local Button = setmetatable({}, Component)
Button.__index = Button

function Button.new(parent, settings)
    local self = Component.new(parent, "Button", settings)
    self.Callback = settings.Callback or function() end
    self.Label = settings.Label or "Button"
    self.ColSpan = settings.ColSpan or 1
    
    -- Create root frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    frame.Parent = parent.Container
    CreateCorner(frame, 7)
    CreateStroke(frame, Theme.ElementStroke, 1)
    
    -- Text label
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 1, 0)
    text.Position = UDim2.new(0, 8, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = self.Label
    text.TextColor3 = Theme.TextColor
    text.TextSize = 13
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    -- Button click area
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame
    
    local hoverTween
    button.MouseEnter:Connect(function()
        if self.Locked then return end
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quint), { BackgroundColor3 = Theme.ElementHover })
        hoverTween:Play()
    end)
    button.MouseLeave:Connect(function()
        if self.Locked then return end
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quint), { BackgroundColor3 = Theme.ElementBg })
        hoverTween:Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if self.Locked then return end
        local success, err = pcall(self.Callback)
        if not success then
            local originalColor = frame.BackgroundColor3
            frame.BackgroundColor3 = Theme.ErrorBg
            task.delay(0.5, function()
                frame.BackgroundColor3 = originalColor
            end)
            warn("GridLib Button callback error:", err)
        end
    end)
    
    self.Root = frame
    FadeIn(self.Root, 0.7)
    return self
end

function Button:Set(newLabel)
    if self.Root and self.Root:FindFirstChildWhichIsA("TextLabel") then
        self.Root:FindFirstChildWhichIsA("TextLabel").Text = newLabel
    end
    self.Label = newLabel
end

-- Toggle component
local Toggle = setmetatable({}, Component)
Toggle.__index = Toggle

function Toggle.new(parent, settings)
    local self = Component.new(parent, "Toggle", settings)
    self.Callback = settings.Callback or function() end
    self.Label = settings.Label or "Toggle"
    self.Default = settings.Default or false
    self.Flag = settings.Flag
    self.ColSpan = settings.ColSpan or 1
    self.Value = self.Default
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    frame.Parent = parent.Container
    CreateCorner(frame, 7)
    CreateStroke(frame, Theme.ElementStroke, 1)
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 1, 0)
    text.Position = UDim2.new(0, 8, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = self.Label
    text.TextColor3 = Theme.TextColor
    text.TextSize = 13
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    -- Switch container
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 50, 0, 24)
    switch.Position = UDim2.new(1, -58, 0.5, -12)
    switch.BackgroundColor3 = Theme.ToggleBg
    switch.BorderSizePixel = 0
    switch.Parent = frame
    CreateCorner(switch, 12)
    CreateStroke(switch, Theme.ElementStroke, 1)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(0, 2, 0.5, -10)
    indicator.BackgroundColor3 = Theme.ToggleDisabled
    indicator.BorderSizePixel = 0
    indicator.Parent = switch
    CreateCorner(indicator, 10)
    
    local function UpdateVisuals()
        local targetPos = self.Value and UDim2.new(1, -28, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetColor = self.Value and Theme.ToggleEnabled or Theme.ToggleDisabled
        TweenService:Create(indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPos,
            BackgroundColor3 = targetColor
        }):Play()
    end
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = switch
    
    button.MouseButton1Click:Connect(function()
        if self.Locked then return end
        self.Value = not self.Value
        UpdateVisuals()
        local success, err = pcall(self.Callback, self.Value)
        if not success then
            frame.BackgroundColor3 = Theme.ErrorBg
            task.delay(0.5, function()
                frame.BackgroundColor3 = Theme.ElementBg
            end)
            warn("GridLib Toggle callback error:", err)
        end
        if self.Flag then
            GridLib.Flags[self.Flag] = self.Value
        end
    end)
    
    UpdateVisuals()
    if self.Flag then GridLib.Flags[self.Flag] = self.Value end
    
    self.Root = frame
    FadeIn(self.Root, 0.7)
    return self
end

function Toggle:Set(value)
    self.Value = value
    if self.Root then
        local switch = self.Root:FindFirstChildWhichIsA("Frame")
        if switch then
            local indicator = switch:FindFirstChildWhichIsA("Frame")
            if indicator then
                local targetPos = self.Value and UDim2.new(1, -28, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                local targetColor = self.Value and Theme.ToggleEnabled or Theme.ToggleDisabled
                TweenService:Create(indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = targetPos,
                    BackgroundColor3 = targetColor
                }):Play()
            end
        end
    end
    if self.Flag then GridLib.Flags[self.Flag] = self.Value end
    self.Callback(self.Value)
end

-- Slider component
local Slider = setmetatable({}, Component)
Slider.__index = Slider

function Slider.new(parent, settings)
    local self = Component.new(parent, "Slider", settings)
    self.Callback = settings.Callback or function() end
    self.Label = settings.Label or "Slider"
    self.Min = settings.Min or 0
    self.Max = settings.Max or 100
    self.Default = settings.Default or self.Min
    self.Suffix = settings.Suffix or ""
    self.Flag = settings.Flag
    self.ColSpan = settings.ColSpan or 1
    self.Value = self.Default
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    frame.Parent = parent.Container
    CreateCorner(frame, 7)
    CreateStroke(frame, Theme.ElementStroke, 1)
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 0, 20)
    text.Position = UDim2.new(0, 8, 0, 4)
    text.BackgroundTransparency = 1
    text.Text = self.Label
    text.TextColor3 = Theme.TextColor
    text.TextSize = 13
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -68, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(self.Value) .. self.Suffix
    valueLabel.TextColor3 = Theme.TextColor
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 6)
    track.Position = UDim2.new(0, 8, 0, 32)
    track.BackgroundColor3 = Theme.SliderBg
    track.BorderSizePixel = 0
    track.Parent = frame
    CreateCorner(track, 3)
    CreateStroke(track, Theme.SliderStroke, 1)
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
    progress.BackgroundColor3 = Theme.SliderProgress
    progress.BorderSizePixel = 0
    progress.Parent = track
    CreateCorner(progress, 3)
    
    local grab = Instance.new("TextButton")
    grab.Size = UDim2.new(0, 12, 0, 12)
    grab.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -6, 0.5, -6)
    grab.BackgroundColor3 = Theme.SliderProgress
    grab.BackgroundTransparency = 0.5
    grab.Text = ""
    grab.Parent = track
    CreateCorner(grab, 6)
    
    local dragging = false
    local function SetValueFromMouse(input)
        local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local newValue = self.Min + (self.Max - self.Min) * relativeX
        newValue = math.floor(newValue + 0.5)
        self.Value = math.clamp(newValue, self.Min, self.Max)
        progress.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
        grab.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -6, 0.5, -6)
        valueLabel.Text = tostring(self.Value) .. self.Suffix
        if self.Flag then GridLib.Flags[self.Flag] = self.Value end
        self.Callback(self.Value)
    end
    
    grab.MouseButton1Down:Connect(function(input)
        if self.Locked then return end
        dragging = true
        SetValueFromMouse(input)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            SetValueFromMouse(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if self.Locked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            SetValueFromMouse(input)
        end
    end)
    
    self.Root = frame
    if self.Flag then GridLib.Flags[self.Flag] = self.Value end
    FadeIn(self.Root, 0.7)
    return self
end

function Slider:Set(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    if self.Root then
        local track = self.Root:FindFirstChildWhichIsA("Frame"):FindFirstChild("Frame")
        if track then
            local progress = track:FindFirstChildWhichIsA("Frame")
            local grab = track:FindFirstChildWhichIsA("TextButton")
            if progress then
                progress.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
            end
            if grab then
                grab.Position = UDim2.new((self.Value - self.Min) / (Max - Min), -6, 0.5, -6)
            end
        end
        local valueLabel = self.Root:FindFirstChildWhichIsA("TextLabel")
        if valueLabel and valueLabel ~= self.Root:FindFirstChildWhichIsA("TextLabel") then
            -- find correct one
            for _, child in ipairs(self.Root:GetChildren()) do
                if child:IsA("TextLabel") and child.TextXAlignment == Enum.TextXAlignment.Right then
                    child.Text = tostring(self.Value) .. self.Suffix
                    break
                end
            end
        end
    end
    if self.Flag then GridLib.Flags[self.Flag] = self.Value end
    self.Callback(self.Value)
end

-- Input component
local Input = setmetatable({}, Component)
Input.__index = Input

function Input.new(parent, settings)
    local self = Component.new(parent, "Input", settings)
    self.Callback = settings.Callback or function() end
    self.Label = settings.Label or "Input"
    self.PlaceholderText = settings.PlaceholderText or ""
    self.NumbersOnly = settings.NumbersOnly or false
    self.ColSpan = settings.ColSpan or 1
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    frame.Parent = parent.Container
    CreateCorner(frame, 7)
    CreateStroke(frame, Theme.ElementStroke, 1)
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 0, 20)
    text.Position = UDim2.new(0, 8, 0, 4)
    text.BackgroundTransparency = 1
    text.Text = self.Label
    text.TextColor3 = Theme.TextColor
    text.TextSize = 13
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 0, 26)
    box.Position = UDim2.new(0, 8, 0, 26)
    box.BackgroundColor3 = Theme.InputBg
    box.TextColor3 = Theme.TextColor
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    box.PlaceholderText = self.PlaceholderText
    box.Text = ""
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = frame
    CreateCorner(box, 6)
    CreateStroke(box, Theme.InputStroke, 1)
    
    if self.NumbersOnly then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            box.Text = box.Text:gsub("[^%d%.]", "")
        end)
    end
    
    box.FocusLost:Connect(function(enterPressed)
        if self.Locked then return end
        self.Callback(box.Text)
    end)
    
    self.Root = frame
    FadeIn(self.Root, 0.7)
    return self
end

function Input:Set(text)
    if self.Root then
        local box = self.Root:FindFirstChildWhichIsA("TextBox")
        if box then
            box.Text = text
        end
    end
    self.Callback(text)
end

-- Label component
local Label = setmetatable({}, Component)
Label.__index = Label

function Label.new(parent, settings)
    local self = Component.new(parent, "Label", settings)
    self.Text = settings.Text or "Label"
    self.ColSpan = settings.ColSpan or 1
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    frame.Parent = parent.Container
    CreateCorner(frame, 7)
    CreateStroke(frame, Theme.ElementStroke, 1)
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 1, 0)
    text.Position = UDim2.new(0, 8, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = self.Text
    text.TextColor3 = Theme.TextColor
    text.TextSize = 13
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    self.Root = frame
    FadeIn(self.Root, 0.7)
    return self
end

function Label:Set(newText)
    if self.Root then
        local textLabel = self.Root:FindFirstChildWhichIsA("TextLabel")
        if textLabel then
            textLabel.Text = newText
        end
    end
    self.Text = newText
end

-- Section component (collapsible container)
local Section = setmetatable({}, Component)
Section.__index = Section

function Section.new(parent, settings)
    local self = Component.new(parent, "Section", settings)
    self.Title = settings.Title or "Section"
    self.ColSpan = settings.ColSpan or 1
    self.Collapsed = settings.Collapsed or false
    self.Children = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    frame.Parent = parent.Container
    CreateCorner(frame, 7)
    CreateStroke(frame, Theme.ElementStroke, 1)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Theme.SectionHeaderBg
    header.BorderSizePixel = 0
    header.Parent = frame
    CreateCorner(header, 7)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = Theme.TextColor
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -32, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6031098662" -- arrow down
    arrow.ImageColor3 = Theme.TextColor
    arrow.Parent = header
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Visible = not self.Collapsed
    content.Parent = frame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content
    
    self.Container = content
    self.Header = header
    self.ContentFrame = content
    self.Arrow = arrow
    
    local function Toggle()
        if self.Locked then return end
        self.Collapsed = not self.Collapsed
        local targetRot = self.Collapsed and 0 or 180
        local targetHeight = self.Collapsed and 0 or self:CalculateContentHeight()
        TweenService:Create(content, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Rotation = targetRot
        }):Play()
        task.wait(0.35)
        content.Visible = not self.Collapsed
        frame.Size = UDim2.new(1, 0, 0, 40 + (self.Collapsed and 0 or self:CalculateContentHeight()))
    end
    
    local headerButton = Instance.new("TextButton")
    headerButton.Size = UDim2.new(1, 0, 1, 0)
    headerButton.BackgroundTransparency = 1
    headerButton.Text = ""
    headerButton.Parent = header
    headerButton.MouseButton1Click:Connect(Toggle)
    
    self.Root = frame
    self.Toggle = Toggle
    FadeIn(self.Root, 0.7)
    return self
end

function Section:CalculateContentHeight()
    local total = 0
    for _, child in ipairs(self.Children) do
        if child.Root and child.Root.Parent == self.ContentFrame then
            total = total + child.Root.AbsoluteSize.Y + 8
        end
    end
    return math.max(0, total - 8)
end

function Section:AddElement(element)
    table.insert(self.Children, element)
    if element.Root then
        element.Root.Parent = self.ContentFrame
        local newHeight = self:CalculateContentHeight()
        self.ContentFrame.Size = UDim2.new(1, 0, 0, newHeight)
        self.Root.Size = UDim2.new(1, 0, 0, 40 + newHeight)
    end
end

function Section:RemoveElement(element)
    for i, e in ipairs(self.Children) do
        if e == element then
            table.remove(self.Children, i)
            break
        end
    end
    local newHeight = self:CalculateContentHeight()
    self.ContentFrame.Size = UDim2.new(1, 0, 0, newHeight)
    self.Root.Size = UDim2.new(1, 0, 0, 40 + newHeight)
end

-- Grid class
local Grid = {}
Grid.__index = Grid

function Grid.new(parent, settings)
    local self = setmetatable({}, Grid)
    self.Parent = parent
    self.Columns = settings.Columns or 2
    self.Gap = settings.Gap or 8
    self.Container = parent.ContentContainer
    self.Elements = {}
    self.RowContainer = Instance.new("Frame")
    self.RowContainer.Size = UDim2.new(1, 0, 0, 0)
    self.RowContainer.BackgroundTransparency = 1
    self.RowContainer.Parent = self.Container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, self.Gap)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.RowContainer
    
    self.Layout = layout
    return self
end

function Grid:AddElement(element)
    table.insert(self.Elements, element)
    self:Reflow()
end

function Grid:RemoveElement(element)
    for i, e in ipairs(self.Elements) do
        if e == element then
            table.remove(self.Elements, i)
            break
        end
    end
    self:Reflow()
end

function Grid:Reflow()
    -- Clear existing rows
    for _, child in ipairs(self.RowContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name == "GridRow" then
            child:Destroy()
        end
    end
    
    if #self.Elements == 0 then return end
    
    local containerWidth = self.Container.AbsoluteSize.X
    if containerWidth <= 0 then
        task.wait()
        containerWidth = self.Container.AbsoluteSize.X
    end
    local cellWidth = (containerWidth - (self.Gap * (self.Columns - 1))) / self.Columns
    
    local rows = {}
    local currentRow = { elements = {}, usedColumns = 0, height = 0 }
    
    for _, element in ipairs(self.Elements) do
        local colSpan = element.ColSpan or 1
        if currentRow.usedColumns + colSpan > self.Columns then
            table.insert(rows, currentRow)
            currentRow = { elements = {}, usedColumns = 0, height = 0 }
        end
        table.insert(currentRow.elements, element)
        currentRow.usedColumns = currentRow.usedColumns + colSpan
    end
    if #currentRow.elements > 0 then
        table.insert(rows, currentRow)
    end
    
    for rowIdx, row in ipairs(rows) do
        local rowFrame = Instance.new("Frame")
        rowFrame.Name = "GridRow"
        rowFrame.Size = UDim2.new(1, 0, 0, 0)
        rowFrame.BackgroundTransparency = 1
        rowFrame.Parent = self.RowContainer
        
        local xOffset = 0
        local maxHeight = 0
        
        for _, element in ipairs(row.elements) do
            local colSpan = element.ColSpan or 1
            local width = (cellWidth * colSpan) + (self.Gap * (colSpan - 1))
            if element.Root then
                element.Root.Size = UDim2.new(0, width, 0, element.Root.Size.Y.Offset)
                element.Root.Position = UDim2.new(0, xOffset, 0, 0)
                element.Root.Parent = rowFrame
                maxHeight = math.max(maxHeight, element.Root.Size.Y.Offset)
                xOffset = xOffset + width + self.Gap
            end
        end
        
        rowFrame.Size = UDim2.new(1, 0, 0, maxHeight)
    end
    
    self.RowContainer.Size = UDim2.new(1, 0, 0, self.RowContainer.AbsoluteSize.Y)
end

function Grid:CreateButton(settings)
    local btn = Button.new(self, settings)
    self:AddElement(btn)
    return btn
end

function Grid:CreateToggle(settings)
    local toggle = Toggle.new(self, settings)
    self:AddElement(toggle)
    return toggle
end

function Grid:CreateSlider(settings)
    local slider = Slider.new(self, settings)
    self:AddElement(slider)
    return slider
end

function Grid:CreateInput(settings)
    local input = Input.new(self, settings)
    self:AddElement(input)
    return input
end

function Grid:CreateLabel(settings)
    local label = Label.new(self, settings)
    self:AddElement(label)
    return label
end

function Grid:CreateSection(settings)
    local section = Section.new(self, settings)
    self:AddElement(section)
    return section
end

-- Window class
local Window = {}
Window.__index = Window

function Window.new(settings)
    local self = setmetatable({}, Window)
    self.Title = settings.Title or "GridLib"
    self.Size = settings.Size or UDim2.new(0, 500, 0, 475)
    
    -- ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "GridLib"
    self.Gui.ResetOnSpawn = false
    self.Gui.Parent = PlayerGui
    
    -- Main frame
    self.Main = Instance.new("Frame")
    self.Main.Size = self.Size
    self.Main.Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    self.Main.BackgroundColor3 = Theme.WindowBg
    self.Main.BorderSizePixel = 0
    self.Main.Parent = self.Gui
    CreateCorner(self.Main, 10)
    
    -- Topbar
    self.Topbar = Instance.new("Frame")
    self.Topbar.Size = UDim2.new(1, 0, 0, 45)
    self.Topbar.BackgroundColor3 = Theme.TopbarBg
    self.Topbar.BorderSizePixel = 0
    self.Topbar.Parent = self.Main
    CreateCorner(self.Topbar, 10)
    
    -- Topbar title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme.TextColor
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Topbar
    
    -- Close button (optional)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, -8)
    closeBtn.Position = UDim2.new(1, -38, 0, 4)
    closeBtn.BackgroundColor3 = Theme.ElementBg
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.TextColor
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = self.Topbar
    CreateCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        self.Gui:Destroy()
    end)
    
    -- Content container (ScrollingFrame)
    self.ContentContainer = Instance.new("ScrollingFrame")
    self.ContentContainer.Size = UDim2.new(1, -12, 1, -57)
    self.ContentContainer.Position = UDim2.new(0, 6, 0, 51)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentContainer.ScrollBarThickness = 6
    self.ContentContainer.ScrollBarImageColor3 = Theme.ElementStroke
    self.ContentContainer.Parent = self.Main
    
    -- Make draggable
    MakeDraggable(self.Main, self.Topbar)
    
    return self
end

function Window:CreateGrid(settings)
    local grid = Grid.new(self, settings)
    return grid
end

-- Public API
function GridLib:CreateWindow(settings)
    return Window.new(settings)
end

return GridLib

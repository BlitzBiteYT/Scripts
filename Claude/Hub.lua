-- ============================================================
--  CustomPanel.lua  —  Standalone Roblox Lua client-side script
--  Slide-out side panel replicating TurtleUiLib's visual style.
--  NO loadstring / NO external library required.
--
--  Usage:
--    Execute this script inside any Roblox executor, or place it
--    inside a LocalScript in StarterPlayerScripts.
--
--  Controls:
--    • Click / tap the ">" trigger button  → open panel
--    • Click / tap outside the open panel  → close panel
--    • Press RightShift                    → toggle panel
--    • Drag the trigger button anywhere    → it remembers position
-- ============================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  COLOUR PALETTE  (mirrors TurtleUiLib exactly)
-- ============================================================
local C = {
    Body       = Color3.fromHex("2F3640"),  -- dark panel background
    Header     = Color3.fromHex("00A8FF"),  -- bright-blue header bar
    Accent     = Color3.fromHex("0097E6"),  -- border / trigger button
    Widget     = Color3.fromHex("353B48"),  -- button / input background
    Border     = Color3.fromHex("718093"),  -- widget borders
    TextPri    = Color3.fromHex("F5F6FA"),  -- primary text (near-white)
    TextSec    = Color3.fromHex("DCDDE1"),  -- secondary / placeholder text
    Dark       = Color3.fromHex("2F3640"),  -- header title text (dark on blue)
}

-- ============================================================
--  SCREEN GUI  — full-screen, parented to CoreGui
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "CustomPanel"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    -- Synapse X protection (if available)
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    ScreenGui.Parent = game.CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
--  UTILITY — terse Instance factory
-- ============================================================
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

-- ============================================================
--  Z-INDEX CONSTANTS  (follows TurtleUiLib layering scheme)
-- ============================================================
-- Overlay (below panel)       : 4
-- Panel body                  : 5
-- Panel widgets               : 6
-- Panel widget elements       : 7
-- Panel header                : 8
-- Panel header text           : 9
-- Trigger button              : 10

-- ============================================================
--  TRIGGER BUTTON  — top-right default, freely draggable
-- ============================================================
local TriggerBtn = make("TextButton", {
    Name             = "TriggerButton",
    Size             = UDim2.new(0, 28, 0, 28),
    Position         = UDim2.new(1, -38, 0, 10),   -- top-right default
    AnchorPoint      = Vector2.new(0, 0),
    BackgroundColor3 = C.Accent,
    BorderColor3     = C.Border,
    BorderSizePixel  = 1,
    Text             = ">",
    TextColor3       = C.TextPri,
    Font             = Enum.Font.SourceSans,
    TextSize         = 17,
    ZIndex           = 10,
    AutoButtonColor  = false,
}, ScreenGui)

-- ============================================================
--  CLICK-OUTSIDE OVERLAY  — transparent, sits below panel
-- ============================================================
local Overlay = make("TextButton", {
    Name                   = "Overlay",
    Size                   = UDim2.new(1, 0, 1, 0),
    Position               = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text                   = "",
    ZIndex                 = 4,
    Visible                = false,
    AutoButtonColor        = false,
}, ScreenGui)

-- ============================================================
--  SLIDE-OUT PANEL  — 25 % screen width, full height
-- ============================================================
local PANEL_HIDDEN = UDim2.new(1,    0, 0, 0)   -- off-screen (right)
local PANEL_SHOWN  = UDim2.new(0.75, 0, 0, 0)   -- slides in from right

local Panel = make("Frame", {
    Name             = "Panel",
    Size             = UDim2.new(0.25, 0, 1, 0),
    Position         = PANEL_HIDDEN,
    BackgroundColor3 = C.Body,
    BorderSizePixel  = 0,
    ZIndex           = 5,
    ClipsDescendants = true,
}, ScreenGui)

-- Left accent border stripe (mirrors TurtleUiLib's window border colour)
make("Frame", {
    Name             = "LeftBorder",
    Size             = UDim2.new(0, 3, 1, 0),
    Position         = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = C.Accent,
    BorderSizePixel  = 0,
    ZIndex           = 6,
}, Panel)

-- ── 1. HEADER BAR  (26 px tall — matches TurtleUiLib Header spec) ──────────
local HEADER_H = 26

local HeaderBar = make("Frame", {
    Name             = "HeaderBar",
    Size             = UDim2.new(1, 0, 0, HEADER_H),
    Position         = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = C.Header,
    BorderSizePixel  = 0,
    ZIndex           = 8,
}, Panel)

make("TextLabel", {
    Name                   = "HeaderText",
    Size                   = UDim2.new(1, -8, 1, 0),
    Position               = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text                   = "Menu",
    TextColor3             = C.Dark,          -- dark text on blue bar
    Font                   = Enum.Font.SourceSans,
    TextSize               = 17,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 9,
}, HeaderBar)

-- ── 2. SEARCH BAR  (Box widget style — 32 px row) ───────────────────────────
local SEARCH_Y = HEADER_H          -- starts immediately below header

local SearchBox = make("TextBox", {
    Name              = "SearchBox",
    Size              = UDim2.new(1, -6, 0, 26),
    Position          = UDim2.new(0, 3, 0, SEARCH_Y + 3),
    BackgroundColor3  = C.Widget,
    BorderColor3      = C.Border,
    BorderSizePixel   = 1,
    PlaceholderText   = "Search...",
    PlaceholderColor3 = C.TextSec,
    Text              = "",
    TextColor3        = C.TextPri,
    Font              = Enum.Font.SourceSans,
    TextSize          = 17,
    ClearTextOnFocus  = false,            -- mobile: don't wipe on tap
    ZIndex            = 6,
}, Panel)

-- Mobile keyboard fix: defer CaptureFocus so the keyboard reliably opens
SearchBox.Focused:Connect(function()
    task.defer(function()
        if SearchBox and SearchBox.Parent then
            SearchBox:CaptureFocus()
        end
    end)
end)

-- ── 3. SECTION LABEL  (206 x 29 px — matches TurtleUiLib Label spec) ────────
local LABEL_Y = SEARCH_Y + 32      -- 32 px below search bar

make("TextLabel", {
    Name                   = "SectionLabel",
    Size                   = UDim2.new(0, 206, 0, 29),
    Position               = UDim2.new(0, 3, 0, LABEL_Y + 2),
    BackgroundTransparency = 1,
    Text                   = "Actions",
    TextColor3             = C.TextSec,
    Font                   = Enum.Font.SourceSans,
    TextSize               = 17,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 6,
}, Panel)

-- ── 4. SCROLLABLE BUTTON LIST  (fills remaining height) ─────────────────────
local LIST_Y = LABEL_Y + 32        -- 32 px below section label

local ScrollFrame = make("ScrollingFrame", {
    Name                 = "ButtonList",
    Size                 = UDim2.new(1, 0, 1, -LIST_Y),   -- remaining height
    Position             = UDim2.new(0, 0, 0, LIST_Y),
    BackgroundColor3     = C.Body,
    BorderSizePixel      = 0,
    ScrollBarThickness   = 4,
    ScrollBarImageColor3 = C.Border,
    CanvasSize           = UDim2.new(0, 0, 0, 0),
    ZIndex               = 6,
    ClipsDescendants     = true,
}, Panel)

-- ============================================================
--  SAMPLE BUTTONS  (Button spec: 182 x 26 px, +32 px per row)
-- ============================================================
local BUTTON_DEFS = {
    { name = "Teleport",    cb = function() print("Teleport clicked")    end },
    { name = "Fly",         cb = function() print("Fly clicked")         end },
    { name = "Speed Boost", cb = function() print("Speed Boost clicked") end },
    { name = "Noclip",      cb = function() print("Noclip clicked")      end },
    { name = "ESP",         cb = function() print("ESP clicked")         end },
    { name = "God Mode",    cb = function() print("God Mode clicked")    end },
    { name = "Auto Farm",   cb = function() print("Auto Farm clicked")   end },
}

local buttonEntries = {}   -- { btn = TextButton, nameLower = string }

do
    local yOff = 3
    for _, def in ipairs(BUTTON_DEFS) do
        local btn = make("TextButton", {
            Name             = def.name,
            Size             = UDim2.new(0, 182, 0, 26),
            Position         = UDim2.new(0, 3, 0, yOff),
            BackgroundColor3 = C.Widget,
            BorderColor3     = C.Border,
            BorderSizePixel  = 1,
            Text             = def.name,
            TextColor3       = C.TextPri,
            Font             = Enum.Font.SourceSans,
            TextSize         = 17,
            AutoButtonColor  = false,
            ZIndex           = 7,
        }, ScrollFrame)

        btn.MouseButton1Down:Connect(def.cb)

        table.insert(buttonEntries, { btn = btn, nameLower = def.name:lower() })
        yOff = yOff + 32
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOff + 3)
end

-- Filter button list based on search text; update canvas height
local function applyFilter(raw)
    local q = raw:lower()
    local yOff = 3
    for _, entry in ipairs(buttonEntries) do
        if q == "" or entry.nameLower:find(q, 1, true) then
            entry.btn.Visible  = true
            entry.btn.Position = UDim2.new(0, 3, 0, yOff)
            yOff = yOff + 32
        else
            entry.btn.Visible = false
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOff + 3)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    applyFilter(SearchBox.Text)
end)

-- ============================================================
--  TWEEN SYSTEM  — 0.3 s Quad-Out, tracks active state
-- ============================================================
local TWEEN_INFO  = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenActive = false

local function tweenTo(targetPos, onDone)
    tweenActive = true
    local tw = TweenService:Create(Panel, TWEEN_INFO, { Position = targetPos })
    tw.Completed:Connect(function()
        tweenActive = false
        if onDone then onDone() end
    end)
    tw:Play()
end

-- ============================================================
--  PANEL STATE MACHINE
-- ============================================================
local panelOpen      = false
local lastTriggerPos = TriggerBtn.Position   -- position memory

local function openPanel()
    if panelOpen or tweenActive then return end
    panelOpen          = true
    TriggerBtn.Visible = false
    Overlay.Visible    = true
    tweenTo(PANEL_SHOWN)
end

local function closePanel()
    if not panelOpen or tweenActive then return end
    panelOpen       = false
    Overlay.Visible = false
    tweenTo(PANEL_HIDDEN, function()
        -- Restore trigger at its remembered position
        TriggerBtn.Position = lastTriggerPos
        TriggerBtn.Visible  = true
        -- Reset search
        SearchBox.Text = ""
        applyFilter("")
    end)
end

local function togglePanel()
    if panelOpen then closePanel() else openPanel() end
end

-- ============================================================
--  TRIGGER BUTTON — draggable (delta-based RunService.Stepped)
-- ============================================================
local isDragging      = false
local dragMouseStart  = Vector2.zero
local dragPosStart    = TriggerBtn.Position
local dragConn        = nil
local movedSignif     = false     -- distinguishes drag vs click

local DRAG_THRESHOLD = 4          -- pixels before we count it as a drag

TriggerBtn.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if tweenActive then return end

    isDragging     = true
    movedSignif    = false
    dragMouseStart = Vector2.new(input.Position.X, input.Position.Y)
    dragPosStart   = TriggerBtn.Position

    dragConn = RunService.Stepped:Connect(function()
        if not isDragging then return end
        local cur   = UserInputService:GetMouseLocation()
        local delta = cur - dragMouseStart

        if delta.Magnitude >= DRAG_THRESHOLD then
            movedSignif = true
        end

        TriggerBtn.Position = UDim2.new(
            dragPosStart.X.Scale,
            dragPosStart.X.Offset + delta.X,
            dragPosStart.Y.Scale,
            dragPosStart.Y.Offset + delta.Y
        )
    end)
end)

TriggerBtn.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end

    if isDragging then
        isDragging       = false
        lastTriggerPos   = TriggerBtn.Position   -- save position
        if dragConn then
            dragConn:Disconnect()
            dragConn = nil
        end
    end
end)

-- Activated fires after InputEnded; only toggle if it was a tap, not a drag
TriggerBtn.Activated:Connect(function()
    if not movedSignif then
        togglePanel()
    end
end)

-- ============================================================
--  CLICK OUTSIDE — overlay closes the panel
-- ============================================================
Overlay.MouseButton1Down:Connect(function()
    closePanel()
end)

-- ============================================================
--  KEYBOARD TOGGLE  — RightShift
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        togglePanel()
    end
end)

--[[
    Compact Two‑Column Roblox Script Loader
    Fetches script list from GitHub, shows a small draggable GUI with search,
    and runs loadstring(game:HttpGet(BASE_URL .. GameName))()
--]]

local BASE_URL = "https://raw.githubusercontent.com/gumanba/Scripts/main/"
local LIST_URL = "https://raw.githubusercontent.com/BlitzBiteYT/Scripts/refs/heads/main/scriptlist.txt"

-- Services
local CoreGui = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- ----------- Create main GUI ----------
local screen = Instance.new("ScreenGui")
screen.Name = "CompactScriptLoader"
screen.Parent = CoreGui

-- Main frame – smaller size for two‑column layout
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 300, 0, 380)
mainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screen

-- Rounded corners for the main frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Gradient background for a modern look
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 38))
})
grad.Parent = mainFrame

-- ---------- Title bar (drag handle) ----------
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Text = "📜 Scripts"
titleText.Size = UDim2.new(1, -35, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -28, 0, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 13)
closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- ---------- Search bar ----------
local searchBox = Instance.new("TextBox")
searchBox.Name = "Search"
searchBox.Size = UDim2.new(1, -16, 0, 26)
searchBox.Position = UDim2.new(0, 8, 0, 34)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.PlaceholderText = "🔍 Search..."
searchBox.Font = Enum.Font.SourceSans
searchBox.TextSize = 13
searchBox.BorderSizePixel = 0
searchBox.Parent = mainFrame
local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

-- ---------- Scrolling frame for the two‑column grid ----------
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, -16, 1, -68)
scroll.Position = UDim2.new(0, 8, 0, 66)
scroll.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- will be updated
scroll.Parent = mainFrame
local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scroll

-- Grid layout: exactly 2 columns
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 134, 0, 38)       -- two cells fit in 300px width
grid.CellPadding = UDim2.new(0, 6, 0, 4)       -- horizontal & vertical padding
grid.FillDirection = Enum.FillDirection.Horizontal
grid.FillDirectionMaxCells = 2
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Top
grid.SortOrder = Enum.SortOrder.LayoutOrder    -- manual order (alphabetical)
grid.Parent = scroll

-- ---------- Dragging logic (works on mobile touch & PC mouse) ----------
local dragToggle = false
local dragStartPos, startMousePos

local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        startMousePos = input.Position
        dragStartPos = mainFrame.Position
    end
end

local function stopDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end

local function updateDrag(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or
                      input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startMousePos
        mainFrame.Position = UDim2.new(
            dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y
        )
    end
end

titleBar.InputBegan:Connect(startDrag)
titleBar.InputEnded:Connect(stopDrag)
UIS.InputChanged:Connect(updateDrag)

-- ---------- Fetch & parse list ----------
local rawList = ""
pcall(function()
    rawList = game:HttpGet(LIST_URL)
end)

local function getSortedNames()
    local names = {}
    -- split by any whitespace
    for name in rawList:gmatch("%S+") do
        table.insert(names, name)
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local allNames = getSortedNames()
if #allNames == 0 then
    local err = Instance.new("TextLabel")
    err.Text = "❌ Failed to load list!"
    err.Size = UDim2.new(1, 0, 1, 0)
    err.BackgroundTransparency = 1
    err.TextColor3 = Color3.new(1, 0.3, 0.3)
    err.TextScaled = true
    err.Font = Enum.Font.SourceSansBold
    err.Parent = scroll
    return
end

-- ---------- Button creation ----------
local buttons = {}

local function createButtons(filter)
    -- Remove old buttons
    for _, btn in ipairs(buttons) do
        btn:Destroy()
    end
    table.clear(buttons)

    local lowerFilter = filter:lower()
    local order = 0

    for _, name in ipairs(allNames) do
        if lowerFilter == "" or name:lower():find(lowerFilter, 1, true) then
            order = order + 1
            local btn = Instance.new("TextButton")
            btn.Name = name
            btn.LayoutOrder = order
            -- Size is controlled by grid.CellSize, but we still need a default
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.SourceSansSemibold
            btn.Text = name
            btn.TextSize = 12
            btn.TextTruncate = Enum.TextTruncate.AtEnd
            btn.BorderSizePixel = 0
            btn.Parent = scroll

            -- Rounded corners for each button
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            -- Subtle gradient on buttons
            local btnGrad = Instance.new("UIGradient")
            btnGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 210)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 110, 180))
            })
            btnGrad.Parent = btn

            -- Hover / press effects (optional)
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(90, 150, 220)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
            end)

            btn.MouseButton1Click:Connect(function()
                local url = BASE_URL .. name
                pcall(function()
                    loadstring(game:HttpGet(url))()
                end)
            end)

            table.insert(buttons, btn)
        end
    end

    -- Update CanvasSize based on number of rows
    local rows = math.ceil(#buttons / 2)
    local totalHeight = rows * (38 + 4)  -- cell height + vertical padding
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 100))
end

-- Initial creation
createButtons("")

-- Search filter
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    createButtons(searchBox.Text)
end)

-- Fallback: update canvas when children are added
scroll.ChildAdded:Connect(function()
    if #buttons > 0 then
        local rows = math.ceil(#buttons / 2)
        scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(rows * 42, 100))
    end
end)

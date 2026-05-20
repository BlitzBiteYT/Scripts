-- ============================================================
--  MyHub UI Library  v1.0.0
--  Self-contained Roblox executor UI library
--  Rendering: ScreenGui + Frame hierarchy (PlayerGui / CoreGui)
--  Author   : Generated for MyHub spec
-- ============================================================

-- ── Prevent duplicate loads ──────────────────────────────────
if getgenv and getgenv().MyHubLib then
    return getgenv().MyHubLib
end

-- ── Services ─────────────────────────────────────────────────
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

-- ── Theme tokens ─────────────────────────────────────────────
local Theme = {
    AccentPrimary  = Color3.fromHex("#2dc653"),
    AccentLight    = Color3.fromHex("#74e89b"),
    WindowBg       = Color3.fromHex("#1a1a2e"),
    TitlebarBg     = Color3.fromHex("#12122a"),
    SidebarBg      = Color3.fromHex("#16162e"),
    ContentBg      = Color3.fromHex("#0f0f1e"),
    SectionBg      = Color3.fromHex("#1d1d35"),
    TextPrimary    = Color3.fromHex("#e2e0f0"),
    TextSecondary  = Color3.fromHex("#8b85b0"),
    TextMuted      = Color3.fromHex("#5a5580"),
    BorderColor    = Color3.fromHex("#2dc653"),
    ToggleOn       = Color3.fromHex("#2dc653"),
    ToggleOff      = Color3.fromHex("#2a2a44"),
    TrackBg        = Color3.fromHex("#2a2a44"),
}

-- ── Utility helpers ──────────────────────────────────────────

--- Creates a UICorner with given radius.
local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

--- Creates a UIStroke on a parent frame.
local function MakeStroke(parent, color, alpha, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or Theme.BorderColor
    s.Transparency = alpha or 0.4
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

--- Creates a UIListLayout for stacking children.
local function MakeList(parent, padding, dir)
    local l = Instance.new("UIListLayout")
    l.Padding  = UDim.new(0, padding or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Parent   = parent
    return l
end

--- Creates a UIPadding instance.
local function MakePadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 8)
    p.PaddingRight  = UDim.new(0, right  or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft   = UDim.new(0, left   or 8)
    p.Parent        = parent
    return p
end

--- Quick Frame builder.
local function MakeFrame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3   = props.Color      or Theme.WindowBg
    f.BackgroundTransparency = props.Alpha  or 0
    f.Size               = props.Size       or UDim2.new(1,0,0,30)
    f.Position           = props.Position   or UDim2.new(0,0,0,0)
    f.BorderSizePixel    = 0
    f.ClipsDescendants   = props.Clip       or false
    f.ZIndex             = props.ZIndex     or 1
    f.Name               = props.Name       or "Frame"
    if props.Parent then f.Parent = props.Parent end
    return f
end

--- Quick TextLabel builder.
local function MakeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text      = props.Text     or ""
    l.TextColor3 = props.Color   or Theme.TextPrimary
    l.TextSize  = props.Size     or 13
    l.Font      = props.Font     or Enum.Font.Gotham
    l.TextXAlignment = props.AlignX or Enum.TextXAlignment.Left
    l.TextYAlignment = props.AlignY or Enum.TextYAlignment.Center
    l.Size      = props.FrameSize or UDim2.new(1,0,1,0)
    l.Position  = props.Position  or UDim2.new(0,0,0,0)
    l.ZIndex    = props.ZIndex    or 2
    l.Name      = props.Name      or "Label"
    l.TextTruncate = Enum.TextTruncate.AtEnd
    if props.Parent then l.Parent = props.Parent end
    return l
end

--- Quick TextButton builder.
local function MakeButton(props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3   = props.Color   or Theme.SectionBg
    b.BackgroundTransparency = props.Alpha or 0
    b.Text     = props.Text    or ""
    b.TextColor3 = props.TextColor or Theme.TextPrimary
    b.TextSize = props.TextSize  or 13
    b.Font     = props.Font      or Enum.Font.Gotham
    b.Size     = props.Size      or UDim2.new(1,0,0,30)
    b.Position = props.Position  or UDim2.new(0,0,0,0)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex   = props.ZIndex    or 2
    b.Name     = props.Name      or "Button"
    b.ClipsDescendants = props.Clip or false
    if props.Parent then b.Parent = props.Parent end
    return b
end

--- Tween helper: tweens a property table.
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t     or 0.2,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

--- Makes a frame draggable via titlebar.
local function MakeDraggable(titlebar, target)
    local dragging   = false
    local dragStart  = Vector3.new()
    local startPos   = UDim2.new()

    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            dragStart  = input.Position
            startPos   = target.Position
        end
    end)

    titlebar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and
           input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── Library table ────────────────────────────────────────────
local Lib = {}
Lib.__index = Lib

-- Internal state storage accessible by other scripts
local _State = {}
if getgenv then
    getgenv()._MyHubState = _State
end

-- ── CreateWindow ─────────────────────────────────────────────

---Creates the main UI window.
---@param cfg table  { Title, Keybind, Theme }
---@return table     Window object
function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    local title   = cfg.Title   or "MyHub"
    local keybind = cfg.Keybind or Enum.KeyCode.RightShift

    -- ── Root ScreenGui ────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name               = "MyHubGui"
    gui.ResetOnSpawn       = false
    gui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset     = true
    -- Try CoreGui first (exec), fall back to PlayerGui
    local ok = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── Main window frame ─────────────────────────────────────
    local win = MakeFrame({
        Name     = "Window",
        Color    = Theme.WindowBg,
        Alpha    = 0.09,
        Size     = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        Parent   = gui,
    })
    MakeCorner(win, 8)
    MakeStroke(win, Theme.BorderColor, 0.55, 1)

    -- ── Titlebar (40px) ───────────────────────────────────────
    local titlebar = MakeFrame({
        Name   = "Titlebar",
        Color  = Theme.TitlebarBg,
        Size   = UDim2.new(1,0,0,40),
        Parent = win,
    })
    MakeCorner(titlebar, 8)
    -- Clip bottom corners via overlap trick
    local titleFill = MakeFrame({
        Name   = "TitleFill",
        Color  = Theme.TitlebarBg,
        Size   = UDim2.new(1,0,0,20),
        Position = UDim2.new(0,0,1,-20),
        Parent = titlebar,
    })

    -- Decorative dots (close / min / max)
    local dotColors = { "#ff5f57", "#febc2e", "#28c840" }
    for i, hex in ipairs(dotColors) do
        local dot = MakeFrame({
            Name   = "Dot"..i,
            Color  = Color3.fromHex(hex),
            Size   = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0, 10 + (i-1)*16, 0.5, -5),
            Parent = titlebar,
        })
        MakeCorner(dot, 5)
    end

    -- Title label
    MakeLabel({
        Text   = title,
        Color  = Theme.TextPrimary,
        Size   = 14,
        Font   = Enum.Font.GothamBold,
        FrameSize = UDim2.new(1,-180,1,0),
        Position  = UDim2.new(0, 60, 0, 0),
        Parent    = titlebar,
    })

    -- Keybind badge (pill)
    local badge = MakeFrame({
        Name   = "KeybindBadge",
        Color  = Theme.SectionBg,
        Size   = UDim2.new(0, 80, 0, 22),
        Position = UDim2.new(1, -90, 0.5, -11),
        Parent = titlebar,
    })
    MakeCorner(badge, 11)
    MakeStroke(badge, Theme.BorderColor, 0.4, 1)
    MakeLabel({
        Text   = "RightShift",
        Color  = Theme.TextSecondary,
        Size   = 10,
        Font   = Enum.Font.Gotham,
        AlignX = Enum.TextXAlignment.Center,
        Parent = badge,
    })

    -- Make titlebar draggable
    MakeDraggable(titlebar, win)

    -- ── Body (below titlebar) ─────────────────────────────────
    local body = MakeFrame({
        Name   = "Body",
        Color  = Theme.WindowBg,
        Alpha  = 1,  -- transparent; window bg shows through
        Size   = UDim2.new(1,0,1,-40),
        Position = UDim2.new(0,0,0,40),
        Parent = win,
    })

    -- ── Sidebar (80px) ────────────────────────────────────────
    local sidebar = MakeFrame({
        Name   = "Sidebar",
        Color  = Theme.SidebarBg,
        Size   = UDim2.new(0, 80, 1, 0),
        Parent = body,
    })
    local sidebarList = MakeList(sidebar, 4)
    MakePadding(sidebar, 8, 4, 8, 4)

    -- ── Content pane ──────────────────────────────────────────
    local content = MakeFrame({
        Name   = "Content",
        Color  = Theme.ContentBg,
        Size   = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 80, 0, 0),
        Clip   = true,
        Parent = body,
    })
    MakeCorner(content, 8) -- bottom-right corner

    -- ── Visibility toggle ─────────────────────────────────────
    local visible = true
    local function SetVisible(state)
        visible = state
        if state then
            win.Visible = true
            Tween(win, { Size = UDim2.new(0,580,0,420) }, 0.2)
        else
            -- Store tween in local so we can access .Completed
            -- without the :Completed chaining that Lua 5.1
            -- rejects at compile time.
            local hideTween =
                Tween(win, { Size = UDim2.new(0,0,0,0) }, 0.2)
            hideTween.Completed:Connect(function()
                win.Visible = false
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == keybind then
            SetVisible(not visible)
        end
    end)

    -- ── Window object ─────────────────────────────────────────
    local Window = {}
    Window._tabs      = {}
    Window._tabBtns   = {}
    Window._activeTab = nil
    Window._gui       = gui
    Window._win       = win

    --- Switches the visible tab.
    local function ShowTab(tabObj)
        for _, t in ipairs(Window._tabs) do
            t._frame.Visible = (t == tabObj)
        end
        for _, b in ipairs(Window._tabBtns) do
            if b._tabObj == tabObj then
                b.BackgroundColor3 = Color3.fromHex("#212138")
                b._stroke.Enabled  = true
            else
                b.BackgroundColor3 = Theme.SidebarBg
                b._stroke.Enabled  = false
            end
        end
        Window._activeTab = tabObj
    end

    ---Adds a tab to the sidebar.
    ---@param opts table  { Name, Icon }
    ---@return table      Tab object
    function Window:AddTab(opts)
        opts = opts or {}
        local name = opts.Name or "Tab"

        -- Sidebar button
        local btn = MakeButton({
            Name      = name.."Btn",
            Color     = Theme.SidebarBg,
            Text      = name,
            TextColor = Theme.TextSecondary,
            TextSize  = 11,
            Font      = Enum.Font.GothamBold,
            Size      = UDim2.new(1,0,0,60),
            Parent    = sidebar,
        })
        MakeCorner(btn, 6)

        -- Left accent border (hidden when inactive)
        local stroke = Instance.new("UIStroke")
        stroke.Color       = Theme.AccentPrimary
        stroke.Thickness   = 2
        stroke.Enabled     = false
        stroke.Parent      = btn
        btn._stroke  = stroke
        btn._tabObj  = nil  -- assigned below

        -- Tab content frame (scrollable)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name             = name.."Tab"
        scroll.BackgroundTransparency = 1
        scroll.Size             = UDim2.new(1,0,1,0)
        scroll.CanvasSize       = UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Theme.AccentPrimary
        scroll.BorderSizePixel  = 0
        scroll.Visible          = false
        scroll.Parent           = content
        MakePadding(scroll, 10, 10, 10, 10)
        MakeList(scroll, 10)

        -- Tab object
        local Tab = {}
        Tab._frame  = scroll
        Tab._name   = name

        btn._tabObj = Tab
        table.insert(Window._tabs, Tab)
        table.insert(Window._tabBtns, btn)

        -- Show first tab automatically
        if #Window._tabs == 1 then
            ShowTab(Tab)
            btn.BackgroundColor3 = Color3.fromHex("#212138")
            stroke.Enabled       = true
        end

        btn.MouseButton1Click:Connect(function()
            ShowTab(Tab)
        end)
        btn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(btn, {
                    BackgroundColor3 = Color3.fromHex("#1c1c34")
                }, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(btn, {
                    BackgroundColor3 = Theme.SidebarBg
                }, 0.15)
            end
        end)

        ---Adds a section inside the tab.
        ---@param sectionName string
        ---@return table Section object
        function Tab:AddSection(sectionName)
            -- Section title label (above frame)
            local titleLbl = MakeLabel({
                Text   = string.upper(sectionName or "Section"),
                Color  = Theme.TextMuted,
                Size   = 10,
                Font   = Enum.Font.GothamBold,
                FrameSize = UDim2.new(1,0,0,14),
                Parent    = scroll,
            })

            -- Section frame
            local secFrame = MakeFrame({
                Name   = (sectionName or "Section").."Frame",
                Color  = Theme.SectionBg,
                Size   = UDim2.new(1,0,0,8),  -- grows via AutoSize
                Parent = scroll,
            })
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            MakeCorner(secFrame, 8)
            MakeStroke(secFrame, Color3.new(1,1,1), 0.96, 1)
            MakePadding(secFrame, 10, 10, 10, 10)
            MakeList(secFrame, 8)

            local Section = {}

            -- ── Toggle ────────────────────────────────────────
            ---Adds a toggle switch component.
            ---@param opts table { Name, Default, Callback }
            function Section:AddToggle(opts)
                opts     = opts or {}
                local key  = opts.Name or "toggle"
                local val  = opts.Default ~= nil and opts.Default or false
                local cb   = opts.Callback or function() end

                _State[key] = val

                local row = MakeFrame({
                    Name   = key.."Row",
                    Color  = Theme.SectionBg,
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,0,28),
                    Parent = secFrame,
                })

                MakeLabel({
                    Text   = opts.Name or "Toggle",
                    Color  = Theme.TextPrimary,
                    Size   = 13,
                    FrameSize = UDim2.new(1,-50,1,0),
                    Parent    = row,
                })

                -- Pill track
                local pill = MakeFrame({
                    Name   = "Pill",
                    Color  = val and Theme.ToggleOn or Theme.ToggleOff,
                    Size   = UDim2.new(0, 38, 0, 18),
                    Position = UDim2.new(1,-40, 0.5,-9),
                    Parent = row,
                })
                MakeCorner(pill, 9)

                -- Thumb
                local thumb = MakeFrame({
                    Name   = "Thumb",
                    Color  = Color3.new(1,1,1),
                    Size   = UDim2.new(0,14,0,14),
                    Position = val
                        and UDim2.new(1,-16,0.5,-7)
                        or  UDim2.new(0, 2, 0.5,-7),
                    Parent = pill,
                })
                MakeCorner(thumb, 7)

                -- Click hitbox (invisible button over row)
                local hit = MakeButton({
                    Color  = Color3.new(0,0,0),
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,1,0),
                    ZIndex = 5,
                    Parent = row,
                })

                local function Refresh()
                    local thumbPos = val
                        and UDim2.new(1,-16,0.5,-7)
                        or  UDim2.new(0, 2, 0.5,-7)
                    Tween(pill, {
                        BackgroundColor3 = val
                            and Theme.ToggleOn or Theme.ToggleOff
                    }, 0.15)
                    Tween(thumb, { Position = thumbPos }, 0.15)
                end

                hit.MouseButton1Click:Connect(function()
                    val = not val
                    _State[key] = val
                    Refresh()
                    cb(val)
                end)
            end

            -- ── Slider ────────────────────────────────────────
            ---Adds a slider component.
            ---@param opts table { Name, Min, Max, Default, Callback }
            function Section:AddSlider(opts)
                opts      = opts or {}
                local key  = opts.Name    or "slider"
                local min  = opts.Min     or 0
                local max  = opts.Max     or 100
                local val  = opts.Default or min
                local cb   = opts.Callback or function() end

                _State[key] = val

                local wrap = MakeFrame({
                    Name   = key.."Wrap",
                    Color  = Theme.SectionBg,
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,0,44),
                    Parent = secFrame,
                })

                -- Top row: label + value
                local topRow = MakeFrame({
                    Color = Theme.SectionBg,
                    Alpha = 1,
                    Size  = UDim2.new(1,0,0,20),
                    Parent = wrap,
                })
                MakeLabel({
                    Text   = opts.Name or "Slider",
                    Color  = Theme.TextPrimary,
                    Size   = 13,
                    FrameSize = UDim2.new(1,-40,1,0),
                    Parent    = topRow,
                })
                local valLbl = MakeLabel({
                    Text   = tostring(val),
                    Color  = Theme.AccentLight,
                    Size   = 12,
                    Font   = Enum.Font.GothamBold,
                    AlignX = Enum.TextXAlignment.Right,
                    FrameSize = UDim2.new(0,36,1,0),
                    Position  = UDim2.new(1,-36,0,0),
                    Parent    = topRow,
                })

                -- Track
                local track = MakeFrame({
                    Name   = "Track",
                    Color  = Theme.TrackBg,
                    Size   = UDim2.new(1,0,0,6),
                    Position = UDim2.new(0,0,1,-6),
                    Parent = wrap,
                })
                MakeCorner(track, 3)

                -- Filled portion
                local filled = MakeFrame({
                    Name   = "Filled",
                    Color  = Theme.AccentPrimary,
                    Size   = UDim2.new((val-min)/(max-min),0,1,0),
                    Parent = track,
                })
                MakeCorner(filled, 3)

                -- Thumb
                local sThumb = MakeFrame({
                    Name   = "Thumb",
                    Color  = Color3.new(1,1,1),
                    Size   = UDim2.new(0,12,0,12),
                    Position = UDim2.new(
                        (val-min)/(max-min), -6, 0.5, -6
                    ),
                    Parent = track,
                })
                MakeCorner(sThumb, 6)

                -- Drag logic
                local dragging = false

                local function UpdateSlider(absX)
                    local tAbs = track.AbsolutePosition.X
                    local tSz  = track.AbsoluteSize.X
                    local pct  = math.clamp((absX - tAbs) / tSz, 0, 1)
                    val = math.floor(min + pct * (max - min) + 0.5)
                    _State[key] = val
                    local p = (val - min) / (max - min)
                    filled.Size     = UDim2.new(p, 0, 1, 0)
                    sThumb.Position = UDim2.new(p, -6, 0.5, -6)
                    valLbl.Text     = tostring(val)
                    cb(val)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType ==
                       Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input.Position.X)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input.UserInputType ==
                       Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and
                       input.UserInputType ==
                       Enum.UserInputType.MouseMovement then
                        UpdateSlider(input.Position.X)
                    end
                end)
            end

            -- ── Dropdown ──────────────────────────────────────
            ---Adds a dropdown selector component.
            ---@param opts table { Name, Options, Default, Callback }
            function Section:AddDropdown(opts)
                opts      = opts or {}
                local key  = opts.Name    or "dropdown"
                local options = opts.Options or {}
                local sel  = opts.Default or (options[1] or "")
                local cb   = opts.Callback or function() end
                local open = false

                _State[key] = sel

                local wrap = MakeFrame({
                    Name   = key.."DDWrap",
                    Color  = Theme.SectionBg,
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,0,28),
                    Parent = secFrame,
                })

                MakeLabel({
                    Text   = opts.Name or "Dropdown",
                    Color  = Theme.TextPrimary,
                    Size   = 13,
                    FrameSize = UDim2.new(0.5,-4,1,0),
                    Parent    = wrap,
                })

                -- Select button
                local selBtn = MakeButton({
                    Name   = "SelBtn",
                    Color  = Theme.TrackBg,
                    Text   = sel .. "  ▾",
                    TextColor = Theme.TextPrimary,
                    TextSize  = 12,
                    Size   = UDim2.new(0.5,-4, 0, 22),
                    Position = UDim2.new(0.5,4, 0.5,-11),
                    Parent = wrap,
                })
                MakeCorner(selBtn, 5)
                MakeStroke(selBtn, Theme.BorderColor, 0.5, 1)

                -- Dropdown list (appears below wrap)
                local list = MakeFrame({
                    Name   = "DDList",
                    Color  = Theme.SectionBg,
                    Size   = UDim2.new(0.5,-4, 0,
                        #options * 26 + 6),
                    Position = UDim2.new(0.5,4, 1,2),
                    Clip   = true,
                    ZIndex = 10,
                    Parent = wrap,
                })
                MakeCorner(list, 6)
                MakeStroke(list, Theme.BorderColor, 0.5, 1)
                MakePadding(list, 3, 4, 3, 4)
                MakeList(list, 2)
                list.Visible = false

                local function CloseDD()
                    open = false
                    list.Visible = false
                    wrap.Size = UDim2.new(1,0,0,28)
                end

                -- Populate options
                for _, opt in ipairs(options) do
                    local item = MakeButton({
                        Name   = opt.."Item",
                        Color  = Theme.SectionBg,
                        Text   = opt,
                        TextColor = Theme.TextPrimary,
                        TextSize  = 12,
                        Size   = UDim2.new(1,0,0,22),
                        ZIndex = 11,
                        Parent = list,
                    })
                    MakeCorner(item, 4)
                    item.MouseButton1Click:Connect(function()
                        sel = opt
                        _State[key]  = sel
                        selBtn.Text  = sel .. "  ▾"
                        CloseDD()
                        cb(sel)
                    end)
                    item.MouseEnter:Connect(function()
                        Tween(item,{
                            BackgroundColor3=Color3.fromHex("#212138")
                        }, 0.1)
                    end)
                    item.MouseLeave:Connect(function()
                        Tween(item,{
                            BackgroundColor3=Theme.SectionBg
                        }, 0.1)
                    end)
                end

                selBtn.MouseButton1Click:Connect(function()
                    open = not open
                    list.Visible = open
                    if open then
                        wrap.Size = UDim2.new(1,0,0,
                            28 + #options*26 + 10)
                    else
                        wrap.Size = UDim2.new(1,0,0,28)
                    end
                end)
            end

            -- ── Button ────────────────────────────────────────
            ---Adds a clickable button component.
            ---@param opts table { Name, Callback }
            function Section:AddButton(opts)
                opts = opts or {}
                local cb = opts.Callback or function() end

                local btn = MakeButton({
                    Name   = (opts.Name or "Btn").."Btn",
                    Color  = Theme.SectionBg,
                    Text   = opts.Name or "Button",
                    TextColor = Theme.AccentPrimary,
                    TextSize  = 13,
                    Font      = Enum.Font.GothamBold,
                    Size   = UDim2.new(1,0,0,28),
                    Parent = secFrame,
                })
                MakeCorner(btn, 6)
                MakeStroke(btn, Theme.BorderColor, 0.4, 1)

                btn.MouseButton1Click:Connect(function()
                    Tween(btn,{
                        BackgroundColor3 = Theme.AccentPrimary
                    }, 0.1)
                    local btnTween = Tween(btn,{
                        BackgroundColor3 = Theme.SectionBg
                    }, 0.15)
                    btnTween.Completed:Connect(cb)
                end)
                btn.MouseEnter:Connect(function()
                    Tween(btn,{
                        BackgroundColor3 = Color3.fromHex("#212138")
                    }, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn,{
                        BackgroundColor3 = Theme.SectionBg
                    }, 0.15)
                end)
            end

            -- ── TextBox ───────────────────────────────────────
            ---Adds a single-line text input component.
            ---@param opts table { Name, Default, Callback }
            function Section:AddTextBox(opts)
                opts = opts or {}
                local key = opts.Name or "textbox"
                local def = opts.Default or ""
                local cb  = opts.Callback or function() end

                _State[key] = def

                local wrap = MakeFrame({
                    Name   = key.."TBWrap",
                    Color  = Theme.SectionBg,
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,0,28),
                    Parent = secFrame,
                })

                MakeLabel({
                    Text   = opts.Name or "TextBox",
                    Color  = Theme.TextPrimary,
                    Size   = 13,
                    FrameSize = UDim2.new(0.45,-4,1,0),
                    Parent    = wrap,
                })

                local box = Instance.new("TextBox")
                box.Name                 = "Input"
                box.BackgroundColor3     = Theme.TrackBg
                box.BackgroundTransparency = 0
                box.Text                 = def
                box.PlaceholderText      = "..."
                box.PlaceholderColor3    = Theme.TextMuted
                box.TextColor3           = Theme.TextPrimary
                box.TextSize             = 12
                box.Font                 = Enum.Font.Gotham
                box.Size                 = UDim2.new(0.55,-4,0,22)
                box.Position             = UDim2.new(0.45,4,0.5,-11)
                box.BorderSizePixel      = 0
                box.ClearTextOnFocus     = false
                box.ZIndex               = 3
                box.Parent               = wrap
                MakeCorner(box, 5)

                local stroke = MakeStroke(
                    box, Theme.BorderColor, 0.7, 1
                )

                -- Highlight on focus
                box.Focused:Connect(function()
                    Tween(stroke,{ Transparency = 0 }, 0.15)
                end)
                box.FocusLost:Connect(function(enter)
                    Tween(stroke,{ Transparency = 0.7 }, 0.15)
                    _State[key] = box.Text
                    cb(box.Text)
                end)
            end

            -- ── ColorPicker ───────────────────────────────────
            ---Adds a row of color swatches.
            ---@param opts table { Name, Colors, Default, Callback }
            function Section:AddColorPicker(opts)
                opts    = opts or {}
                local swatches = opts.Colors or {
                    "#ff4444","#ff8844","#ffdd44",
                    "#44ff88","#44aaff","#aa44ff",
                }
                local cb  = opts.Callback or function() end
                local sel = opts.Default  or swatches[1]

                local wrap = MakeFrame({
                    Name   = (opts.Name or "CP").."CPWrap",
                    Color  = Theme.SectionBg,
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,0,42),
                    Parent = secFrame,
                })

                MakeLabel({
                    Text   = opts.Name or "Color",
                    Color  = Theme.TextPrimary,
                    Size   = 13,
                    FrameSize = UDim2.new(1,0,0,16),
                    Parent    = wrap,
                })

                local swatchRow = MakeFrame({
                    Color  = Theme.SectionBg,
                    Alpha  = 1,
                    Size   = UDim2.new(1,0,0,22),
                    Position = UDim2.new(0,0,0,18),
                    Parent = wrap,
                })
                MakeList(swatchRow, 6, Enum.FillDirection.Horizontal)

                for _, hex in ipairs(swatches) do
                    local sw = MakeButton({
                        Color  = Color3.fromHex(hex),
                        Text   = "",
                        Size   = UDim2.new(0,22,0,22),
                        Parent = swatchRow,
                    })
                    MakeCorner(sw, 4)
                    sw.MouseButton1Click:Connect(function()
                        sel = hex
                        cb(Color3.fromHex(hex))
                    end)
                end
            end

            return Section
        end

        return Tab
    end

    ---Destroys the window and all instances.
    function Window:Destroy()
        gui:Destroy()
    end

    return Window
end

-- ── Register and return library ───────────────────────────────
if getgenv then
    getgenv().MyHubLib = Lib
end

return Lib

-- ============================================================
-- USAGE EXAMPLE
-- ============================================================
--[[
local Lib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/.../MyHub.lua"))()

local Win = Lib:CreateWindow({
    Title   = "MyHub",
    Keybind = Enum.KeyCode.RightShift,
    Theme   = "MyHub",
})

local Tab = Win:AddTab({ Name = "Combat" })
local Sec = Tab:AddSection("Combat Settings")

Sec:AddToggle({
    Name     = "Aimbot",
    Default  = true,
    Callback = function(v) print("Aimbot:", v) end,
})

Sec:AddSlider({
    Name     = "Hitbox Exp.",
    Min      = 1, Max = 10, Default = 4,
    Callback = function(v) print("Hitbox:", v) end,
})

Sec:AddDropdown({
    Name    = "Part",
    Options = { "Head", "Torso", "HRP" },
    Default = "Head",
    Callback = function(v) print("Part:", v) end,
})

Sec:AddButton({
    Name     = "Reset Config",
    Callback = function() print("Config reset!") end,
})

Sec:AddTextBox({
    Name     = "Cmd Prefix",
    Default  = ";",
    Callback = function(v) print("Prefix:", v) end,
})

Sec:AddColorPicker({
    Name     = "Highlight",
    Callback = function(c) print("Color:", c) end,
})
--]]

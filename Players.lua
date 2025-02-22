-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")  -- For GUI animations

-- Create ScreenGui and Main Window Frame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomModernUI"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

-- Increase the height from 320 to 340 to make room for the new button
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 340)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -170) -- Centered (adjusted for new height)
mainFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 60, 60)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Header (Draggable Area)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
header.BorderSizePixel = 0
header.Parent = mainFrame
header.Active = true  -- Allow it to receive input

local headerLine = Instance.new("Frame")
headerLine.Name = "HeaderLine"
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 1, -2)
headerLine.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Other's Players Menu"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.Active = false  -- so header gets input
titleLabel.Parent = header

-- Minimize and Maximize Buttons on the header
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -30, 0, 10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.Text = "-"
MinimizeButton.Parent = header

local MaximizeButton = Instance.new("TextButton")
MaximizeButton.Name = "MaximizeButton"
MaximizeButton.Size = UDim2.new(0, 20, 0, 20)
MaximizeButton.Position = UDim2.new(1, -30, 0, 10)
MaximizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MaximizeButton.TextColor3 = Color3.new(1, 1, 1)
MaximizeButton.Font = Enum.Font.GothamBold
MaximizeButton.TextSize = 18
MaximizeButton.Text = "+"
MaximizeButton.Parent = header
MaximizeButton.Visible = false

-- Dropdown Button (to toggle dropdown list)
local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Size = UDim2.new(0, 280, 0, 30)
dropdownButton.Position = UDim2.new(0, 20, 0, 60)
dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownButton.TextColor3 = Color3.new(1, 1, 1)
dropdownButton.Font = Enum.Font.Gotham
dropdownButton.TextSize = 18
dropdownButton.Text = "Select Player"
dropdownButton.Parent = mainFrame

local dropBtnCorner = Instance.new("UICorner")
dropBtnCorner.CornerRadius = UDim.new(0, 6)
dropBtnCorner.Parent = dropdownButton

-- Scrollable Dropdown List (as a ScrollingFrame)
local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(0, 280, 0, 120)
dropdownList.Position = UDim2.new(0, 20, 0, 100)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownList.BorderSizePixel = 0
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.Visible = false
dropdownList.ScrollBarThickness = 6
dropdownList.Parent = mainFrame

local dropListCorner = Instance.new("UICorner")
dropListCorner.CornerRadius = UDim.new(0, 6)
dropListCorner.Parent = dropdownList

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = dropdownList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

-- Teleport Button (below dropdown list)
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(0, 280, 0, 30)
teleportButton.Position = UDim2.new(0, 20, 0, 220)
teleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.TextSize = 18
teleportButton.Text = "Teleport"
teleportButton.Parent = mainFrame

local tpBtnCorner = Instance.new("UICorner")
tpBtnCorner.CornerRadius = UDim.new(0, 6)
tpBtnCorner.Parent = teleportButton

-- Follow Button (below Teleport)
local followButton = Instance.new("TextButton")
followButton.Name = "FollowButton"
followButton.Size = UDim2.new(0, 280, 0, 30)
followButton.Position = UDim2.new(0, 20, 0, 260)
followButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
followButton.TextColor3 = Color3.new(1, 1, 1)
followButton.Font = Enum.Font.GothamBold
followButton.TextSize = 18
followButton.Text = "Follow"
followButton.Parent = mainFrame

local followBtnCorner = Instance.new("UICorner")
followBtnCorner.CornerRadius = UDim.new(0, 6)
followBtnCorner.Parent = followButton

-- Fling Button (new; below Follow)
local flingButton = Instance.new("TextButton")
flingButton.Name = "FlingButton"
flingButton.Size = UDim2.new(0, 280, 0, 30)
flingButton.Position = UDim2.new(0, 20, 0, 300)
flingButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flingButton.TextColor3 = Color3.new(1, 1, 1)
flingButton.Font = Enum.Font.GothamBold
flingButton.TextSize = 18
flingButton.Text = "Fling"
flingButton.Parent = mainFrame

local flingBtnCorner = Instance.new("UICorner")
flingBtnCorner.CornerRadius = UDim.new(0, 6)
flingBtnCorner.Parent = flingButton

-- Auto-Updating Dropdown Functionality
local selectedPlayerName = nil  -- Stores the actual username

local function refreshDropdown()
    for _, child in pairs(dropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    local players = Players:GetPlayers()
    local totalHeight = 0
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            local item = Instance.new("TextButton")
            item.Name = "Item" .. player.DisplayName
            item.Size = UDim2.new(1, 0, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            item.TextColor3 = Color3.new(1, 1, 1)
            item.Font = Enum.Font.Gotham
            item.TextSize = 18
            item.Text = player.DisplayName
            item.Parent = dropdownList

            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 4)
            itemCorner.Parent = item

            item.MouseButton1Click:Connect(function()
                selectedPlayerName = player.Name  -- store actual username  
                dropdownButton.Text = player.DisplayName  
                dropdownList.Visible = false  
            end)
            totalHeight = totalHeight + 34  -- 30 height + 4 padding  
        end
    end
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

refreshDropdown()

dropdownButton.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)

Players.PlayerAdded:Connect(function(player)
    wait(0.1)
    refreshDropdown()
end)

Players.PlayerRemoving:Connect(function(player)
    wait(0.1)
    refreshDropdown()
end)

-- Teleport Functionality
teleportButton.MouseButton1Click:Connect(function()
    if selectedPlayerName then
        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = targetPlayer.Character.HumanoidRootPart
            local localChar = LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                local localHRP = localChar.HumanoidRootPart
                -- Teleport local player 5 studs behind the target using its LookVector (i.e. its back)
                localHRP.CFrame = CFrame.new(targetHRP.Position - targetHRP.CFrame.LookVector * 5)
            end
        end
    else
        warn("No player selected!")
    end
end)

-- Follow Functionality (toggles follow on/off)
local isFollowing = false
local followConnection

followButton.MouseButton1Click:Connect(function()
    if selectedPlayerName then
        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if isFollowing then
                -- Stop following
                if followConnection then
                    followConnection:Disconnect()
                end
                isFollowing = false
                followButton.Text = "Follow"
            else
                local localChar = LocalPlayer.Character
                if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    isFollowing = true
                    followButton.Text = "Stop Follow"
                    followConnection = RunService.Heartbeat:Connect(function()
                        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHRP = targetPlayer.Character.HumanoidRootPart
                            local localHRP = localChar.HumanoidRootPart
                            -- Continuously update local player's position to be 5 studs behind the target's back
                            localHRP.CFrame = CFrame.new(targetHRP.Position - targetHRP.CFrame.LookVector * 5)
                        else
                            if followConnection then
                                followConnection:Disconnect()
                            end
                            isFollowing = false
                            followButton.Text = "Follow"
                        end
                    end)
                else
                    warn("Your character is invalid!")
                end
            end
        else
            warn("Target player not found or invalid!")
        end
    else
        warn("No player selected!")
    end
end)

-- Fling Functionality
-- Notification function for errors
local function Message(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end

local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    
    local TCharacter = TargetPlayer.Character  
    local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")  
    local TRootPart = TCharacter and TCharacter:FindFirstChild("HumanoidRootPart")  
    local THead = TCharacter and TCharacter:FindFirstChild("Head")  
    local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")  
    local Handle = (Accessory and Accessory:FindFirstChild("Handle"))
    
    if Character and Humanoid and RootPart then  
        if RootPart.Velocity.Magnitude < 50 then  
            getgenv().OldPos = RootPart.CFrame  
        end  
        if THumanoid and THumanoid.Sit then  
            return Message("Error Occurred", "Target is sitting", 5)  
        end  
        if THead then  
            workspace.CurrentCamera.CameraSubject = THead  
        elseif Handle then  
            workspace.CurrentCamera.CameraSubject = Handle  
        elseif TRootPart then  
            workspace.CurrentCamera.CameraSubject = THumanoid  
        end  
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then  
            return  
        end  

        local function FPos(BasePart, Pos, Ang)  
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang  
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)  
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)  
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)  
        end  

        local function SFBasePart(BasePart)  
            local TimeToWait = 2  
            local Time = tick()  
            local Angle = 0  

            repeat  
                if RootPart and THumanoid then  
                    if BasePart.Velocity.Magnitude < 50 then  
                        Angle = Angle + 100  
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                    else  
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                    end  
                else  
                    break  
                end  
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or   
                  TargetPlayer.Parent ~= Players or not TargetPlayer.Character or   
                  THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait  
        end  

        workspace.FallenPartsDestroyHeight = math.huge  
          
        local BV = Instance.new("BodyVelocity")  
        BV.Name = "EpixVel"  
        BV.Parent = RootPart  
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)  
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)  
          
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)  
          
        if TRootPart and THead then  
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then  
                SFBasePart(THead)  
            else  
                SFBasePart(TRootPart)  
            end  
        elseif TRootPart and not THead then  
            SFBasePart(TRootPart)  
        elseif not TRootPart and THead then  
            SFBasePart(THead)  
        elseif not TRootPart and not THead and Accessory and Handle then  
            SFBasePart(Handle)  
        else  
            return Message("Error Occurred", "Target is missing necessary parts", 5)  
        end  
          
        BV:Destroy()  
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)  
        workspace.CurrentCamera.CameraSubject = Humanoid  
          
        repeat  
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)  
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))  
            Humanoid:ChangeState("GettingUp")  
            for _, part in ipairs(Character:GetChildren()) do  
                if part:IsA("BasePart") then  
                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()  
                end  
            end  
            task.wait()  
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25  
    else  
        Message("Error Occurred", "Random error", 5)  
    end
end

flingButton.MouseButton1Click:Connect(function()
    if selectedPlayerName then
        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
        if targetPlayer and targetPlayer ~= LocalPlayer then
            -- (Optional whitelist check; change the UserId as needed)
            if targetPlayer.UserId ~= 1414978355 then
                SkidFling(targetPlayer)
            else
                Message("Error Occurred", "This user is whitelisted! (Owner)", 5)
            end
        else
            warn("Target player not found or invalid!")
        end
    else
        warn("No player selected!")
    end
end)

-- Minimize/Maximize Functionality
local function animateGui(targetSize, showControls)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    -- Hide controls immediately before tweening when minimizing
    if not showControls then
        dropdownButton.Visible = false
        teleportButton.Visible = false
        followButton.Visible = false
        flingButton.Visible = false
        dropdownList.Visible = false
        MinimizeButton.Visible = false
        MaximizeButton.Visible = false
    end
    
    local tween = TweenService:Create(mainFrame, tweenInfo, {Size = targetSize})
    tween:Play()
    
    tween.Completed:Connect(function()
        if showControls then
            -- Maximizing: show all controls and the minimize button
            dropdownButton.Visible = true
            teleportButton.Visible = true
            followButton.Visible = true
            flingButton.Visible = true
            MinimizeButton.Visible = true
            MaximizeButton.Visible = false
        else
            -- Minimizing: only show the maximize button after tween completes
            dropdownButton.Visible = false
            teleportButton.Visible = false
            followButton.Visible = false
            flingButton.Visible = false
            dropdownList.Visible = false
            Minimi

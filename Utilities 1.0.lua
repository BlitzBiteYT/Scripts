Remember:-- Loading the Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Creating the Window
local Window = Rayfield:CreateWindow({
   Name = "🛠️ Utilities 🛠️",
   LoadingTitle = "Loading.....",
   LoadingSubtitle = "By JeJe",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Creating the 'Main' Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Creating a section within the 'Main' Tab
local MainSection = MainTab:CreateSection("Main Settings")

-- Creating the 'Hitbox Size' Slider
local HitboxSlider = MainTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {1, 100},  -- Adjust the range as needed
   Increment = 1,
   Suffix = "Units",  -- Customize the suffix as needed
   CurrentValue = 10,  -- Default starting value
   Flag = "HitboxSize",  -- Unique flag for saving configuration
   Callback = function(Value)
      -- Code to adjust hitbox size for all players
      SetHitboxSize(Value)
   end,
})

-- Creating the 'Big Hitbox' Button
local BigHitboxButton = MainTab:CreateButton({
   Name = "Activate Big Hitbox",
   Callback = function()
      -- Activate the big hitbox functionality
      EnableHitboxVisuals(true)
   end
})

-- Creating the 'Speed' Slider
local SpeedSlider = MainTab:CreateSlider({
   Name = "Speed",
   Range = {16, 100},  -- Adjust the range as needed
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,  -- Default starting value
   Flag = "Speed",  -- Unique flag for saving configuration
   Callback = function(Value)
      -- Code to adjust player speed
      SetPlayerSpeed(Value)
   end,
})

-- Creating the 'Jump Power' Slider
local JumpPowerSlider = MainTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},  -- Adjust the range as needed
   Increment = 1,
   Suffix = "Jump Power",
   CurrentValue = 50,  -- Default starting value
   Flag = "JumpPower",  -- Unique flag for saving configuration
   Callback = function(Value)
      -- Code to adjust player jump power
      SetPlayerJumpPower(Value)
   end,
})

-- Creating the 'ESP' Button
local EspButton = MainTab:CreateButton({
   Name = "ESP",
   Callback = function()
      -- Execute the ESP script
      loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
   end
})

-- Creating the 'Infinite Jumps' Button
local InfiniteJumpsButton = MainTab:CreateButton({
   Name = "Infinite Jumps",
   Callback = function()
      -- Execute the Infinite Jumps script
      loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/InfiniteJumps'))()
   end
})

-- Creating the 'Infinite Yield' Button
local InfiniteYieldButton = MainTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
      -- Load and execute the Infinite Yield script
      local success, result = pcall(function()
         loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Infinite%20Yield.txt"))()
      end)
      
      if not success then
         Rayfield:Notify({
            Title = "Error",
            Content = "Failed to load Infinite Yield: " .. result,
            Duration = 5,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Success",
            Content = "Infinite Yield script executed successfully!",
            Duration = 5,
            Image = 4483362458
         })
      end
   end
})

-- Function to set the hitbox size
function SetHitboxSize(size)
   -- Loop through all players and adjust their hitbox size
   for _, player in pairs(game:GetService("Players"):GetPlayers()) do
      local character = player.Character
      if character then
         local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
         if humanoidRootPart then
            local hitbox = humanoidRootPart:FindFirstChild("HitboxVisual")
            if hitbox then
               hitbox.Size = Vector3.new(size, size, size)
            end
         end
      end
   end
end

-- Function to enable or disable hitbox visuals
function EnableHitboxVisuals(enable)
   for _, player in pairs(game:GetService("Players"):GetPlayers()) do
      local character = player.Character
      if character then
         local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
         if humanoidRootPart then
            local hitbox = humanoidRootPart:FindFirstChild("HitboxVisual")
            if not hitbox and enable then
               -- Create and add hitbox visual
               hitbox = Instance.new("Part")
               hitbox.Name = "HitboxVisual"
               hitbox.Size = Vector3.new(10, 10, 10)  -- Default size
               hitbox.Anchored = true
               hitbox.CanCollide = false
               hitbox.BrickColor = BrickColor.new("Bright red")
               hitbox.Transparency = 0.5
               hitbox.Parent = humanoidRootPart
            elseif hitbox and not enable then
               -- Remove hitbox visual
               hitbox:Destroy()
            end
         end
      end
   end
end

-- Function to set player speed
function SetPlayerSpeed(speed)
   for _, player in pairs(game:GetService("Players"):GetPlayers()) do
      local character = player.Character
      if character then
         local humanoid = character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.WalkSpeed = speed
         end
      end
   end
end

-- Function to set player jump power
function SetPlayerJumpPower(jumpPower)
   for _, player in pairs(game:GetService("Players"):GetPlayers()) do
      local character = player.Character
      if character then
         local humanoid = character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.JumpPower = jumpPower
         end
      end
   end
end

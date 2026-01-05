local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "kitty Hub - Cheese Escape",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "kitty Hub",
   LoadingSubtitle = "by iamcheese-man github",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "kitty hub", -- Create a custom folder for your hub/game
      FileName = "music player-kh"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
local servTab = Window:CreateTab("Server", 4483362458) -- Title, Image
local Section = servTab:CreateSection("Section 1")

local getcButton = servTab:CreateButton({
   Name = "Get 1 Cheese",
   Callback = function()
   game:GetService("ReplicatedStorage").AddCheese:FireServer()


   end,
})
local lplrtab = Window:CreateTab("LocalPlayer", 4483362458)
local Section2 = lplrtab:CreateSection("Section2")

local speedSlider = lplrtab:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 1000},
   Increment = 1,
   Suffix = "",
   CurrentValue = 16,
   Flag = "walkspeed", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = Value
   -- The variable (Value) is a number which correlates to the value the slider is currently at
   end,
})

local tpinput = lplrtab:CreateInput({
   Name = "Teleport To",
   CurrentValue = "",
   PlaceholderText = "player to tp to",
   RemoveTextAfterFocusLost = false,
   Flag = "TPInput1",
   Callback = function(Text)
       local targetPlayer = game.Players:FindFirstChild(Text)
       local localPlayer = game.Players.LocalPlayer

       if targetPlayer and targetPlayer.Character and localPlayer.Character then
           local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
           local myHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")

           if targetHRP and myHRP then
               -- Add a small offset above and to the side of the player
               local offset = Vector3.new(2, 5, 0)
               local destination = targetHRP.Position + offset
               localPlayer.Character:MoveTo(destination)
           end
       else
           warn("Invalid player name or missing character parts.")
       end
   end,
})

local dmgdisButton = lplrtab:CreateButton({
   Name = "Disable Damage",
   Callback = function()
   -- The function that takes place when the button is pressed

game:GetService("ReplicatedStorage").Events.DamagePlayer:Destroy()

   end,
})


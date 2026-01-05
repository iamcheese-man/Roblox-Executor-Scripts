-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Sound handling
local function makeSound()
    local old = player.PlayerGui:FindFirstChild("LocalSound")
    if old then old:Destroy() end

    local s = Instance.new("Sound")
    s.Name = "LocalSound"
    s.Parent = player.PlayerGui
    s.Volume = 1
    return s
end

local sound = makeSound()

-- Recommended sounds
local recommendedSounds = {
    "9045743976",
    "1846405622",
    "1837768517",
    "1840684529"
}

-- Window (your template)
local Window = Rayfield:CreateWindow({
   Name = "kitty Hub - Music Player",
   Icon = 0,
   LoadingTitle = "kitty Hub",
   LoadingSubtitle = "Local Music Player",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "kitty hub",
      FileName = "MusicPlayer"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false
})

-- 🎵 Music tab
local musicTab = Window:CreateTab("Music", 4483362458)
local Section = musicTab:CreateSection("Sound Player")

local SoundId = ""

-- Sound ID input
musicTab:CreateInput({
   Name = "Sound ID",
   CurrentValue = "",
   PlaceholderText = "Enter Sound ID",
   RemoveTextAfterFocusLost = false,
   Flag = "SoundID",
   Callback = function(Text)
       SoundId = Text
   end,
})

-- ✅ FIXED Recommended sounds dropdown
musicTab:CreateDropdown({
   Name = "Recommended Sounds",
   Options = recommendedSounds,
   CurrentOption = nil,
   Flag = "Recommended",
   Callback = function(Option)
       if typeof(Option) == "table" then
           SoundId = Option[1]
       else
           SoundId = Option
       end
   end,
})

-- Volume slider
musicTab:CreateSlider({
   Name = "Volume",
   Range = {0, 100},
   Increment = 1,
   Suffix = "%",
   CurrentValue = 100,
   Flag = "Volume",
   Callback = function(Value)
       sound.Volume = math.clamp(Value / 100, 0, 1)
   end,
})

-- Play button
musicTab:CreateButton({
   Name = "▶ Play",
   Callback = function()
       local id = tonumber(SoundId)
       if id then
           sound.SoundId = "rbxassetid://" .. id
           sound:Play()
           Rayfield:Notify({
               Title = "Playing",
               Content = "Sound ID: "..id,
               Duration = 3
           })
       else
           Rayfield:Notify({
               Title = "Error",
               Content = "Invalid Sound ID",
               Duration = 3
           })
       end
   end,
})

-- Stop button
musicTab:CreateButton({
   Name = "⏹ Stop",
   Callback = function()
       if sound.IsPlaying then
           sound:Stop()
       end
   end,
})

-- Respawn fix
player.CharacterAdded:Connect(function()
    task.wait(1)
    sound = makeSound()
end)

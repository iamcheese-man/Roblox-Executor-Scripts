-- Rayfield Launcher for your executor scripts
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeID = game.PlaceId

-- Fetch LauncherConfig.json from this repo
local function fetchConfig()
    local url = "https://raw.githubusercontent.com/iamcheese-man/Roblox-Executor-Scripts/main/LauncherConfig.json"
    local success, res = pcall(function() return game:HttpGet(url) end)
    if success then
        local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
        if ok then
            return data
        else
            warn("Failed to decode LauncherConfig.json")
            return {}
        end
    else
        warn("Failed to fetch LauncherConfig.json")
        return {}
    end
end

local configData = fetchConfig()

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "kitty hub - script launcher",
    LoadingTitle = "kittyhub",
    LoadingSubtitle = "by iamcheese-man",
    Theme = "Default",
    ConfigurationSaving = { Enabled = true, FolderName = "CheeseHub", FileName = "LauncherConfig" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Scripts Tab
local scriptsTab = Window:CreateTab("Scripts", 4483362458)
local scriptsSection = scriptsTab:CreateSection("Available Scripts")

-- Add buttons for each script
for _, scriptData in ipairs(configData) do
    local allowed = false
    if scriptData.place_id == 0 then
        allowed = true -- universal script
    elseif scriptData.place_id == placeID then
        allowed = true
    end

    if allowed then
        -- Create script button
        scriptsTab:CreateButton({
            Name = scriptData.name,
            Callback = function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(scriptData.raw_url))()
                end)
                if success then
                    Rayfield:Notify({
                        Title = "Loaded Script",
                        Content = scriptData.name,
                        Duration = 3
                    })
                else
                    Rayfield:Notify({
                        Title = "Error",
                        Content = tostring(err),
                        Duration = 5
                    })
                end
            end
        })

        -- Description label under the button
        scriptsTab:CreateLabel({
            Name = scriptData.description
        })
    end
end

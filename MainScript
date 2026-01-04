local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Recommended Sound IDs
local recommendedSounds = {
	"9045743976",
	"1846405622",
	"1837768517",
	"1840684529",
}

-- Random string generator
local function randomString(length)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local str = ""
	for i = 1, length do
		str = str .. chars:sub(math.random(1, #chars), math.random(1, #chars))
	end
	return str
end

-- Generate unique GUI name
local function getUniqueGuiName()
	local name
	repeat
		name = randomString(16)
	until not CoreGui:FindFirstChild(name)
	return name
end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = getUniqueGuiName()
gui.ResetOnSpawn = false
gui.Parent = CoreGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Create main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

-- Make GUI draggable with UIDragDetector
local dragDetector = Instance.new("UIDragDetector")
dragDetector.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.1, 0)
corner.Parent = frame

-- Sound ID TextBox
local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(0.9, 0, 0, 30)
idBox.Position = UDim2.new(0.05, 0, 0.05, 0)
idBox.PlaceholderText = "Enter Sound ID"
idBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.ClearTextOnFocus = false
idBox.Text = ""
idBox.Parent = frame

-- Recommended Label
local recLabel = Instance.new("TextLabel")
recLabel.Size = UDim2.new(0.9, 0, 0, 20)
recLabel.Position = UDim2.new(0.05, 0, 0.19, 0)
recLabel.Text = "Recommended Sounds:"
recLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
recLabel.BackgroundTransparency = 1
recLabel.TextScaled = true
recLabel.Font = Enum.Font.SourceSans
recLabel.Parent = frame

-- Recommended Sound Buttons
for i, soundId in ipairs(recommendedSounds) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 25)
	btn.Position = UDim2.new(0.05, 0, 0.19 + (i * 0.08), 0)
	btn.Text = soundId
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSans
	btn.TextScaled = true
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		idBox.Text = soundId
	end)
end

-- Play Button
local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0.4, 0, 0, 30)
playButton.Position = UDim2.new(0.05, 0, 0.85, 0)
playButton.Text = "Play"
playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Parent = frame

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.4, 0, 0, 30)
stopButton.Position = UDim2.new(0.55, 0, 0.85, 0)
stopButton.Text = "Stop"
stopButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Parent = frame

-- Volume TextBox
local volumeBox = Instance.new("TextBox")
volumeBox.Size = UDim2.new(0.9, 0, 0, 30)
volumeBox.Position = UDim2.new(0.05, 0, 0.75, 0)
volumeBox.PlaceholderText = "Enter Volume (0 - 100)"
volumeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
volumeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
volumeBox.ClearTextOnFocus = false
volumeBox.Text = "100"
volumeBox.Parent = frame

-- Volume Label
local volumeLabel = Instance.new("TextLabel")
volumeLabel.Size = UDim2.new(0.9, 0, 0, 20)
volumeLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
volumeLabel.Text = "Volume"
volumeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
volumeLabel.BackgroundTransparency = 1
volumeLabel.TextScaled = true
volumeLabel.Font = Enum.Font.SourceSans
volumeLabel.Parent = frame

-- Function to create or reset sound
local function makeSound()
	local existing = gui:FindFirstChild("LocalSound")
	if existing then
		existing:Destroy()
	end
	local s = Instance.new("Sound")
	s.Name = "LocalSound"
	s.Parent = gui
	return s
end

local sound = makeSound()

-- Update volume
local function updateVolume()
	local volume = tonumber(volumeBox.Text)
	if volume then
		sound.Volume = math.clamp(volume / 100, 0, 1)
	end
end

-- Play Button Logic
playButton.MouseButton1Click:Connect(function()
	local id = tonumber(idBox.Text)
	if id then
		sound.SoundId = "rbxassetid://" .. id
		sound:Play()
		updateVolume()
	end
end)

-- Stop Button Logic
stopButton.MouseButton1Click:Connect(function()
	if sound and sound.IsPlaying then
		sound:Stop()
	end
end)

-- Update volume on TextBox change
volumeBox.FocusLost:Connect(updateVolume)

-- Respawn fix
player.CharacterAdded:Connect(function()
	task.wait(1)
	sound = makeSound()
end)

-- Place this in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function getPositionOfModel(model)
	if model:IsA("Model") then
		if model.PrimaryPart then
			return model.PrimaryPart.Position
		else
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") then
					return part.Position
				end
			end
		end
	end
	return nil
end

local function teleportToWeapons()
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local weaponsFolder = workspace:WaitForChild("Weapons")

	-- Save original position
	local originalCFrame = hrp.CFrame

	-- Collect positions of all valid weapon models
	local weaponPositions = {}
	for _, child in ipairs(weaponsFolder:GetChildren()) do
		local pos = getPositionOfModel(child)
		if pos then
			table.insert(weaponPositions, pos)
		end
	end

	local index = 1
	local heartbeatConn

	heartbeatConn = RunService.Heartbeat:Connect(function()
		if index > #weaponPositions then
			-- Finished teleporting to all weapons, return to original spot
			hrp.CFrame = originalCFrame
			heartbeatConn:Disconnect()
			return
		end

		-- Teleport to current weapon position
		hrp.CFrame = CFrame.new(weaponPositions[index])
		index += 1
	end)
end

teleportToWeapons()

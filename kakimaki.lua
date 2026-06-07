local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Flying = false
local Noclip = false
local Speed = 450
local NameESP = false

local BV
local BG
local FlyConnection

------------------------------------------------
-- 🧊 GUI
------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

------------------------------------------------
-- 🧊 STYLE
------------------------------------------------
local function Glass(frame)
	frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 0.92
	frame.BorderSizePixel = 0

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,10)
	c.Parent = frame

	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(255,255,255)
	s.Transparency = 0.85
	s.Thickness = 1
	s.Parent = frame
end

------------------------------------------------
-- ✈ FLY UI
------------------------------------------------
local FlyFrame = Instance.new("Frame")
FlyFrame.Parent = ScreenGui
FlyFrame.Size = UDim2.new(0,200,0,42)
FlyFrame.Position = UDim2.new(0,20,0,120)
Glass(FlyFrame)

local FlyLabel = Instance.new("TextButton")
FlyLabel.Parent = FlyFrame
FlyLabel.Size = UDim2.new(1,0,1,0)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "FLY: OFF"
FlyLabel.Font = Enum.Font.GothamSemibold
FlyLabel.TextSize = 14
FlyLabel.TextColor3 = Color3.fromRGB(255,255,255)
FlyLabel.AutoButtonColor = false

------------------------------------------------
-- 🧊 NOCLIP UI
------------------------------------------------
local NoclipFrame = Instance.new("Frame")
NoclipFrame.Parent = ScreenGui
NoclipFrame.Size = UDim2.new(0,200,0,42)
NoclipFrame.Position = UDim2.new(0,20,0,165)
Glass(NoclipFrame)

local NoclipLabel = Instance.new("TextLabel")
NoclipLabel.Parent = NoclipFrame
NoclipLabel.Size = UDim2.new(1,0,1,0)
NoclipLabel.BackgroundTransparency = 1
NoclipLabel.Text = "NOCLIP OFF"
NoclipLabel.Font = Enum.Font.GothamSemibold
NoclipLabel.TextSize = 14
NoclipLabel.TextColor3 = Color3.fromRGB(235,235,235)

------------------------------------------------
-- 👁 NAME ESP UI
------------------------------------------------
local NameFrame = Instance.new("Frame")
NameFrame.Parent = ScreenGui
NameFrame.Size = UDim2.new(0,200,0,42)
NameFrame.Position = UDim2.new(0,20,0,210)
Glass(NameFrame)

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = NameFrame
NameLabel.Size = UDim2.new(1,0,1,0)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "NAME ESP OFF"
NameLabel.Font = Enum.Font.GothamSemibold
NameLabel.TextSize = 14
NameLabel.TextColor3 = Color3.fromRGB(235,235,235)

------------------------------------------------
-- UI UPDATE
------------------------------------------------
local function UpdateUI()

	if Flying then
		FlyLabel.Text = "FLY: ON"
		FlyLabel.TextColor3 = Color3.fromRGB(0,255,170)
	else
		FlyLabel.Text = "FLY: OFF"
		FlyLabel.TextColor3 = Color3.fromRGB(255,255,255)
	end

	if Noclip then
		NoclipLabel.Text = "NOCLIP ON"
		NoclipLabel.TextColor3 = Color3.fromRGB(80,160,255)
	else
		NoclipLabel.Text = "NOCLIP OFF"
		NoclipLabel.TextColor3 = Color3.fromRGB(255,80,80)
	end

	if NameESP then
		NameLabel.Text = "NAME ESP ON"
		NameLabel.TextColor3 = Color3.fromRGB(255,255,0)
	else
		NameLabel.Text = "NAME ESP OFF"
		NameLabel.TextColor3 = Color3.fromRGB(255,80,80)
	end
end

------------------------------------------------
-- FLY TOGGLE (FIXED)
------------------------------------------------
local function StartFly()

	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	if BV then BV:Destroy() end
	if BG then BG:Destroy() end

	BV = Instance.new("BodyVelocity")
	BV.MaxForce = Vector3.new(999999,999999,999999)
	BV.Velocity = Vector3.zero
	BV.Parent = HumanoidRootPart

	BG = Instance.new("BodyGyro")
	BG.MaxTorque = Vector3.new(999999,999999,999999)
	BG.P = 1000
	BG.Parent = HumanoidRootPart

	if FlyConnection then
		FlyConnection:Disconnect()
	end

	FlyConnection = RunService.RenderStepped:Connect(function()

		local camera = workspace.CurrentCamera
		local moveDirection = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection += camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection -= camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection -= camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection += camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection += Vector3.new(0,1,0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			moveDirection -= Vector3.new(0,1,0)
		end

		if moveDirection.Magnitude > 0 then
			BV.Velocity = moveDirection.Unit * Speed
		else
			BV.Velocity = Vector3.zero
		end

		BG.CFrame = camera.CFrame
	end)
end

local function StopFly()
	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if BV then BV:Destroy() BV = nil end
	if BG then BG:Destroy() BG = nil end
end

local function ToggleFly()
	Flying = not Flying
	UpdateUI()

	if Flying then
		StartFly()
	else
		StopFly()
	end
end

FlyLabel.MouseButton1Click:Connect(ToggleFly)

------------------------------------------------
-- NAME ESP
------------------------------------------------
local function AddNameESP(player)
	if player == LocalPlayer then return end

	local function Setup(character)
		local head = character:WaitForChild("Head", 5)
		if not head then return end

		if head:FindFirstChild("NameESP") then
			head.NameESP:Destroy()
		end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "NameESP"
		billboard.Size = UDim2.new(0,200,0,50)
		billboard.StudsOffset = Vector3.new(0,2.5,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local label = Instance.new("TextLabel")
		label.Parent = billboard
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.Text = player.Name
		label.TextColor3 = Color3.new(1,1,1)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextScaled = true

		billboard.Enabled = NameESP
	end

	if player.Character then
		Setup(player.Character)
	end

	player.CharacterAdded:Connect(Setup)
end

local function ToggleNameESP(state)
	NameESP = state
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local head = player.Character:FindFirstChild("Head")
			if head then
				local esp = head:FindFirstChild("NameESP")
				if esp then
					esp.Enabled = state
				elseif state then
					AddNameESP(player)
				end
			end
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	AddNameESP(player)
end

Players.PlayerAdded:Connect(AddNameESP)

------------------------------------------------
-- NOCLIP + INPUT
------------------------------------------------
local function SetNoclip(state)
	Noclip = state
	if Character then
		for _, part in ipairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not state
			end
		end
	end
end

RunService.Stepped:Connect(function()
	if Noclip and Character then
		for _, part in ipairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.U then
		SetNoclip(not Noclip)
		UpdateUI()
	end

	if input.KeyCode == Enum.KeyCode.J then
		ToggleNameESP(not NameESP)
		UpdateUI()
	end
end)

UpdateUI()
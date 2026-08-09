-- ========================================================
-- ToxMisc.lua - Aba MISC
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local FlingPage = env.MiscPage or env.FlingPage
local Settings = env.Settings

local CreateToggle = env.CreateToggle
local CreateInputWithButton = env.CreateInputWithButton
local CreateButton = env.CreateButton

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = env.Player

-- FLING LOGIC
local function SkidFling(TargetPlayer)
	if not TargetPlayer or not TargetPlayer.Character then return end

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart or Character:FindFirstChild("HumanoidRootPart")

	local TCharacter = TargetPlayer.Character
	local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")

	if Character and Humanoid and RootPart and TRootPart then
		pcall(function() Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
		local OldPos = RootPart.CFrame

		local BV = Instance.new("BodyVelocity")
		BV.Name = "ToxFlingVel"
		BV.Parent = RootPart
		BV.Velocity = Vector3.new(9e6, 9e6, 9e6)
		BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

		local Time = tick()
		repeat
			if RootPart and TRootPart and Humanoid.Health > 0 then
				RootPart.CFrame = TRootPart.CFrame * CFrame.new(0, 0, 0)
				RootPart.Velocity = Vector3.new(9e6, 9e6 * 5, 9e6)
				RootPart.RotVelocity = Vector3.new(9e7, 9e7, 9e7)
			end
			task.wait()
		until not TRootPart or TRootPart.Velocity.Magnitude > 500 or tick() > Time + 2

		BV:Destroy()
		RootPart.CFrame = OldPos
		RootPart.Velocity = Vector3.zero
		RootPart.RotVelocity = Vector3.zero
	end
end

local function ExecuteFling(TargetInput)
	if not TargetInput or TargetInput == "" then
		if env.Message then env.Message("Fling Error", "Please enter a target name or 'all'", 3) end
		return
	end

	local query = TargetInput:lower()
	if query == "all" or query == "others" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then SkidFling(p) end
		end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				if p.Name:lower():sub(1, #query) == query or p.DisplayName:lower():sub(1, #query) == query then
					SkidFling(p)
					break
				end
			end
		end
	end
end

-- NO FALL DAMAGE
local noFallConn
local function StartNoFall()
	if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
	noFallConn = RunService.PreRender:Connect(function()
		if env.Destroyed or not Settings.NoFallDamage then
			if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
			return
		end
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root and root.AssemblyLinearVelocity.Y < -75 then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -75, root.AssemblyLinearVelocity.Z)
		end
	end)
end

-- ANTI VOID
local antiVoidConn, lastSafeCFrame
local function StartAntiVoid()
	if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
	antiVoidConn = RunService.Heartbeat:Connect(function()
		if env.Destroyed or not Settings.AntiVoid then
			if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
			return
		end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if hum and root then
			if hum.FloorMaterial ~= Enum.Material.Air and root.Velocity.Y > -10 then
				lastSafeCFrame = root.CFrame
			end
			if root.Position.Y <= -250 then
				root.Velocity = Vector3.zero
				root.RotVelocity = Vector3.zero
				if lastSafeCFrame then root.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
				else root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z) end
				if env.CustomNotify then env.CustomNotify("Anti Void Rescued You!", Color3.fromRGB(100, 255, 100)) end
			end
		end
	end)
end

-- ANTI FLING
local antiFlingConn
local function StartAntiFling()
	if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
	antiFlingConn = RunService.Stepped:Connect(function()
		if env.Destroyed or not Settings.AntiFling then
			if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
			return
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				for _, part in ipairs(p.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end
	end)
end

-- CONSTRUÇÃO DOS ELEMENTOS DA ABA MISC (EXATAMENTE COMO NO SEU SCRIPT ANTIGO)
CreateToggle("Ctrl Click TP", FlingPage, Settings.CtrlClickTP, function(v) Settings.CtrlClickTP = v end)

CreateToggle("No Fall Damage", FlingPage, Settings.NoFallDamage, function(v)
    Settings.NoFallDamage = v
    if v then StartNoFall() end
end)

CreateToggle("Anti Void", FlingPage, Settings.AntiVoid, function(v)
    Settings.AntiVoid = v
    if v then StartAntiVoid() end
end)

CreateToggle("Anti Fling", FlingPage, Settings.AntiFling, function(v)
    Settings.AntiFling = v
    if v then StartAntiFling() end
end)

CreateInputWithButton("Target Fling", FlingPage, "", "Fling", function(text)
    ExecuteFling(text)
end)

CreateButton("Music Player", FlingPage, function()
    if env.MusicGui then env.MusicGui.Visible = not env.MusicGui.Visible end
end)

if Settings.AntiFling then StartAntiFling() end
if Settings.AntiVoid then StartAntiVoid() end
if Settings.NoFallDamage then StartNoFall() end

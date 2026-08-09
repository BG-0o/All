-- ========================================================
-- ToxMisc.lua - Módulo com todas as opções de MISC
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local MiscPage = env.MiscPage or env.FlingPage
local Settings = env.Settings

local CreateToggle = env.CreateToggle
local CreateInputWithButton = env.CreateInputWithButton
local CreateButton = env.CreateButton
local CustomNotify = env.CustomNotify

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = env.Player

-- LÓGICA DO FLING
local function SkidFling(TargetPlayer)
	if not TargetPlayer or not TargetPlayer.Character then return end

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart or Character:FindFirstChild("HumanoidRootPart")

	local TCharacter = TargetPlayer.Character
	local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
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
		CustomNotify("Enter target name!", Color3.fromRGB(255, 100, 100))
		return
	end

	local query = TargetInput:lower()
	if query == "all" then
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

-- WALK FLING
local WalkFlingConn
local function SetWalkFling(enabled)
	Settings.WalkFling = enabled
	if WalkFlingConn then WalkFlingConn:Disconnect() WalkFlingConn = nil end
	if enabled then
		WalkFlingConn = RunService.PostSimulation:Connect(function()
			if env.Destroyed or not Settings.WalkFling then SetWalkFling(false) return end
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local vel = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
				root.AssemblyAngularVelocity = Vector3.new(0, 10000, 0)
			end
		end)
	end
end

-- ANTI FLING
local AntiFlingConn
local function SetAntiFling(enabled)
	Settings.AntiFling = enabled
	if AntiFlingConn then AntiFlingConn:Disconnect() AntiFlingConn = nil end
	if enabled then
		AntiFlingConn = RunService.Stepped:Connect(function()
			if env.Destroyed or not Settings.AntiFling then SetAntiFling(false) return end
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
end

-- ANTI AFK
local AntiAFKConn
local function SetAntiAFK(enabled)
	Settings.AntiAFK = enabled
	if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
	if enabled then
		AntiAFKConn = LocalPlayer.Idled:Connect(function()
			if Settings.AntiAFK and not env.Destroyed then
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0, 0))
			end
		end)
	end
end

-- NO FALL DAMAGE
local NoFallConn
local function SetNoFall(enabled)
	Settings.NoFallDamage = enabled
	if NoFallConn then NoFallConn:Disconnect() NoFallConn = nil end
	if enabled then
		NoFallConn = RunService.PreRender:Connect(function()
			if env.Destroyed or not Settings.NoFallDamage then SetNoFall(false) return end
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and root.AssemblyLinearVelocity.Y < -75 then
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -75, root.AssemblyLinearVelocity.Z)
			end
		end)
	end
end

-- ========================================================
-- DESENHANDO OS BOTÕES DA ABA MISC
-- ========================================================

CreateInputWithButton("Target Fling", MiscPage, "", "Fling", function(txt)
	ExecuteFling(txt)
end)

CreateToggle("Walk Fling", MiscPage, Settings.WalkFling, function(v)
	SetWalkFling(v)
end)

CreateToggle("Anti Fling", MiscPage, Settings.AntiFling, function(v)
	SetAntiFling(v)
end)

CreateToggle("Anti AFK", MiscPage, Settings.AntiAFK, function(v)
	SetAntiAFK(v)
end)

CreateToggle("No Fall Damage", MiscPage, Settings.NoFallDamage, function(v)
	SetNoFall(v)
end)

-- Ativar padrões
if Settings.AntiFling then SetAntiFling(true) end
if Settings.AntiAFK then SetAntiAFK(true) end

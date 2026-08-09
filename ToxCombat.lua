-- ToxCombat.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxCombat = {}

-- FIX: Busca de Alvos e Fling para "ALL", "random", "others", usernames e display names
function ToxCombat:GetPlayer(Name)
	if not Name or Name == "" then return nil end
	Name = string.lower(Name)

	if Name == "all" or Name == "others" then
		return "all"
	elseif Name == "random" then
		local GetPlayers = Players:GetPlayers()
		if table.find(GetPlayers, LocalPlayer) then 
			table.remove(GetPlayers, table.find(GetPlayers, LocalPlayer)) 
		end
		if #GetPlayers > 0 then
			return GetPlayers[math.random(#GetPlayers)]
		end
		return nil
	else
		for _, x in ipairs(Players:GetPlayers()) do
			if x ~= LocalPlayer then
				if string.find(string.lower(x.Name), Name) or string.find(string.lower(x.DisplayName), Name) then
					return x
				end
			end
		end
	end
	return nil
end

function ToxCombat:SkidFling(TargetPlayer, hub)
	if not TargetPlayer or not TargetPlayer.Character then return end

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart or Character:FindFirstChild("HumanoidRootPart")

	local TCharacter = TargetPlayer.Character
	local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")

	if Character and Humanoid and RootPart and TRootPart then
		local oldPos = RootPart.CFrame
        local bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(0, 999999, 0)
        bav.Parent = RootPart

        local startTime = tick()
        while tick() - startTime < 1.5 do
            if not TRootPart or not RootPart then break end
            RootPart.CFrame = TRootPart.CFrame * CFrame.Angles(math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), 0)
            RootPart.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
            RunService.Heartbeat:Wait()
        end

        bav:Destroy()
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
        RootPart.CFrame = oldPos
	end
end

function ToxCombat:ExecuteFling(TargetInput, hub)
	if not TargetInput or TargetInput == "" then
		if hub then hub:CustomNotify("Please enter a target name or 'all'", Color3.fromRGB(255, 100, 100)) end
		return
	end

	local LowerInput = string.lower(TargetInput)

	if LowerInput == "all" or LowerInput == "others" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then self:SkidFling(p, hub) end
		end
	else
		local TargetObj = self:GetPlayer(TargetInput)
		if TargetObj == "all" then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then self:SkidFling(p, hub) end
			end
		elseif typeof(TargetObj) == "Instance" and TargetObj:IsA("Player") then
			self:SkidFling(TargetObj, hub)
		else
			if hub then hub:CustomNotify("Username/Target Invalid", Color3.fromRGB(255, 100, 100)) end
		end
	end
end

function ToxCombat:Init(parentPage, hub)
    local Box = Instance.new("Frame")
	Box.Size = UDim2.new(1, -5, 0, 48)
	Box.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Box.BorderSizePixel = 0
	Box.Parent = parentPage

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -170, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = "Target Fling"
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Box

	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(0, 85, 0, 27)
	Input.Position = UDim2.new(1, -155, 0.5, -13)
	Input.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
	Input.BorderSizePixel = 0
	Input.Text = ""
	Input.PlaceholderText = "Nick/ALL/Random"
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	Input.TextSize = 11
	Input.Font = Enum.Font.Gotham
	Input.ClearTextOnFocus = false
	Input.Parent = Box

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 4)
	InputCorner.Parent = Input

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 60, 0, 27)
	Button.Position = UDim2.new(1, -65, 0.5, -13)
	Button.BackgroundColor3 = Color3.fromRGB(9, 0, 136)
	Button.BorderSizePixel = 0
	Button.Text = "Fling"
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamBold
	Button.Parent = Box

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 4)
	ButtonCorner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		self:ExecuteFling(Input.Text, hub)
	end)
end

return ToxCombat

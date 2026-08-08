local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BundleAnimationsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleAnimBtn"
toggleBtn.Size = UDim2.new(0, 130, 0, 36)
toggleBtn.Position = UDim2.new(0, 15, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleBtn.Text = "▶ Animations"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 440, 0, 320)
mainFrame.Position = UDim2.new(0.5, -220, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Header Container
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 45)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

-- Play Icon
local iconLabel = Instance.new("TextLabel")
iconLabel.Size = UDim2.new(0, 28, 0, 28)
iconLabel.Position = UDim2.new(0, 12, 0, 8)
iconLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
iconLabel.Text = "▶"
iconLabel.TextColor3 = Color3.fromRGB(20, 20, 23)
iconLabel.Font = Enum.Font.SourceSansBold
iconLabel.TextSize = 12
iconLabel.Parent = headerFrame

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 6)
iconCorner.Parent = iconLabel

-- Title Text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 48, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BUNDLE ANIMATIONS"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

-- Close Button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.Parent = headerFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -55)
scrollFrame.Position = UDim2.new(0, 10, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

local animList = {"Idle", "Walk", "Run", "Jump", "Fall"}
local savedCustomIds = {}
local defaultAnimIds = {}
local toggleStates = {} -- Menyimpan status ON/OFF tiap baris

local function captureDefaults(animateScript)
	if not animateScript then return end
	if not defaultAnimIds["Idle"] and animateScript:FindFirstChild("idle") then
		local a1 = animateScript.idle:FindFirstChild("Animation1")
		if a1 then defaultAnimIds["Idle"] = a1.AnimationId end
	end
	if not defaultAnimIds["Walk"] and animateScript:FindFirstChild("walk") then
		local w = animateScript.walk:FindFirstChild("WalkAnim")
		if w then defaultAnimIds["Walk"] = w.AnimationId end
	end
	if not defaultAnimIds["Run"] and animateScript:FindFirstChild("run") then
		local r = animateScript.run:FindFirstChild("RunAnim")
		if r then defaultAnimIds["Run"] = r.AnimationId end
	end
	if not defaultAnimIds["Jump"] and animateScript:FindFirstChild("jump") then
		local j = animateScript.jump:FindFirstChild("JumpAnim")
		if j then defaultAnimIds["Jump"] = j.AnimationId end
	end
	if not defaultAnimIds["Fall"] and animateScript:FindFirstChild("fall") then
		local f = animateScript.fall:FindFirstChild("FallAnim")
		if f then defaultAnimIds["Fall"] = f.AnimationId end
	end
end

local function applyAnimToCharacter(animType, id, enableCustom)
	local char = player.Character
	if not char then return end
	local animateScript = char:FindFirstChild("Animate")
	if not animateScript then return end

	captureDefaults(animateScript)

	local cleanId = id and tostring(id):gsub("%D", "") or ""
	local formattedId = nil

	if enableCustom and cleanId ~= "" and #cleanId >= 5 then
		formattedId = "rbxassetid://" .. cleanId
	else
		-- Gunakan ID default jika OFF / ID invalid / kosong
		if animType == "Idle" then formattedId = defaultAnimIds["Idle"]
		elseif animType == "Walk" then formattedId = defaultAnimIds["Walk"]
		elseif animType == "Run" then formattedId = defaultAnimIds["Run"]
		elseif animType == "Jump" then formattedId = defaultAnimIds["Jump"]
		elseif animType == "Fall" then formattedId = defaultAnimIds["Fall"]
		end
	end

	if animType == "Idle" and animateScript:FindFirstChild("idle") then
		if animateScript.idle:FindFirstChild("Animation1") and formattedId then
			animateScript.idle.Animation1.AnimationId = formattedId
		end
		if animateScript.idle:FindFirstChild("Animation2") and formattedId then
			animateScript.idle.Animation2.AnimationId = formattedId
		end
	elseif animType == "Walk" and animateScript:FindFirstChild("walk") and animateScript.walk:FindFirstChild("WalkAnim") then
		if formattedId then animateScript.walk.WalkAnim.AnimationId = formattedId end
	elseif animType == "Run" and animateScript:FindFirstChild("run") and animateScript.run:FindFirstChild("RunAnim") then
		if formattedId then animateScript.run.RunAnim.AnimationId = formattedId end
	elseif animType == "Jump" and animateScript:FindFirstChild("jump") and animateScript.jump:FindFirstChild("JumpAnim") then
		if formattedId then animateScript.jump.JumpAnim.AnimationId = formattedId end
	elseif animType == "Fall" and animateScript:FindFirstChild("fall") and animateScript.fall:FindFirstChild("FallAnim") then
		if formattedId then animateScript.fall.FallAnim.AnimationId = formattedId end
	end

	-- Reload animasi berjalan
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
		end
	end
end

-- Helper Baris UI
local function createAnimRow(name, order)
	toggleStates[name] = false -- Status awal: OFF

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, -6, 0, 42)
	rowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	rowFrame.BorderSizePixel = 0
	rowFrame.LayoutOrder = order
	rowFrame.Parent = scrollFrame

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = rowFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 60, 1, 0)
	nameLabel.Position = UDim2.new(0, 15, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = rowFrame

	local idBox = Instance.new("TextBox")
	idBox.Size = UDim2.new(1, -190, 0, 26)
	idBox.Position = UDim2.new(0, 80, 0.5, -13)
	idBox.BackgroundTransparency = 1
	idBox.Text = "— default —"
	idBox.TextColor3 = Color3.fromRGB(150, 150, 160)
	idBox.Font = Enum.Font.SourceSans
	idBox.TextSize = 13
	idBox.ClearTextOnFocus = true
	idBox.Parent = rowFrame

	-- 🔄 TOMBOL ON / OFF
	local toggleOnOffBtn = Instance.new("TextButton")
	toggleOnOffBtn.Size = UDim2.new(0, 48, 0, 26)
	toggleOnOffBtn.Position = UDim2.new(1, -95, 0.5, -13)
	toggleOnOffBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	toggleOnOffBtn.Text = "OFF"
	toggleOnOffBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
	toggleOnOffBtn.Font = Enum.Font.SourceSansBold
	toggleOnOffBtn.TextSize = 12
	toggleOnOffBtn.Parent = rowFrame

	local toggleOnOffCorner = Instance.new("UICorner")
	toggleOnOffCorner.CornerRadius = UDim.new(0, 6)
	toggleOnOffCorner.Parent = toggleOnOffBtn

	-- Tombol Reset (X)
	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(0, 30, 0, 26)
	resetBtn.Position = UDim2.new(1, -40, 0.5, -13)
	resetBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	resetBtn.Text = "X"
	resetBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
	resetBtn.Font = Enum.Font.SourceSansBold
	resetBtn.TextSize = 12
	resetBtn.Parent = rowFrame

	local resetCorner = Instance.new("UICorner")
	resetCorner.CornerRadius = UDim.new(0, 6)
	resetCorner.Parent = resetBtn

	-- Logika Perubahan Tombol ON/OFF
	local function updateToggleUI()
		local isON = toggleStates[name]
		local textId = idBox.Text
		local clean = textId:gsub("%D", "")

		if isON then
			if textId ~= "" and textId ~= "— default —" and #clean >= 5 then
				-- Tampilan Saat ON & Valid
				toggleOnOffBtn.Text = "ON"
				toggleOnOffBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87) -- Hijau
				toggleOnOffBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				idBox.TextColor3 = Color3.fromRGB(100, 255, 150)
				savedCustomIds[name] = textId
				applyAnimToCharacter(name, textId, true)
			else
				-- Jika diketik kosong/invalid tapi ditekan ON, otomatis kembali OFF
				toggleStates[name] = false
				toggleOnOffBtn.Text = "OFF"
				toggleOnOffBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
				toggleOnOffBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
				idBox.TextColor3 = Color3.fromRGB(255, 100, 100) -- Merah penanda invalid
				applyAnimToCharacter(name, "", false)
			end
		else
			-- Tampilan Saat OFF
			toggleOnOffBtn.Text = "OFF"
			toggleOnOffBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
			toggleOnOffBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
			if textId == "" or textId == "— default —" then
				idBox.TextColor3 = Color3.fromRGB(150, 150, 160)
			end
			applyAnimToCharacter(name, "", false)
		end
	end

	-- Click Event ON / OFF
	toggleOnOffBtn.MouseButton1Click:Connect(function()
		toggleStates[name] = not toggleStates[name]
		updateToggleUI()
	end)

	-- Reset Button Event
	resetBtn.MouseButton1Click:Connect(function()
		toggleStates[name] = false
		savedCustomIds[name] = nil
		idBox.Text = "— default —"
		updateToggleUI()
	end)
end

for index, name in ipairs(animList) do
	createAnimRow(name, index)
end

local dragging, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local function setGuiState(visible)
	mainFrame.Visible = visible
	toggleBtn.Text = visible and "▶ Animations" or "▶ Open Anim"
end

toggleBtn.MouseButton1Click:Connect(function() setGuiState(not mainFrame.Visible) end)
closeBtn.MouseButton1Click:Connect(function() setGuiState(false) end)

-- Re-apply saat respawn
player.CharacterAdded:Connect(function(newChar)
	local animScript = newChar:WaitForChild("Animate", 3)
	if animScript then
		task.wait(0.5)
		captureDefaults(animScript)
	end
	task.wait(1)
	for animName, isON in pairs(toggleStates) do
		if isON and savedCustomIds[animName] then
			applyAnimToCharacter(animName, savedCustomIds[animName], true)
		end
	end
end)

if player.Character then
	task.spawn(function()
		local animScript = player.Character:WaitForChild("Animate", 3)
		if animScript then captureDefaults(animScript) end
	end)
end

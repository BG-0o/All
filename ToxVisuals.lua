-- ========================================================
-- ToxVisuals.lua - Aba VISUALS
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local VisualsPage = env.VisualsPage
local Settings = env.Settings
local ColorMap = env.ColorMap

local CreateToggle = env.CreateToggle
local CreateToggleWithValue = env.CreateToggleWithValue
local CreateDropdown = env.CreateDropdown
local CreateInputWithToggle = env.CreateInputWithToggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = env.Player

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "V4_ESP_Folder"
pcall(function() ESPFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)

local ESPStorage = {}

local function RemoveESP(p)
    if ESPStorage[p] then
        for _, v in pairs(ESPStorage[p]) do pcall(function() v:Destroy() end) end
        ESPStorage[p] = nil
    end
end

local function ClearAllESP()
    for p in pairs(ESPStorage) do RemoveESP(p) end
    ESPFolder:ClearAllChildren()
end

local function UpdatePlayerESP(targetPlayer)
	if targetPlayer == LocalPlayer then return end
	local char = targetPlayer.Character
	if not char then RemoveESP(targetPlayer) return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then RemoveESP(targetPlayer) return end
	if Settings.DisableTeam and targetPlayer.Team == LocalPlayer.Team then RemoveESP(targetPlayer) return end

	local color = (Settings.ShowTeamColor and targetPlayer.TeamColor) and targetPlayer.TeamColor.Color or Settings.EspColor
	local displayName = (Settings.NameType == "Display") and targetPlayer.DisplayName or targetPlayer.Name
	local cache = ESPStorage[targetPlayer] or {}

	-- BILLBOARD
	if Settings.ESP then
		if not cache.Billboard or not cache.Billboard.Parent then
			local BB = Instance.new("BillboardGui")
			BB.Name = targetPlayer.Name .. "_ESP"
			BB.Adornee = root
			BB.Size = UDim2.new(0, 200, 0, 50)
			BB.StudsOffset = Vector3.new(0, 3, 0)
			BB.AlwaysOnTop = true
			BB.Parent = ESPFolder

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = color
			Label.TextSize = Settings.EspSize
			Label.Font = Enum.Font.GothamBold
			Label.Parent = BB

			cache.Billboard = BB; cache.Label = Label
		end
		cache.Label.TextColor3 = color
		cache.Label.TextSize = Settings.EspSize
		cache.Label.Text = Settings.ShowHealth and string.format("%s [%d HP]", displayName, math.floor(hum.Health)) or displayName
	else
		if cache.Billboard then cache.Billboard:Destroy(); cache.Billboard = nil; cache.Label = nil end
	end

	-- HIGHLIGHT (CHAMS)
	if Settings.Chams then
		if not cache.Highlight or not cache.Highlight.Parent then
			local Highlight = Instance.new("Highlight")
			Highlight.Adornee = char
			Highlight.FillColor = color
			Highlight.FillTransparency = Settings.ChamOpacity
			Highlight.OutlineColor = Settings.OutlineColor
			Highlight.OutlineTransparency = Settings.OutlineOpacity
			Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			Highlight.Parent = ESPFolder
			cache.Highlight = Highlight
		else
			cache.Highlight.FillColor = color
			cache.Highlight.Adornee = char
		end
	else
		if cache.Highlight then cache.Highlight:Destroy(); cache.Highlight = nil end
	end

	if not cache.Billboard and not cache.Highlight then RemoveESP(targetPlayer)
	else ESPStorage[targetPlayer] = cache end
end

local function UpdateESP()
	if env.Destroyed or (not Settings.ESP and not Settings.Chams) then ClearAllESP() return end
	for _, targetPlayer in ipairs(Players:GetPlayers()) do UpdatePlayerESP(targetPlayer) end
end

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- SPECTATE LOGIC
local spectateConn, spectateTarget
local function StopSpectate()
	if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
	spectateTarget = nil
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function StartSpectate(targetName)
	StopSpectate()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and (p.Name:lower():sub(1, #targetName) == targetName:lower() or p.DisplayName:lower():sub(1, #targetName) == targetName:lower()) then
			spectateTarget = p
			break
		end
	end

	if spectateTarget and spectateTarget.Character then
		spectateConn = RunService.RenderStepped:Connect(function()
			if env.Destroyed or not Settings.Spectating then StopSpectate(); return end
			if spectateTarget and spectateTarget.Character and spectateTarget.Character:FindFirstChildOfClass("Humanoid") then
				workspace.CurrentCamera.CameraSubject = spectateTarget.Character:FindFirstChildOfClass("Humanoid")
			else
				StopSpectate()
			end
		end)
	else
		if env.Message then env.Message("Spectate", "Player not found", 3) end
		Settings.Spectating = false
	end
end

-- FREECAM
local freecamPart
local function ToggleFreecam(v)
    Settings.Freecam = v
    if v then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = true end
        freecamPart = Instance.new("Part")
        freecamPart.Name = "FreecamPart"
        freecamPart.Transparency = 1
        freecamPart.CanCollide = false
        freecamPart.Anchored = true
        freecamPart.CFrame = workspace.CurrentCamera.CFrame
        freecamPart.Parent = workspace
        workspace.CurrentCamera.CameraSubject = freecamPart
    else
        if freecamPart then freecamPart:Destroy(); freecamPart = nil end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end
end

RunService.RenderStepped:Connect(function()
    if not env.Destroyed and Settings.Freecam and freecamPart then
        local CamCF = workspace.CurrentCamera.CFrame
        local Speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 3 or 1
        local Dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + CamCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - CamCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - CamCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + CamCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then Dir = Dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then Dir = Dir - Vector3.new(0, 1, 0) end
        freecamPart.CFrame = freecamPart.CFrame + (Dir * Speed)
    end
end)

-- FULLBRIGHT (RESTAURA ILUMINAÇÃO SEM BUGS)
local origAmbient = Lighting.Ambient
local fullbrightConn
local function ToggleFullbright(v)
    Settings.Fullbright = v
    if fullbrightConn then fullbrightConn:Disconnect(); fullbrightConn = nil end
    if v then
        fullbrightConn = RunService.RenderStepped:Connect(function()
            if not Settings.Fullbright or env.Destroyed then
                if fullbrightConn then fullbrightConn:Disconnect(); fullbrightConn = nil end
                Lighting.Ambient = origAmbient
                return
            end
            Lighting.Ambient = Color3.fromRGB(160, 160, 160)
            Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
            Lighting.Brightness = 1.2
            Lighting.FogEnd = 9e9
            Lighting.GlobalShadows = false
        end)
    else
        Lighting.Ambient = origAmbient
    end
end

-- FOV CHANGER (LÓGICA DINÂMICA SEM PERDER O CONTROLE)
RunService.RenderStepped:Connect(function()
    if not env.Destroyed and Settings.FOVEnabled then
        workspace.CurrentCamera.FieldOfView = Settings.FOVValue
    end
end)

-- BOTÕES DA ABA VISUALS
CreateToggleWithValue("Enable ESP", VisualsPage, Settings.ESP, Settings.EspSize, function(v)
    Settings.ESP = v
    if not v then ClearAllESP() end
end, function(val) Settings.EspSize = val end)

CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Purple"}, VisualsPage, Settings.EspColorName, function(v)
    Settings.EspColorName = v
    Settings.EspColor = ColorMap[v] or Color3.fromRGB(255, 255, 255)
    ClearAllESP()
end)

CreateDropdown("Name Display", {"Display", "Username"}, VisualsPage, Settings.NameType, function(v) Settings.NameType = v end)
CreateToggle("Show Health", VisualsPage, Settings.ShowHealth, function(v) Settings.ShowHealth = v end)
CreateToggle("Chams / Highlight", VisualsPage, Settings.Chams, function(v) Settings.Chams = v if not v then ClearAllESP() end end)
CreateToggle("Use Team Color", VisualsPage, Settings.ShowTeamColor, function(v) Settings.ShowTeamColor = v end)
CreateToggle("Ignore Team", VisualsPage, Settings.DisableTeam, function(v) Settings.DisableTeam = v ClearAllESP() end)

CreateInputWithToggle("Spectate Player", VisualsPage, "", function(enabled, nick)
    Settings.Spectating = enabled
    if enabled then StartSpectate(nick) else StopSpectate() end
end)

CreateToggle("Freecam", VisualsPage, false, function(v) ToggleFreecam(v) end)

CreateToggleWithValue("FOV Editor", VisualsPage, false, 70, function(v)
    Settings.FOVEnabled = v
    if not v then workspace.CurrentCamera.FieldOfView = 70 end
end, function(val)
    Settings.FOVValue = val
    if Settings.FOVEnabled then workspace.CurrentCamera.FieldOfView = val end
end)

CreateToggle("Fullbright", VisualsPage, false, function(v) ToggleFullbright(v) end)

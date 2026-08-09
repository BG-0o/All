-- ========================================================
-- ToxHub.lua - Base Framework & Core Loader
-- ========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().FPDH = workspace.FallenPartsDestroyHeight or -500

local LOGO_ID = "rbxassetid://120675082996894"
local MAIN_COLOR = Color3.fromRGB(9, 0, 136) 

local ColorMap = {
	["White"] = Color3.fromRGB(255, 255, 255),
	["Red"] = Color3.fromRGB(255, 50, 50),
	["Green"] = Color3.fromRGB(50, 255, 50),
	["Blue"] = Color3.fromRGB(50, 150, 255),
	["Yellow"] = Color3.fromRGB(255, 255, 50),
	["Cyan"] = Color3.fromRGB(50, 255, 255),
	["Magenta"] = Color3.fromRGB(255, 50, 255),
	["Orange"] = Color3.fromRGB(255, 150, 50),
	["Purple"] = Color3.fromRGB(150, 50, 255)
}

local Settings = {
	Noclip = false,
	InfiniteJump = false,
	Speed = false,
	Jump = false,
	Fly = false,
	FlyCar = false,
	NoFallDamage = false,
	AntiVoid = false,
	AntiFling = true,
	CtrlClickTP = false,
	Float = false,
	NormalizeAnims = false,
	Emulation = false,
	AntiAFK = true,
	ChatLogs = false,
	Render3D = true,
    Freecam = false,
    Fullbright = false,
    FOVEnabled = false,
    FOVValue = 70,
    Spectating = false,
    LoopTP = false,
	SpeedValue = 16,
	JumpValue = 50,
	FlySpeed = 5,
	FlyCarSpeed = 5,
	FloatStrength = 7,
	UpBind = Enum.KeyCode.E,
	DownBind = Enum.KeyCode.Q,
	ESP = false,
	EspColorName = "White",
	EspColor = Color3.fromRGB(255, 255, 255),
	EspSize = 13,
	UseLegacy = false,
	ShowHealth = false,
	NameType = "Display",
	Chams = false,
	UseHighlights = false,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	OutlineOpacity = 0.5,
	ChamOpacity = 0.75,
	Tracers = false,
	DisableTeam = false,
	ShowTeamColor = false,
	GUIKeybind = Enum.KeyCode.LeftAlt,
    MusicAutoPlay = false,
    MusicLoop = false
}

local SavedIDs = {} 
local CurrentTrackIndex = 1

local Character, Humanoid, RootPart
local Destroyed = false
local IsLoaded = false

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows
}

local FolderName = "ToxV1_Data"
local ConfigFilePath = FolderName .. "/config.json"

local function EnsureFolder()
    if makefolder and isfolder then
        pcall(function()
            if not isfolder(FolderName) then makefolder(FolderName) end
        end)
    end
end

local function AutoSaveConfiguration()
    if Destroyed then return end
    EnsureFolder()
    if not writefile then return end

    local data = {
        Settings = {
            Speed = Settings.Speed,
            SpeedValue = Settings.SpeedValue,
            Jump = Settings.Jump,
            JumpValue = Settings.JumpValue,
            Fly = Settings.Fly,
            FlySpeed = Settings.FlySpeed,
            FlyCar = Settings.FlyCar,
            FlyCarSpeed = Settings.FlyCarSpeed,
            Float = Settings.Float,
            FloatStrength = Settings.FloatStrength,
            Noclip = Settings.Noclip,
            InfiniteJump = Settings.InfiniteJump,
            CtrlClickTP = Settings.CtrlClickTP,
            NoFallDamage = Settings.NoFallDamage,
            AntiVoid = Settings.AntiVoid,
            AntiFling = Settings.AntiFling,
            AntiAFK = Settings.AntiAFK,
            ChatLogs = Settings.ChatLogs,
            Render3D = Settings.Render3D,
            ESP = Settings.ESP,
            EspSize = Settings.EspSize,
            EspColorName = Settings.EspColorName,
            ShowHealth = Settings.ShowHealth,
            NameType = Settings.NameType,
            Chams = Settings.Chams,
            ShowTeamColor = Settings.ShowTeamColor,
            DisableTeam = Settings.DisableTeam,
            Freecam = Settings.Freecam,
            Fullbright = Settings.Fullbright,
            FOVEnabled = Settings.FOVEnabled,
            FOVValue = Settings.FOVValue,
            GUIKeybind = Settings.GUIKeybind and Settings.GUIKeybind.Name or "LeftAlt",
            MusicAutoPlay = Settings.MusicAutoPlay,
            MusicLoop = Settings.MusicLoop
        },
        SavedIDs = SavedIDs
    }

    pcall(function()
        local json = HttpService:JSONEncode(data)
        writefile(ConfigFilePath, json)
    end)
end

local RenderSavedIDs 

local function LoadConfiguration()
    if not isfile or not readfile or not isfile(ConfigFilePath) then return end

    pcall(function()
        local content = readfile(ConfigFilePath)
        local data = HttpService:JSONDecode(content)

        if data then
            if data.Settings then
                for k, v in pairs(data.Settings) do
                    if k == "GUIKeybind" then
                        pcall(function() Settings.GUIKeybind = Enum.KeyCode[v] end)
                    else
                        Settings[k] = v
                    end
                end
            end
            if data.SavedIDs then
                SavedIDs = data.SavedIDs
                if RenderSavedIDs then RenderSavedIDs() end
            end
        end
    end)
end

LoadConfiguration()

-- SISTEMA DE NOTIFICAÇÕES
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "ToxNotifs"
NotifGui.DisplayOrder = 999
NotifGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 240, 1, -40)
NotifContainer.Position = UDim2.new(1, -250, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 6)
NotifLayout.Parent = NotifContainer

local function CustomNotify(text, color)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = NotifContainer
    
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Frame
    local Stroke = Instance.new("UIStroke") Stroke.Color = MAIN_COLOR Stroke.Thickness = 1.5 Stroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = color or Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.Parent = Frame
    
    Frame.BackgroundTransparency = 1
    Label.TextTransparency = 1
    Stroke.Transparency = 1

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(Frame, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(Label, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(Stroke, tweenInfo, {Transparency = 0}):Play()

    task.delay(3.5, function()
        local tweenOut = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        local t1 = TweenService:Create(Frame, tweenOut, {BackgroundTransparency = 1})
        local t2 = TweenService:Create(Label, tweenOut, {TextTransparency = 1})
        local t3 = TweenService:Create(Stroke, tweenOut, {Transparency = 1})
        t1:Play() t2:Play() t3:Play()
        t1.Completed:Connect(function() Frame:Destroy() end)
    end)
end

local function Message(_Title, _Text, Time)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
	end)
end

Players.PlayerAdded:Connect(function(p) CustomNotify(p.DisplayName .. " joined", Color3.fromRGB(100, 255, 100)) end)
Players.PlayerRemoving:Connect(function(p) CustomNotify(p.DisplayName .. " left", Color3.fromRGB(255, 100, 100)) end)

local function UpdateCharacter()
	if Destroyed then return end
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
end
UpdateCharacter()

local ParentContainer = (gethui and gethui()) or game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")

local Gui = Instance.new("ScreenGui")
Gui.Name = "ToxV1Gui"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999999999
Gui.Parent = ParentContainer

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 8) MainCorner.Parent = Main
local MainStroke = Instance.new("UIStroke") MainStroke.Color = MAIN_COLOR MainStroke.Thickness = 2 MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = MAIN_COLOR
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Dragging, DragInput, DragStart, StartPos
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true; DragStart = input.Position; StartPos = Main.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
	end
end)
TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		local Delta = input.Position - DragStart
		Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
	end
end)

local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(0, 18, 0, 18)
LogoImage.Position = UDim2.new(0, 10, 0.5, -9)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = LOGO_ID
LogoImage.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 34, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Tox v1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 34, 0, 26)
Minimize.Position = UDim2.new(1, -40, 0, 6)
Minimize.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
Minimize.BorderSizePixel = 0
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = TopBar
local MinimizeCorner = Instance.new("UICorner") MinimizeCorner.CornerRadius = UDim.new(0, 4) MinimizeCorner.Parent = Minimize

local Tabs = Instance.new("ScrollingFrame")
Tabs.Size = UDim2.new(1, -10, 0, 34)
Tabs.Position = UDim2.new(0, 5, 0, 44)
Tabs.BackgroundTransparency = 1
Tabs.BorderSizePixel = 0
Tabs.ScrollBarThickness = 2
Tabs.ScrollBarImageColor3 = MAIN_COLOR
Tabs.ScrollingDirection = Enum.ScrollingDirection.X
Tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
Tabs.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = Tabs

TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Tabs.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 5, 0, 0)
end)

local Pages = {}
local function CreatePage(Name)
	local Page = Instance.new("ScrollingFrame")
	Page.Name = Name
	Page.Size = UDim2.new(1, -16, 1, -88)
	Page.Position = UDim2.new(0, 8, 0, 84)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 4
	Page.ScrollBarImageColor3 = MAIN_COLOR
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.Visible = false
	Page.Parent = Main

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 6)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Page

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
	end)

	Pages[Name] = Page
	return Page
end

local CombatPage = CreatePage("COMBAT")
local PlayerPage = CreatePage("PLAYER")
local VisualsPage = CreatePage("VISUALS")
local FlingPage = CreatePage("MISC")
local ScriptsPage = CreatePage("SCRIPTS")
local ConfigPage = CreatePage("CONFIG")

local CurrentPage = CombatPage

local function CreateTab(Name, Page)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 75, 0, 28)
	Button.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
	Button.BorderSizePixel = 0
	Button.Text = Name
	Button.TextColor3 = Color3.fromRGB(170, 170, 185)
	Button.TextSize = 11
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Parent = Tabs

	local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 4) Corner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		for _, OtherPage in pairs(Pages) do OtherPage.Visible = false end
		Page.Visible = true
		CurrentPage = Page

		for _, Object in ipairs(Tabs:GetChildren()) do
			if Object:IsA("TextButton") then
				Object.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
				Object.TextColor3 = Color3.fromRGB(170, 170, 185)
			end
		end

		Button.BackgroundColor3 = MAIN_COLOR
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	return Button
end

local CombatTab = CreateTab("COMBAT", CombatPage)
local PlayerTab = CreateTab("PLAYER", PlayerPage)
local VisualsTab = CreateTab("VISUALS", VisualsPage)
local FlingTab = CreateTab("MISC", FlingPage)
local ScriptsTab = CreateTab("SCRIPTS", ScriptsPage)
local ConfigTab = CreateTab("CONFIG", ConfigPage)

CombatPage.Visible = true
CombatTab.BackgroundColor3 = MAIN_COLOR
CombatTab.TextColor3 = Color3.fromRGB(255, 255, 255)

-- CHAT LOGS GUI
local ChatLogGui = Instance.new("Frame")
ChatLogGui.Name = "ChatLogFrame"
ChatLogGui.Size = UDim2.new(0, 350, 0, 230)
ChatLogGui.Position = UDim2.new(0.5, 180, 0.5, -115)
ChatLogGui.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
ChatLogGui.BorderSizePixel = 0
ChatLogGui.ClipsDescendants = true
ChatLogGui.Visible = false
ChatLogGui.Parent = Gui

local ChatLogCorner = Instance.new("UICorner") ChatLogCorner.CornerRadius = UDim.new(0, 8) ChatLogCorner.Parent = ChatLogGui
local ChatLogStroke = Instance.new("UIStroke") ChatLogStroke.Color = MAIN_COLOR ChatLogStroke.Thickness = 2 ChatLogStroke.Parent = ChatLogGui

local ChatLogTopBar = Instance.new("Frame")
ChatLogTopBar.Size = UDim2.new(1, 0, 0, 32)
ChatLogTopBar.BackgroundColor3 = MAIN_COLOR
ChatLogTopBar.BorderSizePixel = 0
ChatLogTopBar.Parent = ChatLogGui

local ChatLogTitle = Instance.new("TextLabel")
ChatLogTitle.Size = UDim2.new(1, -110, 1, 0)
ChatLogTitle.Position = UDim2.new(0, 10, 0, 0)
ChatLogTitle.BackgroundTransparency = 1
ChatLogTitle.Text = "Chat Logs"
ChatLogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatLogTitle.Font = Enum.Font.GothamBold
ChatLogTitle.TextSize = 13
ChatLogTitle.TextXAlignment = Enum.TextXAlignment.Left
ChatLogTitle.Parent = ChatLogTopBar

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 52, 0, 22)
ClearBtn.Position = UDim2.new(1, -60, 0.5, -11)
ClearBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
ClearBtn.BorderSizePixel = 0
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 11
ClearBtn.Parent = ChatLogTopBar

local ClearCorner = Instance.new("UICorner") ClearCorner.CornerRadius = UDim.new(0, 4) ClearCorner.Parent = ClearBtn

local ChatLogScroll = Instance.new("ScrollingFrame")
ChatLogScroll.Size = UDim2.new(1, -12, 1, -42)
ChatLogScroll.Position = UDim2.new(0, 6, 0, 36)
ChatLogScroll.BackgroundTransparency = 1
ChatLogScroll.BorderSizePixel = 0
ChatLogScroll.ScrollBarThickness = 4
ChatLogScroll.ScrollBarImageColor3 = MAIN_COLOR
ChatLogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatLogScroll.Parent = ChatLogGui

local ChatLogLayout = Instance.new("UIListLayout")
ChatLogLayout.Padding = UDim.new(0, 4)
ChatLogLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLogLayout.Parent = ChatLogScroll

ChatLogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ChatLogScroll.CanvasSize = UDim2.new(0, 0, 0, ChatLogLayout.AbsoluteContentSize.Y + 10)
    ChatLogScroll.CanvasPosition = Vector2.new(0, ChatLogLayout.AbsoluteContentSize.Y)
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(ChatLogScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
end)

local LastChatCache = {}
local function AddChatLog(p, msg)
    if not Settings.ChatLogs or Destroyed or not p then return end
    local cleanMsg = tostring(msg):gsub("<[^>]+>", "")
    if cleanMsg == "" then return end
    local pName = p.DisplayName or p.Name
    local cacheKey = pName .. ":" .. cleanMsg
    if LastChatCache[cacheKey] and (tick() - LastChatCache[cacheKey]) < 0.8 then return end
    LastChatCache[cacheKey] = tick()
    local timestamp = os.date("%H:%M:%S")
    local logText = string.format("[%s] %s: %s", timestamp, pName, cleanMsg)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -6, 0, 0)
    Label.AutomaticSize = Enum.AutomaticSize.Y
    Label.BackgroundTransparency = 1
    Label.Text = logText
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ChatLogScroll
end

-- MUSIC PLAYER GUI
local MusicGui = Instance.new("Frame")
MusicGui.Name = "MusicPlayerFrame"
MusicGui.Size = UDim2.new(0, 330, 0, 350)
MusicGui.Position = UDim2.new(0.5, -165, 0.5, -175)
MusicGui.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
MusicGui.BorderSizePixel = 0
MusicGui.ClipsDescendants = true
MusicGui.Visible = false
MusicGui.Parent = Gui

local MusicCorner = Instance.new("UICorner") MusicCorner.CornerRadius = UDim.new(0, 8) MusicCorner.Parent = MusicGui
local MusicStroke = Instance.new("UIStroke") MusicStroke.Color = MAIN_COLOR MusicStroke.Thickness = 2 MusicStroke.Parent = MusicGui

local MusicTopBar = Instance.new("Frame")
MusicTopBar.Size = UDim2.new(1, 0, 0, 32)
MusicTopBar.BackgroundColor3 = MAIN_COLOR
MusicTopBar.BorderSizePixel = 0
MusicTopBar.Parent = MusicGui

local MusicTitle = Instance.new("TextLabel")
MusicTitle.Size = UDim2.new(1, -40, 1, 0)
MusicTitle.Position = UDim2.new(0, 10, 0, 0)
MusicTitle.BackgroundTransparency = 1
MusicTitle.Text = "Tox Music Player"
MusicTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicTitle.Font = Enum.Font.GothamBold
MusicTitle.TextSize = 13
MusicTitle.TextXAlignment = Enum.TextXAlignment.Left
MusicTitle.Parent = MusicTopBar

local MusicCloseBtn = Instance.new("TextButton")
MusicCloseBtn.Size = UDim2.new(0, 24, 0, 22)
MusicCloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
MusicCloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
MusicCloseBtn.BorderSizePixel = 0
MusicCloseBtn.Text = "X"
MusicCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicCloseBtn.Font = Enum.Font.GothamBold
MusicCloseBtn.TextSize = 11
MusicCloseBtn.Parent = MusicTopBar
local MusicCloseCorner = Instance.new("UICorner") MusicCloseCorner.CornerRadius = UDim.new(0, 4) MusicCloseCorner.Parent = MusicCloseBtn
MusicCloseBtn.MouseButton1Click:Connect(function() MusicGui.Visible = false end)

local CustomSound = Instance.new("Sound")
CustomSound.Name = "ToxMusicSound"
CustomSound.Looped = false
CustomSound.Volume = 1
CustomSound.Parent = SoundService

local MusicContent = Instance.new("Frame")
MusicContent.Size = UDim2.new(1, -16, 1, -40)
MusicContent.Position = UDim2.new(0, 8, 0, 36)
MusicContent.BackgroundTransparency = 1
MusicContent.Parent = MusicGui

local IDInput = Instance.new("TextBox")
IDInput.Size = UDim2.new(0, 130, 0, 26)
IDInput.Position = UDim2.new(0, 0, 0, 0)
IDInput.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
IDInput.PlaceholderText = "Sound ID..."
IDInput.Text = ""
IDInput.TextColor3 = Color3.fromRGB(255, 255, 255)
IDInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
IDInput.Font = Enum.Font.Gotham
IDInput.TextSize = 11
IDInput.ClearTextOnFocus = false
IDInput.Parent = MusicContent
local IDInputCorner = Instance.new("UICorner") IDInputCorner.CornerRadius = UDim.new(0, 4) IDInputCorner.Parent = IDInput

local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 110, 0, 26)
NameInput.Position = UDim2.new(0, 134, 0, 0)
NameInput.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
NameInput.PlaceholderText = "Track Name..."
NameInput.Text = ""
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
NameInput.Font = Enum.Font.Gotham
NameInput.TextSize = 11
NameInput.ClearTextOnFocus = false
NameInput.Parent = MusicContent
local NameInputCorner = Instance.new("UICorner") NameInputCorner.CornerRadius = UDim.new(0, 4) NameInputCorner.Parent = NameInput

local PlayPauseBtn = Instance.new("TextButton")
PlayPauseBtn.Size = UDim2.new(0, 64, 0, 26)
PlayPauseBtn.Position = UDim2.new(1, -64, 0, 0)
PlayPauseBtn.BackgroundColor3 = MAIN_COLOR
PlayPauseBtn.Text = "Play"
PlayPauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayPauseBtn.Font = Enum.Font.GothamBold
PlayPauseBtn.TextSize = 11
PlayPauseBtn.Parent = MusicContent
local PlayPauseCorner = Instance.new("UICorner") PlayPauseCorner.CornerRadius = UDim.new(0, 4) PlayPauseCorner.Parent = PlayPauseBtn

local SavedScroll = Instance.new("ScrollingFrame")
SavedScroll.Size = UDim2.new(1, 0, 1, -64)
SavedScroll.Position = UDim2.new(0, 0, 0, 62)
SavedScroll.BackgroundTransparency = 1
SavedScroll.ScrollBarThickness = 3
SavedScroll.ScrollBarImageColor3 = MAIN_COLOR
SavedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SavedScroll.Parent = MusicContent

local SavedLayout = Instance.new("UIListLayout")
SavedLayout.Padding = UDim.new(0, 4)
SavedLayout.SortOrder = Enum.SortOrder.LayoutOrder
SavedLayout.Parent = SavedScroll

-- GERADORES DA INTERFACE (CONSTRUTORES)
local function CreateToggle(Name, Page, DefaultValue, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 39)
	Button.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = Page

	local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 4) BtnCorner.Parent = Button

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -65, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	local Toggle = Instance.new("Frame")
	Toggle.Size = UDim2.new(0, 38, 0, 20)
	Toggle.Position = UDim2.new(1, -48, 0.5, -10)
	Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	Toggle.BorderSizePixel = 0
	Toggle.Parent = Button

	local ToggleCorner = Instance.new("UICorner") ToggleCorner.CornerRadius = UDim.new(0, 4) ToggleCorner.Parent = Toggle

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 14, 0, 14)
	Indicator.Position = UDim2.new(0, 3, 0.5, -7)
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = Toggle

	local IndicatorCorner = Instance.new("UICorner") IndicatorCorner.CornerRadius = UDim.new(0, 3) IndicatorCorner.Parent = Indicator

	local Enabled = DefaultValue or false

	local function Update()
		if Enabled then
			Toggle.BackgroundColor3 = Color3.fromRGB(50, 180, 70)
			Indicator.Position = UDim2.new(1, -17, 0.5, -7)
		else
			Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
			Indicator.Position = UDim2.new(0, 3, 0.5, -7)
		end
	end

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Enabled = not Enabled
		Update()
		Callback(Enabled)
        AutoSaveConfiguration()
	end)

	Update()
	return Button
end

local function CreateToggleWithValue(Name, Page, DefaultToggle, DefaultValue, CallbackToggle, CallbackValue)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -5, 0, 39)
	Container.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Container.BorderSizePixel = 0
	Container.Parent = Page

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -125, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(0, 55, 0, 25)
	Input.Position = UDim2.new(1, -112, 0.5, -12)
	Input.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
	Input.BorderSizePixel = 0
	Input.Text = tostring(DefaultValue)
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.TextSize = 12
	Input.Font = Enum.Font.Gotham
	Input.ClearTextOnFocus = false
	Input.Parent = Container

	local InputCorner = Instance.new("UICorner") InputCorner.CornerRadius = UDim.new(0, 4) InputCorner.Parent = Input

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 38, 0, 20)
	ToggleButton.Position = UDim2.new(1, -48, 0.5, -10)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Text = ""
	ToggleButton.AutoButtonColor = false
	ToggleButton.Parent = Container

	local ToggleCorner = Instance.new("UICorner") ToggleCorner.CornerRadius = UDim.new(0, 4) ToggleCorner.Parent = ToggleButton

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 14, 0, 14)
	Indicator.Position = UDim2.new(0, 3, 0.5, -7)
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = ToggleButton

	local IndicatorCorner = Instance.new("UICorner") IndicatorCorner.CornerRadius = UDim.new(0, 3) IndicatorCorner.Parent = Indicator

	local Enabled = DefaultToggle or false

	local function UpdateToggle()
		if Enabled then
			ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 70)
			Indicator.Position = UDim2.new(1, -17, 0.5, -7)
		else
			ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
			Indicator.Position = UDim2.new(0, 3, 0.5, -7)
		end
	end

	ToggleButton.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Enabled = not Enabled
		UpdateToggle()
		CallbackToggle(Enabled)
        AutoSaveConfiguration()
	end)

	Input.FocusLost:Connect(function()
		if Destroyed then return end
		local Number = tonumber(Input.Text)
		if Number then
			CallbackValue(Number)
            AutoSaveConfiguration()
		else
			Input.Text = tostring(DefaultValue)
		end
	end)

	UpdateToggle()
	return Container
end

local function CreateInputWithButton(Name, Page, DefaultText, ButtonText, Callback)
	local Box = Instance.new("Frame")
	Box.Size = UDim2.new(1, -5, 0, 48)
	Box.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Box.BorderSizePixel = 0
	Box.Parent = Page

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -170, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
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
	Input.Text = DefaultText or ""
	Input.PlaceholderText = "Nick"
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	Input.TextSize = 12
	Input.Font = Enum.Font.Gotham
	Input.ClearTextOnFocus = false
	Input.Parent = Box

	local InputCorner = Instance.new("UICorner") InputCorner.CornerRadius = UDim.new(0, 4) InputCorner.Parent = Input

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 60, 0, 27)
	Button.Position = UDim2.new(1, -65, 0.5, -13)
	Button.BackgroundColor3 = MAIN_COLOR
	Button.BorderSizePixel = 0
	Button.Text = ButtonText or "Fling"
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamBold
	Button.Parent = Box

	local ButtonCorner = Instance.new("UICorner") ButtonCorner.CornerRadius = UDim.new(0, 4) ButtonCorner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Callback(Input.Text)
	end)

	return Box
end

local function CreateInputWithToggle(Name, Page, DefaultText, CallbackToggle)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -5, 0, 48)
	Container.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Container.BorderSizePixel = 0
	Container.Parent = Page

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -160, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(0, 90, 0, 27)
	Input.Position = UDim2.new(1, -145, 0.5, -13)
	Input.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
	Input.BorderSizePixel = 0
	Input.Text = DefaultText or ""
	Input.PlaceholderText = "Nick"
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	Input.TextSize = 12
	Input.Font = Enum.Font.Gotham
	Input.ClearTextOnFocus = false
	Input.Parent = Container

	local InputCorner = Instance.new("UICorner") InputCorner.CornerRadius = UDim.new(0, 4) InputCorner.Parent = Input

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 38, 0, 20)
	ToggleButton.Position = UDim2.new(1, -48, 0.5, -10)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Text = ""
	ToggleButton.AutoButtonColor = false
	ToggleButton.Parent = Container

	local ToggleCorner = Instance.new("UICorner") ToggleCorner.CornerRadius = UDim.new(0, 4) ToggleCorner.Parent = ToggleButton

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 14, 0, 14)
	Indicator.Position = UDim2.new(0, 3, 0.5, -7)
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = ToggleButton

	local IndicatorCorner = Instance.new("UICorner") IndicatorCorner.CornerRadius = UDim.new(0, 3) IndicatorCorner.Parent = Indicator

	local Enabled = false

	local function UpdateToggle()
		if Enabled then
			ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 70)
			Indicator.Position = UDim2.new(1, -17, 0.5, -7)
		else
			ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
			Indicator.Position = UDim2.new(0, 3, 0.5, -7)
		end
	end

	ToggleButton.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Enabled = not Enabled
		UpdateToggle()
		CallbackToggle(Enabled, Input.Text)
	end)

	UpdateToggle()
	return Container
end

local function CreateTeleportRow(Name, Page, CallbackGo, CallbackLoop)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -5, 0, 48)
	Container.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Container.BorderSizePixel = 0
	Container.Parent = Page

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -210, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(0, 75, 0, 27)
	Input.Position = UDim2.new(1, -195, 0.5, -13)
	Input.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
	Input.BorderSizePixel = 0
	Input.Text = ""
	Input.PlaceholderText = "Nick"
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	Input.TextSize = 11
	Input.Font = Enum.Font.Gotham
	Input.ClearTextOnFocus = false
	Input.Parent = Container

	local InputCorner = Instance.new("UICorner") InputCorner.CornerRadius = UDim.new(0, 4) InputCorner.Parent = Input

	local GoBtn = Instance.new("TextButton")
	GoBtn.Size = UDim2.new(0, 45, 0, 27)
	GoBtn.Position = UDim2.new(1, -115, 0.5, -13)
	GoBtn.BackgroundColor3 = MAIN_COLOR
	GoBtn.BorderSizePixel = 0
	GoBtn.Text = "Go!"
	GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	GoBtn.TextSize = 11
	GoBtn.Font = Enum.Font.GothamBold
	GoBtn.Parent = Container

	local GoCorner = Instance.new("UICorner") GoCorner.CornerRadius = UDim.new(0, 4) GoCorner.Parent = GoBtn

	local LoopBtn = Instance.new("TextButton")
	LoopBtn.Size = UDim2.new(0, 60, 0, 27)
	LoopBtn.Position = UDim2.new(1, -65, 0.5, -13)
	LoopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	LoopBtn.BorderSizePixel = 0
	LoopBtn.Text = "Loop TP"
	LoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	LoopBtn.TextSize = 10
	LoopBtn.Font = Enum.Font.GothamBold
	LoopBtn.Parent = Container

	local LoopCorner = Instance.new("UICorner") LoopCorner.CornerRadius = UDim.new(0, 4) LoopCorner.Parent = LoopBtn

	local LoopEnabled = false

	GoBtn.MouseButton1Click:Connect(function()
		if Destroyed then return end
		CallbackGo(Input.Text)
	end)

	LoopBtn.MouseButton1Click:Connect(function()
		if Destroyed then return end
		LoopEnabled = not LoopEnabled
		LoopBtn.BackgroundColor3 = LoopEnabled and Color3.fromRGB(50, 180, 70) or Color3.fromRGB(180, 50, 50)
		CallbackLoop(LoopEnabled, Input.Text)
	end)

	return Container
end

local function CreateDropdown(Name, Options, Page, DefaultOption, Callback)
	local Box = Instance.new("Frame")
	Box.Size = UDim2.new(1, -5, 0, 48)
	Box.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Box.BorderSizePixel = 0
	Box.Parent = Page

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -110, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Box

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 95, 0, 27)
	Button.Position = UDim2.new(1, -107, 0.5, -13)
	Button.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
	Button.BorderSizePixel = 0
	Button.Text = DefaultOption
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 12
	Button.Font = Enum.Font.Gotham
	Button.Parent = Box

	local CurrentIdx = 1
	for i, opt in ipairs(Options) do if opt == DefaultOption then CurrentIdx = i end end

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		CurrentIdx = CurrentIdx + 1
		if CurrentIdx > #Options then CurrentIdx = 1 end
		Button.Text = Options[CurrentIdx]
		Callback(Options[CurrentIdx])
        AutoSaveConfiguration()
	end)

	return Box
end

local function CreateKeybind(Name, Page, DefaultKey, Callback)
	local Box = Instance.new("Frame")
	Box.Size = UDim2.new(1, -5, 0, 48)
	Box.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Box.BorderSizePixel = 0
	Box.Parent = Page

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -110, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Name
	Label.TextColor3 = Color3.fromRGB(240, 240, 240)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Box

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 95, 0, 27)
	Button.Position = UDim2.new(1, -107, 0.5, -13)
	Button.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
	Button.BorderSizePixel = 0
	Button.Text = DefaultKey and DefaultKey.Name or "None"
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 12
	Button.Font = Enum.Font.Gotham
	Button.Parent = Box

	local Binding = false
	local JustStarted = false

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Binding = true; JustStarted = true
		Button.Text = "Press Key..."
		task.defer(function() JustStarted = false end)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not Binding or JustStarted then return end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			Binding = false
			if input.KeyCode == Enum.KeyCode.Escape then
				Button.Text = "None"; Callback(nil)
			else
				Button.Text = input.KeyCode.Name; Callback(input.KeyCode)
			end
            AutoSaveConfiguration()
		else
			Binding = false; Button.Text = "None"; Callback(nil); AutoSaveConfiguration()
		end
	end)

	return Box
end

local function CreateButton(Name, Page, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 39)
	Button.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
	Button.BorderSizePixel = 0
	Button.Text = Name
	Button.TextColor3 = Color3.fromRGB(240, 240, 240)
	Button.TextSize = 13
	Button.Font = Enum.Font.GothamMedium
	Button.Parent = Page

	local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 4) Corner.Parent = Button
	Button.MouseButton1Click:Connect(function() if not Destroyed then Callback() end end)
	return Button
end

-- AMBIENTE COMPARTILHADO (ToxEnv)
getgenv().ToxEnv = {
    Settings = Settings,
    ColorMap = ColorMap,
    CombatPage = CombatPage,
    PlayerPage = PlayerPage,
    VisualsPage = VisualsPage,
    MiscPage = FlingPage,
    FlingPage = FlingPage,
    ScriptsPage = ScriptsPage,
    ConfigPage = ConfigPage,
    
    CreateToggle = CreateToggle,
    CreateToggleWithValue = CreateToggleWithValue,
    CreateInputWithButton = CreateInputWithButton,
    CreateInputWithToggle = CreateInputWithToggle,
    CreateTeleportRow = CreateTeleportRow,
    CreateDropdown = CreateDropdown,
    CreateKeybind = CreateKeybind,
    CreateButton = CreateButton,
    CustomNotify = CustomNotify,
    Message = Message,
    AutoSaveConfiguration = AutoSaveConfiguration,
    
    MusicGui = MusicGui,
    ChatLogGui = ChatLogGui,
    
    Player = Player,
    Destroyed = false
}

-- ANIMACAO DE LOADING & CARREGAMENTO DOS MÓDULOS
local function ShowCenterLoadSequence()
    local SplashFrame = Instance.new("Frame")
    SplashFrame.Size = UDim2.new(0, 320, 0, 95)
    SplashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    SplashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SplashFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    SplashFrame.BorderSizePixel = 0
    SplashFrame.ClipsDescendants = true
    SplashFrame.Parent = NotifGui

    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 10) Corner.Parent = SplashFrame
    local Stroke = Instance.new("UIStroke") Stroke.Color = MAIN_COLOR Stroke.Thickness = 2 Stroke.Parent = SplashFrame

    local SplashLogo = Instance.new("ImageLabel")
    SplashLogo.Size = UDim2.new(0, 42, 0, 42)
    SplashLogo.Position = UDim2.new(0, 16, 0, 12)
    SplashLogo.BackgroundTransparency = 1
    SplashLogo.Image = LOGO_ID
    SplashLogo.Parent = SplashFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -75, 0, 22)
    TitleLabel.Position = UDim2.new(0, 68, 0, 12)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Tox Loading..."
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = SplashFrame

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -75, 0, 18)
    SubLabel.Position = UDim2.new(0, 68, 0, 32)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Tox v1 Utility GUI"
    SubLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    SubLabel.Font = Enum.Font.GothamMedium
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = SplashFrame

    local BarBackground = Instance.new("Frame")
    BarBackground.Size = UDim2.new(1, -32, 0, 8)
    BarBackground.Position = UDim2.new(0, 16, 1, -20)
    BarBackground.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    BarBackground.BorderSizePixel = 0
    BarBackground.Parent = SplashFrame

    local BarCorner = Instance.new("UICorner") BarCorner.CornerRadius = UDim.new(0, 4) BarCorner.Parent = BarBackground

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = MAIN_COLOR
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBackground

    local BarFillCorner = Instance.new("UICorner") BarFillCorner.CornerRadius = UDim.new(0, 4) BarFillCorner.Parent = BarFill

    local PercentLabel = Instance.new("TextLabel")
    PercentLabel.Size = UDim2.new(0, 40, 0, 18)
    PercentLabel.Position = UDim2.new(1, -56, 0, 12)
    PercentLabel.BackgroundTransparency = 1
    PercentLabel.Text = "0%"
    PercentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PercentLabel.Font = Enum.Font.GothamBold
    PercentLabel.TextSize = 11
    PercentLabel.TextXAlignment = Enum.TextXAlignment.Right
    PercentLabel.Parent = SplashFrame

    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://6029232301"
    Sound.Volume = 0.6
    Sound.Parent = SoundService
    Sound:Play()
    Sound.Ended:Connect(function() Sound:Destroy() end)

    local duration = 5
    local steps = 100
    for i = 1, steps do
        local p = i / steps
        BarFill.Size = UDim2.new(p, 0, 1, 0)
        PercentLabel.Text = math.floor(p * 100) .. "%"
        if i == steps then TitleLabel.Text = "Tox Loaded Successfully" end
        task.wait(duration / steps)
    end

    local fallTween = TweenService:Create(SplashFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 1.3, 0),
        BackgroundTransparency = 1
    })
    fallTween:Play()
    fallTween.Completed:Connect(function()
        SplashFrame:Destroy()
        if not Destroyed then
            task.wait(1)
            Main.Size = UDim2.new(0, 0, 0, 0)
            Main.Position = UDim2.new(0.5, 0, 0.5, 0)
            Main.Visible = true

            Main:TweenSizeAndPosition(
                UDim2.new(0, 330, 0, 395),
                UDim2.new(0.5, -165, 0.5, -197),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Back,
                0.5,
                true
            )

            IsLoaded = true

            -- CARREGAMENTO DOS MÓDULOS SEPARADOS NO GITHUB
            local baseUrl = "https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/"
            pcall(function() loadstring(game:HttpGet(baseUrl .. "ToxCombat.lua"))() end)
            pcall(function() loadstring(game:HttpGet(baseUrl .. "ToxPlayer.lua"))() end)
            pcall(function() loadstring(game:HttpGet(baseUrl .. "ToxVisuals.lua"))() end)
            pcall(function() loadstring(game:HttpGet(baseUrl .. "ToxMisc.lua"))() end)
            pcall(function() loadstring(game:HttpGet(baseUrl .. "ToxScript.lua"))() end)
            pcall(function() loadstring(game:HttpGet(baseUrl .. "ToxConfig.lua"))() end)
        end
    end)
end

task.spawn(ShowCenterLoadSequence)

-- ATALHO DE TECLA PARA ABRIR/FECHAR A GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or Destroyed then return end
    if Settings.GUIKeybind and input.KeyCode == Settings.GUIKeybind then
        Main.Visible = not Main.Visible
        if Settings.ChatLogs then ChatLogGui.Visible = Main.Visible end
    end
end)

local Minimized = false
Minimize.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	Main.Size = Minimized and UDim2.new(0, 330, 0, 38) or UDim2.new(0, 330, 0, 395)
	Tabs.Visible = not Minimized
	if CurrentPage then CurrentPage.Visible = not Minimized end
	Minimize.Text = Minimized and "+" or "-"
end)

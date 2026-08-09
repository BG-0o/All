-- ToxHub.lua (Tox v1 Utility Suite Completa com AIM & CONFIGS)
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

    -- COMBAT & AIM CONFIGS
    Aimbot = false,
    AimbotSmoothness = 2,
    AimPart = "Head",
    ShowFOV = false,
    FOVRadius = 120,
    SilentAim = false,
    SilentAimFOV = 100,
    HitboxExpander = false,
    HitboxSize = 10,
    KillAura = false,
    KillAuraRange = 15,

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
local Character
local Humanoid
local RootPart
local Destroyed = false

local FolderName = "ToxV1_Data"
local ConfigFilePath = FolderName .. "/config.json"

local function EnsureFolder()
    if makefolder and isfolder then
        pcall(function()
            if not isfolder(FolderName) then
                makefolder(FolderName)
            end
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
            Aimbot = Settings.Aimbot,
            AimbotSmoothness = Settings.AimbotSmoothness,
            AimPart = Settings.AimPart,
            ShowFOV = Settings.ShowFOV,
            FOVRadius = Settings.FOVRadius,
            SilentAim = Settings.SilentAim,
            HitboxExpander = Settings.HitboxExpander,
            HitboxSize = Settings.HitboxSize,
            KillAura = Settings.KillAura,
            KillAuraRange = Settings.KillAuraRange,
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
                    elseif k == "EspColorName" then
                        Settings.EspColorName = v
                        Settings.EspColor = ColorMap[v] or Color3.fromRGB(255, 255, 255)
                    else
                        Settings[k] = v
                    end
                end
            end
            if data.SavedIDs then
                SavedIDs = data.SavedIDs
            end
        end
    end)
end

LoadConfiguration()

-- FOV CIRCLE DRAWING
local FOVCircle = (Drawing and Drawing.new) and Drawing.new("Circle") or nil
if FOVCircle then
    FOVCircle.Color = Color3.fromRGB(0, 200, 255)
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    FOVCircle.Visible = false
end

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
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = MAIN_COLOR
    Stroke.Thickness = 1.5
    Stroke.Parent = Frame
    
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
        t1.Completed:Connect(function()
            Frame:Destroy()
        end)
    end)
end

local function UpdateCharacter()
	if Destroyed then return end
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
end

UpdateCharacter()

local ParentContainer = (gethui and gethui()) or game:GetService("CoreGui")
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

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = MAIN_COLOR
MainStroke.Thickness = 2
MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = MAIN_COLOR
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Dragging, DragInput, DragStart, StartPos

local function UpdateDrag(input)
	local Delta = input.Position - DragStart
	Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPos = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then Dragging = false end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		DragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		UpdateDrag(input)
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

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = Minimize

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

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 3)
	Padding.PaddingBottom = UDim.new(0, 8)
	Padding.Parent = Page

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
	end)

	Pages[Name] = Page
	return Page, Layout
end

local CombatPage, CombatLayout = CreatePage("COMBAT")
local PlayerPage, PlayerLayout = CreatePage("PLAYER")
local VisualsPage, VisualsLayout = CreatePage("VISUALS")
local FlingPage, FlingLayout = CreatePage("MISC")
local ScriptsPage, ScriptsLayout = CreatePage("SCRIPTS")
local ConfigPage, ConfigLayout = CreatePage("CONFIG")

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

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 4)
	Corner.Parent = Button

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

-- CHAT LOGS GUI (COM BOTÃO DE MINIMIZAR "-")
local ChatLogGui = Instance.new("Frame")
ChatLogGui.Name = "ChatLogFrame"
ChatLogGui.Size = UDim2.new(0, 350, 0, 230)
ChatLogGui.Position = UDim2.new(0.5, 180, 0.5, -115)
ChatLogGui.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
ChatLogGui.BorderSizePixel = 0
ChatLogGui.ClipsDescendants = true
ChatLogGui.Visible = false
ChatLogGui.Parent = Gui

local ChatLogCorner = Instance.new("UICorner")
ChatLogCorner.CornerRadius = UDim.new(0, 8)
ChatLogCorner.Parent = ChatLogGui

local ChatLogStroke = Instance.new("UIStroke")
ChatLogStroke.Color = MAIN_COLOR
ChatLogStroke.Thickness = 2
ChatLogStroke.Parent = ChatLogGui

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

local ChatLogMinBtn = Instance.new("TextButton")
ChatLogMinBtn.Size = UDim2.new(0, 24, 0, 22)
ChatLogMinBtn.Position = UDim2.new(1, -88, 0.5, -11)
ChatLogMinBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
ChatLogMinBtn.BorderSizePixel = 0
ChatLogMinBtn.Text = "-"
ChatLogMinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatLogMinBtn.Font = Enum.Font.GothamBold
ChatLogMinBtn.TextSize = 14
ChatLogMinBtn.Parent = ChatLogTopBar

local ChatLogMinCorner = Instance.new("UICorner")
ChatLogMinCorner.CornerRadius = UDim.new(0, 4)
ChatLogMinCorner.Parent = ChatLogMinBtn

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

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 4)
ClearCorner.Parent = ClearBtn

local ChatLogScroll = Instance.new("ScrollingFrame")
ChatLogScroll.Size = UDim2.new(1, -12, 1, -42)
ChatLogScroll.Position = UDim2.new(0, 6, 0, 36)
ChatLogScroll.BackgroundTransparency = 1
ChatLogScroll.BorderSizePixel = 0
ChatLogScroll.ScrollBarThickness = 4
ChatLogScroll.ScrollBarImageColor3 = MAIN_COLOR
ChatLogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatLogScroll.Parent = ChatLogGui

local ChatLogMinState = false
ChatLogMinBtn.MouseButton1Click:Connect(function()
    ChatLogMinState = not ChatLogMinState
    ChatLogScroll.Visible = not ChatLogMinState
    ChatLogGui.Size = ChatLogMinState and UDim2.new(0, 350, 0, 32) or UDim2.new(0, 350, 0, 230)
    ChatLogMinBtn.Text = ChatLogMinState and "+" or "-"
end)

-- MUSIC PLAYER GUI (COM BOTÃO DE MINIMIZAR "-")
local MusicGui = Instance.new("Frame")
MusicGui.Name = "MusicPlayerFrame"
MusicGui.Size = UDim2.new(0, 330, 0, 350)
MusicGui.Position = UDim2.new(0.5, -165, 0.5, -175)
MusicGui.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
MusicGui.BorderSizePixel = 0
MusicGui.ClipsDescendants = true
MusicGui.Visible = false
MusicGui.Parent = Gui

local MusicCorner = Instance.new("UICorner")
MusicCorner.CornerRadius = UDim.new(0, 8)
MusicCorner.Parent = MusicGui

local MusicStroke = Instance.new("UIStroke")
MusicStroke.Color = MAIN_COLOR
MusicStroke.Thickness = 2
MusicStroke.Parent = MusicGui

local MusicTopBar = Instance.new("Frame")
MusicTopBar.Size = UDim2.new(1, 0, 0, 32)
MusicTopBar.BackgroundColor3 = MAIN_COLOR
MusicTopBar.BorderSizePixel = 0
MusicTopBar.Parent = MusicGui

local MusicTitle = Instance.new("TextLabel")
MusicTitle.Size = UDim2.new(1, -70, 1, 0)
MusicTitle.Position = UDim2.new(0, 10, 0, 0)
MusicTitle.BackgroundTransparency = 1
MusicTitle.Text = "Tox Music Player"
MusicTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicTitle.Font = Enum.Font.GothamBold
MusicTitle.TextSize = 13
MusicTitle.TextXAlignment = Enum.TextXAlignment.Left
MusicTitle.Parent = MusicTopBar

local MusicMinBtn = Instance.new("TextButton")
MusicMinBtn.Size = UDim2.new(0, 24, 0, 22)
MusicMinBtn.Position = UDim2.new(1, -56, 0.5, -11)
MusicMinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MusicMinBtn.BorderSizePixel = 0
MusicMinBtn.Text = "-"
MusicMinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicMinBtn.Font = Enum.Font.GothamBold
MusicMinBtn.TextSize = 14
MusicMinBtn.Parent = MusicTopBar

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

local MusicContent = Instance.new("Frame")
MusicContent.Size = UDim2.new(1, -16, 1, -40)
MusicContent.Position = UDim2.new(0, 8, 0, 36)
MusicContent.BackgroundTransparency = 1
MusicContent.Parent = MusicGui

local MusicMinState = false
MusicMinBtn.MouseButton1Click:Connect(function()
    MusicMinState = not MusicMinState
    MusicContent.Visible = not MusicMinState
    MusicGui.Size = MusicMinState and UDim2.new(0, 330, 0, 32) or UDim2.new(0, 330, 0, 350)
    MusicMinBtn.Text = MusicMinState and "+" or "-"
end)

MusicCloseBtn.MouseButton1Click:Connect(function()
    MusicGui.Visible = false
end)

-- GERADORES DA INTERFACE
local function CreateToggle(Name, Page, DefaultValue, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 39)
	Button.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = Page

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

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 4)
	ToggleCorner.Parent = Toggle

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 14, 0, 14)
	Indicator.Position = UDim2.new(0, 3, 0.5, -7)
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = Toggle

	local IndicatorCorner = Instance.new("UICorner")
	IndicatorCorner.CornerRadius = UDim.new(0, 3)
	IndicatorCorner.Parent = Indicator

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

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 4)
	InputCorner.Parent = Input

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 38, 0, 20)
	ToggleButton.Position = UDim2.new(1, -48, 0.5, -10)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Text = ""
	ToggleButton.AutoButtonColor = false
	ToggleButton.Parent = Container

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 4)
	ToggleCorner.Parent = ToggleButton

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 14, 0, 14)
	Indicator.Position = UDim2.new(0, 3, 0.5, -7)
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = ToggleButton

	local IndicatorCorner = Instance.new("UICorner")
	IndicatorCorner.CornerRadius = UDim.new(0, 3)
	IndicatorCorner.Parent = Indicator

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

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 4)
	InputCorner.Parent = Input

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

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 4)
	ButtonCorner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Callback(Input.Text)
	end)

	return Box
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
	for i, opt in ipairs(Options) do
		if opt == DefaultOption then CurrentIdx = i end
	end

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

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 4)
	Corner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		if Destroyed then return end
		Callback()
	end)

	return Button
end

-- FIX: FLING COMPATÍVEL COM ALL / RANDOM / OTHERS E NICKS
local function GetPlayer(Name)
	if not Name or Name == "" then return nil end
	Name = string.lower(Name)

	if Name == "all" or Name == "others" then
		return "all"
	elseif Name == "random" then
		local GetPlayers = Players:GetPlayers()
		if table.find(GetPlayers, Player) then 
			table.remove(GetPlayers, table.find(GetPlayers, Player)) 
		end
		if #GetPlayers > 0 then
			return GetPlayers[math.random(#GetPlayers)]
		end
		return nil
	else
		for _, x in ipairs(Players:GetPlayers()) do
			if x ~= Player then
				if string.find(string.lower(x.Name), Name) or string.find(string.lower(x.DisplayName), Name) then
					return x
				end
			end
		end
	end
	return nil
end

local function SkidFling(TargetPlayer)
	if not TargetPlayer or not TargetPlayer.Character then return end

	local Character = Player.Character
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
            RootPart.Velocity = Vector3.new(99999, 99999, 99999)
            RunService.Heartbeat:Wait()
        end

        bav:Destroy()
        RootPart.Velocity = Vector3.zero
        RootPart.RotVelocity = Vector3.zero
        RootPart.CFrame = oldPos
	end
end

local function ExecuteFling(TargetInput)
	if not TargetInput or TargetInput == "" then
		return CustomNotify("Please enter a target name or 'all'", Color3.fromRGB(255, 100, 100))
	end

	local LowerInput = string.lower(TargetInput)

	if LowerInput == "all" or LowerInput == "others" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Player then SkidFling(p) end
		end
	else
		local TargetObj = GetPlayer(TargetInput)
		if TargetObj == "all" then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= Player then SkidFling(p) end
			end
		elseif typeof(TargetObj) == "Instance" and TargetObj:IsA("Player") then
			SkidFling(TargetObj)
		else
			CustomNotify("Username Invalid", Color3.fromRGB(255, 100, 100))
		end
	end
end

-- FIX: ANTI-VOID FUNCIONAL
local LastSafeCFrame = nil
local AntiVoidConnection = nil
local function StopAntiVoid()
	if AntiVoidConnection then AntiVoidConnection:Disconnect() AntiVoidConnection = nil end
end

local function StartAntiVoid()
	StopAntiVoid()
	AntiVoidConnection = RunService.Heartbeat:Connect(function()
		if Destroyed or not Settings.AntiVoid or not Character or not RootPart or not Humanoid then return end

		if Humanoid.FloorMaterial ~= Enum.Material.Air and RootPart.Velocity.Y > -10 then
			LastSafeCFrame = RootPart.CFrame
		end

		local fpdh = workspace.FallenPartsDestroyHeight or -500
		local isFallingOut = false
		if RootPart.Position.Y <= (fpdh + 25) or RootPart.Position.Y <= -250 then
			isFallingOut = true
		end

		if isFallingOut then
			RootPart.Velocity = Vector3.zero
			RootPart.RotVelocity = Vector3.zero
			if LastSafeCFrame then
				RootPart.CFrame = LastSafeCFrame + Vector3.new(0, 3, 0)
			else
				RootPart.CFrame = CFrame.new(RootPart.Position.X, 100, RootPart.Position.Z)
			end
			CustomNotify("Anti Void Rescued You!", Color3.fromRGB(100, 255, 100))
		end
	end)
end

-- BUSCA DE JOGADOR MAIS PRÓXIMO PARA O AIMBOT
local function GetClosestPlayerToMouse()
    local Closest = nil
    local ShortestDistance = Settings.FOVRadius or 120
    local MousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local targetPart = p.Character:FindFirstChild(Settings.AimPart or "Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and hum and hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if OnScreen then
                    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                    if Distance < ShortestDistance then
                        ShortestDistance = Distance
                        Closest = targetPart
                    end
                end
            end
        end
    end
    return Closest
end

-- PREENCHIMENTO DAS ABAS

-- ABA 1: COMBAT (OPÇÕES COMPLETA DE AIM & FLING)
CreateToggle("Aimbot (Right Click)", CombatPage, Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggleWithValue("Aim Smoothness", CombatPage, true, Settings.AimbotSmoothness, function(v) end, function(val) Settings.AimbotSmoothness = val end)
CreateDropdown("Aim Part", {"Head", "HumanoidRootPart", "Torso"}, CombatPage, Settings.AimPart, function(v) Settings.AimPart = v end)
CreateToggleWithValue("Show FOV Circle", CombatPage, Settings.ShowFOV, Settings.FOVRadius, function(v) Settings.ShowFOV = v end, function(val) Settings.FOVRadius = val end)
CreateToggle("Silent Aim", CombatPage, Settings.SilentAim, function(v) Settings.SilentAim = v end)
CreateToggleWithValue("Hitbox Expander", CombatPage, Settings.HitboxExpander, Settings.HitboxSize, function(v) Settings.HitboxExpander = v end, function(val) Settings.HitboxSize = val end)
CreateToggleWithValue("Kill Aura", CombatPage, Settings.KillAura, Settings.KillAuraRange, function(v) Settings.KillAura = v end, function(val) Settings.KillAuraRange = val end)
CreateInputWithButton("Target Fling", CombatPage, "", "Fling", function(text) ExecuteFling(text) end)

-- ABA 2: PLAYER
CreateToggleWithValue("Speed", PlayerPage, Settings.Speed, Settings.SpeedValue, function(v) Settings.Speed = v end, function(val) Settings.SpeedValue = val end)
CreateToggleWithValue("Jump", PlayerPage, Settings.Jump, Settings.JumpValue, function(v) Settings.Jump = v end, function(val) Settings.JumpValue = val end)
CreateToggleWithValue("Fly", PlayerPage, Settings.Fly, Settings.FlySpeed, function(v) Settings.Fly = v end, function(val) Settings.FlySpeed = val end)
CreateToggleWithValue("Flycar", PlayerPage, Settings.FlyCar, Settings.FlyCarSpeed, function(v) Settings.FlyCar = v end, function(val) Settings.FlyCarSpeed = val end)
CreateToggleWithValue("Float", PlayerPage, Settings.Float, Settings.FloatStrength, function(v) Settings.Float = v end, function(val) Settings.FloatStrength = val end)
CreateToggle("Noclip", PlayerPage, Settings.Noclip, function(v) Settings.Noclip = v end)
CreateToggle("Infinite Jump", PlayerPage, Settings.InfiniteJump, function(v) Settings.InfiniteJump = v end)

-- ABA 3: VISUALS
CreateToggleWithValue("Enable ESP", VisualsPage, Settings.ESP, Settings.EspSize, function(v) Settings.ESP = v end, function(val) Settings.EspSize = val end)
CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Purple"}, VisualsPage, Settings.EspColorName, function(v) 
    Settings.EspColorName = v 
    Settings.EspColor = ColorMap[v] or Color3.fromRGB(255, 255, 255) 
    AutoSaveConfiguration() 
end)

-- ABA 4: MISC
CreateToggle("Ctrl Click TP", FlingPage, Settings.CtrlClickTP, function(v) Settings.CtrlClickTP = v end)
CreateToggle("No Fall Damage", FlingPage, Settings.NoFallDamage, function(v) Settings.NoFallDamage = v end)
CreateToggle("Anti Void", FlingPage, Settings.AntiVoid, function(v) Settings.AntiVoid = v if v then StartAntiVoid() else StopAntiVoid() end end)
CreateToggle("Anti Fling", FlingPage, Settings.AntiFling, function(v) Settings.AntiFling = v end)
CreateInputWithButton("Target Fling", FlingPage, "", "Fling", function(text) ExecuteFling(text) end)
CreateButton("Music Player", FlingPage, function() MusicGui.Visible = not MusicGui.Visible end)

-- ABA 5: SCRIPTS
CreateButton("Infinite Yield", ScriptsPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

-- ABA 6: CONFIG (OPÇÕES COMPLETAS DE DE SALVAMENTO E RESETAÇÃO)
CreateButton("Salvar Configurações", ConfigPage, function()
    AutoSaveConfiguration()
    CustomNotify("Configurações Salvas com Sucesso!", Color3.fromRGB(100, 255, 100))
end)

CreateButton("Recarregar Configurações", ConfigPage, function()
    LoadConfiguration()
    CustomNotify("Configurações Recarregadas!", Color3.fromRGB(100, 200, 255))
end)

CreateButton("Resetar Configurações Padrão", ConfigPage, function()
    if isfile and isfile(ConfigFilePath) then
        delfile(ConfigFilePath)
    end
    CustomNotify("Configurações Resetadas!", Color3.fromRGB(255, 100, 100))
end)

CreateToggle("Anti AFK", ConfigPage, Settings.AntiAFK, function(v) Settings.AntiAFK = v end)
CreateToggle("Chat Logs", ConfigPage, Settings.ChatLogs, function(v) Settings.ChatLogs = v ChatLogGui.Visible = v end)

CreateButton("Rejoin Server", ConfigPage, function()
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, Player)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
	end
end)

CreateButton("DESTROY / Unload", ConfigPage, function()
	Destroyed = true
	if CustomSound then CustomSound:Stop() CustomSound:Destroy() end
    if FOVCircle then FOVCircle:Destroy() end
    NotifGui:Destroy()
	Gui:Destroy()
end)

-- LOOP EM SEGUNDO PLANO (MOVEMENT, AIMBOT, HITBOX & KILL AURA)
RunService.RenderStepped:Connect(function()
	if Destroyed then return end
    
    -- Movimento
    if Humanoid and Humanoid.Health > 0 then
        Humanoid.WalkSpeed = Settings.Speed and Settings.SpeedValue or 16
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = Settings.Jump and Settings.JumpValue or 50
    end

    -- FOV Circle Position
    if FOVCircle then
        FOVCircle.Visible = Settings.Aimbot and Settings.ShowFOV
        FOVCircle.Radius = Settings.FOVRadius or 120
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end

    -- Aimbot Camera Lock (Botão Direito do Mouse)
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local Target = GetClosestPlayerToMouse()
        if Target then
            local Smooth = Settings.AimbotSmoothness or 2
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), 1 / Smooth)
        end
    end

    -- Hitbox Expander
    if Settings.HitboxExpander then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(Settings.HitboxSize or 10, Settings.HitboxSize or 10, Settings.HitboxSize or 10)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end
    end

    -- Kill Aura
    if Settings.KillAura and RootPart then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local dist = (RootPart.Position - tHrp.Position).Magnitude
                    if dist <= (Settings.KillAuraRange or 15) then
                        local tool = Character and Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end
    end
end)

-- ANIMAÇÃO SPLASH DE CARREGAMENTO (5 SEGUNDOS)
local function ShowCenterLoadSequence()
    local SplashFrame = Instance.new("Frame")
    SplashFrame.Size = UDim2.new(0, 320, 0, 95)
    SplashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    SplashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SplashFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    SplashFrame.BorderSizePixel = 0
    SplashFrame.ClipsDescendants = true
    SplashFrame.Parent = NotifGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = SplashFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = MAIN_COLOR
    Stroke.Thickness = 2
    Stroke.Parent = SplashFrame

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

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = BarBackground

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = MAIN_COLOR
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBackground

    local BarFillCorner = Instance.new("UICorner")
    BarFillCorner.CornerRadius = UDim.new(0, 4)
    BarFillCorner.Parent = BarFill

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
    TweenService:Create(Stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(SplashLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(TitleLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(SubLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(BarBackground, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(PercentLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    
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
        end
    end)
end

task.spawn(ShowCenterLoadSequence)

-- LÓGICA DE MINIMIZAR A JANELA PRINCIPAL
local Minimized = false
Minimize.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	Main.Size = Minimized and UDim2.new(0, 330, 0, 38) or UDim2.new(0, 330, 0, 395)
	Tabs.Visible = not Minimized
	if CurrentPage then CurrentPage.Visible = not Minimized end
	Minimize.Text = Minimized and "+" or "-"
end)

if Settings.AntiVoid then StartAntiVoid() end
print("Tox v1 Suite Carregada com Aimbot e Configs!")

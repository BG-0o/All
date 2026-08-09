-- ToxConfig.lua
local HttpService = game:GetService("HttpService")

local ToxConfig = {}
ToxConfig.FolderName = "ToxHub_Data"
ToxConfig.ConfigFilePath = ToxConfig.FolderName .. "/config.json"

ToxConfig.ColorMap = {
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

ToxConfig.Settings = {
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

ToxConfig.SavedIDs = {}

function ToxConfig:EnsureFolder()
    if makefolder and isfolder then
        pcall(function()
            if not isfolder(self.FolderName) then
                makefolder(self.FolderName)
            end
        end)
    end
end

function ToxConfig:Save()
    self:EnsureFolder()
    if not writefile then return end

    local data = {
        Settings = {
            Speed = self.Settings.Speed,
            SpeedValue = self.Settings.SpeedValue,
            Jump = self.Settings.Jump,
            JumpValue = self.Settings.JumpValue,
            Fly = self.Settings.Fly,
            FlySpeed = self.Settings.FlySpeed,
            FlyCar = self.Settings.FlyCar,
            FlyCarSpeed = self.Settings.FlyCarSpeed,
            Float = self.Settings.Float,
            FloatStrength = self.Settings.FloatStrength,
            Noclip = self.Settings.Noclip,
            InfiniteJump = self.Settings.InfiniteJump,
            CtrlClickTP = self.Settings.CtrlClickTP,
            NoFallDamage = self.Settings.NoFallDamage,
            AntiVoid = self.Settings.AntiVoid,
            AntiFling = self.Settings.AntiFling,
            AntiAFK = self.Settings.AntiAFK,
            ChatLogs = self.Settings.ChatLogs,
            Render3D = self.Settings.Render3D,
            ESP = self.Settings.ESP,
            EspSize = self.Settings.EspSize,
            EspColorName = self.Settings.EspColorName,
            ShowHealth = self.Settings.ShowHealth,
            NameType = self.Settings.NameType,
            Chams = self.Settings.Chams,
            ShowTeamColor = self.Settings.ShowTeamColor,
            DisableTeam = self.Settings.DisableTeam,
            Freecam = self.Settings.Freecam,
            Fullbright = self.Settings.Fullbright,
            FOVEnabled = self.Settings.FOVEnabled,
            FOVValue = self.Settings.FOVValue,
            GUIKeybind = self.Settings.GUIKeybind and self.Settings.GUIKeybind.Name or "LeftAlt",
            MusicAutoPlay = self.Settings.MusicAutoPlay,
            MusicLoop = self.Settings.MusicLoop
        },
        SavedIDs = self.SavedIDs
    }

    pcall(function()
        local json = HttpService:JSONEncode(data)
        writefile(self.ConfigFilePath, json)
    end)
end

function ToxConfig:Load()
    if not isfile or not readfile or not isfile(self.ConfigFilePath) then return end

    pcall(function()
        local content = readfile(self.ConfigFilePath)
        local data = HttpService:JSONDecode(content)

        if data then
            if data.Settings then
                for k, v in pairs(data.Settings) do
                    if k == "GUIKeybind" then
                        pcall(function() self.Settings.GUIKeybind = Enum.KeyCode[v] end)
                    elseif k == "EspColorName" then
                        self.Settings.EspColorName = v
                        self.Settings.EspColor = self.ColorMap[v] or Color3.fromRGB(255, 255, 255)
                    else
                        self.Settings[k] = v
                    end
                end
            end
            if data.SavedIDs then
                self.SavedIDs = data.SavedIDs
            end
        end
    end)
end

ToxConfig:Load()
return ToxConfig

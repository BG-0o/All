-- ToxConfig.lua (Sistema de Salvamento e Carregamento JSON)
local HttpService = game:GetService("HttpService")

local ToxConfig = {
    Folder = "ToxHub",
    File = "ToxHub/AutoSave.json",
    Settings = {
        Combat = { Target = "all", FlingSpeed = 10000, AutoFling = false },
        Player = { AntiVoid = false, WalkSpeed = 16, JumpPower = 50, Noclip = false },
        Visuals = { ESP = false, ESPColor = {1, 0, 0} },
        Misc = { AntiAFK = true }
    }
}

function ToxConfig:Init()
    if isfolder and not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    self:Load()
end

function ToxConfig:Save()
    if writefile then
        pcall(function()
            local json = HttpService:JSONEncode(self.Settings)
            writefile(self.File, json)
        end)
    end
end

function ToxConfig:Load()
    if isfile and isfile(self.File) then
        pcall(function()
            local content = readfile(self.File)
            local decoded = HttpService:JSONDecode(content)
            if type(decoded) == "table" then
                for category, tbl in pairs(decoded) do
                    if self.Settings[category] then
                        for k, v in pairs(tbl) do
                            self.Settings[category][k] = v
                        end
                    end
                end
            end
        end)
    end
end

function ToxConfig:Set(category, key, value)
    if not self.Settings[category] then
        self.Settings[category] = {}
    end
    self.Settings[category][key] = value
    self:Save() -- Salva automaticamente no disco ao alterar
end

function ToxConfig:Get(category, key, defaultValue)
    if self.Settings[category] and self.Settings[category][key] ~= nil then
        return self.Settings[category][key]
    end
    return defaultValue
end

function ToxConfig:InitUI(parentFrame, hub)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "Configurações & AutoSave"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = parentFrame

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -10, 0, 30)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Text = "Salvar Configurações Manualmente"
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.TextSize = 14
    saveBtn.Parent = parentFrame

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 4)
    saveCorner.Parent = saveBtn

    saveBtn.MouseButton1Click:Connect(function()
        self:Save()
        saveBtn.Text = "Configurações Salvas!"
        task.wait(1.5)
        saveBtn.Text = "Salvar Configurações Manualmente"
    end)
end

ToxConfig:Init()
return ToxConfig

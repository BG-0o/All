-- ToxConfig.lua
local HttpService = game:GetService("HttpService")

local ToxConfig = {
    Folder = "ToxHub",
    File = "ToxHub/AutoSave.json",
    Settings = {
        Combat = {
            Target = "all",
            FlingSpeed = 10000,
            AutoFling = false,
            HitboxSize = 2,
            HitboxEnabled = false,
            KillAura = false,
            KillAuraRange = 15
        },
        Player = {
            AntiVoid = false,
            WalkSpeed = 16,
            JumpPower = 50,
            Fly = false,
            FlySpeed = 50,
            Noclip = false,
            InfiniteJump = false
        },
        Visuals = {
            ESP = false,
            ESPBoxes = false,
            ESPNames = false,
            ESPTracers = false,
            ESPChams = false,
            ESPColor = {1, 0, 0} -- RGB normalizado (0 a 1)
        },
        Misc = {
            AntiAFK = true,
            Fullbright = false,
            FPSBooster = false
        }
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
                for cat, tbl in pairs(decoded) do
                    if self.Settings[cat] then
                        for k, v in pairs(tbl) do
                            self.Settings[cat][k] = v
                        end
                    else
                        self.Settings[cat] = tbl
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
    self:Save() -- AutoSave instantâneo ao alternar/modificar opções
end

function ToxConfig:Get(category, key, defaultValue)
    if self.Settings[category] and self.Settings[category][key] ~= nil then
        return self.Settings[category][key]
    end
    return defaultValue
end

function ToxConfig:InitUI(parentFrame, hub)
    local layout = parentFrame:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", parentFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "SISTEMA DE CONFIGURAÇÕES & AUTOSAVE"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 15
    title.Parent = parentFrame

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -10, 0, 32)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Text = "Salvar Configurações Manualmente"
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.TextSize = 14
    saveBtn.Parent = parentFrame

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = saveBtn

    saveBtn.MouseButton1Click:Connect(function()
        self:Save()
        saveBtn.Text = "Configurações Salvas com Sucesso!"
        task.wait(1.5)
        saveBtn.Text = "Salvar Configurações Manualmente"
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, -10, 0, 32)
    resetBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.Text = "Resetar Configurações Padrão"
    resetBtn.Font = Enum.Font.SourceSansBold
    resetBtn.TextSize = 14
    resetBtn.Parent = parentFrame

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 4)
    rCorner.Parent = resetBtn

    resetBtn.MouseButton1Click:Connect(function()
        if isfile and isfile(self.File) then
            delfile(self.File)
        end
        resetBtn.Text = "Configurações Resetadas! Recarregue a GUI."
    end)
end

ToxConfig:Init()
return ToxConfig

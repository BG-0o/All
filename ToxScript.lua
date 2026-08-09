-- ToxScript.lua
local ToxScript = {}

function ToxScript:Init(parentFrame, hub)
    local scripts = {
        { Name = "Infinite Yield", Url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source" },
        { Name = "Dark Dex Explorer", Url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua" },
        { Name = "SimpleSpy Remote", Url = "https://raw.githubusercontent.com/exunys/SimpleSpy/main/SimpleSpy.lua" }
    }

    for _, s in ipairs(scripts) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "Executar " .. s.Name
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.Parent = parentFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            pcall(function()
                loadstring(game:HttpGet(s.Url))()
            end)
        end)
    end
end

return ToxScript

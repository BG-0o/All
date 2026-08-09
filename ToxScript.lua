-- ToxScript.lua
local ToxScript = {}

function ToxScript:Init(parentPage, hub)
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
            Callback()
        end)
        return Button
    end

    CreateButton("Infinite Yield", parentPage, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    CreateButton("FE Emotes", parentPage, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/FeEmotes.lua", true))()
    end)

    CreateButton("Wall Walk", parentPage, function()
        loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
    end)
end

return ToxScript

local PLACE_ID = 109983668079237
local FIREBASE_URL = "https://olaaa-dc667-default-rtdb.firebaseio.com/jobid.json" -- Troque para sua URL real

-- Gui
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)

local Dropdown = Instance.new("TextButton", Frame)
Dropdown.Size = UDim2.new(0.8, 0, 0.3, 0)
Dropdown.Position = UDim2.new(0.1, 0, 0.1, 0)
Dropdown.Text = "Selecionar: Não definido"

local AcharBtn = Instance.new("TextButton", Frame)
AcharBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
AcharBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
AcharBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
AcharBtn.Text = "Achar Servidor"

local lista = {"Não definido", "1M/s", "2M/s", "3M/s", "4M/s", "5M/s", "6M/s", "7M/s", "8M/s", "9M/s", "10M/s"}
local selecionado = nil

-- Dropdown simples
Dropdown.MouseButton1Click:Connect(function()
    for _, btn in pairs(Frame:GetChildren()) do
        if btn:IsA("TextButton") and btn.Name == "Opt" then
            btn:Destroy()
        end
    end
    for i, opt in ipairs(lista) do
        local btn = Instance.new("TextButton", Frame)
        btn.Name = "Opt"
        btn.Size = UDim2.new(0.8, 0, 0.2, 0)
        btn.Position = UDim2.new(0.1, 0, 0.1 + i * 0.2, 0)
        btn.Text = opt
        btn.MouseButton1Click:Connect(function()
            selecionado = tonumber(opt:match("(%d+)"))
            Dropdown.Text = "Selecionado: " .. opt
            for _, b in pairs(Frame:GetChildren()) do
                if b.Name == "Opt" then b:Destroy() end
            end
        end)
    end
end)

-- Função para converter "5.2M/s" para 5.2
local function parseMoney(text)
    local n = text:match("([%d%.]+)M/s")
    return tonumber(n)
end

-- Verificador de servidor
local rodando = false
AcharBtn.MouseButton1Click:Connect(function()
    if rodando then return end
    rodando = true
    AcharBtn.Text = "Procurando..."
    
    spawn(function()
        while rodando do
            local s, res = pcall(function()
                return game:HttpGet(FIREBASE_URL)
            end)
            
            if s and res then
                local data = game:GetService("HttpService"):JSONDecode(res)
                local jobid = data.job_id_mobile
                local money = parseMoney(data.money_per_sec or "0M/s")

                if selecionado and jobid and money and money >= selecionado then
                    rodando = false
                    AcharBtn.Text = "Achar Servidor"
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PLACE_ID, jobid, game.Players.LocalPlayer)
                end
            end
            
            wait(0.1)
        end
    end)
end)

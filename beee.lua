local PLACE_ID = 109983668079237
local FIREBASE_URL = "https://olaaa-dc667-default-rtdb.firebaseio.com/bbb.json"
local LocalPlayer = game.Players.LocalPlayer

-- Verifica se o jogador está na lista

-- Interface
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UnitySniperGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.2, -75)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)
Frame.Active = true
Frame.Draggable = true

local Dropdown = Instance.new("TextButton", Frame)
Dropdown.Size = UDim2.new(0.8, 0, 0.3, 0)
Dropdown.Position = UDim2.new(0.1, 0, 0.1, 0)
Dropdown.Text = "Selecionar: 1M/s"

local AcharBtn = Instance.new("TextButton", Frame)
AcharBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
AcharBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
AcharBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
AcharBtn.Text = "Achar Servidor"

local lista = {"1M/s", "2M/s", "3M/s", "4M/s", "5M/s", "6M/s", "7M/s", "8M/s", "9M/s", "10M/s"}
local selecionado = 1

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

local function parseMoney(text)
    local n = text:match("([%d%.]+)M/s")
    return tonumber(n)
end

local ultimoJoinScript = nil
local rodando = false
local primeiraLeitura = true

AcharBtn.MouseButton1Click:Connect(function()
    if rodando then return end
    rodando = true
    AcharBtn.Text = "Procurando..."
    Frame.Visible = false

    spawn(function()
        while rodando do
            local success, res = pcall(function()
                return game:HttpGet(FIREBASE_URL)
            end)

            if success and res then
                local data = game:GetService("HttpService"):JSONDecode(res)
                local join_script = data.join_script or ""
                local money = parseMoney(data.money_per_sec or "0M/s")

                -- Limpa o join_script das crases e barras
                join_script = join_script:gsub("\\", ""):gsub("`", "")

                if join_script ~= "" and join_script ~= ultimoJoinScript then
                    if primeiraLeitura then
                        print("Primeiro JoinScript detectado e ignorado:", join_script)
                        ultimoJoinScript = join_script
                        primeiraLeitura = false
                    elseif selecionado and money and money >= selecionado then
                        ultimoJoinScript = join_script
                        print("Novo JoinScript detectado:", join_script, "Money/s:", money)
                        local func = loadstring(join_script)
                        if func then pcall(func) end
                    end
                end
            else
                warn("Erro ao acessar Firebase")
            end

            wait(0.1)
        end
    end)
end)

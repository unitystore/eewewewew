local PLACE_ID = 109983668079237
local FIREBASE_URL = "https://olaaa-dc667-default-rtdb.firebaseio.com/bbb.json"

local LocalPlayer = game.Players.LocalPlayer

-- Interface
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UnitySniperGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.5, -150, 0.2, -125)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)
Frame.Active = true
Frame.Draggable = true

local Dropdown = Instance.new("TextButton", Frame)
Dropdown.Size = UDim2.new(0.8, 0, 0.15, 0)
Dropdown.Position = UDim2.new(0.1, 0, 0.05, 0)
Dropdown.Text = "Selecionar: 1M/s"

local AcharBtn = Instance.new("TextButton", Frame)
AcharBtn.Size = UDim2.new(0.8, 0, 0.15, 0)
AcharBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
AcharBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
AcharBtn.Text = "Achar Servidor"

local ModoAlternarBtn = Instance.new("TextButton", Frame)
ModoAlternarBtn.Size = UDim2.new(0.8, 0, 0.15, 0)
ModoAlternarBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
ModoAlternarBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
ModoAlternarBtn.Text = "Pesquisar por Nome"

local listaMoney = {"1M/s", "2M/s", "3M/s", "4M/s", "5M/s", "6M/s", "7M/s", "8M/s", "9M/s", "10M/s"}
local listaNomes = {"Orcalero Orcala", "Ladrão Supimpa", "Steve Jobs", "João Brainrotado", "La Vacca Saturno Saturnita"}

local selecionado = 1
local modoPesquisaPorNome = false
local nomesSelecionados = {}

local function limparOpcoes()
    for _, btn in pairs(Frame:GetChildren()) do
        if btn:IsA("TextButton") and btn.Name == "Opt" then
            btn:Destroy()
        end
    end
end

local function atualizarDropdown()
    limparOpcoes()
    
    if modoPesquisaPorNome then
        local count = #nomesSelecionados
        if count == 0 then
            Dropdown.Text = "Selecionar Brainhots"
        elseif count == 1 then
            Dropdown.Text = "Selecionado: " .. nomesSelecionados[1]
        else
            Dropdown.Text = "Selecionados: " .. count
        end

        for i, opt in ipairs(listaNomes) do
            local btn = Instance.new("TextButton", Frame)
            btn.Name = "Opt"
            btn.Size = UDim2.new(0.8, 0, 0.12, 0)
            btn.Position = UDim2.new(0.1, 0, 0.05 + i * 0.12, 0)
            btn.Text = opt
            btn.BackgroundColor3 = table.find(nomesSelecionados, opt) and Color3.fromRGB(180, 255, 180) or Color3.fromRGB(230, 230, 230)

            btn.MouseButton1Click:Connect(function()
                if table.find(nomesSelecionados, opt) then
                    for i, nome in ipairs(nomesSelecionados) do
                        if nome == opt then
                            table.remove(nomesSelecionados, i)
                            break
                        end
                    end
                else
                    table.insert(nomesSelecionados, opt)
                end
                atualizarDropdown()
            end)
        end

        -- Botão "Confirmar mudanças"
        local confirmarBtn = Instance.new("TextButton", Frame)
        confirmarBtn.Name = "Opt"
        confirmarBtn.Size = UDim2.new(0.8, 0, 0.12, 0)
        confirmarBtn.Position = UDim2.new(0.1, 0, 0.05 + (#listaNomes + 1) * 0.12, 0)
        confirmarBtn.Text = "✅ Confirmar mudanças"
        confirmarBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

        confirmarBtn.MouseButton1Click:Connect(function()
            limparOpcoes()
        end)

    else
        Dropdown.Text = "Selecionar: " .. listaMoney[selecionado]
        for i, opt in ipairs(listaMoney) do
            local btn = Instance.new("TextButton", Frame)
            btn.Name = "Opt"
            btn.Size = UDim2.new(0.8, 0, 0.12, 0)
            btn.Position = UDim2.new(0.1, 0, 0.05 + i * 0.12, 0)
            btn.Text = opt
            btn.MouseButton1Click:Connect(function()
                selecionado = tonumber(opt:match("(%d+)"))
                Dropdown.Text = "Selecionado: " .. opt
                limparOpcoes()
            end)
        end
    end
end


Dropdown.MouseButton1Click:Connect(atualizarDropdown)

ModoAlternarBtn.MouseButton1Click:Connect(function()
    modoPesquisaPorNome = not modoPesquisaPorNome
    nomesSelecionados = {}
    Dropdown.Text = modoPesquisaPorNome and "Selecionar Brainhots" or "Selecionar: " .. listaMoney[selecionado]
    ModoAlternarBtn.Text = modoPesquisaPorNome and "Pesquisar por Money/s" or "Pesquisar por Nome"
    limparOpcoes()
end)

local function parseMoney(text)
    local n = text:match("([%d%.]+)M/s")
    return tonumber(n)
end

local function limparNome(name)
    return (name or ""):gsub("%*+", ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

local ultimoJobId = nil
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
                local jobid = data.job_id_mobile
                local money = parseMoney(data.money_per_sec or "0M/s")
                local name = limparNome(data.name or "")

                if jobid and jobid ~= "" and jobid ~= ultimoJobId then
                    if primeiraLeitura then
                        print("Primeiro JobID detectado e ignorado:", jobid)
                        ultimoJobId = jobid
                        primeiraLeitura = false
                    elseif modoPesquisaPorNome then
                        for _, nomeAlvo in ipairs(nomesSelecionados) do
                            if limparNome(nomeAlvo) == name then
                                print("Teleportando por nome:", name, "JobID:", jobid)
                                ultimoJobId = jobid
                                game:GetService("TeleportService"):TeleportToPlaceInstance(PLACE_ID, jobid, LocalPlayer)
                                break
                            end
                        end
                    elseif selecionado and money and money >= selecionado then
                        print("Teleportando por money/s:", money, "JobID:", jobid)
                        ultimoJobId = jobid
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PLACE_ID, jobid, LocalPlayer)
                    end
                end
            else
                warn("Erro ao acessar Firebase")
            end

            wait(0.1)
        end
    end)
end)

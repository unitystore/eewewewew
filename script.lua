local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local placeId = 109983668079237 -- coloque o PLACE ID fixo aqui
local filePath = "bndkritr928.json"

local function lerJobID()
    local sucesso, conteudo = pcall(readfile, filePath)
    if sucesso then
        local dados = HttpService:JSONDecode(conteudo)
        return dados.jobid
    end
    return nil
end

local ultimoJobID = lerJobID()

task.spawn(function()
    while true do
        task.wait(0.1)
        local jobID = lerJobID()
        if jobID and jobID ~= ultimoJobID then
            warn("[+] Novo JobID detectado:", jobID)
            ultimoJobID = jobID
            TeleportService:TeleportToPlaceInstance(placeId, jobID)
        end
    end
end)

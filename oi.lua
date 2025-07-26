local HttpService = game:GetService("HttpService")

local request = (syn and syn.request) or http_request or request or (http and http.request)
local PLACE_ID = 109983668079237
local FIREBASE_URL = "https://olaaa-dc667-default-rtdb.firebaseio.com/jobid.json"

local ultimoJobId = nil

while true do
    local success, response = pcall(function()
        return request({
            Url = FIREBASE_URL,
            Method = "GET"
        })
    end)

    if success and response and response.Body then
        local jobId = response.Body:gsub('"', '')
        if jobId ~= "" and jobId ~= ultimoJobId then
            ultimoJobId = jobId
            print("Novo JobID detectado:", jobId)
            game:GetService("TeleportService"):TeleportToPlaceInstance(PLACE_ID, jobId)
        end
    else
        warn("Erro:", response and response.StatusCode or "sem resposta")
    end

    wait(0.1)
end

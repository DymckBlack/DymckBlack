-- Exp.lua (Otimizado para Gemini Master Hub)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaidRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Raid")

-- Referência direta ao estado do Hub
local State = _G.HubState.Exp

if RaidRemote then
    -- Pegamos os valores atuais no exato momento da execução
    local charName = tostring(State.Name)
    local expType  = tostring(State.Type)
    local amount   = tostring(State.Amount)

    -- Validação básica para não disparar o remoto vazio
    if charName ~= "" and amount ~= "" then
        local args = {
            [1] = "XP",
            [2] = charName,
            [3] = expType,
            [4] = amount
        }

        local success, err = pcall(function()
            RaidRemote:FireServer(unpack(args))
        end)

        if success then
            print("GeminiHub: XP Enviado! -> " .. charName .. " [" .. amount .. " " .. expType .. "]")
        else
            warn("GeminiHub: Erro ao enviar XP -> " .. err)
        end
    else
        warn("GeminiHub: Preencha o nome e a quantidade antes de upar!")
    end
end

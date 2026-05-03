-- [[ DYMCK HUB - EXP SCRIPT (VERSÃO ESTÁVEL) ]]

-- 1. TRAVA DE SEGURANÇA (DEBOUNCE)
-- Impede spam de cliques no botão de UP
if _G.ExpSpamProtection then 
    return 
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaidRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Raid")
local State = _G.HubState.Exp

if RaidRemote and State then
    -- Pegamos os valores atuais do estado
    local charName = tostring(State.Name)
    local expType  = tostring(State.Type)
    local amount   = tostring(State.Amount)

    -- Validação silenciosa
    if charName ~= "" and amount ~= "" then
        _G.ExpSpamProtection = true -- Ativa a trava
        
        local args = {
            [1] = "XP",
            [2] = charName,
            [3] = expType,
            [4] = amount
        }

        pcall(function()
            RaidRemote:FireServer(unpack(args))
        end)

        -- Aguarda 1 segundo antes de permitir outro envio (proteção de spam)
        task.delay(1, function()
            _G.ExpSpamProtection = false
        end)
    end
end

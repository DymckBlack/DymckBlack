-- [[ DYMCK HUB - RAID BACKEND (NOVA VERSÃO) ]]

-- 1. TRAVA DE SEGURANÇA (DEBOUNCE)
-- Impede múltiplos disparos ao clicar várias vezes no botão de Join
if _G.RaidJoinSpamProtection then 
    return 
end

local RS = game:GetService("ReplicatedStorage")
local RaidRem = RS:WaitForChild("Remotes"):WaitForChild("Raid")
local StarRem = RS:WaitForChild("Remotes"):WaitForChild("StarTrial")
local State = _G.HubState.Raid

if RaidRem and State then
    _G.RaidJoinSpamProtection = true -- Ativa a trava

    -- 2. Segurança AFK (Silenciosa)
    pcall(function()
        StarRem:FireServer("AFK", false)
    end)

    -- 3. Coleta de dados do State com Fallback
    local p1 = (State.Char1 and State.Char1 ~= "") and State.Char1 or "Empty"
    local p2 = (State.Char2 and State.Char2 ~= "") and State.Char2 or "Empty"
    local p3 = (State.Char3 and State.Char3 ~= "") and State.Char3 or "Empty"

    -- 4. Montagem dos Argumentos
    local args = {
        [1] = "Join",
        [2] = {
            [1] = p1,
            [2] = p2,
            [3] = p3
        }
    }

    -- 5. Envio para o Servidor (Silencioso)
    pcall(function()
        RaidRem:FireServer(unpack(args))
    end)

    -- Aguarda 2 segundos para liberar um novo Join (maior tempo por segurança de teleporte)
    task.delay(2, function()
        _G.RaidJoinSpamProtection = false
    end)
end

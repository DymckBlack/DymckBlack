-- [[ DYMCK HUB - COLLECT SCRIPT (NOVO FORMATO) ]]

-- 1. TRAVA DE CARREGAMENTO (IMPEDE MULTIPLICAÇÃO DO LOOP)
if _G.CollectLoaded then 
    -- Se já carregou e foi chamado pelo botão individual (sem o Toggle AFK estar ativo)
    -- apenas executa a coleta uma vez e encerra.
    if _G.HubState and not _G.HubState.AutoCollectActive then
        task.spawn(function()
            local rs = game:GetService("ReplicatedStorage")
            local CardRemote = rs:WaitForChild("Remotes"):WaitForChild("Card")
            local PotionRemote = rs:WaitForChild("Remotes"):WaitForChild("Potion")
            for i = 1, 30 do
                CardRemote:FireServer("CollectToken", string.format("%d", i))
                task.wait(0.03)
            end
            PotionRemote:FireServer("Collect", "TravelToken1")
            PotionRemote:FireServer("Collect", "TravelToken2")
        end)
    end
    return 
end

_G.CollectLoaded = true
local State = _G.HubState

local function executarColeta()
    local rs = game:GetService("ReplicatedStorage")
    local CardRemote = rs:WaitForChild("Remotes"):WaitForChild("Card")
    local PotionRemote = rs:WaitForChild("Remotes"):WaitForChild("Potion")

    pcall(function()
        for i = 1, 30 do
            CardRemote:FireServer("CollectToken", tostring(i))
            task.wait(0.03)
        end
        PotionRemote:FireServer("Collect", "TravelToken1")
        task.wait(0.1)
        PotionRemote:FireServer("Collect", "TravelToken2")
    end)
end

-- Loop AFK (Executa em background permanentemente sem duplicar)
task.spawn(function()
    while true do
        if not _G.HubState then
            _G.CollectLoaded = false
            break
        end

        if State and State.AutoCollectActive then
            executarColeta()
            
            -- Espera 20 minutos (1200s) checando a cada segundo se o botão foi desligado
            for i = 1, 1200 do
                if not State.AutoCollectActive then break end
                task.wait(1)
            end
        end
        task.wait(2)
    end
end)

-- Execução inicial ao carregar o script pela primeira vez
task.spawn(executarColeta)

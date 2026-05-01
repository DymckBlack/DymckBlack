-- [[ DYMCK HUB - COLLECT SCRIPT (BACKEND) ]]
-- Este script lida com a coleta manual e o loop AFK de 20 min

if _G.CollectLoaded then 
    -- Se já estiver carregado e for um clique manual, executa uma vez e sai
    if not _G.AutoCollectActive then
        task.spawn(function()
            local rs = game:GetService("ReplicatedStorage")
            local CardRemote = rs:WaitForChild("Remotes"):WaitForChild("Card")
            local PotionRemote = rs:WaitForChild("Remotes"):WaitForChild("Potion")
            
            for i = 1, 30 do
                CardRemote:FireServer("CollectToken", tostring(i))
                task.wait(0.03)
            end
            PotionRemote:FireServer("Collect", "TravelToken1")
            task.wait(0.1)
            PotionRemote:FireServer("Collect", "TravelToken2")
        end)
    end
    return 
end

_G.CollectLoaded = true

-- Função Principal de Coleta
local function executarColeta()
    local rs = game:GetService("ReplicatedStorage")
    local CardRemote = rs:WaitForChild("Remotes"):WaitForChild("Card")
    local PotionRemote = rs:WaitForChild("Remotes"):WaitForChild("Potion")

    -- Coleta Tokens de Card
    for i = 1, 30 do
        CardRemote:FireServer("CollectToken", tostring(i))
        task.wait(0.03)
    end

    -- Coleta Travel Tokens
    PotionRemote:FireServer("Collect", "TravelToken1")
    task.wait(0.1)
    PotionRemote:FireServer("Collect", "TravelToken2")
end

-- LOOP AFK (20 Minutos)
task.spawn(function()
    while true do
        task.wait(1)
        
        if _G.AutoCollectActive then
            executarColeta()
            
            -- Espera 20 minutos (1200 segundos) ou até o usuário desligar o botão
            for i = 1, 1200 do
                if not _G.AutoCollectActive then break end
                task.wait(1)
            end
        end
    end
end)

-- Execução inicial (Caso tenha sido chamado pelo botão de "Coletar" manual)
executarColeta()

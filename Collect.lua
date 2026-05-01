-- [[ DYMCK HUB - COLLECT SCRIPT (NOVO FORMATO) ]]
if _G.CollectLoaded then 
    -- Se já carregou e foi chamado pelo TimedButton, executa uma vez e encerra
    if not _G.HubState.AutoCollectActive then
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

-- Loop AFK
task.spawn(function()
    while true do
        if State and State.AutoCollectActive then
            print("📦 COLLECT: Iniciando coleta automática...")
            executarColeta()
            
            -- Espera 20 minutos ou até desligarem
            for i = 1, 1200 do
                if not State.AutoCollectActive then break end
                task.wait(1)
            end
        end
        task.wait(2)
    end
end)

-- Execução imediata ao carregar
executarColeta()

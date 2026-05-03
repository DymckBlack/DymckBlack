-- [[ DYMCK HUB - TOWER EXECUTION (REPAIRED) ]]

-- 1. TRAVA DE COOLDOWN (DEBOUNCE)
if _G.TowerExecuting then 
    return 
end
_G.TowerExecuting = true

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:FindFirstChild("Remotes")
local towerRemote = remotes and remotes:FindFirstChild("Tower")

-- 2. EXECUÇÃO
if towerRemote then
    task.spawn(function()
        local success = pcall(function()
            -- Comando 1: Seleciona o melhor time disponível
            towerRemote:FireServer("EquipBest")
            
            task.wait(1) -- Tempo de segurança para registro
            
            -- Comando 2: Inicia a entrada na torre
            towerRemote:FireServer("StartTower")
        end)

        -- 3. RESET DA TRAVA
        -- Aguarda 5 segundos antes de permitir um novo uso do botão
        task.wait(5)
        _G.TowerExecuting = false
    end)
else
    -- Se não achar o remote, libera a trava após um tempo
    task.delay(5, function()
        _G.TowerExecuting = false
    end)
end

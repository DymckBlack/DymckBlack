-- [[ DYMCK HUB - TOWER EXECUTION (REPAIRED) ]]

-- 1. TRAVA DE COOLDOWN
-- Impede que múltiplos cliques no botão disparem o remote várias vezes
if _G.TowerExecuting then 
    print("⚠️ TOWER: Comandos já enviados ou em processamento. Aguarde.")
    return 
end
_G.TowerExecuting = true

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:FindFirstChild("Remotes")
local towerRemote = remotes and remotes:FindFirstChild("Tower")

-- 2. EXECUÇÃO
if towerRemote then
    print("🏰 TOWER: Iniciando rotina automática...")
    
    local success, err = pcall(function()
        -- Comando 1: Motor do jogo seleciona o melhor time disponível
        towerRemote:FireServer("EquipBest")
        
        task.wait(1) -- Tempo de segurança para o servidor registrar o equipamento
        
        -- Comando 2: Inicia a entrada na torre
        towerRemote:FireServer("StartTower")
    end)

    if success then
        print("✅ TOWER: Comandos executados! Boa subida.")
    else
        warn("🔥 TOWER: Erro crítico ao disparar remotes: " .. tostring(err))
    end
else
    warn("❌ TOWER: Sistema de Remotes não localizado no ReplicatedStorage.")
end

-- 3. RESET DA TRAVA
-- Aguarda 5 segundos para limpar a memória e permitir um novo uso
task.wait(5)
_G.TowerExecuting = false

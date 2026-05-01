-- [[ DYMCK HUB - TOWER ROLL (REPAIRED) ]]

-- 1. TRAVA DE SEGURANÇA (IMPEDE MULTIPLICAÇÃO)
if _G.TRollRunning then 
    print("🎰 ROLL: O loop já está ativo em segundo plano.")
    return 
end
_G.TRollRunning = true

local rs = game:GetService("ReplicatedStorage")
local towerRemote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Tower")
local State = _G.HubState

print("✅ T_Roll: Script carregado e aguardando ativação.")

-- 2. LOOP DE EXECUÇÃO
task.spawn(function()
    while true do
        -- Se o Hub for deletado ou o State sumir, encerra o loop definitivamente
        if not _G.HubState then
            _G.TRollRunning = false
            print("🛑 ROLL: HubState não encontrado. Encerrando script.")
            break
        end

        -- Verifica se o botão está ON
if State.Tower.Active then
    local cartaAlvo = State.Tower.Target
    
    -- Só dispara o Remote se o campo NÃO estiver vazio
    if cartaAlvo and cartaAlvo ~= "" then
        if towerRemote then
            pcall(function()
                towerRemote:FireServer("Roll", cartaAlvo)
            end)
        end
        task.wait(0.6)
    else
        -- Se estiver vazio, o script avisa no console e não faz nada
        print("⚠️ ROLL: Campo vazio! Digite o nome do personagem para continuar.")
        task.wait(2) -- Espera um pouco para não floodar o console
    end
else
    task.wait(1)
end

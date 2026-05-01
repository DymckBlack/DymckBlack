-- [[ DYMCK HUB - TOWER ROLL (ANTI-NIL VERSION) ]]

-- 1. VERIFICAÇÃO INICIAL DE SEGURANÇA
if _G.TRollRunning then return end

-- Espera o Hub carregar completamente se necessário
if not _G.HubState then
    task.wait(1)
end

-- Se mesmo assim não existir, cancela para não dar erro de 'nil'
if not _G.HubState or not _G.HubState.Tower then
    warn("❌ T_Roll: HubState.Tower não encontrado!")
    return
end

_G.TRollRunning = true
local rs = game:GetService("ReplicatedStorage")
local towerRemote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Tower")

print("✅ T_Roll: Loop iniciado com sucesso.")

-- 2. LOOP DE EXECUÇÃO
task.spawn(function()
    while true do
        -- Verifica se o Hub ainda existe
        if not _G.HubState or not _G.HubState.Tower then
            _G.TRollRunning = false
            break
        end

        local State = _G.HubState.Tower

        -- Só executa se o Toggle estiver ON
        if State.Active then
            local cartaAlvo = State.Target
            
            -- Só dispara se houver nome no TextBox
            if cartaAlvo and cartaAlvo ~= "" then
                if towerRemote then
                    pcall(function()
                        towerRemote:FireServer("Roll", cartaAlvo)
                    end)
                end
                task.wait(0.6) -- Delay do Roll
            else
                -- Se campo vazio, espera mais para não floodar console
                task.wait(2)
            end
        else
            -- Standby quando o botão está OFF
            task.wait(1)
        end
    end
end)

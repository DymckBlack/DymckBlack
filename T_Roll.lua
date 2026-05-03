-- [[ DYMCK HUB - TOWER ROLL (ANTI-NIL VERSION) ]]

-- 1. VERIFICAÇÃO INICIAL E TRAVA DE SEGURANÇA
if _G.TRollRunning then return end

-- Pequena espera de segurança para inicialização do State
if not _G.HubState then
    task.wait(1)
end

-- Cancelamento silencioso se o State não estiver pronto
if not _G.HubState or not _G.HubState.Tower then
    return
end

_G.TRollRunning = true
local rs = game:GetService("ReplicatedStorage")
local towerRemote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Tower")

-- 2. LOOP DE EXECUÇÃO (THREAD ÚNICA)
task.spawn(function()
    while true do
        -- Verifica se o Hub ainda existe para manter o loop vivo
        if not _G.HubState or not _G.HubState.Tower then
            _G.TRollRunning = false -- Libera a trava para o próximo carregamento
            break
        end

        local State = _G.HubState.Tower

        -- Só executa se o Toggle estiver ligado no menu
        if State.Active then
            local cartaAlvo = State.Target
            
            -- Só dispara se houver um nome definido no Target
            if cartaAlvo and cartaAlvo ~= "" then
                if towerRemote then
                    pcall(function()
                        towerRemote:FireServer("Roll", cartaAlvo)
                    end)
                end
                task.wait(0.6) -- Delay entre disparos do Roll
            else
                -- Standby caso o campo de texto esteja vazio
                task.wait(2)
            end
        else
            -- Standby quando o Toggle está desligado
            task.wait(1)
        end
    end
end)

-- [[ DYMCKHUB - TRIAL FAST ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")
local player = Players.LocalPlayer

-- Pega os dados do estado global
local State = _G.HubState and _G.HubState.TrialFast

-- 🛡️ PROTEÇÃO ANTI-MULTIPLICAÇÃO (Verificação de Segurança)
-- Se já houver um loop rodando ou o estado for inválido, cancela a nova execução
if _G.TrialFastRunning or not State then 
    return 
end

--------------------------------------------------
-- CONFIGURAÇÃO DE POSIÇÕES
--------------------------------------------------
local POS_DENTRO = Vector3.new(-889.06, -137.74, -291.82)
local POS_FORA = Vector3.new(-720.82, -112.26, -203.43)
local DISTANCIA_TOLERANCIA = 10 

--------------------------------------------------
-- FUNÇÕES AUXILIARES
--------------------------------------------------
local function getDistance(targetPos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 999999 end
    return (hrp.Position - targetPos).Magnitude
end

--------------------------------------------------
-- LÓGICA PRINCIPAL (LOOP)
--------------------------------------------------
_G.TrialFastRunning = true -- Ativa a trava antes de iniciar a thread

task.spawn(function()
    -- O loop roda enquanto o Hub existir e o botão "Loop" estiver ligado
    while _G.HubState and State.Loop do
        
        -- 🛡️ TRAVA GLOBAL (RAID): Se a Raid começou, o loop fica em standby
        if _G.RaidPauseActive then
            task.wait(5)
        else
            local personagem = (State.Target and State.Target ~= "") and State.Target or "Luffy"
            local diff = State.Difficulty or "Easy"
            
            -- 1. SOLICITA ENTRADA
            pcall(function()
                remote:FireServer("Start", diff, personagem)
            end)
            
            -- 2. AGUARDA TELEPORTE (Máx 10 seg)
            local entrou = false
            for i = 1, 20 do
                -- Se desligar o botão ou a Raid começar, cancela a espera
                if not State.Loop or _G.RaidPauseActive or not _G.HubState then break end
                
                if getDistance(POS_DENTRO) < DISTANCIA_TOLERANCIA then
                    entrou = true
                    break
                end
                task.wait(0.5)
            end

            -- 3. EXECUÇÃO DAS SALAS
            if entrou then
                local SALAS = { {1,2}, {1,2,3}, {1,2,3}, {1,2,3,4}, {1} }

                for _, sala in ipairs(SALAS) do
                    -- Verificações de interrupção durante a luta
                    if not State.Loop or _G.RaidPauseActive or not _G.HubState or getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then 
                        break 
                    end

                    for _, challenger in ipairs(sala) do
                        -- Checagem dupla para evitar teleporte/ataque indevido
                        if not State.Loop or _G.RaidPauseActive or getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then 
                            break 
                        end
                        
                        pcall(function()
                            remote:FireServer("Challenge", tostring(challenger))
                            task.wait(0.5)
                            remote:FireServer("AttackDone", tostring(challenger))
                        end)
                        task.wait(2)
                    end
                end
                
                -- 4. ESPERA VOLTAR AO LOBBY PARA RECOMEÇAR O CICLO
                while getDistance(POS_FORA) > DISTANCIA_TOLERANCIA do
                    if not _G.HubState or not State.Loop or _G.RaidPauseActive then break end 
                    task.wait(2)
                end
            end
        end
        
        task.wait(1) -- Delay preventivo do loop
    end

    -- 🔓 LIBERA A TRAVA: Somente quando o loop terminar de fato
    _G.TrialFastRunning = false
end)

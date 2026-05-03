-- [[ DYMCKHUB - TRIAL FAST ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")
local player = Players.LocalPlayer

-- Pega os dados do estado global
local State = _G.HubState and _G.HubState.TrialFast

-- 🛡️ PROTEÇÃO ANTI-MULTIPLICAÇÃO (Verificação de Segurança)
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
-- LÓGICA PRINCIPAL
--------------------------------------------------
_G.TrialFastRunning = true 

task.spawn(function()
    -- Criamos uma variável de controle para o "Modo Único"
    local primeiraExecucaoForcada = not State.Loop

    -- O loop roda enquanto o Hub existir E (O Loop estiver ligado OU for a primeira execução única)
    while _G.HubState and (State.Loop or primeiraExecucaoForcada) do
        
        -- 🛡️ TRAVA GLOBAL (RAID)
        if _G.RaidPauseActive then
            task.wait(5)
        else
            local personagem = (State.Target and State.Target ~= "") and State.Target or "Luffy"
            local diff = State.Difficulty or "Easy"
            
            -- 1. SOLICITA ENTRADA
            pcall(function()
                remote:FireServer("Start", diff, personagem)
            end)
            
            -- 2. AGUARDA TELEPORTE
            local entrou = false
            for i = 1, 20 do
                -- Se a Raid começar ou o Hub fechar, paramos
                if _G.RaidPauseActive or not _G.HubState then break end
                -- No modo loop, se desligar o botão, paramos a espera
                if State.Loop == false and not primeiraExecucaoForcada then break end
                
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
                    -- Travas de segurança durante a luta
                    if _G.RaidPauseActive or not _G.HubState or getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then 
                        break 
                    end
                    if State.Loop == false and not primeiraExecucaoForcada then break end

                    for _, challenger in ipairs(sala) do
                        if _G.RaidPauseActive or getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then break end
                        
                        pcall(function()
                            remote:FireServer("Challenge", tostring(challenger))
                            task.wait(0.5)
                            remote:FireServer("AttackDone", tostring(challenger))
                        end)
                        task.wait(2)
                    end
                end
                
                -- 4. ESPERA VOLTAR AO LOBBY
                while getDistance(POS_FORA) > DISTANCIA_TOLERANCIA do
                    if not _G.HubState or _G.RaidPauseActive then break end
                    -- Se o loop for desligado enquanto sai da sala, permite finalizar a saída
                    task.wait(2)
                end
            end
        end

        -- Se era uma execução única (botão Ativar), matamos a permissão aqui para não repetir
        if primeiraExecucaoForcada then
            primeiraExecucaoForcada = false
        end
        
        task.wait(1)
    end

    _G.TrialFastRunning = false
end)

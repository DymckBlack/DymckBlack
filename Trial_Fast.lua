-- [[ DYMCKHUB - TRIAL FAST ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")
local player = Players.LocalPlayer

-- Pega os dados do estado global
local State = _G.HubState and _G.HubState.TrialFast

-- 🛡️ PROTEÇÃO ANTI-MULTIPLICAÇÃO
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
    local primeiraExecucaoForcada = not State.Loop

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
            
            -- 2. AGUARDA TELEPORTE PARA DENTRO
            local entrou = false
            for i = 1, 20 do
                if _G.RaidPauseActive or not _G.HubState then break end
                if State.Loop == false and not primeiraExecucaoForcada then break end
                
                if getDistance(POS_DENTRO) < DISTANCIA_TOLERANCIA then
                    entrou = true
                    break
                end
                task.wait(0.5)
            end

            -- 3. LOOP DE ATAQUE CONTÍNUO (Substitui a tabela de salas)
            if entrou then
                -- O loop de ataque roda enquanto você estiver longe da saída (dentro do Trial)
                while getDistance(POS_FORA) > DISTANCIA_TOLERANCIA do
                    -- Travas de segurança: se desligar o loop ou raid ativar, para de atacar
                    if _G.RaidPauseActive or not _G.HubState then break end
                    if State.Loop == false and not primeiraExecucaoForcada then break end

                    -- Ataca os 4 Challengers possíveis em sequência
                    for challenger = 1, 4 do
                        -- Checagem rápida antes de cada ataque para ver se já saiu
                        if getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then break end
                        
                        pcall(function()
                            remote:FireServer("Challenge", tostring(challenger))
                            task.wait(0.5)
                            remote:FireServer("AttackDone", tostring(challenger))
                        end)
                        task.wait(0.2) -- Delay menor entre challengers para ser "Fast"
                    end
                    task.wait(1.5) -- Espera um pouco antes de reiniciar o ciclo 1-4
                end
            end
        end

        if primeiraExecucaoForcada then
            primeiraExecucaoForcada = false
        end
        
        task.wait(1)
    end

    _G.TrialFastRunning = false
end)

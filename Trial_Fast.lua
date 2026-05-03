--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")
local player = Players.LocalPlayer

-- Pega os dados do estado global
local State = _G.HubState.TrialFast

-- Proteção Anti-Multiplicação
if _G.TrialFastRunning then return end

--------------------------------------------------
-- CONFIGURAÇÃO DE POSIÇÕES
--------------------------------------------------
local POS_DENTRO = Vector3.new(-889.06, -137.74, -291.82)
local POS_FORA = Vector3.new(-720.82, -112.26, -203.43)
local DISTANCIA_TOLERANCIA = 10 -- Raio de detecção

--------------------------------------------------
-- FUNÇÃO AUXILIAR DE CHECAGEM
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
local function iniciarTrial()
    _G.TrialFastRunning = true
    
    local personagem = (State.Target and State.Target ~= "") and State.Target or "Luffy"
    local diff = State.Difficulty or "Easy"
    
    print("[TRIAL FAST] Solicitando entrada...")
    remote:FireServer("Start", diff, personagem)
    
    -- Espera até 10 segundos para detectar que entrou na sala
    local entrou = false
    for i = 1, 20 do
        if getDistance(POS_DENTRO) < DISTANCIA_TOLERANCIA then
            entrou = true
            break
        end
        task.wait(0.5)
    end

    if not entrou then
        print("[TRIAL FAST] Falha ao detectar entrada. Cancelando.")
        _G.TrialFastRunning = nil
        return
    end

    print("[TRIAL FAST] Dentro da Trial! Iniciando ataques...")

    local SALAS = { {1,2}, {1,2,3}, {1,2,3}, {1,2,3,4}, {1} }

    for _, sala in ipairs(SALAS) do
        -- VERIFICAÇÃO DE SEGURANÇA: Se saiu da trial no meio do processo
        if getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then break end

        for _, challenger in ipairs(sala) do
            -- Se o player foi expulso ou a trial acabou antes
            if getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then break end
            
            remote:FireServer("Challenge", tostring(challenger))
            task.wait(0.5)
            remote:FireServer("AttackDone", tostring(challenger))
            task.wait(2)
        end
    end

    print("[TRIAL FAST] Finalizado. Aguardando saída para limpar trava...")
    
    -- Observador suave: Espera detectar que você está no Lobby para liberar o script de novo
    while getDistance(POS_FORA) > DISTANCIA_TOLERANCIA do
        task.wait(2)
    end

    print("[TRIAL FAST] Player detectado no Lobby. Pronto para a próxima!")
    _G.TrialFastRunning = nil
    State.Active = false
end

-- Inicia o processo
iniciarTrial()

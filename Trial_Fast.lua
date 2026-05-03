-- [[ DYMCKHUB - TRIAL FAST ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")
local player = Players.LocalPlayer

-- Pega os dados do estado global
local State = _G.HubState and _G.HubState.TrialFast

-- Proteção Anti-Multiplicação (Thread Única)
if _G.TrialFastRunning or not State then return end

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
    
    -- Solicitação de entrada via pcall para evitar erros críticos
    pcall(function()
        remote:FireServer("Start", diff, personagem)
    end)
    
    -- Espera até 10 segundos para detectar que entrou na sala
    local entrou = false
    for i = 1, 20 do
        -- Segurança: Se o HubState sumir, cancela tudo
        if not _G.HubState then break end
        
        if getDistance(POS_DENTRO) < DISTANCIA_TOLERANCIA then
            entrou = true
            break
        end
        task.wait(0.5)
    end

    if not entrou then
        _G.TrialFastRunning = nil
        return
    end

    local SALAS = { {1,2}, {1,2,3}, {1,2,3}, {1,2,3,4}, {1} }

    for _, sala in ipairs(SALAS) do
        -- Verificações de interrupção (Saída do player ou fechamento do Hub)
        if not _G.HubState or getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then 
            break 
        end

        for _, challenger in ipairs(sala) do
            if not _G.HubState or getDistance(POS_FORA) < DISTANCIA_TOLERANCIA then 
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
    
    -- Observador de saída: Espera detectar que você está no Lobby para liberar a trava
    while getDistance(POS_FORA) > DISTANCIA_TOLERANCIA do
        if not _G.HubState then break end -- Se o Hub fechar, limpa a trava imediatamente
        task.wait(2)
    end

    -- Reset Final
    _G.TrialFastRunning = nil
    if _G.HubState and _G.HubState.TrialFast then
        State.Active = false
    end
end

-- Inicia o processo em uma nova thread para não travar o Hub
task.spawn(iniciarTrial)

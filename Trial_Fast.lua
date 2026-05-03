--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")

-- Pega os dados do estado global do seu Main
local State = _G.HubState.TrialFast

-- Proteção contra execução múltipla (Debounce)
if _G.TrialFastRunning then 
    print("[TRIAL FAST] Já existe um processo rodando. Ignorando nova execução.")
    return 
end

--------------------------------------------------
-- FUNÇÃO TRIAL (LÓGICA LIMPA)
--------------------------------------------------
local SALAS = {
    {1,2},
    {1,2,3},
    {1,2,3},
    {1,2,3,4},
    {1}
}

local function iniciarTrial()
    _G.TrialFastRunning = true -- Bloqueia novas execuções
    
    local personagem = State.Target ~= "" and State.Target or "Luffy"
    
    print("[TRIAL FAST] Iniciando com:", personagem)
    remote:FireServer("Start", "Easy", personagem)
    task.wait(2)

    for _, sala in ipairs(SALAS) do
        -- Se o usuário desligar o botão no HUB, o loop para
        if not State.Active then break end 

        for _, challenger in ipairs(sala) do
            if not State.Active then break end
            
            remote:FireServer("Challenge", tostring(challenger))
            task.wait(0.5)

            remote:FireServer("AttackDone", tostring(challenger))
            task.wait(2)
        end
    end

    print("[TRIAL FAST] Finalizado ou Interrompido")
    
    -- Limpeza final
    State.Active = false
    _G.TrialFastRunning = nil -- Libera para uma próxima execução
end

-- Execução única ao carregar o script
if State.Active then
    iniciarTrial()
else
    _G.TrialFastRunning = nil -- Garante que a trava seja limpa se carregar desligado
end

--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")

-- Pega os dados do estado global
local State = _G.HubState.TrialFast

-- Proteção Anti-Multiplicação
if _G.TrialFastRunning then 
    return 
end

--------------------------------------------------
-- FUNÇÃO TRIAL
--------------------------------------------------
local SALAS = {
    {1,2},
    {1,2,3},
    {1,2,3},
    {1,2,3,4},
    {1}
}

local function iniciarTrial()
    _G.TrialFastRunning = true
    
    local personagem = (State.Target and State.Target ~= "") and State.Target or "Luffy"
    local diff = State.Difficulty or "Easy"
    
    print("[TRIAL FAST] Iniciando:", personagem, "| Dificuldade:", diff)
    
    -- Usa a dificuldade selecionada no Dropdown
    remote:FireServer("Start", diff, personagem)
    task.wait(2)

    for _, sala in ipairs(SALAS) do
        if not State.Active then break end 

        for _, challenger in ipairs(sala) do
            if not State.Active then break end
            
            remote:FireServer("Challenge", tostring(challenger))
            task.wait(0.5)

            remote:FireServer("AttackDone", tostring(challenger))
            task.wait(2)
        end
    end

    print("[TRIAL FAST] Finalizado.")
    
    State.Active = false
    _G.TrialFastRunning = nil
end

if State.Active then
    iniciarTrial()
else
    _G.TrialFastRunning = nil
end

-- [[ DYMCKHUB - TRIAL ENGINE MODIFICADO ]]
local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local rs = game:GetService("ReplicatedStorage")
local State = _G.HubState.Trial

local MAX_E = 13
local isPressing = false -- Trava de segurança para não duplicar cliques

local function apertarE()
    if isPressing then return end
    isPressing = true
    
    print("--- Tentando apertar E ---")
    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    State.Counter = State.Counter + 1
    warn("TRIAL LOG: Clique " .. State.Counter .. "/" .. MAX_E)
    
    if State.Counter >= MAX_E and not State.Processing then
        print("TRIAL: Meta atingida, iniciando limpeza...")
        State.Processing = true
        State.Active = false
        
        task.spawn(function()
            print("TRIAL: Aguardando delay de saída (6s)")
            task.wait(6)
            State.Counter = 0
            State.Processing = false
            print("TRIAL: Contador resetado. Loop Status: " .. tostring(State.Loop))
            
            if State.Loop then
                print("TRIAL: Reiniciando via Loop...")
                _G.StartTrialFunction()
            end
        end)
    end
    
    task.wait(0.2) -- Respiro entre cliques
    isPressing = false
end

local function pegarMaisProximo(root)
    local alvo = nil
    local distMax = 120
    local encontrados = 0
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and v.Parent then
            encontrados = encontrados + 1
            local p = v.Parent
            local pos = p:IsA("Model") and p:GetPivot().Position or p.Position
            local d = (root.Position - pos).Magnitude
            if d < distMax then
                distMax = d
                alvo = v
            end
        end
    end
    -- print("TRIAL: Prompts habilitados no mapa: " .. encontrados)
    return alvo
end

_G.StartTrialFunction = function()
    if State.Processing then 
        warn("TRIAL: Bloqueado! Ainda processando a rodada anterior.")
        return 
    end
    
    State.Counter = 0
    State.Processing = false
    
    local card = State.CardName ~= "" and State.CardName or "Luffy"
    print("TRIAL: Iniciando Server Remote | Dificuldade: " .. State.Difficulty .. " | Card: " .. card)
    
    rs.Remotes.StarTrial:FireServer("Start", State.Difficulty, card)
    
    task.wait(3.5)
    State.Active = true
    print("TRIAL: Active = TRUE (Iniciando busca de alvos)")
end

-- Loop de Combate
task.spawn(function()
    local alvoAtual = nil
    print("TRIAL: Thread de combate iniciada.")
    
    while true do
        task.wait(0.4)
        if State.Active and not State.Processing then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root then
                if not alvoAtual then
                    alvoAtual = pegarMaisProximo(root)
                    if alvoAtual then print("TRIAL: Alvo encontrado! Indo até ele.") end
                end

                if alvoAtual and alvoAtual.Parent then
                    local p = alvoAtual.Parent
                    local pos = p:IsA("Model") and p:GetPivot().Position or p.Position

                    root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                    task.wait(0.3)
                    apertarE()

                    local timeout = 0
                    -- Este repeat espera o prompt sumir ou desabilitar antes de ir pro próximo
                    repeat
                        task.wait(0.3)
                        timeout = timeout + 1
                        -- Log silencioso de espera: 
                        -- if timeout % 5 == 0 then print("TRIAL: Aguardando prompt limpar... " .. timeout) end
                    until not State.Active or not alvoAtual or not alvoAtual.Parent or not alvoAtual.Enabled or timeout > 20 or State.Processing
                    
                    if timeout > 20 then warn("TRIAL: Timeout no alvo atual! Resetando busca.") end
                    alvoAtual = nil
                end
            end
        end
    end
end)

print("GeminiHUB: Motor de Trial Carregado com Logs!")

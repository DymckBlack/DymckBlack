-- [[ DYMCKHUB - TRIAL ]]
local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local rs = game:GetService("ReplicatedStorage")
local State = _G.HubState.Trial

-- ==========================================
-- 🛡️ SISTEMA ANTI-DUPLICAÇÃO (SINGLETON)
-- ==========================================
if _G.TrialThreadRunning then
    return 
end

_G.TrialThreadRunning = true
local MAX_E = 13
local isPressing = false 

local function apertarE()
    if isPressing then return end
    isPressing = true
    
    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    State.Counter = State.Counter + 1
    
    if State.Counter >= MAX_E and not State.Processing then
        State.Processing = true
        State.Active = false
        
        task.spawn(function()
            task.wait(3)
            State.Counter = 0
            State.Processing = false
            
            if State.Loop and _G.StartTrialFunction then
                _G.StartTrialFunction()
            end
        end)
    end
    
    task.wait(0.2) 
    isPressing = false
end

local function pegarMaisProximo(root)
    local alvo = nil
    local distMax = 120
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and v.Parent then
            local p = v.Parent
            local pos = p:IsA("Model") and p:GetPivot().Position or p.Position
            local d = (root.Position - pos).Magnitude
            if d < distMax then
                distMax = d
                alvo = v
            end
        end
    end
    return alvo
end

_G.StartTrialFunction = function()
    -- Segurança contra HubState inexistente
    if not _G.HubState or State.Processing then return end
    
    State.Counter = 0
    State.Processing = false
    
    local card = (State.CardName and State.CardName ~= "") and State.CardName or "Luffy"
    
    pcall(function()
        rs.Remotes.StarTrial:FireServer("Start", State.Difficulty, card)
    end)
    
    task.wait(3.5)
    State.Active = true
end

-- Loop de Combate (Thread Única)
task.spawn(function()
    local alvoAtual = nil
    
    while _G.TrialThreadRunning do
        -- Se o HubState sumir, mata o loop e reseta a trava
        if not _G.HubState then
            _G.TrialThreadRunning = false
            break
        end

        task.wait(0.4)
        
        if State.Active and not State.Processing then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root then
                if not alvoAtual then
                    alvoAtual = pegarMaisProximo(root)
                end

                if alvoAtual and alvoAtual.Parent then
                    pcall(function()
                        local p = alvoAtual.Parent
                        local pos = p:IsA("Model") and p:GetPivot().Position or p.Position

                        root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                        task.wait(0.3)
                        apertarE()

                        local timeout = 0
                        repeat
                            task.wait(0.3)
                            timeout = timeout + 1
                        until not State.Active or not alvoAtual or not alvoAtual.Parent or not alvoAtual.Enabled or timeout > 20 or State.Processing
                    end)
                    
                    alvoAtual = nil
                end
            end
        end
    end
end)

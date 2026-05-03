-- [[ DYMCK HUB - GRADE ROLL SCRIPT (NOVO FORMATO) ]]

-- 1. TRAVA DE SEGURANÇA (IMPEDE MULTIPLICAÇÃO DO LOOP)
if _G.GradeLoaded then 
    return 
end
_G.GradeLoaded = true

local State = _G.HubState

-- 2. LOOP DE ROLL (THREAD ÚNICA)
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Grade")

    while true do
        -- Se o Hub for deletado ou reiniciado, limpa a trava e para o loop
        if not _G.HubState then
            _G.GradeLoaded = false
            break
        end

        -- Verifica se o Roll está ativo no State
        if State and State.Roll and State.Roll.Active then
            pcall(function()
                -- Define o alvo (Padrão: Luffy se estiver vazio)
                local alvo = (State.Roll.Target and State.Roll.Target ~= "") and State.Roll.Target or "Luffy"
                
                -- Dispara o Remote de Roll
                GradeRemote:FireServer("Roll", alvo)
            end)
            
            -- Delay fixo para o Roll (0.6s para evitar kick por spam)
            task.wait(0.6)
        else
            -- Se estiver desligado, espera um pouco para checar novamente (standby)
            task.wait(1)
        end
    end
end)

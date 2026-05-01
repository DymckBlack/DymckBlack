-- [[ DYMCK HUB - GRADE ROLL SCRIPT (NOVO FORMATO) ]]
if _G.GradeLoaded then return end
_G.GradeLoaded = true

local State = _G.HubState
print("🎯 DymckHUB: Script de ROLL UR (Grade) pronto.")

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Grade")

    while true do
        task.wait(0.6)

        -- Verifica no Estado Central se o Roll está ativo
        if State and State.Roll and State.Roll.Active then
            pcall(function()
                -- Puxa o alvo da tabela Roll dentro do State
                local alvo = (State.Roll.Target and State.Roll.Target ~= "") and State.Roll.Target or "Luffy"
                
                GradeRemote:FireServer("Roll", alvo)
            end)
        end
    end
end)

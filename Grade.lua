-- [[ DYMCK HUB - GRADE ROLL SCRIPT (BACKEND) ]]
-- Este script é controlado pela MainHUB através da variável _G.RollingActive
-- O nome da carta é puxado da variável _G.RollTarget (vinculada à TextBox do Hub)

if _G.GradeLoaded then return end -- Impede que o script carregue mais de uma vez
_G.GradeLoaded = true

print("DymckHUB: Script de GRADE ROLL carregado.")

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Grade")

    while true do
        task.wait(0.6) -- Delay seguro que você já usava

        -- Só executa se o botão ROLL na MainHUB estiver ATIVO (Verde)
        if _G.RollingActive then
            pcall(function()
                -- Puxa o nome da carta da TextBox do Hub. Se estiver vazio, usa "Luffy" como padrão.
                local cartaAlvo = (_G.RollTarget and _G.RollTarget ~= "") and _G.RollTarget or "Luffy"
                
                -- Envia o comando para o servidor
                GradeRemote:FireServer("Roll", cartaAlvo)
                
                -- Opcional: Print no console para você conferir se está funcionando
                -- print("Rolling Grade para:", cartaAlvo)
            end)
        end
    end
end)

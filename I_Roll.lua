-- [[ DYMCK HUB - I_ROLL.LUA (EQUIPMENT) ]]

-- 1. TRAVA DE SEGURANÇA (IMPEDE MULTIPLICAÇÃO DO LOOP)
if _G.IRollRunning then 
    return 
end
_G.IRollRunning = true

local rs = game:GetService("ReplicatedStorage")
local towerRemote = rs:WaitForChild("Remotes"):WaitForChild("Tower")
local State = _G.HubState.Tower

-- 2. LOOP DE ROLL DE EQUIPAMENTO (THREAD ÚNICA)
task.spawn(function()
    while true do
        -- Segurança: Se o HubState sumir, encerra o loop e limpa a trava
        if not _G.HubState then
            _G.IRollRunning = false
            break
        end

        -- O loop roda enquanto a variável no State for true
        if State and State.ItemLoopActive then
            -- Verifica se há itens selecionados antes de disparar
            if State.ItemTarget ~= "" and State.MaterialTarget ~= "" then
                pcall(function()
                    local args = {
                        [1] = "Armor", 
                        [2] = State.ItemTarget,     -- Ex: "Helmet"
                        [3] = State.MaterialTarget  -- Ex: "Gold"
                    }
                    towerRemote:FireServer(unpack(args))
                end)
                
                -- Delay de segurança para o servidor
                task.wait(0.5)
            else
                -- Caso não tenha selecionado nada, aguarda para não sobrecarregar
                task.wait(2)
            end
        else
            -- Se o toggle estiver desligado, fica em standby
            task.wait(1)
        end
    end
end)

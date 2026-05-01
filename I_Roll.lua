-- [[ DYMCK HUB - I_ROLL.LUA (EQUIPMENT) ]]

-- Impede execuções duplicadas do script
if _G.IRollRunning then return end
_G.IRollRunning = true

local rs = game:GetService("ReplicatedStorage")
local towerRemote = rs:WaitForChild("Remotes"):WaitForChild("Tower")
local State = _G.HubState.Tower

print("🎲 I_ROLL: Iniciando Loop para " .. tostring(State.ItemTarget))

task.spawn(function()
    -- O loop roda enquanto a variável no State for true
    while State and State.ItemLoopActive do
        task.wait(0.5) -- Delay de segurança para o servidor

        -- Verifica se há itens selecionados antes de disparar
        if State.ItemTarget ~= "" and State.MaterialTarget ~= "" then
            pcall(function()
                local args = {
                    [1] = "Armor", 
                    [2] = State.ItemTarget,     -- Puxa do Dropdown (Ex: "Helmet")
                    [3] = State.MaterialTarget  -- Puxa do Dropdown (Ex: "Gold")
                }
                towerRemote:FireServer(unpack(args))
            end)
        else
            warn("⚠️ I_ROLL: Selecione o Item e a Pedra no Hub!")
            task.wait(2)
        end
        
        -- Segurança: Se o HubState sumir, mata o loop
        if not _G.HubState then break end
    end
    
    print("🛑 I_ROLL: Loop finalizado.")
    _G.IRollRunning = false
end)

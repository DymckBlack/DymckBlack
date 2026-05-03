-- [[ DYMCK HUB - UPAR ESTRELA ]]

-- 1. TRAVA DE SEGURANÇA (DEBOUNCE)
if _G.StarUpSpamProtection then 
    return 
end

local State = _G.HubState.StarTrialLogic

if State and State.UnitName and State.UnitName ~= "" then
    _G.StarUpSpamProtection = true -- Ativa a trava

    local args = {
        [1] = "Star",
        [2] = State.UnitName
    }

    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StarTrial")
        remote:FireServer(unpack(args))
    end)

    -- Aguarda 0.8 segundos antes de permitir um novo upgrade
    task.delay(0.8, function()
        _G.StarUpSpamProtection = false
    end)
end

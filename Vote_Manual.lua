-- [[ DYMCKHUB - VOTE MANUAL ]]

-- 1. TRAVA DE SEGURANÇA (DEBOUNCE)
-- Evita spam de cliques no botão
if _G.ManualVoteSpam then 
    return 
end

local State = _G.HubState.Vote

if State and State.Selected then
    _G.ManualVoteSpam = true -- Ativa a trava

    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.Raid:FireServer("Vote", State.Selected)
    end)

    -- Aguarda 1 segundo antes de permitir votar manualmente de novo
    task.delay(1, function()
        _G.ManualVoteSpam = false
    end)
end

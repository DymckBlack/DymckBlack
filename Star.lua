-- Star.lua
local State = _G.HubState.StarTrialLogic

if State and State.UnitName ~= "" then
    -- ESTE PRINT VAI NO CONSOLE (F9)
    warn("⭐ STAR TRIAL: Tentando dar UP na unidade: " .. tostring(State.UnitName))

    local args = {
        [1] = "Star",
        [2] State.UnitName
    }

    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StarTrial"):FireServer(unpack(args))
        print("✅ STAR TRIAL: Remote enviado com sucesso!")
    end)
else
    warn("⚠️ STAR TRIAL: Falha ao iniciar - Nome da unidade está vazio.")
end

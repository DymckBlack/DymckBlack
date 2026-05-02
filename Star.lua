-- Star.lua (Hospedado no GitHub)
local State = _G.HubState.StarTrialLogic

if State and State.UnitName ~= "" then
    warn("⭐ STAR TRIAL: Tentando dar UP na unidade: " .. tostring(State.UnitName))

    local args = {
        [1] = "Star",
        [2] = State.UnitName -- O sinal de '=' e a vírgula acima são essenciais
    }

    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StarTrial")
        remote:FireServer(unpack(args))
        print("✅ STAR TRIAL: Remote enviado com sucesso!")
    end)
else
    warn("⚠️ STAR TRIAL: Falha ao iniciar - Nome da unidade está vazio ou State inexistente.")
end

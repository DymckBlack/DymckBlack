-- Star.lua (Hospedado no GitHub)
local State = _G.HubState.StarTrialLogic

if State and State.UnitName ~= "" then
    local args = {
        [1] = "Star",
        [2] = State.UnitName
    }

    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StarTrial"):FireServer(unpack(args))
    end)
end

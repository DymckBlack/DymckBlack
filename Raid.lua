-- [[ DYMCK HUB - RAID BACKEND (NOVA VERSÃO) ]]

local RS = game:GetService("ReplicatedStorage")
local RaidRem = RS:WaitForChild("Remotes"):WaitForChild("Raid")
local StarRem = RS:WaitForChild("Remotes"):WaitForChild("StarTrial")
local State = _G.HubState.Raid

-- 1. Segurança AFK
pcall(function()
    StarRem:FireServer("AFK", false)
end)

-- 2. Coleta de dados do State com Fallback
local p1 = (State.Char1 and State.Char1 ~= "") and State.Char1 or "Empty"
local p2 = (State.Char2 and State.Char2 ~= "") and State.Char2 or "Empty"
local p3 = (State.Char3 and State.Char3 ~= "") and State.Char3 or "Empty"

-- 3. Montagem dos Argumentos conforme o padrão do jogo
local args = {
    [1] = "Join",
    [2] = {
        [1] = p1,
        [2] = p2,
        [3] = p3
    }
}

-- 4. Envio para o Servidor
local success, err = pcall(function()
    RaidRem:FireServer(unpack(args))
end)

if success then
    print("⚔️ RAID: Join enviado com " .. p1 .. ", " .. p2 .. ", " .. p3)
else
    warn("❌ RAID: Erro ao entrar: " .. tostring(err))
end

-- [[ DYMCK HUB - CASH SCRIPT (BACKEND PURIFICADO) ]]
-- Este script roda em segundo plano e é controlado pela variável _G.CashActive

if _G.CashLoaded then return end 
_G.CashLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Memória de Sessão
_G.SavedPlotNumber = nil 

-- Coordenadas Fixas para Identificação
local PlotPositions = {
    [1] = Vector3.new(-600.56, 7.15, -131.69),
    [2] = Vector3.new(-588.79, 7.15, -228.43),
    [3] = Vector3.new(-592.89, 7.15, -321.67),
    [4] = Vector3.new(-476.58, 7.15, -326.79),
    [5] = Vector3.new(-480.35, 7.15, -228.60),
    [6] = Vector3.new(-480.89, 7.15, -131.18)
}

-- Função interna para identificar o Plot por proximidade
local function GetMyPlotByPos()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closestNum = nil
    local shortestDist = math.huge
    for num, pos in pairs(PlotPositions) do
        local dist = (root.Position - pos).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            closestNum = num
        end
    end
    return closestNum
end

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CardRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Card")
    local Plots = workspace:WaitForChild("Plots")
    
    print("DymckHUB: Loop de CASH iniciado e aguardando ativação.")

    while true do
        if _G.CashActive then
            -- Identifica o Plot apenas na primeira vez que o Cash é ligado
            if not _G.SavedPlotNumber then 
                _G.SavedPlotNumber = GetMyPlotByPos() 
                if _G.SavedPlotNumber then
                    print("DymckHUB: Plot identificado automaticamente: " .. _G.SavedPlotNumber)
                end
            end

            if _G.SavedPlotNumber then
                -- 1. FASE DE COLETA (Sincronizada para evitar bug de cache)
                pcall(function()
                    local plot = Plots:FindFirstChild(tostring(_G.SavedPlotNumber))
                    if plot then
                        local display = plot.Map:FindFirstChild("Display")
                        if display then
                            local sides = {display:FindFirstChild("Left"), display:FindFirstChild("Right")}
                            for _, side in pairs(sides) do
                                if side then
                                    for slotIdx = 1, 9 do
                                        local card = side:FindFirstChild(tostring(slotIdx))
                                        if card then 
                                            CardRemote:FireServer("Collect", card) 
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

                -- 2. ESPERA DA COLETA (Ajustado para estabilidade)
                task.wait(1.8) 

                -- 3. FASE DE TROCA DE PÁGINA (Única por ciclo)
                pcall(function()
                    CardRemote:FireServer("Page", "RightArrow")
                end)

                -- 4. ESPERA DA PÁGINA (Evita o Double Click no servidor)
                task.wait(1.8) 
            else
                -- Caso não consiga identificar o plot (ex: player morreu), tenta novamente em breve
                task.wait(2)
                _G.SavedPlotNumber = GetMyPlotByPos()
            end
        else
            -- Se o Cash for desligado na UI, reseta o Plot salvo para permitir re-identificação se mudar de lugar
            _G.SavedPlotNumber = nil
            task.wait(1) 
        end
    end
end)

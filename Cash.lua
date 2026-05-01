-- [[ DYMCK HUB - CASH SCRIPT (BACKEND ATUALIZADO) ]]
-- Integrado ao novo HubState

if _G.CashLoaded then return end 
_G.CashLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Pega a referência do Estado Central
local State = _G.HubState

-- Memória de Sessão
local SavedPlotNumber = nil 

-- Coordenadas Fixas para Identificação
local PlotPositions = {
    [1] = Vector3.new(-600.56, 7.15, -131.69),
    [2] = Vector3.new(-588.79, 7.15, -228.43),
    [3] = Vector3.new(-592.89, 7.15, -321.67),
    [4] = Vector3.new(-476.58, 7.15, -326.79),
    [5] = Vector3.new(-480.35, 7.15, -228.60),
    [6] = Vector3.new(-480.89, 7.15, -131.18)
}

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
    
    print("DymckHUB: Loop de CASH iniciado e vinculado ao HubState.")

    while true do
        -- AQUI A MUDANÇA CRÍTICA: Agora checa o State.CashActive
        if State.CashActive then
            if not SavedPlotNumber then 
                SavedPlotNumber = GetMyPlotByPos() 
                if SavedPlotNumber then
                    print("DymckHUB: Plot identificado: " .. SavedPlotNumber)
                end
            end

            if SavedPlotNumber then
                pcall(function()
                    local plot = Plots:FindFirstChild(tostring(SavedPlotNumber))
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

                task.wait(1.8) 

                pcall(function()
                    CardRemote:FireServer("Page", "RightArrow")
                end)

                task.wait(1.8) 
            else
                task.wait(2)
                SavedPlotNumber = GetMyPlotByPos()
            end
        else
            SavedPlotNumber = nil
            task.wait(1) 
        end
    end
end)

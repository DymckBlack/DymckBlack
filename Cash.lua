-- [[ DYMCK HUB - CASH SCRIPT (VERSÃO ESTÁVEL) ]]

-- 1. TRAVA DE CARREGAMENTO (IMPEDE MULTIPLICAÇÃO)
if _G.CashLoopRunning then 
    return 
end
_G.CashLoopRunning = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
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
    return (shortestDist < 50) and closestNum or nil
end

local CardRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Card")
local Plots = workspace:WaitForChild("Plots")

-- O LOOP PRINCIPAL
task.spawn(function()
    while true do
        -- Se o Hub for fechado ou o estado for perdido, limpamos a trava e paramos
        if not _G.HubState then
            _G.CashLoopRunning = false
            break
        end

        if State.CashActive then
            -- Identifica o Plot apenas uma vez por ativação
            if not SavedPlotNumber then 
                SavedPlotNumber = GetMyPlotByPos() 
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
                
                task.wait(1.5)

                pcall(function()
                    CardRemote:FireServer("Page", "RightArrow")
                end)

                task.wait(1.5)
            else
                task.wait(5)
            end
        else
            SavedPlotNumber = nil
            task.wait(1) 
        end
    end
end)

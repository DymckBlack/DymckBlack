-- [[ DYMCK HUB - ANTI-AFK (FINAL SILENCIOSO + ESTÁVEL) ]]

if _G.AntiAFKRunning then 
    return 
end
_G.AntiAFKRunning = true

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

task.spawn(function()
    local lastMove = 0
    local keys = {"w","a","s","d"}

    while true do
        if not _G.HubState then
            _G.AntiAFKRunning = false
            break
        end

        if _G.HubState.AntiAFKActive then
            if tick() - lastMove >= 600 then
                lastMove = tick()

                pcall(function()
                    VirtualUser:CaptureController()

                    local key = keys[math.random(1, #keys)]

                    VirtualUser:SetKeyDown(key)
                    task.wait(0.3)
                    VirtualUser:SetKeyUp(key)
                end)
            end
        end

        task.wait(1)
    end
end)

if not _G.AntiAFKConnection then
    _G.AntiAFKConnection = lp.Idled:Connect(function()
        if _G.HubState and _G.HubState.AntiAFKActive then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end

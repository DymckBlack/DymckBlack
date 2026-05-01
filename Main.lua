local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 🌐 CONFIG
-- ==========================================
local BASE_URL = "https://raw.githubusercontent.com/DymckBlack/DymckBlack/main/"

-- ==========================================
-- 🧠 ESTADO CENTRAL
-- ==========================================

_G.HubState = _G.HubState or {
    CashActive = false, -- ADICIONE ESTA LINHA
    AutoCollectActive = false, -- ADICIONE ESTA LINHA TAMBÉM
    Roll = { Target = "", Active = false },
    AntiAFKActive = false,
    Tower = { Target = "", Active = false, ItemAction = "Roll", ItemTarget = "", MaterialTarget = "", ItemLoopActive = false },
    Raid = { Char1 = "", Char2 = "", Char3 = "", Active = false },
    Vote = { Selected = "Ninja", Auto = false },
    Exp = { Name = "", Type = "Common", Amount = "1" },
    Manga = { Name = "" },
    Trial = {}
}
local State = _G.HubState

-- ==========================================
-- 🧹 RESET
-- ==========================================

if pGui:FindFirstChild("GeminiMasterHub") then
    pGui.GeminiMasterHub:Destroy()
end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "GeminiMasterHub"

-- ==========================================
-- 🎨 CORES
-- ==========================================

local COR_AZUL = Color3.fromRGB(0,120,255)
local COR_VERMELHO = Color3.fromRGB(180,50,50)
local COR_VERDE = Color3.fromRGB(0,200,100)
local COR_FUNDO = Color3.fromRGB(25,25,28)

-- ==========================================
-- 🗺️ DATABASE
-- ==========================================

local Database = {
    Decks = {
        "Pirate","Ninja","Soul","Slayer","Sorcerer","Dragon",
        "Fire","Hero","Hunter","Solo","Titan","Chainsaw",
        "Flight","Ego","Clover","Ghoul","Geass","Bizarre",
        "Fairy","Sins","Note","Slime","Mage","Zero",
        "Vagrant","Rebellion","Viking","Mercenary"
    },
    Items = {
        "Helmet","Necklace","Chestplate","Gauntlets","Sword","Shoes"
    },
    Materials = {
        "Bronze","Silver","Gold","Platinum","Diamond"
    },
    ExpTypes = {
        "Common","Rare","Epic","Legendary","Mythical"
    }
}

-- ==========================================
-- 🧱 MAIN
-- ==========================================

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,425,0,425)
main.Position = UDim2.new(0.5,-212,0.5,-212)
main.BackgroundColor3 = Color3.fromRGB(20,20,22)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- ==========================================
-- 🎛 HEADER
-- ==========================================

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,65)
header.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

-- ==========================================
-- CONTROLES
-- ==========================================

local controls = Instance.new("Frame", header)
controls.Size = UDim2.new(0,80,1,0)
controls.Position = UDim2.new(1,-85,0,0)
controls.BackgroundTransparency = 1
controls.ZIndex = 5

local ctrlLayout = Instance.new("UIListLayout", controls)
ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ctrlLayout.Padding = UDim.new(0,8)

local function CreateControlBtn(text, color, callback)
    local btn = Instance.new("TextButton", controls)
    btn.Size = UDim2.new(0,30,0,30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 📦 BODY
-- ==========================================

local body = Instance.new("Frame", main)
body.Size = UDim2.new(1,0,1,-65)
body.Position = UDim2.new(0,0,0,65)
body.BackgroundTransparency = 1

-- ==========================================
-- 📑 PAGES + GRID
-- ==========================================

local pages = {}

local function createPage(name)
    local sc = Instance.new("ScrollingFrame", body)
    sc.Size = UDim2.new(1,-10,1,-10)
    sc.Position = UDim2.new(0,5,0,5)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 0 -- REMOVIDO: Agora a barra sumiu!
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false

    local grid = Instance.new("UIGridLayout", sc)
    grid.CellSize = UDim2.new(0,120,0,160) -- Aumentei um pouco a altura da célula
    grid.CellPadding = UDim2.new(0,12,0,12) -- Mais espaço entre os cards
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pages[name] = sc
end

createPage("Global")
createPage("Torre")
createPage("Invasão")
createPage("Trial")

-- ==========================================
-- 🧩 CARD PADRÃO (CORRIGIDO)
-- ==========================================

-- ==========================================
-- 🧩 CARD PADRÃO (VERSÃO COM ORDEM MANUAL)
-- ==========================================

local function CreateCard(page, title)
    local card = Instance.new("Frame", pages[page])
    card.Size = UDim2.new(0,120,0,160)
    card.BackgroundColor3 = COR_FUNDO
    card.BorderSizePixel = 1
    card.BorderColor3 = Color3.fromRGB(40,40,45)
    Instance.new("UICorner", card)

    -- Título do Card
    local label = Instance.new("TextLabel", card)
    label.Size = UDim2.new(1,0,0,30)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = COR_AZUL
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    -- Container interno para os componentes
    local container = Instance.new("Frame", card)
    container.Size = UDim2.new(1,-10,1,-35)
    container.Position = UDim2.new(0,5,0,30)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0,5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- ✅ ESTA É A LINHA CHAVE:
    -- Agora todos os cards aceitam a numeração 'order' nos componentes
    layout.SortOrder = Enum.SortOrder.LayoutOrder 

    return container
end

--local function CreateCard(page, title)
    --local card = Instance.new("Frame", pages[page])
    --card.Size = UDim2.new(0,120,0,160)
    --card.BackgroundColor3 = COR_FUNDO
    --card.BorderSizePixel = 1
   --card.BorderColor3 = Color3.fromRGB(40,40,45)
    --Instance.new("UICorner", card)

-- ==========================================
    -- Título
-- ==========================================

    local label = Instance.new("TextLabel", card)
    label.Size = UDim2.new(1,0,0,30)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = COR_AZUL
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

-- ==========================================
    -- Container interno
-- ==========================================

    local container = Instance.new("Frame", card)
    container.Size = UDim2.new(1,-10,1,-35)
    container.Position = UDim2.new(0,5,0,30)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0,5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return container
end

-- ==========================================
-- 🔧 COMPONENTES (VERSÃO 2.1 - ESTÁVEL)
-- ==========================================

local function LoadScript(name)
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(BASE_URL .. name))()
        end)
        if not success then warn("Erro ao carregar script: " .. name .. " | " .. err) end
    end)
end

-- ==========================================
-- 1. Botão Liga/Desliga (Toggle)
-- ==========================================
local function AddToggle(parent, text, stateTable, key, scriptName, order)
    local btn = Instance.new("TextButton", parent)
    btn.LayoutOrder = order or 0
    btn.Size = UDim2.new(1, 0, 0, 27)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn)

    btn.BackgroundColor3 = stateTable[key] and COR_VERDE or COR_VERMELHO

    btn.MouseButton1Click:Connect(function()
        stateTable[key] = not stateTable[key]
        btn.BackgroundColor3 = stateTable[key] and COR_VERDE or COR_VERMELHO
        
        if stateTable[key] and scriptName then
            LoadScript(scriptName)
        end
    end)
end

-- ==========================================
-- 2. Botão de Clique Único (Timed)
-- ==========================================
local function AddTimedButton(parent, text, scriptName, order)
    local btn = Instance.new("TextButton", parent)
    btn.LayoutOrder = order or 0
    btn.Size = UDim2.new(1, 0, 0, 27)
    btn.BackgroundColor3 = COR_VERMELHO
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = COR_VERDE
        if scriptName then LoadScript(scriptName) end
        task.wait(1)
        btn.BackgroundColor3 = COR_VERMELHO
    end)
end

-- ==========================================
-- 3. Caixa de Texto (TextBox)
-- ==========================================
local function AddTextBox(parent, placeholder, stateTable, key, order)
    local box = Instance.new("TextBox", parent)
    box.LayoutOrder = order or 0
    box.Size = UDim2.new(1, 0, 0, 27)
    box.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    box.PlaceholderText = placeholder
    box.Text = stateTable[key] or ""
    box.TextColor3 = Color3.new(0, 0, 0)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 10
    box.ClipsDescendants = true
    Instance.new("UICorner", box)

    box.FocusLost:Connect(function()
        stateTable[key] = box.Text
    end)
end

-- ==========================================
-- 4. Menu de Escolha (Dropdown)
-- ==========================================
local function AddDropdown(parent, list, stateTable, key, order)
    local btn = Instance.new("TextButton", parent)
    btn.LayoutOrder = order or 0
    btn.Size = UDim2.new(1, 0, 0, 27)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    
    if stateTable[key] == "" or stateTable[key] == nil then
        stateTable[key] = list[1]
    end
    btn.Text = stateTable[key]
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.ClipsDescendants = true 
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        local currentPos = table.find(list, btn.Text) or 1
        local nextPos = currentPos + 1
        if nextPos > #list then nextPos = 1 end
        
        stateTable[key] = list[nextPos]
        btn.Text = list[nextPos]
    end)
end

-- ==========================================
-- 5. Botão Híbrido (Toggle/Execução)
-- ==========================================
local function AddHybridButton(parent, text, stateTable, actionKey, activeKey, scriptRoll, scriptUpgrade, order)
    local btn = Instance.new("TextButton", parent)
    btn.LayoutOrder = order or 0
    btn.Size = UDim2.new(1, 0, 0, 27)
    btn.BackgroundColor3 = COR_VERMELHO
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if stateTable[actionKey] == "Roll" then
            stateTable[activeKey] = not stateTable[activeKey]
            btn.BackgroundColor3 = stateTable[activeKey] and COR_VERDE or COR_VERMELHO
            btn.Text = stateTable[activeKey] and "ROLL: ON" or "ROLL: OFF"
            
            if stateTable[activeKey] then
                LoadScript(scriptRoll)
            end
        else
            btn.BackgroundColor3 = COR_VERDE
            btn.Text = "EXECUTANDO..."
            LoadScript(scriptUpgrade)
            
            task.wait(1.5)
            btn.BackgroundColor3 = COR_VERMELHO
            btn.Text = text
        end
    end)
end

-- ==========================================
-- 6. Botões Duplos (Lado a Lado)
-- ==========================================
local function AddDoubleButtons(parent, text1, script1, text2, callback2, order)
    local container = Instance.new("Frame", parent)
    container.LayoutOrder = order or 0
    container.Size = UDim2.new(1, 0, 0, 27)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 5)

    local function CreateMiniBtn(txt, isScript, action)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0.5, -3, 1, 0)
        btn.BackgroundColor3 = COR_VERMELHO
        btn.Text = txt
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            btn.BackgroundColor3 = COR_VERDE
            if isScript then LoadScript(action) else action() end
            task.wait(1)
            btn.BackgroundColor3 = COR_VERMELHO
        end)
    end

    CreateMiniBtn(text1, true, script1)
    CreateMiniBtn(text2, false, callback2)
end

-- ==========================================
-- 🌍 ABA: GLOBAL
-- ==========================================

-- 1. CARD CASH
local cashCard = CreateCard("Global", "CASH")
AddToggle(cashCard, "ON/OFF", State, "CashActive", "Cash.lua")

-- 2. CARD COLLECT
local collectCard = CreateCard("Global", "COLLECT")
AddTimedButton(collectCard, "Coletar Agora", "Collect.lua")
AddToggle(collectCard, "Coleta AFK", State, "AutoCollectActive", "Collect.lua")

-- 3. CARD ROLL
local rollCard = CreateCard("Global", "ROLL UR")
-- Sincronizado com State.Roll.Target
AddTextBox(rollCard, "Nome do Personagem", State.Roll, "Target") 
-- Sincronizado com State.Roll.Active
AddToggle(rollCard, "INICIAR ROLL", State.Roll, "Active", "Grade.lua")

-- 4. CARD ANTI AFK
local afkCard = CreateCard("Global", "Anti-AFK")
AddToggle(afkCard, "ANTI AFK", State, "AntiAFKActive", "Anti_Afk.lua")

-- ==========================================
-- 🏰 ABA: TORRE
-- ==========================================

-- 1. CARD TOWER
local towerCard = CreateCard("Torre", "TOWER")
AddTimedButton(towerCard, "Iniciar Torre", "Tower.lua")

-- 2. CARD TOWER ROLL
local t_rollCard = CreateCard("Torre", "TOWER ROLL")
AddTextBox(t_rollCard, "Nome do Personagem", State.Tower, "Target")
AddToggle(t_rollCard, "INICIAR ROLL", State.Tower, "Active", "T_Roll.lua")

-- 3. CARD SET TOWER
local itemCard = CreateCard("Torre", "SET TOWER")
AddDropdown(itemCard, {"Roll", "Upgrade"}, State.Tower, "ItemAction")
AddDropdown(itemCard, Database.Items, State.Tower, "ItemTarget")
AddDropdown(itemCard, Database.Materials, State.Tower, "MaterialTarget")
AddHybridButton(itemCard, "EXECUTAR", State.Tower, "ItemAction", "ItemLoopActive", "I_Roll.lua", "I_Upgrade.lua")

-- ==========================================
-- ⚔️ ABA: INVASÃO
-- ==========================================

local raidCard = CreateCard("Invasão", "RAID")

-- 1. Inputs (Ordem 1, 2, 3)
AddTextBox(raidCard, "Personagem 1", State.Raid, "Char1", 1)
AddTextBox(raidCard, "Personagem 2", State.Raid, "Char2", 2)
AddTextBox(raidCard, "Personagem 3", State.Raid, "Char3", 3)

-- 2. Botões (Ordem 4 - Sempre ficará embaixo)
AddDoubleButtons(raidCard, 
    "JOIN", "Raid.lua", 
    "TELEPORT", function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then 
            root.CFrame = CFrame.new(-533.24, -114.05, -208.06) 
        end
    end, 
    4
)

-- ==========================================
-- 📑 TABS
-- ==========================================

local tabContainer = Instance.new("Frame", header)
tabContainer.Size = UDim2.new(1,-95,1,0)
tabContainer.Position = UDim2.new(0,17,0,0)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0,6)

local function addTab(name, default)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0,75,0,35)
    btn.Text = name
    btn.BackgroundColor3 = default and COR_AZUL or Color3.fromRGB(45,45,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold -- Adicionei a fonte para ficar bonito
    btn.TextSize = 11

    local corner = Instance.new("UICorner", btn) -- Faltava criar a variável!
    corner.CornerRadius = UDim.new(0, 8)
    
    if default then pages[name].Visible = true end

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        for _,b in pairs(tabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(45,45,50)
            end
        end

        btn.BackgroundColor3 = COR_AZUL
        pages[name].Visible = true
    end)
end

addTab("Global", true)
addTab("Torre")
addTab("Invasão")
addTab("Trial")

-- ==========================================
-- 🔻 MINIMIZAR (PERFEITO)
-- ==========================================

CreateControlBtn("-", Color3.fromRGB(60,60,65), function()
    local aberto = body.Visible
    body.Visible = not aberto

    main:TweenSize(
        aberto and UDim2.new(0,425,0,65) or UDim2.new(0,425,0,425),
        "Out","Quad",0.25,true
    )
end)

CreateControlBtn("X", COR_VERMELHO, function()
    sg:Destroy()
end)

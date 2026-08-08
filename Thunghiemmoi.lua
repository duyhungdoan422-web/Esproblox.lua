local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espList = {}
local espEnabled = true

local function antiInvisible(character)
    pcall(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
                part.Transparency = 0
            end
        end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.HealthDisplayDistance = math.huge
        end
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Highlight") then
                child:Destroy()
            end
        end
    end)
end

local function createESP(player)
    if player == localPlayer then return end
    local char = player.Character
    if not char then return end
    antiInvisible(char)
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not head or not humanoid or not root then return end
    
    local gui = Instance.new("BillboardGui")
    gui.Adornee = head
    gui.Parent = head
    gui.Size = UDim2.new(0, 200, 0, 60)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    
    local name = Instance.new("TextLabel", gui)
    name.Size = UDim2.new(1, 0, 0.45, 0)
    name.Position = UDim2.new(0, 0, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = player.Name
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextSize = 14
    name.Font = Enum.Font.GothamBold
    name.TextStrokeTransparency = 0.3
    
    local health = Instance.new("TextLabel", gui)
    health.Size = UDim2.new(1, 0, 0.35, 0)
    health.Position = UDim2.new(0, 0, 0.45, 0)
    health.BackgroundTransparency = 1
    health.Text = "100%"
    health.TextColor3 = Color3.new(0, 1, 0)
    health.TextSize = 13
    health.Font = Enum.Font.GothamBold
    health.TextStrokeTransparency = 0.3
    
    local dist = Instance.new("TextLabel", gui)
    dist.Size = UDim2.new(1, 0, 0.3, 0)
    dist.Position = UDim2.new(0, 0, 0.7, 0)
    dist.BackgroundTransparency = 1
    dist.Text = "0m"
    dist.TextColor3 = Color3.new(1, 1, 0)
    dist.TextSize = 12
    dist.Font = Enum.Font.Gotham
    dist.TextStrokeTransparency = 0.3
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0, 255, 255)
    box.Filled = false
    box.Transparency = 0.7
    box.Visible = true
    
    espList[player] = {
        gui = gui,
        name = name,
        health = health,
        dist = dist,
        box = box,
        humanoid = humanoid,
        root = root,
        char = char,
        head = head
    }
end

local function removeESP(player)
    local data = espList[player]
    if data then
        if data.gui then data.gui:Destroy() end
        if data.box then data.box:Remove() end
        espList[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    for _, data in pairs(espList) do
        if data.gui then data.gui.Enabled = espEnabled end
        if data.box then data.box.Visible = espEnabled end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then toggleESP() end
end)

for _, player in Players:GetPlayers() do
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() createESP(player) end)
    if player.Character then createESP(player) end
end)

Players.PlayerRemoving:Connect(removeESP)

local counterLabel
local function createCounter()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ESPCounter"
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(0, 140, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "ESP: 0"
    label.TextColor3 = Color3.new(0, 1, 1)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

pcall(function()
    local old = localPlayer.PlayerGui:FindFirstChild("ESPCounter")
    if old then old:Destroy() end
    counterLabel = createCounter()
end)

RunService.Heartbeat:Connect(function()
    if not espEnabled then
        if counterLabel then counterLabel.Text = "ESP: OFF" end
        return
    end
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local count = 0
    for player, data in pairs(espList) do
        if not data.char or not data.char.Parent then
            removeESP(player)
            goto next
        end
        if data.head and data.head.Parent then
            pcall(function() data.head.LocalTransparencyModifier = 0 end)
        end
        if data.humanoid and data.humanoid.Parent and data.root and data.root.Parent then
            count = count + 1
            local hp = data.humanoid.Health
            local maxHp = data.humanoid.MaxHealth
            local percent = math.floor((hp / maxHp) * 100)
            if percent > 60 then
                data.health.TextColor3 = Color3.new(0, 1, 0)
            elseif percent > 30 then
                data.health.TextColor3 = Color3.new(1, 1, 0)
            else
                data.health.TextColor3 = Color3.new(1, 0, 0)
            end
            data.health.Text = percent .. "%"
            if myRoot then
                local dist = (data.root.Position - myRoot.Position).Magnitude
                data.dist.Text = string.format("%.0fm", dist)
            end
            local headPos, onScreen = Camera:WorldToScreenPoint(data.head.Position)
            local rootPos = Camera:WorldToScreenPoint(data.root.Position)
            if onScreen and headPos.Z > 0 then
                local height = math.abs(headPos.Y - rootPos.Y) * 2.8
                local width = height * 0.5
                data.box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
                data.box.Size = Vector2.new(width, height)
                data.box.Visible = true
            else
                data.box.Visible = false
            end
            data.gui.Enabled = true
        else
            data.gui.Enabled = false
            if data.box then data.box.Visible = false end
        end
        ::next::
    end
    if counterLabel then counterLabel.Text = "ESP: " .. count end
end)

print("ESP da chay. Nhan Insert de bat/tat.")

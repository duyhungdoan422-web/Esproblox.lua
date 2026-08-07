local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espList = {}
local espEnabled = true

local function isCharacterAlive(character)
    if not character then return false end
    if character.Parent ~= workspace then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    return true
end

local function createESP(player)
    local character = player.Character
    if not character then return end
    local head = character:WaitForChild("Head", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not (head and humanoid and root) then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 200, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    
    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.Text = "0m"
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Transparency = 0.8
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(0, 255, 0)
    tracer.Transparency = 0.5
    
    pcall(function()
        head.LocalTransparencyModifier = 0
        root.LocalTransparencyModifier = 0
        humanoid.HealthDisplayDistance = math.huge
    end)
    
    espList[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        distLabel = distLabel,
        box = box,
        tracer = tracer,
        root = root,
        head = head,
        humanoid = humanoid,
        character = character
    }
end

local function removeESP(player)
    local data = espList[player]
    if data then
        if data.billboard then data.billboard:Destroy() end
        if data.box then data.box:Remove() end
        if data.tracer then data.tracer:Remove() end
        espList[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    for _, data in pairs(espList) do
        if data.billboard then
            data.billboard.Enabled = espEnabled
        end
        if data.box then
            data.box.Visible = espEnabled
        end
        if data.tracer then
            data.tracer.Visible = espEnabled
        end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleESP()
    end
end)

for _, player in Players:GetPlayers() do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function() createESP(player) end)
        if player.Character then createESP(player) end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() createESP(player) end)
    player.CharacterRemoving:Connect(function() removeESP(player) end)
end)

Players.PlayerRemoving:Connect(removeESP)

local function createCounter()
    local gui = Instance.new("ScreenGui", localPlayer.PlayerGui)
    gui.Name = "ESPCounter"
    gui.ResetOnSpawn = false
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(0, 250, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.Text = "ESP: 0 players"
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local counterLabel
if localPlayer.PlayerGui then
    local existing = localPlayer.PlayerGui:FindFirstChild("ESPCounter")
    if existing then existing:Destroy() end
    counterLabel = createCounter()
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then 
        if counterLabel then counterLabel.Text = "ESP: OFF" end
        return 
    end
    
    local viewport = Camera.ViewportSize
    local topCenter = Vector2.new(viewport.X / 2, 0)
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local count = 0
    
    for player, data in pairs(espList) do
        if not data.character or not data.character.Parent then
            removeESP(player)
            goto continue
        end
        
        if data.root and data.root.Parent and data.head and data.head.Parent then
            local headPos, onScreen = Camera:WorldToScreenPoint(data.head.Position)
            local rootPos = Camera:WorldToScreenPoint(data.root.Position)
            
            if onScreen and headPos.Z > 0 then
                count = count + 1
                local height = math.abs(headPos.Y - rootPos.Y) * 2.5
                local width = height * 0.5
                data.box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
                data.box.Size = Vector2.new(width, height)
                data.box.Visible = true
                
                data.tracer.From = Vector2.new(rootPos.X, rootPos.Y)
                data.tracer.To = Vector2.new(headPos.X, headPos.Y - 30)
                data.tracer.Visible = true
                
                pcall(function()
                    data.head.LocalTransparencyModifier = 0
                    data.root.LocalTransparencyModifier = 0
                    if data.humanoid then
                        data.humanoid.HealthDisplayDistance = math.huge
                    end
                end)
                
                if myRoot then
                    local dist = (data.root.Position - myRoot.Position).Magnitude
                    data.distLabel.Text = string.format("%.1fm", dist)
                end
                
                data.billboard.Enabled = true
            else
                data.box.Visible = false
                data.tracer.Visible = false
                data.billboard.Enabled = false
            end
        else
            if data.box then data.box.Visible = false end
            if data.tracer then data.tracer.Visible = false end
            if data.billboard then data.billboard.Enabled = false end
        end
        ::continue::
    end
    
    if counterLabel then
        counterLabel.Text = "ESP: " .. count .. " players"
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        for player, data in pairs(espList) do
            if not data.character or not data.character.Parent then
                removeESP(player)
            end
        end
    end
end)

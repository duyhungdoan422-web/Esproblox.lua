local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espList = {}
local espEnabled = true

local function antiInvisible(character)
    pcall(function()
        -- QUÉT TOÀN BỘ PART, ÉP HIỂN THỊ
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
                part.Transparency = 0
            end
        end
        
        -- BẬT HIỂN THỊ MÁU
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.HealthDisplayDistance = math.huge
        end
        
        -- XÓA HIỆU ỨNG TÀNG HÌNH
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Highlight") then
                child.Enabled = false
                child:Destroy()
            end
        end
    end)
end

local function createESP(player)
    local character = player.Character
    if not character then return end
    
    -- CHỐNG TÀNG HÌNH KHI TẠO
    antiInvisible(character)
    
    local head = character:WaitForChild("Head", 3)
    local humanoid = character:WaitForChild("Humanoid", 3)
    if not head or not humanoid then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    
    local healthLabel = Instance.new("TextLabel", billboard)
    healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextSize = 12
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.Text = "100%"
    
    espList[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        healthLabel = healthLabel,
        humanoid = humanoid,
        character = character
    }
end

local function removeESP(player)
    local data = espList[player]
    if data then
        if data.billboard then data.billboard:Destroy() end
        espList[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    for _, data in pairs(espList) do
        if data.billboard then data.billboard.Enabled = espEnabled end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then toggleESP() end
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
    label.Size = UDim2.new(0, 150, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Text = "ESP: 0"
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local counterLabel
if localPlayer.PlayerGui then
    local existing = localPlayer.PlayerGui:FindFirstChild("ESPCounter")
    if existing then existing:Destroy() end
    counterLabel = createCounter()
end

RunService.Heartbeat:Connect(function()
    if not espEnabled then 
        if counterLabel then counterLabel.Text = "ESP: OFF" end
        return
    end
    
    local count = 0
    
    for player, data in pairs(espList) do
        if not data.character or not data.character.Parent then
            removeESP(player)
            goto continue
        end
        
        if data.humanoid and data.humanoid.Parent then
            -- CHỐNG TÀNG HÌNH REFRESH MỖI FRAME
            antiInvisible(data.character)
            
            count = count + 1
            local health = data.humanoid.Health
            local maxHealth = data.humanoid.MaxHealth
            local percent = math.floor((health / maxHealth) * 100)
            
            if percent > 60 then
                data.healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif percent > 30 then
                data.healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                data.healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            
            data.healthLabel.Text = percent .. "%"
            data.billboard.Enabled = true
        else
            data.billboard.Enabled = false
        end
        ::continue::
    end
    
    if counterLabel then counterLabel.Text = "ESP: " .. count end
end)

print("ESP da chay. Nhan Insert de bat/tat.")

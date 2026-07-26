loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espList = {}

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
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    local healthBar = Instance.new("Frame", billboard)
    healthBar.Size = UDim2.new(1, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0, 0, 0.55, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthBar.BorderSizePixel = 1
    healthBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    local healthLabel = Instance.new("TextLabel", billboard)
    healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.75, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 12
    healthLabel.Text = "100%"
    local function updateHealth()
        local hp = humanoid.Health
        local maxHp = humanoid.MaxHealth
        local percent = math.floor((hp / maxHp) * 100)
        healthBar.Size = UDim2.new(hp / maxHp, 0, 0.2, 0)
        healthLabel.Text = percent .. "%"
        if percent > 50 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif percent > 25 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
    humanoid.HealthChanged:Connect(updateHealth)
    updateHealth()
    espList[player] = {billboard, nameLabel, healthBar, healthLabel}
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Transparency = 0.8
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(0, 255, 0)
    tracer.Transparency = 0.5
    espList[player].box = box
    espList[player].tracer = tracer
    espList[player].root = root
    espList[player].head = head
end

local function removeESP(player)
    if espList[player] then
        for _, obj in pairs(espList[player]) do
            if obj:IsA("Instance") then obj:Destroy() end
        end
        if espList[player].box then espList[player].box:Remove() end
        if espList[player].tracer then espList[player].tracer:Remove() end
        espList[player] = nil
    end
end

for _, player in Players:GetPlayers() do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function() createESP(player) end)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() createESP(player) end)
    player.CharacterRemoving:Connect(function() removeESP(player) end)
end)

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y)
    for player, data in pairs(espList) do
        if data.root and data.root.Parent then
            local headPos, onScreen = Camera:WorldToScreenPoint(data.head.Position)
            local rootPos = Camera:WorldToScreenPoint(data.root.Position)
            if onScreen and headPos.Z > 0 then
                local height = math.abs(headPos.Y - rootPos.Y) * 2.5
                local width = height * 0.5
                data.box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
                data.box.Size = Vector2.new(width, height)
                data.box.Visible = true
                data.tracer.From = center
                data.tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/4)
                data.tracer.Visible = true
            else
                data.box.Visible = false
                data.tracer.Visible = false
            end
        end
    end
end)
]])()

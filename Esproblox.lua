local function createESP(player)
    local character = player.Character
    if not character then return end
    
    local head = character:WaitForChild("Head", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not (head and humanoid and root) then return end
    
    -- **A. Tạo BillboardGui (hiện tên + máu)**
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    
    -- Tên
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0 -- viền đen
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    
    -- Thanh máu
    local healthBar = Instance.new("Frame", billboard)
    healthBar.Size = UDim2.new(1, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0, 0, 0.55, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthBar.BorderSizePixel = 1
    healthBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    
    -- Nhãn máu (%)
    local healthLabel = Instance.new("TextLabel", billboard)
    healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.75, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 12
    healthLabel.Text = "100%"
    
    -- Cập nhật máu
    local function updateHealth()
        local hp = humanoid.Health
        local maxHp = humanoid.MaxHealth
        local percent = math.floor((hp / maxHp) * 100)
        healthBar.Size = UDim2.new(hp / maxHp, 0, 0.2, 0)
        healthLabel.Text = percent .. "%"
        
        -- Đổi màu theo máu
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
    
    -- Lưu vào danh sách để xóa sau
    espList[player] = {billboard, nameLabel, healthBar, healthLabel}
    
    -- **B. Vẽ Box ESP (dùng Drawing)**
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Transparency = 0.8
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(0, 255, 0)
    tracer.Transparency = 0.5
    
    -- Thêm vào danh sách để vòng lặp cập nhật
    espList[player].box = box
    espList[player].tracer = tracer
    espList[player].root = root
    espList[player].head = head
end

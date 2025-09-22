local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local isAnimasi = true
local animConn

-- === FUNGSI UTAMA ===
local function setup(char)
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position

    if animConn then animConn:Disconnect() end
    animConn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then return end
        if isAnimasi then
            local direction = (hrp.Position - lastPos)
            local dist = direction.Magnitude
            if dist > 0.01 then
                local moveVector = direction.Unit * math.clamp(dist*5,0,1)
                humanoid:Move(moveVector,false)
            else
                humanoid:Move(Vector3.zero,false)
            end
        end
        lastPos = hrp.Position
    end)
end

player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end

-- === BUAT UI ===
local function createUI()
    if player.PlayerGui:FindFirstChild("Animasi_UI") then
        player.PlayerGui.Animasi_UI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    ScreenGui.Name = "Animasi_UI"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0,160,0,70)
    Frame.Position = UDim2.new(0.05,0,0.05,0)
    Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1,-10,0,22)
    Label.Position = UDim2.new(0,5,0,5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220,220,220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.Text = "Animasi"
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local AnimBtn = Instance.new("TextButton", Frame)
    AnimBtn.Size = UDim2.new(1,-10,0,30)
    AnimBtn.Position = UDim2.new(0,5,0,35)
    AnimBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    AnimBtn.BorderSizePixel = 0
    AnimBtn.TextColor3 = Color3.fromRGB(255,255,255)
    AnimBtn.Font = Enum.Font.GothamBold
    AnimBtn.TextSize = 14
    AnimBtn.Text = "ANIMASI: ON"
    Instance.new("UICorner", AnimBtn).CornerRadius = UDim.new(0,6)

    AnimBtn.MouseButton1Click:Connect(function()
        isAnimasi = not isAnimasi
        if isAnimasi then
            AnimBtn.Text = "ANIMASI: ON"
            AnimBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        else
            AnimBtn.Text = "ANIMASI: OFF"
            AnimBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        end
    end)
end

createUI()

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not player.PlayerGui:FindFirstChild("Animasi_UI") then
        createUI()
    end
end)

print("✅ Animasi script siap, UI minimalis aktif")
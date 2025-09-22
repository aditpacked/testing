local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local isActive = true
local animConn
local elapsedTime = 0

-- 🔹 Fungsi utama bypass anim
local function setup(char)
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position

    if animConn then animConn:Disconnect() end
    animConn = RunService.RenderStepped:Connect(function(dt)
        if not hrp or not hrp.Parent then return end

        if isActive then
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

    -- 🔹 Anti-duduk (paksa berdiri kalau sempat duduk)
    humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid.SeatPart = nil
            local weld = char:FindFirstChild("SeatWeld")
            if weld then weld:Destroy() end
        end
    end)
end

player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end

-- 🔹 Bikin kursi & batang pohon jadi tembus
local function makeSeatsInvisible()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            obj.CanCollide = false
            obj.Transparency = 1
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
        obj.CanCollide = false
        obj.Transparency = 1
    end
end)

makeSeatsInvisible()

-- 🔹 UI Timer + tombol toggle
local ScreenGui, TimerLabel, AnimBtn

local function formatTime(sec)
    local m = math.floor(sec/60)
    local s = math.floor(sec%60)
    return string.format("%02d:%02d", m, s)
end

local function createUI()
    if player.PlayerGui:FindFirstChild("SUCKARDY_AnimUI") then
        player.PlayerGui.SUCKARDY_AnimUI:Destroy()
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SUCKARDY_AnimUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,160,0,110)
    Frame.Position = UDim2.new(0.05,0,0.05,0)
    Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Frame.BackgroundTransparency = 0.8
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0,12)
    UICorner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,20)
    Label.Position = UDim2.new(0,0,0,0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(180,220,255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.Text = "SUCKARDY"
    Label.Parent = Frame

    AnimBtn = Instance.new("TextButton")
    AnimBtn.Size = UDim2.new(1,-10,0,28)
    AnimBtn.Position = UDim2.new(0,5,0,30)
    AnimBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    AnimBtn.BackgroundTransparency = 0.2
    AnimBtn.BorderSizePixel = 0
    AnimBtn.TextColor3 = Color3.fromRGB(255,255,255)
    AnimBtn.Font = Enum.Font.GothamBold
    AnimBtn.TextSize = 13
    AnimBtn.Text = "BYPASS: ON"
    AnimBtn.Parent = Frame

    local AnimCorner = Instance.new("UICorner")
    AnimCorner.CornerRadius = UDim.new(0,6)
    AnimCorner.Parent = AnimBtn

    AnimBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            AnimBtn.Text = "BYPASS: ON"
            AnimBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        else
            AnimBtn.Text = "BYPASS: OFF"
            AnimBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        end
    end)

    TimerLabel = Instance.new("TextLabel")
    TimerLabel.Size = UDim2.new(1,0,0,24)
    TimerLabel.Position = UDim2.new(0,0,0,70)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255,255,180)
    TimerLabel.Font = Enum.Font.GothamBold
    TimerLabel.TextSize = 14
    TimerLabel.Text = "Timer: 00:00"
    TimerLabel.Parent = Frame
end

createUI()

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    elapsedTime = 0 -- reset timer kalau respawn
    if not player.PlayerGui:FindFirstChild("SUCKARDY_AnimUI") then
        createUI()
    elseif TimerLabel then
        TimerLabel.Text = "Timer: 00:00"
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if isActive then
        elapsedTime += dt
        if TimerLabel then
            TimerLabel.Text = "Timer: " .. formatTime(elapsedTime)
        end
    end
end)

print("✅ SUCKARDY Anim + Timer + Anti Kursi/Pohon siap")
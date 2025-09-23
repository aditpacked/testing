local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

pcall(function()
    local raw = game:HttpGet("https://raw.githubusercontent.com/aditpacked/testing/refs/heads/main/bypass.lua")
    loadstring(raw)()
end)

local player = Players.LocalPlayer
local hrp = nil

local function refreshHRP(char)
    if not char then
        char = player.Character or player.CharacterAdded:Wait()
    end
    hrp = char:WaitForChild("HumanoidRootPart")
end
if player.Character then refreshHRP(player.Character) end
player.CharacterAdded:Connect(refreshHRP)

local frameTime = 1/30
local playbackRate = 1.0
local isRunning = false
local ReplayFolder = "SUCKARDY"

local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "SUCKARDYReplay"
screenGui.ResetOnSpawn = false

-- fungsi load / replay (tidak diubah)
-- ...

-- === GUI MAIN ===
local frame = Instance.new("Frame",screenGui)
frame.Size = UDim2.new(0,220,0,140) -- diperbesar biar muat tombol speed
frame.Position = UDim2.new(0.5,-110,0.5,-70)
frame.BackgroundColor3 = Color3.fromRGB(15,15,18)
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.05
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1,0,0,28)
titleBar.BackgroundColor3 = Color3.fromRGB(25,25,30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Walk"
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,26,0,26)
closeBtn.Position = UDim2.new(0,2,0,1)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()
    if screenGui then screenGui:Destroy() end
end)

local miniBtn = Instance.new("TextButton", titleBar)
miniBtn.Size = UDim2.new(0,26,0,26)
miniBtn.Position = UDim2.new(1,-28,0,1)
miniBtn.Text = "—"
miniBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
miniBtn.TextColor3 = Color3.fromRGB(255,255,255)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextScaled = true
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0,6)

local startAll = Instance.new("TextButton",frame)
startAll.Size = UDim2.new(1,-20,0,36)
startAll.Position = UDim2.new(0,10,0,40)
startAll.Text = "Load Map"
startAll.BackgroundColor3 = Color3.fromRGB(45,45,45)
startAll.TextColor3 = Color3.fromRGB(255,255,255)
startAll.Font = Enum.Font.GothamBold
startAll.TextScaled = true
Instance.new("UICorner", startAll).CornerRadius = UDim.new(0,8)
startAll.MouseButton1Click:Connect(function()
    showFolderSelector()
end)

-- === SPEED CONTROL ===
local speeds = {1.0, 1.25, 1.5, 2.0, 3.0}
local currentSpeedIndex = 1

local speedBtn = Instance.new("TextButton", frame)
speedBtn.Size = UDim2.new(1,-20,0,36)
speedBtn.Position = UDim2.new(0,10,0,85)
speedBtn.Text = "Speed: x"..tostring(speeds[currentSpeedIndex])
speedBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextScaled = true
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0,8)

speedBtn.MouseButton1Click:Connect(function()
    currentSpeedIndex = currentSpeedIndex + 1
    if currentSpeedIndex > #speeds then
        currentSpeedIndex = 1
    end
    playbackRate = speeds[currentSpeedIndex]
    speedBtn.Text = "Speed: x"..tostring(speeds[currentSpeedIndex])
end)

-- === Bubble toggle ===
local bubbleBtn = Instance.new("TextButton", screenGui)
bubbleBtn.Size = UDim2.new(0,80,0,32)
bubbleBtn.Position = UDim2.new(0,20,0.7,0)
bubbleBtn.Text = "Auto Walk"
bubbleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
bubbleBtn.TextColor3 = Color3.fromRGB(255,255,255)
bubbleBtn.Font = Enum.Font.GothamBold
bubbleBtn.TextScaled = true
bubbleBtn.Visible = false
bubbleBtn.Active = true
bubbleBtn.Draggable = true
Instance.new("UICorner", bubbleBtn).CornerRadius = UDim.new(0,10)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    bubbleBtn.Visible = true
end)

bubbleBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    bubbleBtn.Visible = false
end)
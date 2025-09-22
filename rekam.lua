-- ============ Core Vars ============
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
end)

local HttpService = game:GetService("HttpService")
local records = {}
local isRecording = false
local frameTime = 1/30 -- 30 FPS
local currentFileName = "Replay.json"
local replayFolder = "SUCKARDY"
local selectedReplayFile = nil

if not isfolder(replayFolder) then
    makefolder(replayFolder)
end

-- helper basename
local function baseName(path)
    local p = path:gsub("\\","/")
    local parts = p:split("/")
    return parts[#parts]
end

-- ============ Record / Save ============
local recordBtn

local function startRecord()
    if isRecording then return end
    records = {}
    isRecording = true
    recordBtn.Text = "⏹ Stop Record"
    task.spawn(function()
        while isRecording do
            if hrp then
                table.insert(records, { pos = hrp.CFrame })
            end
            task.wait(frameTime)
        end
    end)
end

local function stopRecord()
    if not isRecording then return end
    isRecording = false
    recordBtn.Text = "⏺ Start Record"
end

local function saveRecordToFolder(folderName)
    if #records == 0 then return end
    local name = currentFileName
    if not name:match("%.json$") then
        name = name..".json"
    end
    local saveData = {}
    for _, frame in ipairs(records) do
        table.insert(saveData, {
            pos = {frame.pos.Position.X, frame.pos.Position.Y, frame.pos.Position.Z},
            rot = {frame.pos:ToOrientation()}
        })
    end
    local targetDir = replayFolder.."/"..folderName
    if not isfolder(targetDir) then
        makefolder(targetDir)
    end
    writefile(targetDir.."/"..name, HttpService:JSONEncode(saveData))
    print("✅ Replay saved to", targetDir.."/"..name)
end

-- ============ GUI ============
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SUCKARDYReplay"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 220)
frame.Position = UDim2.new(0, 20, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Header bar
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, -20, 0, 30)
header.Position = UDim2.new(0, 10, 0, 10)
header.BackgroundTransparency = 1

-- TextBox (kiri)
local textbox = Instance.new("TextBox", header)
textbox.Size = UDim2.new(1, -40, 1, 0)
textbox.Position = UDim2.new(0, 0, 0, 0)
textbox.PlaceholderText = "Nama File (ex: Run1.json)"
textbox.Text = "Replay.json"
textbox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
textbox.BackgroundTransparency = 0.2
textbox.TextColor3 = Color3.new(1,1,1)
textbox.Font = Enum.Font.Gotham
textbox.TextSize = 14
Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 6)
textbox.FocusLost:Connect(function()
    local txt = textbox.Text
    if not txt:match("%.json$") then txt = txt..".json" end
    currentFileName = txt
end)

-- Close Button (kanan)
local closeMain = Instance.new("TextButton", header)
closeMain.Size = UDim2.new(0, 30, 1, 0)
closeMain.Position = UDim2.new(1, -30, 0, 0)
closeMain.Text = "X"
closeMain.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeMain.BackgroundTransparency = 0.2
closeMain.TextColor3 = Color3.new(1,1,1)
closeMain.Font = Enum.Font.Gotham
closeMain.TextSize = 14
Instance.new("UICorner", closeMain).CornerRadius = UDim.new(0,4)
closeMain.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Container buat tombol
local btnContainer = Instance.new("Frame", frame)
btnContainer.Size = UDim2.new(1, -20, 1, -60)
btnContainer.Position = UDim2.new(0, 10, 0, 50)
btnContainer.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", btnContainer)
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Fungsi buat tombol
local function makeBtn(text, callback)
    local btn = Instance.new("TextButton", btnContainer)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Tombol utama
recordBtn = makeBtn("⏺ Start Record", function()
    if isRecording then stopRecord() else startRecord() end
end)

makeBtn("💾 Save Replay", function()
    local folderGui = Instance.new("Frame", gui)
    folderGui.Size = UDim2.new(0, 250, 0, 300)
    folderGui.Position = UDim2.new(0, 270, 0.5, -150)
    folderGui.BackgroundColor3 = Color3.fromRGB(30,30,30)
    folderGui.BackgroundTransparency = 0.2
    folderGui.Active = true
    folderGui.Draggable = true
    Instance.new("UICorner", folderGui).CornerRadius = UDim.new(0,10)

    local closeBtn = Instance.new("TextButton", folderGui)
    closeBtn.Size = UDim2.new(0, 50, 0, 25)
    closeBtn.Position = UDim2.new(1, -55, 0, 5)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)
    closeBtn.MouseButton1Click:Connect(function()
        folderGui:Destroy()
    end)

    local yPos = 40
    for _, path in ipairs(listfiles(replayFolder)) do
        if isfolder(path) then
            local fname = baseName(path)
            local fbtn = Instance.new("TextButton", folderGui)
            fbtn.Size = UDim2.new(1, -20, 0, 30)
            fbtn.Position = UDim2.new(0, 10, 0, yPos)
            fbtn.Text = "📁 "..fname
            fbtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            fbtn.BackgroundTransparency = 0.2
            fbtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", fbtn).CornerRadius = UDim.new(0,6)
            fbtn.MouseButton1Click:Connect(function()
                saveRecordToFolder(fname)
                folderGui:Destroy()
            end)
            yPos = yPos + 40
        end
    end
end)

makeBtn("📂 Load Replay List", function()
    -- isi load list tetap seperti sebelumnya
    print("Load Replay dipanggil (tinggal masukin fungsi loadReplayList kamu di sini)")
end)
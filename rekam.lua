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

-- GANTI fungsi lama dengan ini
local function saveRecordToFolder(folderName)
    if #records == 0 then
        warn("Tidak ada data untuk disimpan. Rekam dulu.")
        return
    end
    local name = currentFileName
    if not name:match("%.json$") then
        name = name..".json"
    end

    -- root atau subfolder
    local targetDir = replayFolder
    if folderName and folderName ~= "" then
        targetDir = replayFolder.."/"..folderName
    end
    if not isfolder(targetDir) then
        makefolder(targetDir)
    end

    local saveData = {}
    for _, frame in ipairs(records) do
        table.insert(saveData, {
            pos = {frame.pos.Position.X, frame.pos.Position.Y, frame.pos.Position.Z},
            rot = {frame.pos:ToOrientation()}
        })
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

-- Header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, -20, 0, 30)
header.Position = UDim2.new(0, 10, 0, 10)
header.BackgroundTransparency = 1

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

local btnContainer = Instance.new("Frame", frame)
btnContainer.Size = UDim2.new(1, -20, 1, -60)
btnContainer.Position = UDim2.new(0, 10, 0, 50)
btnContainer.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", btnContainer)
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

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

-- ============ Popups ============
local replayFrame
local currentFolder = replayFolder

-- SAVE POPUP
local function openSavePopup()
    local folderGui = Instance.new("Frame", gui)
    folderGui.Size = UDim2.new(0, 250, 0, 320)
    folderGui.Position = UDim2.new(0, 270, 0.5, -160)
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
    closeBtn.MouseButton1Click:Connect(function() folderGui:Destroy() end)

    local listFrame = Instance.new("ScrollingFrame", folderGui)
    listFrame.Size = UDim2.new(1, -20, 1, -80)
    listFrame.Position = UDim2.new(0, 10, 0, 40)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0,10)

    -- Opsi simpan ke ROOT
    local rootBtn = Instance.new("TextButton", listFrame)
    rootBtn.Size = UDim2.new(1, -10, 0, 30)
    rootBtn.Text = "📁 (Root) "..replayFolder
    rootBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    rootBtn.BackgroundTransparency = 0.2
    rootBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", rootBtn).CornerRadius = UDim.new(0,6)
    rootBtn.MouseButton1Click:Connect(function()
        saveRecordToFolder("") -- root
        folderGui:Destroy()
    end)

    -- Daftar subfolder
    local ok, entries = pcall(function() return listfiles(replayFolder) end)
    if ok then
        for _, path in ipairs(entries) do
            if isfolder(path) then
                local fname = baseName(path)
                local fbtn = Instance.new("TextButton", listFrame)
                fbtn.Size = UDim2.new(1, -10, 0, 30)
                fbtn.Text = "📁 "..fname
                fbtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
                fbtn.BackgroundTransparency = 0.2
                fbtn.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", fbtn).CornerRadius = UDim.new(0,6)
                fbtn.MouseButton1Click:Connect(function()
                    saveRecordToFolder(fname)
                    folderGui:Destroy()
                end)
            end
        end
    end

    -- Tombol buat folder baru
    local createBtn = Instance.new("TextButton", folderGui)
    createBtn.Size = UDim2.new(1, -20, 0, 30)
    createBtn.Position = UDim2.new(0, 10, 1, -40)
    createBtn.Text = "+ Create Folder"
    createBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    createBtn.BackgroundTransparency = 0.2
    createBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0,6)
    createBtn.MouseButton1Click:Connect(function()
        local newName = "Folder"..tostring(math.random(1000,9999))
        makefolder(replayFolder.."/"..newName)
        folderGui:Destroy()
        openSavePopup() -- refresh
    end)
end

-- LOAD POPUP
local function loadReplayList(path)
    if replayFrame then replayFrame:Destroy() end
    replayFrame = Instance.new("Frame", gui)
    replayFrame.Size = UDim2.new(0, 280, 0, 340)
    replayFrame.Position = UDim2.new(0, 270, 0.5, -170)
    replayFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    replayFrame.BackgroundTransparency = 0.2
    replayFrame.Active = true
    replayFrame.Draggable = true
    Instance.new("UICorner", replayFrame).CornerRadius = UDim.new(0, 10)

    local closeBtn = Instance.new("TextButton", replayFrame)
    closeBtn.Size = UDim2.new(0, 50, 0, 25)
    closeBtn.Position = UDim2.new(1, -55, 0, 5)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)
    closeBtn.MouseButton1Click:Connect(function()
        replayFrame:Destroy()
        replayFrame = nil
    end)

    local listFrame = Instance.new("ScrollingFrame", replayFrame)
    listFrame.Size = UDim2.new(1, -20, 1, -50)
    listFrame.Position = UDim2.new(0, 10, 0, 40)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0,10)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    currentFolder = path or replayFolder

    if currentFolder ~= replayFolder then
        local backBtn = Instance.new("TextButton", listFrame)
        backBtn.Size = UDim2.new(1, -10, 0, 30)
        backBtn.Text = "⬅️ .. (Back)"
        backBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        backBtn.BackgroundTransparency = 0.2
        backBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0,6)
        backBtn.MouseButton1Click:Connect(function()
            local p = currentFolder:gsub("\\","/")
            local parts = p:split("/")
            local parentPath = table.concat(parts, "/", 1, #parts-1)
            if parentPath == "" then parentPath = replayFolder end
            loadReplayList(parentPath)
        end)
    end

    for _, path in ipairs(listfiles(currentFolder)) do
        local name = baseName(path)
        local container = Instance.new("Frame", listFrame)
        container.Size = UDim2.new(1, -10, 0, 30)
        container.BackgroundTransparency = 1

        local itemBtn = Instance.new("TextButton", container)
        itemBtn.Size = UDim2.new(1, -70, 1, 0)
        itemBtn.Text = (isfolder(path) and "📁 " or "📄 ")..name
        itemBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        itemBtn.BackgroundTransparency = 0.2
        itemBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0,6)

        local delBtn = Instance.new("TextButton", container)
        delBtn.Size = UDim2.new(0, 60, 1, 0)
        delBtn.Position = UDim2.new(1, -60, 0, 0)
        delBtn.Text = "DEL"
        delBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        delBtn.BackgroundTransparency = 0.2
        delBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,6)

        if isfolder(path) then
            itemBtn.MouseButton1Click:Connect(function()
                loadReplayList(path)
            end)
            delBtn.MouseButton1Click:Connect(function()
                delfolder(path)
                loadReplayList(currentFolder)
            end)
        else
            itemBtn.MouseButton1Click:Connect(function()
                selectedReplayFile = path
                for _, c in ipairs(listFrame:GetChildren()) do
                    if c:IsA("Frame") then
                        local b = c:FindFirstChildWhichIsA("TextButton")
                        if b then b.BackgroundColor3 = Color3.fromRGB(45,45,45) end
                    end
                end
                itemBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
            end)
            delBtn.MouseButton1Click:Connect(function()
                delfile(path)
                loadReplayList(currentFolder)
            end)
        end
    end
end

-- ============ Buttons ============
recordBtn = makeBtn("⏺ Start Record", function()
    if isRecording then stopRecord() else startRecord() end
end)

makeBtn("💾 Save Replay", function()
    openSavePopup()
end)

makeBtn("📂 Load Replay List", function()
    loadReplayList(replayFolder)
end)
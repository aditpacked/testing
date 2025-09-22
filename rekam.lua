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
local currentFileName = "ISI NAMA MAP.json"
local replayFolder = "SUCKARDY"
local selectedReplayFile = nil

if not isfolder(replayFolder) then
    makefolder(replayFolder)
end

-- helper path basename (cross / or \)
local function baseName(path)
    local p = path:gsub("\\","/")
    local parts = p:split("/")
    return parts[#parts]
end

-- ============ Record / Save ============
local recordBtn -- forward reference for label updates

local function startRecord()
    if isRecording then return end
    records = {}
    isRecording = true
    if recordBtn and recordBtn.Parent then
        recordBtn.Text = "⏹ Stop Record"
    end
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
    if recordBtn and recordBtn.Parent then
        recordBtn.Text = "⏺ Start Record"
    end
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

-- ============ GUI (Dark + 20% opacity) ============
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SUCKARDYReplay"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Close button utama
do
    local closeMain = Instance.new("TextButton", frame)
    closeMain.Size = UDim2.new(0, 25, 0, 25)
    closeMain.Position = UDim2.new(1, -30, 0, 5)
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
end

-- TextBox nama file
local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 10)
textbox.PlaceholderText = "Nama File (ex: Run1.json)"
textbox.Text = "ISI NAMA MAP.json"
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

-- generator tombol (tema gelap + 20% opacity)
local function makeBtn(ref, text, pos, callback, _)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45) -- paksa dark
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    if ref then
        _G[ref] = btn
    end
    return btn
end

-- ============ Popups (dark + 20%) ============
local function makePopup(w, h, px, py)
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, w, 0, h)
    f.Position = UDim2.new(0, px, 0.5, -math.floor(h/2))
    f.BackgroundColor3 = Color3.fromRGB(30,30,30)
    f.BackgroundTransparency = 0.2
    f.Active = true
    f.Draggable = true
    f.ZIndex = 10
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)

    local closeBtn = Instance.new("TextButton", f)
    closeBtn.Size = UDim2.new(0, 50, 0, 25)
    closeBtn.Position = UDim2.new(1, -55, 0, 5)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.ZIndex = 11
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)
    closeBtn.MouseButton1Click:Connect(function() f:Destroy() end)

    return f
end

-- Save Replay popup
local function openSavePopup()
    local folderGui = makePopup(250, 300, 250, 0)
    folderGui.Name = "SaveReplayPopup"

    local yPos = 40
    local ok, entries = pcall(function() return listfiles(replayFolder) end)
    if ok then
        for _, path in ipairs(entries) do
            if isfolder(path) then
                local fname = baseName(path)
                local fbtn = Instance.new("TextButton", folderGui)
                fbtn.Size = UDim2.new(1, -20, 0, 30)
                fbtn.Position = UDim2.new(0, 10, 0, yPos)
                fbtn.Text = "📁 "..fname
                fbtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
                fbtn.BackgroundTransparency = 0.2
                fbtn.TextColor3 = Color3.new(1,1,1)
                fbtn.ZIndex = 11
                Instance.new("UICorner", fbtn).CornerRadius = UDim.new(0,6)
                fbtn.MouseButton1Click:Connect(function()
                    saveRecordToFolder(fname)
                    folderGui:Destroy()
                end)
                yPos = yPos + 40
            end
        end
    end

    local createBtn = Instance.new("TextButton", folderGui)
    createBtn.Size = UDim2.new(1, -20, 0, 30)
    createBtn.Position = UDim2.new(0, 10, 0, yPos)
    createBtn.Text = "+ Create Folder"
    createBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    createBtn.BackgroundTransparency = 0.2
    createBtn.TextColor3 = Color3.new(1,1,1)
    createBtn.ZIndex = 11
    Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0,6)
    createBtn.MouseButton1Click:Connect(function()
        local newName = "Folder"..tostring(math.random(1000,9999))
        makefolder(replayFolder.."/"..newName)
        folderGui:Destroy()
        openSavePopup() -- refresh
    end)
end

-- Load Replay List popup (dengan back & delete & highlight)
local replayFrame
local currentFolder = replayFolder

local function loadReplayList(path)
    if replayFrame then replayFrame:Destroy() end
    replayFrame = makePopup(280, 340, 250, 0)
    replayFrame.Name = "LoadReplayPopup"

    currentFolder = path or replayFolder

    local listFrame = Instance.new("ScrollingFrame", replayFrame)
    listFrame.Size = UDim2.new(1, -20, 1, -50)
    listFrame.Position = UDim2.new(0, 10, 0, 40)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 6
    listFrame.ZIndex = 11

    local layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0,10)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    -- Back jika bukan root
    if currentFolder ~= replayFolder then
        local backBtn = Instance.new("TextButton", listFrame)
        backBtn.Size = UDim2.new(1, -10, 0, 30)
        backBtn.Text = "⬅️ .. (Back)"
        backBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        backBtn.BackgroundTransparency = 0.2
        backBtn.TextColor3 = Color3.new(1,1,1)
        backBtn.ZIndex = 11
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0,6)
        backBtn.MouseButton1Click:Connect(function()
            local p = currentFolder:gsub("\\","/")
            local parts = p:split("/")
            local parentPath = table.concat(parts, "/", 1, math.max(#parts-1,1))
            if parentPath == "" then parentPath = replayFolder end
            loadReplayList(parentPath)
        end)
    end

    local ok, entries = pcall(function() return listfiles(currentFolder) end)
    if not ok then return end

    for _, path in ipairs(entries) do
        local name = baseName(path)
        local container = Instance.new("Frame", listFrame)
        container.Size = UDim2.new(1, -10, 0, 30)
        container.BackgroundTransparency = 1
        container.ZIndex = 11

        local itemBtn = Instance.new("TextButton", container)
        itemBtn.Size = UDim2.new(1, -70, 1, 0)
        itemBtn.Text = (isfolder(path) and "📁 " or "📄 ")..name
        itemBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        itemBtn.BackgroundTransparency = 0.2
        itemBtn.TextColor3 = Color3.new(1,1,1)
        itemBtn.ZIndex = 11
        Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0,6)

        local delBtn = Instance.new("TextButton", container)
        delBtn.Size = UDim2.new(0, 60, 1, 0)
        delBtn.Position = UDim2.new(1, -60, 0, 0)
        delBtn.Text = "DEL"
        delBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        delBtn.BackgroundTransparency = 0.2
        delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.ZIndex = 11
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
                -- highlight
                for _, c in ipairs(listFrame:GetChildren()) do
                    if c:IsA("Frame") then
                        local b = c:FindFirstChildWhichIsA("TextButton")
                        if b then b.BackgroundColor3 = Color3.fromRGB(45,45,45) end
                    end
                end
                itemBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
                itemBtn.BackgroundTransparency = 0.2
            end)
            delBtn.MouseButton1Click:Connect(function()
                delfile(path)
                loadReplayList(currentFolder)
            end)
        end
    end
end

-- ============ Buttons ============
recordBtn = makeBtn("recordBtn", "⏺ Start Record", 50, function()
    if isRecording then stopRecord() else startRecord() end
end)

makeBtn(nil, "💾 Save Replay", 90, function()
    openSavePopup()
end)

makeBtn(nil, "📂 Load Replay List", 130, function()
    loadReplayList(replayFolder)
end)
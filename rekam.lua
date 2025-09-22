local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SUCKARDYReplay"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2 -- 20% opacity
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- 🔘 Close Button utama
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

-- 🔘 TextBox
local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 10)
textbox.PlaceholderText = "Nama File (ex: Run1.json)"
textbox.Text = "isi nama map.json"
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

-- 🔘 Fungsi buat tombol dengan tema gelap
local function makeBtn(ref, text, pos, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45) -- dark theme
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    if ref then _G[ref] = btn end
    return btn
end

-- 🎥 Tombol Record
recordBtn = makeBtn("recordBtn", "⏺ Start Record", 50, function()
    if isRecording then
        stopRecord()
    else
        startRecord()
    end
end)

-- 💾 Save Replay (popup gelap)
makeBtn(nil, "💾 Save Replay", 90, function()
    local folderGui = Instance.new("Frame", gui)
    folderGui.Size = UDim2.new(0, 250, 0, 300)
    folderGui.Position = UDim2.new(0, 250, 0.5, -150)
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
            local fname = path:split("/")[#path:split("/")]
            local fbtn = Instance.new("TextButton", folderGui)
            fbtn.Size = UDim2.new(1, -20, 0, 30)
            fbtn.Position = UDim2.new(0, 10, 0, yPos)
            fbtn.Text = fname
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

    local createBtn = Instance.new("TextButton", folderGui)
    createBtn.Size = UDim2.new(1, -20, 0, 30)
    createBtn.Position = UDim2.new(0, 10, 0, yPos)
    createBtn.Text = "+ Create Folder"
    createBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    createBtn.BackgroundTransparency = 0.2
    createBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0,6)
    createBtn.MouseButton1Click:Connect(function()
        local newName = "Folder"..tostring(math.random(1000,9999))
        makefolder(replayFolder.."/"..newName)
        folderGui:Destroy()
    end)
end)

-- 📂 Load Replay List (popup gelap)
makeBtn(nil, "📂 Load Replay List", 130, function()
    loadReplayList(replayFolder)
end)

-- === UPDATE loadReplayList biar juga dark ===
local replayFrame
function loadReplayList(path)
    if replayFrame then replayFrame:Destroy() end
    replayFrame = Instance.new("Frame", gui)
    replayFrame.Size = UDim2.new(0, 280, 0, 340)
    replayFrame.Position = UDim2.new(0, 250, 0.5, -170)
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
    layout.SortOrder = Enum.SortOrder.Name
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    -- item juga dark
    for _, path in ipairs(listfiles(path)) do
        local name = path:split("/")[#path:split("/")]

        local container = Instance.new("Frame", listFrame)
        container.Size = UDim2.new(1, -10, 0, 30)
        container.BackgroundTransparency = 1

        local itemBtn = Instance.new("TextButton", container)
        itemBtn.Size = UDim2.new(1, -70, 1, 0)
        itemBtn.Text = name
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
    end
end
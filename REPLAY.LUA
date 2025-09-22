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

local ReplayFolder = "Wataxrecord"

---------------------------------------------------------------------
-- GUI ROOT
---------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WataXReplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

---------------------------------------------------------------------
-- FILE HANDLER & REPLAY CORE
---------------------------------------------------------------------
local function loadReplayJSON(folder, fileName)
    local path = ReplayFolder.."/"..folder.."/"..fileName
    if not isfile(path) then
        warn("Replay file tidak ditemukan:", path)
        return {}
    end
    local raw = readfile(path)
    local data = HttpService:JSONDecode(raw)
    local frames = {}
    for _, step in ipairs(data) do
        local pos, rot = step.pos, step.rot
        local cf = CFrame.new(pos[1],pos[2],pos[3]) * CFrame.Angles(rot[1],rot[2],rot[3])
        table.insert(frames, cf)
    end
    return frames
end

local function getReplayFolders()
local name = f:match("[^/\\]+$")
            table.insert(result, name)
        end
    end
    return result
end

local function getReplayFiles(folder)
    local folderPath = ReplayFolder.."/"..folder
    local result = {}
    for _, f in ipairs(listfiles(folderPath)) do
        if f:match("%.json$") then
            table.insert(result, f:match("[^/\\]+$"))
        end
    end
    return result
end

local function getNearestFrameIndex(frames)
    local startIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,cf in ipairs(frames) do
            local d = (cf.Position - pos).Magnitude
            if d < dist then
                dist = d
                startIdx = i
            end
        end
    end
    if startIdx >= #frames then
        startIdx = math.max(1, #frames - 1)
    end
    return startIdx
end

local function lerpCF(fromCF, toCF)
    local duration = frameTime / math.max(0.05, playbackRate)
    local t = 0
    while t < duration do
        if not isRunning then break end
        local dt = task.wait()
        t += dt
        local alpha = math.min(t / duration, 1)
        if hrp and hrp.Parent and hrp:IsDescendantOf(workspace) then
            hrp.CFrame = fromCF:Lerp(toCF, alpha)
        end
    end
end

local function playReplay(frames)
    if #frames < 2 then return end
    if not hrp then refreshHRP() end
    isRunning = true
    local startIdx = getNearestFrameIndex(frames)
    for i = startIdx, #frames - 1 do
        if not isRunning then break end
        lerpCF(frames[i], frames[i+1])
    end
    isRunning = false
end

-- 🔄 versi looping dengan delay 10 detik setelah respawn
local function playChainedReplays(framesList)
    if #framesList == 0 then return end
    isRunning = true

    while isRunning do
        if not hrp then refreshHRP() end
        local used = {}

        local currentFrames
        local nearestDist = math.huge
        for _, frames in ipairs(framesList) do
            if #frames > 0 then
                local d = (frames[1].Position - hrp.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    currentFrames = frames
                end
            end
        end

        while isRunning and currentFrames do
            used[currentFrames] = true
            local startIdx = getNearestFrameIndex(currentFrames)
            for i = startIdx, #currentFrames - 1 do
                if not isRunning then break end
                lerpCF(currentFrames[i], currentFrames[i+1])
            end
            if not isRunning then break end

            local lastCF = currentFrames[#currentFrames]
            local nextFrames, nextDist = nil, math.huge
            for _, frames in ipairs(framesList) do
                if not used[frames] and #frames > 0 then
                    local d = (frames[1].Position - lastCF.Position).Magnitude
                    if d < nextDist then
                        nextDist = d
                        nextFrames = frames
                    end
                end
            end
            currentFrames = nextFrames
        end

        if not isRunning then break end

        local char = player.Character or player.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart")
        task.wait(10)
    end

    isRunning = false
end

local function showReplaySelectorMulti(folder)
    local files = getReplayFiles(folder)
    if #files == 0 then
        warn("Tidak ada replay JSON di folder", folder)
        return
    end

    local Popup = Instance.new("Frame", screenGui)
    Popup.Size = UDim2.new(0, 260, 0, 360)
    Popup.Position = UDim2.new(0.5, -130, 0.5, -180)
    Popup.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0,10)

    local Scroll = Instance.new("ScrollingFrame", Popup)
    Scroll.Size = UDim2.new(1, -10, 1, -50)
    Scroll.Position = UDim2.new(0,5,0,5)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 6
    Scroll.CanvasSize = UDim2.new(0,0,0,#files * 32)

    local layout = Instance.new("UIListLayout", Scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,4)

    local selected = {}

    for _, name in ipairs(files) do
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(1, 0, 0, 28)
        Btn.Text = "[ ] "..name
        Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Btn.TextColor3 = Color3.fromRGB(220,220,220)
        Btn.Font = Enum.Font.Gotham
        Btn.TextScaled = true

        Btn.MouseButton1Click:Connect(function()
            if selected[name] then
                selected[name] = nil
                Btn.Text = "[ ] "..name
            else
                selected[name] = true
                Btn.Text = "[✔] "..name
            end
        end)
    end

    local okBtn = Instance.new("TextButton", Popup)
    okBtn.Size = UDim2.new(1,-10,0,32)
    okBtn.Position = UDim2.new(0,5,1,-37)
    okBtn.Text = "▶ Start"
    okBtn.BackgroundColor3 = Color3.fromRGB(60,120,220)
    okBtn.TextColor3 = Color3.new(1,1,1)
    okBtn.Font = Enum.Font.GothamBold
    okBtn.TextScaled = true
    Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0,8)

    okBtn.MouseButton1Click:Connect(function()
        Popup:Destroy()
        local framesList = {}
        for name,_ in pairs(selected) do
            local frames = loadReplayJSON(folder, name)
            if #frames > 0 then
                table.insert(framesList, frames)
            end
        end
        if #framesList > 0 then
            playChainedReplays(framesList)
        end
    end)
end

local function showFolderSelector()
    local folders = getReplayFolders()
    if #folders == 0 then
        warn("Tidak ada folder di "..ReplayFolder)
        return
    end

    local Popup = Instance.new("Frame", screenGui)
    Popup.Size = UDim2.new(0, 240, 0, 320)
    Popup.Position = UDim2.new(0.5, -120, 0.5, -160)
    Popup.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0,10)

    local Scroll = Instance.new("ScrollingFrame", Popup)
    Scroll.Size = UDim2.new(1, -10, 1, -10)
    Scroll.Position = UDim2.new(0,5,0,5)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 6
    Scroll.CanvasSize = UDim2.new(0,0,0,#folders * 32)

    local layout = Instance.new("UIListLayout", Scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,4)

    for _, folder in ipairs(folders) do
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(1, 0, 0, 28)
        Btn.Text = folder
        Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Btn.TextColor3 = Color3.fromRGB(220,220,220)
        Btn.Font = Enum.Font.Gotham
        Btn.TextScaled = true

        Btn.MouseButton1Click:Connect(function()
            Popup:Destroy()
            showReplaySelectorMulti(folder)
        end)
    end
end

---------------------------------------------------------------------
-- MENU GUI (Dark Minimalis, hanya Start To End)
---------------------------------------------------------------------
local frame = Instance.new("Frame",screenGui)
frame.Size = UDim2.new(0,260,0,120)
frame.Position = UDim2.new(0.5,-130,0.5,-60)
frame.BackgroundColor3 = Color3.fromRGB(15,15,18)
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.05
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel",frame)
title.Size = UDim2.new(1,0,0,32)
title.Text = "WataX Replay"
title.BackgroundColor3 = Color3.fromRGB(25,25,30)
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
Instance.new("UICorner", title).CornerRadius = UDim.new(0,12)

local startAll = Instance.new("TextButton",frame)
startAll.Size = UDim2.new(1,-20,0,42)
startAll.Position = UDim2.new(0,10,0,50)
startAll.Text = "Start To End"
startAll.BackgroundColor3 = Color3.fromRGB(60,120,220)
startAll.TextColor3 = Color3.fromRGB(255,255,255)
startAll.Font = Enum.Font.GothamBold
startAll.TextScaled = true
Instance.new("UICorner", startAll).CornerRadius = UDim.new(0,10)
startAll.MouseButton1Click:Connect(function()
    showFolderSelector()
end)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,26,0,26)
closeBtn.Position = UDim2.new(1,-28,0,2)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()
    if screenGui then screenGui:Destroy() end
end)
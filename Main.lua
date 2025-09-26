-- Simple PlaceId Loader (Block Xeno Executor Only)
-- By Bimz (anti-Xeno only)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- =========================
-- Config
-- =========================
local PlaceScripts = {
    [73347831908825]  = "https://raw.githubusercontent.com/BimzDnu21/Hell-Expedition/refs/heads/main/Hell-Expedition.lua",
    [135406051460913] = "https://raw.githubusercontent.com/BimzDnu21/Run-And-Hide-Script/refs/heads/main/Run-Hide-By-Bimz.lua",
    [9872472334] = "https://raw.githubusercontent.com/BimzDnu21/Main-Script/refs/heads/main/Script/Evade.lua",
    [16208246546] = "https://raw.githubusercontent.com/BimzDnu21/Main-Script/refs/heads/main/Script/Evade.lua",
}

local TargetExecutorLower = "xeno" -- hanya block executor yang mengandung kata ini (case-insensitive)

-- =========================
-- Utility: Notification UI
-- =========================
local function ShowNotification(msg)
    local player = Players.LocalPlayer
    if not player then return end

    local existing = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("WhitelistNotification")
    if existing then
        existing:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "WhitelistNotification"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.ClipsDescendants = true
    frame.Visible = false

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "⚠️ Executor Tidak Didukung"
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.TextWrapped = true
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -20, 0, 60)
    message.Position = UDim2.new(0, 10, 0, 50)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.Gotham
    message.Text = msg or "Executor ini tidak didukung."
    message.TextSize = 14
    message.TextColor3 = Color3.fromRGB(230, 230, 230)
    message.TextWrapped = true
    message.TextYAlignment = Enum.TextYAlignment.Top
    message.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0.5, -50, 1, -40)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.Text = "Okay"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = frame

    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)

    frame.Visible = true
    pcall(function()
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        }):Play()
    end)

    button.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100,100,100)}):Play()
        end)
    end)
    button.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
        end)
    end)

    button.MouseButton1Click:Connect(function()
        pcall(function()
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1
            }):Play()
        end)
        task.wait(0.3)
        pcall(function() gui:Destroy() end)
    end)
end

-- =========================
-- Executor Detection (Xeno only)
-- =========================
local function tryCall(fn)
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

local function detectExecutorName()
    -- Coba identifyexecutor (beberapa executor punya ini)
    local idRes = tryCall(function()
        if identifyexecutor then
            return identifyexecutor()
        end
    end)
    if idRes then
        if type(idRes) == "string" then
            return idRes
        elseif type(idRes) == "table" and idRes[1] then
            return tostring(idRes[1])
        end
    end

    -- Coba getexecutorname
    local getRes = tryCall(function()
        if getexecutorname then
            return getexecutorname()
        end
    end)
    if getRes and type(getRes) == "string" then
        return getRes
    end

    -- Cek global _G dan nama variabel yang mungkin mengindikasikan Xeno
    -- (beberapa executor expose globals / markers)
    local markers = {"XENO", "xeno", "xeno_executor", "XENO_EXECUTOR"}
    for _, name in ipairs(markers) do
        local ok, val = pcall(function() return _G[name] end)
        if ok and val ~= nil then
            return tostring(name)
        end
    end

    -- Jika ada fungsi/variabel lain bernama 'identifyexecutor' atau 'getexecutorname' di global, laporkan itu
    if rawget(_G, "identifyexecutor") ~= nil then return "identifyexecutor" end
    if rawget(_G, "getexecutorname") ~= nil then return "getexecutorname" end

    return "Unknown"
end

local function isXeno(execName)
    if not execName or execName == "" then return false end
    local lower = tostring(execName):lower()
    if lower:find(TargetExecutorLower, 1, true) then
        return true
    end
    return false
end

-- =========================
-- Run detection and take action
-- =========================
local currentExecutor = detectExecutorName() or "Unknown"
if isXeno(currentExecutor) then
    local kickMsg = ("Executor '%s' (Xeno) tidak didukung."):format(tostring(currentExecutor))
    warn("❌ " .. kickMsg)
    pcall(function()
        ShowNotification(kickMsg .. "\nScript tidak bisa dijalankan.")
    end)
    pcall(function()
        if Players.LocalPlayer then
            Players.LocalPlayer:Kick("Executor Xeno tidak didukung.")
        end
    end)
    return
else
    print("✅ Executor aman/terdeteksi: " .. tostring(currentExecutor))
end

-- =========================
-- PlaceId Loader (original)
-- =========================
local placeId = game.PlaceId
local url = PlaceScripts[placeId]

if not url then
    warn(("❌ PlaceId %s tidak whitelisted"):format(tostring(placeId)))
    pcall(function()
        if Players.LocalPlayer then
            Players.LocalPlayer:Kick("PlaceId " .. tostring(placeId) .. " Non Whitelisted")
        end
    end)
    return
end

-- Memuat script remote dengan aman
local ok, err = pcall(function()
    local got, content = pcall(function() return game:HttpGet(url) end)
    if not (got and type(content) == "string") then
        error("Gagal mengunduh remote script: " .. tostring(content))
    end

    local func
    if loadstring then
        func = loadstring(content)
    else
        local okLoad, loaded = pcall(function() return load(content) end)
        if okLoad and type(loaded) == "function" then
            func = loaded
        end
    end

    if not func then error("loadstring/load returned nil") end
    func()
end)

if ok then
    print("✅ Script remote berhasil dimuat dan dijalankan.")
else
    warn("❌ Gagal memuat/jalankan script remote: " .. tostring(err))
end


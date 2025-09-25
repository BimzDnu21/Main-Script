-- Simple PlaceId Loader
-- By Bimz

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PlaceScripts = {
    [73347831908825]  = "https://raw.githubusercontent.com/BimzDnu21/Hell-Expedition/refs/heads/main/Hell-Expedition.lua",
    [135406051460913] = "https://raw.githubusercontent.com/BimzDnu21/Run-And-Hide-Script/refs/heads/main/Run-Hide-By-Bimz.lua",
    [9872472334] = "https://raw.githubusercontent.com/BimzDnu21/Main-Script/refs/heads/main/Script/Evade.lua",
}

local function ShowNotification(msg)
    local player = Players.LocalPlayer
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
    title.Text = "⚠️ Non-Whitelist Place"
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.TextWrapped = true
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -20, 0, 60)
    message.Position = UDim2.new(0, 10, 0, 50)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.Gotham
    message.Text = msg or "PlaceId ini tidak terdaftar / non-whitelist!"
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
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100,100,100)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        gui:Destroy()
    end)
end

-- === Loader ===
local placeId = game.PlaceId
local url = PlaceScripts[placeId]

if not url then
    warn(("❌ PlaceId %s tidak whitelisted"):format(tostring(placeId)))
    game.Players.LocalPlayer:Kick("PlaceId " .. tostring(placeId) .. " Non Whitelisted")
    --ShowNotification("PlaceId " .. tostring(placeId) .. " tidak whitelisted!\nScript tidak bisa dijalankan.")
    return
end

--print(("🔁 PlaceId %s terdeteksi — memuat: %s"):format(tostring(placeId), url))

local ok, err = pcall(function()
    local func = loadstring(game:HttpGet(url))
    if not func then error("loadstring returned nil") end
    func()
end)

if ok then
    print("✅ Script remote berhasil dimuat dan dijalankan.")
else
    warn("❌ Gagal memuat/jalankan script remote: " .. tostring(err))
end
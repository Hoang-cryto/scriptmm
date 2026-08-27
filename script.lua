--[[
    ╔══════════════════════════════════════════╗
                VĂN KIỀU MENU
                    by@VanHoang
    ╚══════════════════════════════════════════╝
    Mobile-friendly LocalScript
    • Logo mở/đóng menu, kéo được
    • Menu kéo bằng Header
    • Resize toàn bộ menu bằng góc ↘
    • Tab Speed & Fly / Xuyên tường / Hành động
    • Fly Speed tối đa 500
    • Walk Speed tối đa 300
    • Fly ▲ / ▼
    • Hành động: menu nhỏ + emote Roblox
    • Tự xử lý Respawn
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local FLY_SPEED_MIN = 10
local FLY_SPEED_MAX = 500
local DEFAULT_FLY_SPEED = 80

local WALK_SPEED_MIN = 8
local WALK_SPEED_MAX = 300
local DEFAULT_WALK_SPEED = 30

local FLY_VERTICAL_SPEED = 120

local PURPLE = Color3.fromRGB(125, 45, 210)
local PURPLE_LIGHT = Color3.fromRGB(190, 110, 255)
local BG = Color3.fromRGB(10, 10, 13)
local PANEL = Color3.fromRGB(17, 17, 22)
local BUTTON = Color3.fromRGB(25, 25, 32)
local BUTTON_ON = Color3.fromRGB(67, 23, 105)
local TEXT = Color3.fromRGB(235, 235, 242)
local SUBTEXT = Color3.fromRGB(145, 130, 160)

--==================================================
-- STATE
--==================================================
local FlyEnabled = false
local SpeedEnabled = false
local NoClipEnabled = false
local ActionsEnabled = false

local FlySpeed = DEFAULT_FLY_SPEED
local WalkSpeed = DEFAULT_WALK_SPEED

local Character
local Humanoid
local RootPart
local FlyVelocity
local FlyGyro

local FlyUp = false
local FlyDown = false
local OriginalCanCollide = {}

--==================================================
-- CHARACTER / NOCLIP / FLY
--==================================================
local function SaveCollision()
    OriginalCanCollide = {}
    if not Character then return end

    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("BasePart") then
            OriginalCanCollide[obj] = obj.CanCollide
        end
    end
end

local function ApplyNoClip()
    if not Character then return end

    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("BasePart") then
            if OriginalCanCollide[obj] == nil then
                OriginalCanCollide[obj] = obj.CanCollide
            end
            obj.CanCollide = false
        end
    end
end

local function RestoreCollision()
    if not Character then return end

    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("BasePart") and OriginalCanCollide[obj] ~= nil then
            obj.CanCollide = OriginalCanCollide[obj]
        end
    end
end

local function StopFly()
    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end
end

local function StartFly()
    if not Character or not RootPart then return end

    StopFly()

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "VanKieuFlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyVelocity.P = 50000
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = RootPart

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "VanKieuFlyGyro"
    FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyGyro.P = 50000
    FlyGyro.CFrame = RootPart.CFrame
    FlyGyro.Parent = RootPart
end

local function SetupCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")

    StopFly()
    SaveCollision()

    Humanoid.WalkSpeed = SpeedEnabled and WalkSpeed or 16

    if NoClipEnabled then
        ApplyNoClip()
    end

    if FlyEnabled then
        task.wait(0.1)
        StartFly()
    end
end

if Player.Character then
    task.spawn(SetupCharacter, Player.Character)
end

Player.CharacterAdded:Connect(function(character)
    task.spawn(SetupCharacter, character)
end)

--==================================================
-- GUI
--==================================================
local oldGui = PlayerGui:FindFirstChild("VanKieuMenu")
if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VanKieuMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

--==================================================
-- LOGO
--==================================================
local LogoButton = Instance.new("TextButton")
LogoButton.Name = "VanKieuLogo"
LogoButton.Size = UDim2.new(0, 50, 0, 50)
LogoButton.Position = UDim2.new(0, 16, 0.5, -25)
LogoButton.BackgroundColor3 = BG
LogoButton.Text = "VK"
LogoButton.TextColor3 = PURPLE_LIGHT
LogoButton.TextSize = 18
LogoButton.Font = Enum.Font.GothamBold
LogoButton.AutoButtonColor = false
LogoButton.Parent = ScreenGui
Corner(LogoButton, 25)

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = PURPLE
LogoStroke.Thickness = 2
LogoStroke.Parent = LogoButton

--==================================================
-- MAIN FRAME
--==================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Corner(MainFrame, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PURPLE
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.1
MainStroke.Parent = MainFrame

-- Scale toàn bộ menu
local MenuScale = Instance.new("UIScale")
MenuScale.Name = "MenuScale"
MenuScale.Scale = 1
MenuScale.Parent = MainFrame

--==================================================
-- HEADER
--==================================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Corner(Header, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 24)
Title.Position = UDim2.new(0, 14, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Văn Kiều Menu"
Title.TextColor3 = TEXT
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -60, 0, 16)
Subtitle.Position = UDim2.new(0, 14, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by@VanHoang"
Subtitle.TextColor3 = SUBTEXT
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -40, 0, 11)
CloseButton.BackgroundColor3 = BUTTON
CloseButton.Text = "×"
CloseButton.TextColor3 = PURPLE_LIGHT
CloseButton.TextSize = 22
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header
Corner(CloseButton, 8)

--==================================================
-- RESIZE HANDLE
--==================================================
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.new(0, 28, 0, 28)
ResizeHandle.Position = UDim2.new(1, -32, 1, -32)
ResizeHandle.BackgroundColor3 = BUTTON
ResizeHandle.Text = "↘"
ResizeHandle.TextColor3 = PURPLE_LIGHT
ResizeHandle.TextSize = 18
ResizeHandle.Font = Enum.Font.GothamBold
ResizeHandle.AutoButtonColor = false
ResizeHandle.ZIndex = 20
ResizeHandle.Parent = MainFrame
Corner(ResizeHandle, 7)

local ResizeStroke = Instance.new("UIStroke")
ResizeStroke.Color = PURPLE
ResizeStroke.Thickness = 1
ResizeStroke.Parent = ResizeHandle

local resizing = false
local resizeStartX = 0
local resizeStartY = 0
local startScale = 1

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        resizing = true
        resizeStartX = input.Position.X
        resizeStartY = input.Position.Y
        startScale = MenuScale.Scale
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not resizing then return end

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then

        local deltaX = input.Position.X - resizeStartX
        local deltaY = input.Position.Y - resizeStartY
        local delta = math.max(deltaX, deltaY)

        local newScale = startScale + delta / 250
        newScale = math.clamp(newScale, 0.65, 1.5)

        MenuScale.Scale = newScale
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

--==================================================
-- TABS
--==================================================
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -24, 0, 38)
Tabs.Position = UDim2.new(0, 12, 0, 65)
Tabs.BackgroundTransparency = 1
Tabs.Parent = MainFrame

local SpeedFlyTab = Instance.new("TextButton")
SpeedFlyTab.Size = UDim2.new(0.34, -4, 1, 0)
SpeedFlyTab.BackgroundColor3 = BUTTON_ON
SpeedFlyTab.Text = "Speed & Fly"
SpeedFlyTab.TextColor3 = TEXT
SpeedFlyTab.TextSize = 11
SpeedFlyTab.Font = Enum.Font.GothamBold
SpeedFlyTab.AutoButtonColor = false
SpeedFlyTab.Parent = Tabs
Corner(SpeedFlyTab, 8)

local NoClipTab = Instance.new("TextButton")
NoClipTab.Size = UDim2.new(0.32, -4, 1, 0)
NoClipTab.Position = UDim2.new(0.34, 4, 0, 0)
NoClipTab.BackgroundColor3 = BUTTON
NoClipTab.Text = "Xuyên tường"
NoClipTab.TextColor3 = SUBTEXT
NoClipTab.TextSize = 11
NoClipTab.Font = Enum.Font.GothamBold
NoClipTab.AutoButtonColor = false
NoClipTab.Parent = Tabs
Corner(NoClipTab, 8)

local ActionsTab = Instance.new("TextButton")
ActionsTab.Size = UDim2.new(0.34, -4, 1, 0)
ActionsTab.Position = UDim2.new(0.66, 4, 0, 0)
ActionsTab.BackgroundColor3 = BUTTON
ActionsTab.Text = "Hành động"
ActionsTab.TextColor3 = SUBTEXT
ActionsTab.TextSize = 11
ActionsTab.Font = Enum.Font.GothamBold
ActionsTab.AutoButtonColor = false
ActionsTab.Parent = Tabs
Corner(ActionsTab, 8)

--==================================================
-- CONTENT
--==================================================
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -115)
Content.Position = UDim2.new(0, 12, 0, 110)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = PURPLE
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 12)
Padding.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)

--==================================================
-- HELPERS
--==================================================
local function CreateToggle(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -4, 0, 42)
    Button.BackgroundColor3 = BUTTON
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent
    Corner(Button, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(43, 43, 52)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = TEXT
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 40, 1, 0)
    Status.Position = UDim2.new(1, -48, 0, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(125, 125, 135)
    Status.TextSize = 11
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button

    local state = false

    local function SetState(value)
        state = value

        if state then
            Button.BackgroundColor3 = BUTTON_ON
            Stroke.Color = PURPLE_LIGHT
            Status.Text = "ON"
            Status.TextColor3 = TEXT
        else
            Button.BackgroundColor3 = BUTTON
            Stroke.Color = Color3.fromRGB(43, 43, 52)
            Status.Text = "OFF"
            Status.TextColor3 = Color3.fromRGB(125, 125, 135)
        end

        callback(state)
    end

    Button.Activated:Connect(function()
        SetState(not state)
    end)

    return {
        Button = Button,
        SetState = SetState
    }
end

local function CreateSlider(parent, name, minValue, maxValue, defaultValue, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -4, 0, 54)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(defaultValue)
    Label.TextColor3 = Color3.fromRGB(190, 190, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -4, 0, 8)
    Track.Position = UDim2.new(0, 2, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Frame
    Corner(Track, 8)

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = PURPLE
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    Fill.Parent = Track
    Corner(Fill, 8)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(238, 230, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Corner(Knob, 20)

    local dragging = false

    local function UpdateFromX(x)
        local startX = Track.AbsolutePosition.X
        local width = Track.AbsoluteSize.X

        if width <= 0 then return end

        local percent = math.clamp((x - startX) / width, 0, 1)
        local value = math.floor(minValue + ((maxValue - minValue) * percent) + 0.5)

        Label.Text = name .. ": " .. tostring(value)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, 0, 0.5, 0)

        callback(value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then

            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)
end

--==================================================
-- PAGES
--==================================================
local SpeedFlyPage = Instance.new("Frame")
SpeedFlyPage.Size = UDim2.new(1, 0, 0, 0)
SpeedFlyPage.BackgroundTransparency = 1
SpeedFlyPage.AutomaticSize = Enum.AutomaticSize.Y
SpeedFlyPage.Parent = Content

local SpeedFlyLayout = Instance.new("UIListLayout")
SpeedFlyLayout.Padding = UDim.new(0, 8)
SpeedFlyLayout.Parent = SpeedFlyPage

local NoClipPage = Instance.new("Frame")
NoClipPage.Size = UDim2.new(1, 0, 0, 0)
NoClipPage.BackgroundTransparency = 1
NoClipPage.AutomaticSize = Enum.AutomaticSize.Y
NoClipPage.Visible = false
NoClipPage.Parent = Content

local NoClipLayout = Instance.new("UIListLayout")
NoClipLayout.Padding = UDim.new(0, 8)
NoClipLayout.Parent = NoClipPage

local ActionsPage = Instance.new("Frame")
ActionsPage.Size = UDim2.new(1, 0, 0, 0)
ActionsPage.BackgroundTransparency = 1
ActionsPage.AutomaticSize = Enum.AutomaticSize.Y
ActionsPage.Visible = false
ActionsPage.Parent = Content

local ActionsLayout = Instance.new("UIListLayout")
ActionsLayout.Padding = UDim.new(0, 8)
ActionsLayout.Parent = ActionsPage

--==================================================
-- SPEED / FLY CONTROLS
--==================================================
local FlyToggle = CreateToggle(SpeedFlyPage, "Fly", function(state)
    FlyEnabled = state

    if state then
        StartFly()
    else
        StopFly()
        FlyUp = false
        FlyDown = false
    end
end)

CreateSlider(
    SpeedFlyPage,
    "Fly Speed",
    FLY_SPEED_MIN,
    FLY_SPEED_MAX,
    DEFAULT_FLY_SPEED,
    function(value)
        FlySpeed = value
    end
)

local SpeedToggle = CreateToggle(SpeedFlyPage, "Speed", function(state)
    SpeedEnabled = state

    if Humanoid then
        Humanoid.WalkSpeed = state and WalkSpeed or 16
    end
end)

CreateSlider(
    SpeedFlyPage,
    "Walk Speed",
    WALK_SPEED_MIN,
    WALK_SPEED_MAX,
    DEFAULT_WALK_SPEED,
    function(value)
        WalkSpeed = value

        if SpeedEnabled and Humanoid then
            Humanoid.WalkSpeed = WalkSpeed
        end
    end
)

--==================================================
-- NOCLIP
--==================================================
local NoClipToggle = CreateToggle(NoClipPage, "Xuyên tường", function(state)
    NoClipEnabled = state

    if state then
        ApplyNoClip()
    else
        RestoreCollision()
    end
end)

local NoClipInfo = Instance.new("TextLabel")
NoClipInfo.Size = UDim2.new(1, -4, 0, 40)
NoClipInfo.BackgroundTransparency = 1
NoClipInfo.Text = "NoClip • Cho phép nhân vật đi xuyên qua vật thể."
NoClipInfo.TextColor3 = SUBTEXT
NoClipInfo.TextSize = 11
NoClipInfo.Font = Enum.Font.Gotham
NoClipInfo.TextWrapped = true
NoClipInfo.TextXAlignment = Enum.TextXAlignment.Left
NoClipInfo.Parent = NoClipPage

--==================================================
-- ACTIONS / EMOTES
--==================================================
local ActionsToggle = CreateToggle(ActionsPage, "Hành động", function(state)
    ActionsEnabled = state
end)

local ActionInfo = Instance.new("TextLabel")
ActionInfo.Size = UDim2.new(1, -4, 0, 35)
ActionInfo.BackgroundTransparency = 1
ActionInfo.Text = "Menu nhỏ bên cạnh màn hình • Emote Roblox có thể nhìn thấy bởi người chơi khác nếu game hỗ trợ."
ActionInfo.TextColor3 = SUBTEXT
ActionInfo.TextSize = 10
ActionInfo.Font = Enum.Font.Gotham
ActionInfo.TextWrapped = true
ActionInfo.TextXAlignment = Enum.TextXAlignment.Left
ActionInfo.Parent = ActionsPage

--==================================================
-- SMALL ACTION MENU
--==================================================
local ActionMenu = Instance.new("Frame")
ActionMenu.Name = "ActionMenu"
ActionMenu.Size = UDim2.new(0, 145, 0, 240)
ActionMenu.Position = UDim2.new(1, -165, 0.5, -120)
ActionMenu.BackgroundColor3 = BG
ActionMenu.BorderSizePixel = 0
ActionMenu.Visible = false
ActionMenu.Parent = ScreenGui
Corner(ActionMenu, 10)

local ActionStroke = Instance.new("UIStroke")
ActionStroke.Color = PURPLE
ActionStroke.Thickness = 1.5
ActionStroke.Parent = ActionMenu

local ActionTitle = Instance.new("TextLabel")
ActionTitle.Size = UDim2.new(1, -20, 0, 30)
ActionTitle.Position = UDim2.new(0, 10, 0, 5)
ActionTitle.BackgroundTransparency = 1
ActionTitle.Text = "⚡ Hành động"
ActionTitle.TextColor3 = TEXT
ActionTitle.TextSize = 14
ActionTitle.Font = Enum.Font.GothamBold
ActionTitle.TextXAlignment = Enum.TextXAlignment.Left
ActionTitle.Parent = ActionMenu

local ActionList = Instance.new("Frame")
ActionList.Size = UDim2.new(1, -16, 1, -45)
ActionList.Position = UDim2.new(0, 8, 0, 38)
ActionList.BackgroundTransparency = 1
ActionList.Parent = ActionMenu

local ActionLayout = Instance.new("UIListLayout")
ActionLayout.Padding = UDim.new(0, 6)
ActionLayout.Parent = ActionList

local function CreateActionButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 30)
    Button.BackgroundColor3 = BUTTON
    Button.Text = text
    Button.TextColor3 = TEXT
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamMedium
    Button.AutoButtonColor = false
    Button.Parent = ActionList
    Corner(Button, 7)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(43, 43, 52)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.Activated:Connect(callback)

    return Button
end

local function PlayEmote(emoteName)
    if not Humanoid then return end

    -- Dùng Humanoid:PlayEmote khi game/rig hỗ trợ.
    local ok = pcall(function()
        Humanoid:PlayEmote(emoteName)
    end)

    if not ok then
        warn("Emote không được game/rig hỗ trợ: " .. tostring(emoteName))
    end
end

CreateActionButton("👋 Vẫy tay", function()
    PlayEmote("wave")
end)

CreateActionButton("😂 Cười", function()
    PlayEmote("laugh")
end)

CreateActionButton("👍 Đồng ý", function()
    PlayEmote("point")
end)

CreateActionButton("💃 Nhảy", function()
    PlayEmote("dance")
end)

CreateActionButton("🕺 Dance 2", function()
    PlayEmote("dance2")
end)

CreateActionButton("🕺 Dance 3", function()
    PlayEmote("dance3")
end)

CreateActionButton("⏹ Dừng", function()
    if Humanoid then
        for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end)

--==================================================
-- TAB SWITCHING
--==================================================
local function SetTabButton(active)
    SpeedFlyTab.BackgroundColor3 = BUTTON
    SpeedFlyTab.TextColor3 = SUBTEXT

    NoClipTab.BackgroundColor3 = BUTTON
    NoClipTab.TextColor3 = SUBTEXT

    ActionsTab.BackgroundColor3 = BUTTON
    ActionsTab.TextColor3 = SUBTEXT

    active.BackgroundColor3 = BUTTON_ON
    active.TextColor3 = TEXT
end

local function ShowSpeedFly()
    SpeedFlyPage.Visible = true
    NoClipPage.Visible = false
    ActionsPage.Visible = false
    SetTabButton(SpeedFlyTab)
    Content.CanvasPosition = Vector2.new(0, 0)
end

local function ShowNoClip()
    SpeedFlyPage.Visible = false
    NoClipPage.Visible = true
    ActionsPage.Visible = false
    SetTabButton(NoClipTab)
    Content.CanvasPosition = Vector2.new(0, 0)
end

local function ShowActions()
    SpeedFlyPage.Visible = false
    NoClipPage.Visible = false
    ActionsPage.Visible = true
    SetTabButton(ActionsTab)
    Content.CanvasPosition = Vector2.new(0, 0)
end

SpeedFlyTab.Activated:Connect(ShowSpeedFly)
NoClipTab.Activated:Connect(ShowNoClip)
ActionsTab.Activated:Connect(ShowActions)

--==================================================
-- FLY MOBILE BUTTONS
--==================================================
local FlyControls = Instance.new("Frame")
FlyControls.Name = "FlyControls"
FlyControls.Size = UDim2.new(0, 75, 0, 115)
FlyControls.Position = UDim2.new(1, -95, 0.5, -57)
FlyControls.BackgroundColor3 = BG
FlyControls.BorderSizePixel = 0
FlyControls.Visible = false
FlyControls.Parent = ScreenGui
Corner(FlyControls, 10)

local FlyControlsStroke = Instance.new("UIStroke")
FlyControlsStroke.Color = PURPLE
FlyControlsStroke.Thickness = 1.5
FlyControlsStroke.Parent = FlyControls

local function CreateFlyButton(text, y)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 61, 0, 48)
    Button.Position = UDim2.new(0, 7, 0, y)
    Button.BackgroundColor3 = PANEL
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(240, 230, 255)
    Button.TextSize = 18
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = FlyControls
    Corner(Button, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = PURPLE_LIGHT
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Button

    return Button
end

local UpButton = CreateFlyButton("▲", 7)
local DownButton = CreateFlyButton("▼", 60)

local function HoldButton(button, setter)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(true)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(false)
        end
    end)
end

HoldButton(UpButton, function(value)
    FlyUp = value
end)

HoldButton(DownButton, function(value)
    FlyDown = value
end)

--==================================================
-- LOGO / CLOSE
--==================================================
LogoButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.Activated:Connect(function()
    MainFrame.Visible = false
end)

--==================================================
-- DRAG SYSTEM
--==================================================
local function MakeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject

    local dragging = false
    local dragStart
    local startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then

            local delta = input.Position - dragStart

            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

MakeDraggable(LogoButton)
MakeDraggable(MainFrame, Header)
MakeDraggable(FlyControls)
MakeDraggable(ActionMenu, ActionTitle)

--==================================================
-- SYSTEM LOOP
--==================================================
RunService.RenderStepped:Connect(function()
    FlyControls.Visible = FlyEnabled
    ActionMenu.Visible = ActionsEnabled

    if not Character or not Character.Parent then
        return
    end

    if NoClipEnabled then
        ApplyNoClip()
    end

    if SpeedEnabled and Humanoid and Humanoid.Parent then
        if Humanoid.WalkSpeed ~= WalkSpeed then
            Humanoid.WalkSpeed = WalkSpeed
        end
    end

    if FlyEnabled and RootPart and RootPart.Parent and FlyVelocity and FlyGyro then
        local Camera = workspace.CurrentCamera
        if not Camera then return end

        local horizontalDirection = Vector3.zero

        if Humanoid then
            horizontalDirection = Humanoid.MoveDirection
        end

        horizontalDirection = Vector3.new(
            horizontalDirection.X,
            0,
            horizontalDirection.Z
        )

        if horizontalDirection.Magnitude > 1 then
            horizontalDirection = horizontalDirection.Unit
        end

        local verticalVelocity = 0

        if FlyUp then
            verticalVelocity = FLY_VERTICAL_SPEED
        elseif FlyDown then
            verticalVelocity = -FLY_VERTICAL_SPEED
        end

        FlyVelocity.Velocity =
            (horizontalDirection * FlySpeed)
            + Vector3.new(0, verticalVelocity, 0)

        local look = Camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)

        if flatLook.Magnitude > 0.01 then
            FlyGyro.CFrame =
                CFrame.lookAt(
                    RootPart.Position,
                    RootPart.Position + flatLook.Unit
                )
        end
    end
end)

print("Văn Kiều Menu Loaded • by@VanHoang")

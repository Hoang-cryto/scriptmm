--[[
    ╔══════════════════════════════════════════╗
                VĂN KIỀU MENU
                    by@VanHoang
    ╚══════════════════════════════════════════╝
    Mobile-friendly LocalScript
    • Logo mở/đóng menu (Kéo di chuyển được)
    • Menu hình chữ nhật (Kéo di chuyển bằng Header)
    • Tab "Speed and Fly" & "Xuyên tường"
    • Fly + Fly Speed tối đa 500
    • Speed + Walk Speed tối đa 300
    • Cụm nút ▲ / ▼ nằm trong khung vuông (Kéo di chuyển được)
    • Touch + PC Support
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
-- CHARACTER / NOCLIP / FLY LOGIC
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

    if SpeedEnabled then
        Humanoid.WalkSpeed = WalkSpeed
    else
        Humanoid.WalkSpeed = 16
    end

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
-- SCREEN GUI
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

--==================================================
-- LOGO (TOGGLE MENU)
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

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = PURPLE
LogoStroke.Thickness = 2
LogoStroke.Parent = LogoButton

--==================================================
-- MAIN FRAME (RECTANGLE & DRAGGABLE)
--==================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 380) -- Hình chữ nhật chuẩn
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -190)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PURPLE
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.1
MainStroke.Parent = MainFrame

--==================================================
-- HEADER (DRAG HANDLE)
--==================================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

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

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

--==================================================
-- TABS
--==================================================
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -24, 0, 38)
Tabs.Position = UDim2.new(0, 12, 0, 65)
Tabs.BackgroundTransparency = 1
Tabs.Parent = MainFrame

local SpeedFlyTab = Instance.new("TextButton")
SpeedFlyTab.Size = UDim2.new(0.5, -4, 1, 0)
SpeedFlyTab.Position = UDim2.new(0, 0, 0, 0)
SpeedFlyTab.BackgroundColor3 = BUTTON_ON
SpeedFlyTab.Text = "Speed & Fly"
SpeedFlyTab.TextColor3 = TEXT
SpeedFlyTab.TextSize = 12
SpeedFlyTab.Font = Enum.Font.GothamBold
SpeedFlyTab.AutoButtonColor = false
SpeedFlyTab.Parent = Tabs

local SpeedFlyCorner = Instance.new("UICorner")
SpeedFlyCorner.CornerRadius = UDim.new(0, 8)
SpeedFlyCorner.Parent = SpeedFlyTab

local NoClipTab = Instance.new("TextButton")
NoClipTab.Size = UDim2.new(0.5, -4, 1, 0)
NoClipTab.Position = UDim2.new(0.5, 4, 0, 0)
NoClipTab.BackgroundColor3 = BUTTON
NoClipTab.Text = "Xuyên tường"
NoClipTab.TextColor3 = SUBTEXT
NoClipTab.TextSize = 12
NoClipTab.Font = Enum.Font.GothamBold
NoClipTab.AutoButtonColor = false
NoClipTab.Parent = Tabs

local NoClipCorner = Instance.new("UICorner")
NoClipCorner.CornerRadius = UDim.new(0, 8)
NoClipCorner.Parent = NoClipTab

--==================================================
-- CONTENT / SCROLLBAR
--==================================================
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -115)
Content.Position = UDim2.new(0, 12, 0, 110)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = PURPLE
Content.ScrollingDirection = Enum.ScrollingDirection.Y
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
-- HELPERS FOR UI
--==================================================
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

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
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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
SpeedFlyLayout.SortOrder = Enum.SortOrder.LayoutOrder
SpeedFlyLayout.Parent = SpeedFlyPage

local NoClipPage = Instance.new("Frame")
NoClipPage.Size = UDim2.new(1, 0, 0, 0)
NoClipPage.BackgroundTransparency = 1
NoClipPage.AutomaticSize = Enum.AutomaticSize.Y
NoClipPage.Visible = false
NoClipPage.Parent = Content

local NoClipLayout = Instance.new("UIListLayout")
NoClipLayout.Padding = UDim.new(0, 8)
NoClipLayout.SortOrder = Enum.SortOrder.LayoutOrder
NoClipLayout.Parent = NoClipPage

--==================================================
-- CONTROLS
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

CreateSlider(SpeedFlyPage, "Fly Speed", FLY_SPEED_MIN, FLY_SPEED_MAX, DEFAULT_FLY_SPEED, function(value)
    FlySpeed = value
end)

local SpeedToggle = CreateToggle(SpeedFlyPage, "Speed", function(state)
    SpeedEnabled = state
    if Humanoid then
        Humanoid.WalkSpeed = state and WalkSpeed or 16
    end
end)

CreateSlider(SpeedFlyPage, "Walk Speed", WALK_SPEED_MIN, WALK_SPEED_MAX, DEFAULT_WALK_SPEED, function(value)
    WalkSpeed = value
    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
    end
end)

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
-- TAB SWITCHING
--==================================================
local function ShowSpeedFly()
    SpeedFlyPage.Visible = true
    NoClipPage.Visible = false
    SpeedFlyTab.BackgroundColor3 = BUTTON_ON
    SpeedFlyTab.TextColor3 = TEXT
    NoClipTab.BackgroundColor3 = BUTTON
    NoClipTab.TextColor3 = SUBTEXT
    Content.CanvasPosition = Vector2.new(0, 0)
end

local function ShowNoClip()
    SpeedFlyPage.Visible = false
    NoClipPage.Visible = true
    NoClipTab.BackgroundColor3 = BUTTON_ON
    NoClipTab.TextColor3 = TEXT
    SpeedFlyTab.BackgroundColor3 = BUTTON
    SpeedFlyTab.TextColor3 = SUBTEXT
    Content.CanvasPosition = Vector2.new(0, 0)
end

SpeedFlyTab.Activated:Connect(ShowSpeedFly)
NoClipTab.Activated:Connect(ShowNoClip)

--==================================================
-- FLY MOBILE BUTTONS (KHUNG VUÔNG & KÉO DI CHUYỂN)
--==================================================
local FlyControls = Instance.new("Frame")
FlyControls.Name = "FlyControls"
FlyControls.Size = UDim2.new(0, 75, 0, 115) -- Khung vuông bao bọc nút
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
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(true)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(false)
        end
    end)
end

HoldButton(UpButton, function(value) FlyUp = value end)
HoldButton(DownButton, function(value) FlyDown = value end)

--==================================================
-- LOGO / CLOSE TOGGLE
--==================================================
LogoButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.Activated:Connect(function()
    MainFrame.Visible = false
end)

--==================================================
-- SYSTEM LOGIC LOOP
--==================================================
RunService.RenderStepped:Connect(function()
    FlyControls.Visible = FlyEnabled

    if not Character or not Character.Parent then
        return
    end

    -- NOCLIP
    if NoClipEnabled then
        ApplyNoClip()
    end

    -- SPEED
    if SpeedEnabled and Humanoid and Humanoid.Parent then
        if Humanoid.WalkSpeed ~= WalkSpeed then
            Humanoid.WalkSpeed = WalkSpeed
        end
    end

    -- FLY
    if FlyEnabled and RootPart and RootPart.Parent and FlyVelocity and FlyGyro then
        local Camera = workspace.CurrentCamera
        if not Camera then return end

        local horizontalDirection = Vector3.zero
        if Humanoid then
            horizontalDirection = Humanoid.MoveDirection
        end

        horizontalDirection = Vector3.new(horizontalDirection.X, 0, horizontalDirection.Z)
        if horizontalDirection.Magnitude > 1 then
            horizontalDirection = horizontalDirection.Unit
        end

        local verticalVelocity = 0
        if FlyUp then
            verticalVelocity = FLY_VERTICAL_SPEED
        elseif FlyDown then
            verticalVelocity = -FLY_VERTICAL_SPEED
        end

        FlyVelocity.Velocity = (horizontalDirection * FlySpeed) + Vector3.new(0, verticalVelocity, 0)

        local look = Camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.01 then
            FlyGyro.CFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + flatLook.Unit)
        end
    end
end)

--==================================================
-- HELPER DRAGGABLE SYSTEM (DRAG MỌI FRAME TÙY CHỌN)
--==================================================
local function MakeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
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
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- KÍCH HOẠT DI CHUYỂN BẰNG TAY CHO CÁC PHẦN TỬ
MakeDraggable(LogoButton)                  -- Kéo thả Logo
MakeDraggable(MainFrame, Header)          -- Kéo thả Menu chính qua thanh Header
MakeDraggable(FlyControls)                 -- Kéo thả Khung vuông nút Fly

print("Văn Kiều Menu Loaded • by@VanHoang")
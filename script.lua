--[[
    ╔══════════════════════════════════════╗
              VĂN KIỀU MENU
                 by@VanHoang
    ╚══════════════════════════════════════╝

    Mobile-friendly LocalScript
    Chức năng:
    • Fly + chỉnh Fly Speed
    • Speed + chỉnh Walk Speed
    • NoClip
    • Minimize / mở lại menu
    • Hỗ trợ Touch + PC
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
local FLY_SPEED_MAX = 100
local DEFAULT_FLY_SPEED = 30

local WALK_SPEED_MIN = 8
local WALK_SPEED_MAX = 100
local DEFAULT_WALK_SPEED = 16

local PURPLE = Color3.fromRGB(125, 45, 210)
local PURPLE_LIGHT = Color3.fromRGB(180, 100, 255)

local BG = Color3.fromRGB(12, 12, 15)
local PANEL = Color3.fromRGB(18, 18, 23)
local BUTTON = Color3.fromRGB(27, 27, 34)
local BUTTON_ON = Color3.fromRGB(72, 25, 110)

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

local OriginalCanCollide = {}

--==================================================
-- CHARACTER
--==================================================

local function SetupCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")

    OriginalCanCollide = {}

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            OriginalCanCollide[obj] = obj.CanCollide
        end
    end

    if SpeedEnabled then
        Humanoid.WalkSpeed = WalkSpeed
    end

    if NoClipEnabled then
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    end
end

if Player.Character then
    task.spawn(SetupCharacter, Player.Character)
end

Player.CharacterAdded:Connect(function(character)

    -- Tắt fly cũ nếu nhân vật chết
    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    SetupCharacter(character)
end)

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VanKieuMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- MAIN FRAME
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 500)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PURPLE
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.15
MainStroke.Parent = MainFrame

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 75)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 35)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Văn Kiều"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 25
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -80, 0, 20)
Subtitle.Position = UDim2.new(0, 21, 0, 43)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by@VanHoang"
Subtitle.TextColor3 = Color3.fromRGB(145, 120, 170)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

--==================================================
-- MINIMIZE BUTTON
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 42, 0, 42)
Minimize.Position = UDim2.new(1, -55, 0, 15)
Minimize.BackgroundColor3 = BUTTON
Minimize.Text = "—"
Minimize.TextColor3 = PURPLE_LIGHT
Minimize.TextSize = 22
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = Minimize

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -30, 1, -90)
Content.Position = UDim2.new(0, 15, 0, 80)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = PURPLE
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(
        0,
        0,
        0,
        Layout.AbsoluteContentSize.Y + 20
    )
end)

--==================================================
-- TOGGLE CREATOR
--==================================================

local function CreateToggle(text, callback)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.BackgroundColor3 = BUTTON
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -75, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(225, 225, 230)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 45, 1, 0)
    Status.Position = UDim2.new(1, -55, 0, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(130, 130, 140)
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button

    local State = false

    local function SetState(value)
        State = value

        if State then
            Button.BackgroundColor3 = BUTTON_ON
            Stroke.Color = PURPLE_LIGHT
            Status.Text = "ON"
            Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = BUTTON
            Stroke.Color = Color3.fromRGB(45, 45, 55)
            Status.Text = "OFF"
            Status.TextColor3 = Color3.fromRGB(130, 130, 140)
        end

        callback(State)
    end

    Button.Activated:Connect(function()
        SetState(not State)
    end)

    return {
        Button = Button,
        SetState = SetState
    }
end

--==================================================
-- SLIDER
--==================================================

local function CreateSlider(name, minValue, maxValue, defaultValue, callback)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 65)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(defaultValue)
    Label.TextColor3 = Color3.fromRGB(190, 190, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, 0, 0, 10)
    Track.Position = UDim2.new(0, 0, 0, 38)
    Track.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Frame

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = PURPLE
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue),
        0,
        1,
        0
    )
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue),
        0,
        0.5,
        0
    )
    Knob.BackgroundColor3 = Color3.fromRGB(235, 225, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local dragging = false

    local function Update(input)

        local x = input.Position.X
        local start = Track.AbsolutePosition.X
        local width = Track.AbsoluteSize.X

        local percent = math.clamp(
            (x - start) / width,
            0,
            1
        )

        local value = math.floor(
            minValue + ((maxValue - minValue) * percent) + 0.5
        )

        Label.Text = name .. ": " .. tostring(value)

        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, 0, 0.5, 0)

        callback(value)
    end

    Track.Activated:Connect(function()
        -- Mobile tap support
        local mousePos = UserInputService:GetMouseLocation()

        local fakeInput = {
            Position = Vector3.new(mousePos.X, mousePos.Y, 0)
        }

        Update(fakeInput)
    end)

    Track.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            Update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then

            Update(input)
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
-- FLY MOBILE CONTROL
--==================================================

local FlyUp = false
local FlyDown = false

local FlyControls = Instance.new("Frame")
FlyControls.Name = "FlyControls"
FlyControls.Size = UDim2.new(0, 150, 0, 105)
FlyControls.Position = UDim2.new(1, -170, 1, -125)
FlyControls.BackgroundTransparency = 1
FlyControls.Visible = false
FlyControls.Parent = ScreenGui

local function CreateFlyButton(text, position)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 65, 0, 45)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(25, 20, 32)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(240, 230, 255)
    Button.TextSize = 18
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = FlyControls

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = PURPLE
    Stroke.Thickness = 1
    Stroke.Parent = Button

    return Button
end

local UpButton = CreateFlyButton(
    "▲",
    UDim2.new(0, 75, 0, 0)
)

local DownButton = CreateFlyButton(
    "▼",
    UDim2.new(0, 75, 0, 55)
)

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
-- FLY
--==================================================

local function StartFly()

    if not Character or not RootPart then
        return
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
    end

    if FlyGyro then
        FlyGyro:Destroy()
    end

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "VanKieuFlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = RootPart

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "VanKieuFlyGyro"
    FlyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyGyro.P = 50000
    FlyGyro.CFrame = RootPart.CFrame
    FlyGyro.Parent = RootPart

    FlyControls.Visible = true
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

    FlyControls.Visible = false
end

--==================================================
-- NOCLIP
--==================================================

local function ApplyNoClip()

    if not Character then
        return
    end

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

    if not Character then
        return
    end

    for _, obj in ipairs(Character:GetDescendants()) do

        if obj:IsA("BasePart") then

            if OriginalCanCollide[obj] ~= nil then
                obj.CanCollide = OriginalCanCollide[obj]
            end
        end
    end
end

--==================================================
-- BUTTONS
--==================================================

local FlyToggle = CreateToggle("Fly", function(state)

    FlyEnabled = state

    if FlyEnabled then
        StartFly()
    else
        StopFly()
    end
end)

CreateSlider(
    "Fly Speed",
    FLY_SPEED_MIN,
    FLY_SPEED_MAX,
    DEFAULT_FLY_SPEED,
    function(value)
        FlySpeed = value
    end
)

local SpeedToggle = CreateToggle("Speed", function(state)

    SpeedEnabled = state

    if Humanoid then

        if SpeedEnabled then
            Humanoid.WalkSpeed = WalkSpeed
        else
            Humanoid.WalkSpeed = 16
        end

    end
end)

CreateSlider(
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

local NoClipToggle = CreateToggle("NoClip", function(state)

    NoClipEnabled = state

    if NoClipEnabled then
        ApplyNoClip()
    else
        RestoreCollision()
    end
end)

--==================================================
-- MINIMIZE
--==================================================

local Minimized = false

Minimize.Activated:Connect(function()

    Minimized = not Minimized

    Content.Visible = not Minimized

    if Minimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 75)
        Minimize.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 500)
        Minimize.Text = "—"
    end
end)

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function()

    if not Character or not Character.Parent then
        return
    end

    -- NOCLIP
    if NoClipEnabled then
        ApplyNoClip()
    end

    -- FLY
    if FlyEnabled
        and RootPart
        and RootPart.Parent
        and FlyVelocity
        and FlyGyro then

        local Camera = workspace.CurrentCamera

        if not Camera then
            return
        end

        local direction = Vector3.zero

        -- Roblox mobile joystick
        if Humanoid then
            local moveDirection = Humanoid.MoveDirection

            if moveDirection.Magnitude > 0 then
                direction += moveDirection
            end
        end

        -- Camera-based forward direction
        if direction.Magnitude > 0 then

            local horizontal = Vector3.new(
                direction.X,
                0,
                direction.Z
            )

            if horizontal.Magnitude > 0 then
                direction = horizontal.Unit
            end
        end

        -- Mobile lên / xuống
        if FlyUp then
            direction += Vector3.new(0, 1, 0)
        end

        if FlyDown then
            direction += Vector3.new(0, -1, 0)
        end

        -- Giới hạn vector
        if direction.Magnitude > 1 then
            direction = direction.Unit
        end

        FlyVelocity.Velocity = direction * FlySpeed

        -- Nhìn theo camera
        FlyGyro.CFrame = Camera.CFrame
    end
end)

--==================================================
-- INITIAL SETTINGS
--==================================================

MainFrame.Visible = true

print("╔══════════════════════════════════╗")
print("       Văn Kiều Menu Loaded")
print("             by@VanHoang")
print("╚══════════════════════════════════╝")

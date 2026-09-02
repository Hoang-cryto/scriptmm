--[[
==================================================
        VANHOANG HUB - MOVEMENT MENU
        Fly / Speed / Noclip
        PC + MOBILE
        Range: 1 - 500
==================================================
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local FlyEnabled = false
local SpeedEnabled = false
local NoclipEnabled = false

local FlySpeed = 50
local WalkSpeed = 50

local Character
local Humanoid
local RootPart

local function SetupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end

SetupCharacter(Player.Character or Player.CharacterAdded:Wait())

Player.CharacterAdded:Connect(function(char)
    SetupCharacter(char)
end)

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VanHoangHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- LOGO
--------------------------------------------------

local Logo = Instance.new("TextButton")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 65, 0, 65)
Logo.Position = UDim2.new(0, 20, 0.5, -32)
Logo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Logo.Text = "VH"
Logo.TextColor3 = Color3.fromRGB(255,255,255)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold
Logo.AutoButtonColor = true
Logo.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1,0)
LogoCorner.Parent = Logo

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Thickness = 2
LogoStroke.Color = Color3.fromRGB(0,255,150)
LogoStroke.Parent = Logo

--------------------------------------------------
-- MAIN MENU
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = UDim2.new(0, 360, 0, 300)
Main.Position = UDim2.new(0.5, -180, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(0,255,150)
MainStroke.Parent = Main

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,45)
Header.BackgroundColor3 = Color3.fromRGB(28,28,28)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,1,0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ VANHOANG HUB"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-43,0,2)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255,80,80)
Close.TextSize = 28
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

--------------------------------------------------
-- TAB BAR
--------------------------------------------------

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0,100,1,-55)
TabBar.Position = UDim2.new(0,8,0,50)
TabBar.BackgroundColor3 = Color3.fromRGB(27,27,27)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0,7)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabLayout.Parent = TabBar

local function CreateTab(text)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0,88,0,48)
    Button.BackgroundColor3 = Color3.fromRGB(38,38,38)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = TabBar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Button

    return Button
end

local FlyTab = CreateTab("✈️ FLY")
local SpeedTab = CreateTab("⚡ SPEED")
local NoclipTab = CreateTab("👻 NOCLIP")

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-125,1,-55)
Content.Position = UDim2.new(0,118,0,50)
Content.BackgroundColor3 = Color3.fromRGB(25,25,25)
Content.BorderSizePixel = 0
Content.Parent = Main

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0,10)
ContentCorner.Parent = Content

--------------------------------------------------
-- UTILITY
--------------------------------------------------

local function ClearContent()
    for _,v in ipairs(Content:GetChildren()) do
        v:Destroy()
    end
end

local function CreateLabel(text, pos)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,-30,0,35)
    Label.Position = pos
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220,220,220)
    Label.TextSize = 16
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Content
    return Label
end

local function CreateBox(value, pos)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1,-30,0,42)
    Box.Position = pos
    Box.BackgroundColor3 = Color3.fromRGB(38,38,38)
    Box.TextColor3 = Color3.fromRGB(255,255,255)
    Box.PlaceholderColor3 = Color3.fromRGB(150,150,150)
    Box.Text = tostring(value)
    Box.TextSize = 16
    Box.Font = Enum.Font.Gotham
    Box.ClearTextOnFocus = false
    Box.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Box

    return Box
end

local function CreateToggle(text, pos, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-30,0,45)
    Button.Position = pos
    Button.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Button.Text = text .. " : OFF"
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.TextSize = 15
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Button

    local State = false

    Button.MouseButton1Click:Connect(function()
        State = not State

        if State then
            Button.Text = text .. " : ON"
            Button.BackgroundColor3 = Color3.fromRGB(0,130,80)
        else
            Button.Text = text .. " : OFF"
            Button.BackgroundColor3 = Color3.fromRGB(45,45,45)
        end

        callback(State)
    end)

    return Button
end

--------------------------------------------------
-- FLY PAGE
--------------------------------------------------

local FlySpeedBox

local function ShowFly()
    ClearContent()

    CreateLabel("✈️ Fly Control", UDim2.new(0,15,0,10))

    CreateLabel(
        "Fly Speed (1 - 500)",
        UDim2.new(0,15,0,55)
    )

    FlySpeedBox = CreateBox(
        FlySpeed,
        UDim2.new(0,15,0,90)
    )

    FlySpeedBox.FocusLost:Connect(function()
        local n = tonumber(FlySpeedBox.Text)

        if n then
            FlySpeed = math.clamp(math.floor(n),1,500)
            FlySpeedBox.Text = tostring(FlySpeed)
        else
            FlySpeedBox.Text = tostring(FlySpeed)
        end
    end)

    CreateToggle(
        "✈️ Fly",
        UDim2.new(0,15,0,145),
        function(state)
            FlyEnabled = state
        end
    )

    CreateLabel(
        "Hướng bay theo camera",
        UDim2.new(0,15,0,205)
    )

    CreateLabel(
        "Nhìn lên = bay lên\nNhìn xuống = bay xuống",
        UDim2.new(0,15,0,235)
    )
end

--------------------------------------------------
-- SPEED PAGE
--------------------------------------------------

local function ShowSpeed()
    ClearContent()

    CreateLabel(
        "⚡ Speed Control",
        UDim2.new(0,15,0,10)
    )

    CreateLabel(
        "Speed (1 - 500)",
        UDim2.new(0,15,0,55)
    )

    local Box = CreateBox(
        WalkSpeed,
        UDim2.new(0,15,0,90)
    )

    Box.FocusLost:Connect(function()
        local n = tonumber(Box.Text)

        if n then
            WalkSpeed = math.clamp(math.floor(n),1,500)
            Box.Text = tostring(WalkSpeed)
        else
            Box.Text = tostring(WalkSpeed)
        end
    end)

    CreateToggle(
        "⚡ Speed",
        UDim2.new(0,15,0,145),
        function(state)
            SpeedEnabled = state

            if Humanoid then
                if state then
                    Humanoid.WalkSpeed = WalkSpeed
                else
                    Humanoid.WalkSpeed = 16
                end
            end
        end
    )

    CreateLabel(
        "Tốc độ tối đa: 500",
        UDim2.new(0,15,0,205)
    )
end

--------------------------------------------------
-- NOCLIP PAGE
--------------------------------------------------

local function ShowNoclip()
    ClearContent()

    CreateLabel(
        "👻 Noclip",
        UDim2.new(0,15,0,10)
    )

    CreateLabel(
        "Đi xuyên qua vật thể",
        UDim2.new(0,15,0,55)
    )

    CreateToggle(
        "👻 Xuyên tường",
        UDim2.new(0,15,0,105),
        function(state)
            NoclipEnabled = state
        end
    )

    CreateLabel(
        "Khi bật, các bộ phận nhân vật\nsẽ không va chạm với tường.",
        UDim2.new(0,15,0,165)
    )
end

--------------------------------------------------
-- TAB EVENTS
--------------------------------------------------

FlyTab.MouseButton1Click:Connect(ShowFly)
SpeedTab.MouseButton1Click:Connect(ShowSpeed)
NoclipTab.MouseButton1Click:Connect(ShowNoclip)

ShowFly()

--------------------------------------------------
-- FLY SYSTEM
--------------------------------------------------

local BodyVelocity
local BodyGyro

local function StartFly()
    if not RootPart then return end

    if BodyVelocity then
        BodyVelocity:Destroy()
    end

    if BodyGyro then
        BodyGyro:Destroy()
    end

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = RootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    BodyGyro.P = 50000
    BodyGyro.Parent = RootPart
end

local function StopFly()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

--------------------------------------------------
-- MOVEMENT
--------------------------------------------------

RunService.RenderStepped:Connect(function()
    if not Character or not Humanoid or not RootPart then
        return
    end

    ------------------------------------------------
    -- SPEED
    ------------------------------------------------

    if SpeedEnabled then
        Humanoid.WalkSpeed = WalkSpeed
    end

    ------------------------------------------------
    -- NOCLIP
    ------------------------------------------------

    if NoclipEnabled then
        for _,part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    ------------------------------------------------
    -- FLY
    ------------------------------------------------

    if FlyEnabled then

        if not BodyVelocity then
            StartFly()
        end

        Humanoid.PlatformStand = true

        local CamCF = Camera.CFrame

        -- Hướng nhìn của camera
        local Direction = CamCF.LookVector

        BodyVelocity.Velocity =
            Direction * FlySpeed

        -- Xoay nhân vật theo camera
        BodyGyro.CFrame =
            CFrame.new(
                RootPart.Position,
                RootPart.Position + Direction
            )

    else

        if BodyVelocity then
            StopFly()
        end

    end
end)

--------------------------------------------------
-- LOGO OPEN/CLOSE
--------------------------------------------------

Logo.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

--------------------------------------------------
-- DRAG FUNCTION
--------------------------------------------------

local function MakeDraggable(Object)

    local Dragging = false
    local DragStart
    local StartPosition

    local function Update(input)
        local Delta = input.Position - DragStart

        Object.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end

    Object.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true
            DragStart = input.Position
            StartPosition = Object.Position

            input.Changed:Connect(function()

                if input.UserInputState ==
                    Enum.UserInputState.End then

                    Dragging = false

                end

            end)

        end

    end)

    UIS.InputChanged:Connect(function(input)

        if Dragging and (
            input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch
        ) then

            Update(input)

        end

    end)

end

MakeDraggable(Logo)
MakeDraggable(Header)

--------------------------------------------------
-- RESET CHARACTER
--------------------------------------------------

Player.CharacterAdded:Connect(function(char)

    task.wait(0.5)

    SetupCharacter(char)

    if SpeedEnabled then
        Humanoid.WalkSpeed = WalkSpeed
    end

end)

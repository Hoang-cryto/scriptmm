-- aov.lua
-- Mobile-friendly Roblox Hub (for your own Roblox experience/testing)
-- Features: draggable UI, touch resize, speed, mobile fly controls, visual FOV.
-- Note: This is designed as a LocalScript for an experience you control.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG / STATE
-- =========================================================
local SpeedEnabled = false
local WalkSpeedValue = 16

local FlyEnabled = false
local FlySpeedValue = 50

local FOVEnabled = false
local FOVRadius = 100

local Character
local Humanoid
local RootPart

local function refreshCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
    refreshCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    refreshCharacter(char)
    task.wait(0.15)

    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = WalkSpeedValue
    end
end)

-- =========================================================
-- GUI
-- =========================================================
local oldGui = PlayerGui:FindFirstChild("AOVMobileHub")
if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AOVMobileHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = PlayerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeDraggable(gui, handle)
    handle = handle or gui

    local dragging = false
    local dragStart
    local startPos
    local dragInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =========================================================
-- LOGO
-- =========================================================
local LogoButton = Instance.new("TextButton")
LogoButton.Name = "LogoButton"
LogoButton.Size = UDim2.fromOffset(54, 54)
LogoButton.Position = UDim2.new(0, 20, 0, 100)
LogoButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
LogoButton.Text = "AOV"
LogoButton.TextColor3 = Color3.fromRGB(0, 255, 150)
LogoButton.TextSize = 16
LogoButton.Font = Enum.Font.SourceSansBold
LogoButton.AutoButtonColor = true
LogoButton.Parent = ScreenGui
corner(LogoButton, 27)

makeDraggable(LogoButton)

-- =========================================================
-- MAIN FRAME
-- =========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(330, 430)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
corner(MainFrame, 12)

makeDraggable(MainFrame)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.fromOffset(10, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AOV MOBILE HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- =========================================================
-- RESIZE HANDLE - MOUSE + TOUCH
-- =========================================================
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Size = UDim2.fromOffset(24, 24)
ResizeBtn.Position = UDim2.new(1, -24, 1, -24)
ResizeBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
ResizeBtn.Text = "◢"
ResizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResizeBtn.TextSize = 13
ResizeBtn.ZIndex = 10
ResizeBtn.Parent = MainFrame
corner(ResizeBtn, 4)

local resizing = false
local resizeStart
local startSize

ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        resizing = true
        resizeStart = input.Position
        startSize = MainFrame.AbsoluteSize

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not resizing then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - resizeStart
        local width = math.clamp(startSize.X + delta.X, 280, 600)
        local height = math.clamp(startSize.Y + delta.Y, 330, 650)

        MainFrame.Size = UDim2.fromOffset(width, height)
    end
end)

LogoButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- =========================================================
-- CONTENT
-- =========================================================
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -52)
Container.Position = UDim2.fromOffset(10, 45)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new()
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

local function createToggle(name, initial, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.AutoButtonColor = true
    btn.Parent = Container
    corner(btn, 7)

    local state = initial or false

    local function render()
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state
            and Color3.fromRGB(80, 255, 80)
            or Color3.fromRGB(255, 80, 80)
    end

    render()

    btn.Activated:Connect(function()
        state = not state
        render()
        callback(state)
    end)

    return btn
end

local function createSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 52)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = Container
    corner(frame, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.fromOffset(10, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(1, -20, 0, 12)
    sliderBg.Position = UDim2.fromOffset(10, 31)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    sliderBg.Text = ""
    sliderBg.AutoButtonColor = false
    sliderBg.Parent = frame
    corner(sliderBg, 6)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    corner(fill, 6)

    local function setValue(val)
        val = math.clamp(math.floor(val + 0.5), min, max)
        local ratio = (val - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = name .. ": " .. tostring(val)
        callback(val)
    end

    setValue(default)

    local sliding = false

    local function update(input)
        local width = math.max(sliderBg.AbsoluteSize.X, 1)
        local x = math.clamp(
            input.Position.X - sliderBg.AbsolutePosition.X,
            0,
            width
        )
        local ratio = x / width
        setValue(min + (max - min) * ratio)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input)
        end
    end)
end

-- =========================================================
-- SPEED
-- =========================================================
createToggle("Enable Speed", false, function(state)
    SpeedEnabled = state

    if Humanoid then
        Humanoid.WalkSpeed = state and WalkSpeedValue or 16
    end
end)

createSlider("Walk Speed", 1, 200, WalkSpeedValue, function(value)
    WalkSpeedValue = value

    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = value
    end
end)

-- =========================================================
-- FOV VISUAL
-- =========================================================
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.ZIndex = 2
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Color = Color3.fromRGB(255, 0, 0)
FOVStroke.Parent = FOVCircle

local function updateFOV()
    local camera = workspace.CurrentCamera
    if not camera then return end

    FOVCircle.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)

    local viewport = camera.ViewportSize
    FOVCircle.Position = UDim2.fromOffset(
        viewport.X / 2,
        viewport.Y / 2
    )
end

createToggle("Show FOV", false, function(state)
    FOVEnabled = state
    FOVCircle.Visible = state
    updateFOV()
end)

createSlider("FOV Radius", 30, 400, FOVRadius, function(value)
    FOVRadius = value
    updateFOV()
end)

-- =========================================================
-- MOBILE FLY CONTROLS
-- =========================================================
local FlyControl = Instance.new("Frame")
FlyControl.Name = "FlyControl"
FlyControl.Size = UDim2.fromOffset(150, 150)
FlyControl.Position = UDim2.new(1, -170, 1, -190)
FlyControl.BackgroundTransparency = 1
FlyControl.Visible = false
FlyControl.Parent = ScreenGui

local function createFlyButton(text, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(60, 60)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    button.BackgroundTransparency = 0.1
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.Font = Enum.Font.SourceSansBold
    button.Parent = FlyControl
    corner(button, 30)
    return button
end

local UpButton = createFlyButton("↑", UDim2.fromOffset(45, 0))
local DownButton = createFlyButton("↓", UDim2.fromOffset(45, 90))

local upHeld = false
local downHeld = false

local function setHeld(button, setter)
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

setHeld(UpButton, function(value) upHeld = value end)
setHeld(DownButton, function(value) downHeld = value end)

-- =========================================================
-- FLY ENGINE
-- =========================================================
local FlyVelocity
local FlyGyro

local function destroyFlyObjects()
    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end
end

local function stopFly()
    destroyFlyObjects()
    FlyControl.Visible = false

    if Humanoid then
        Humanoid.PlatformStand = false
        Humanoid.AutoRotate = true
    end
end

local function startFly()
    if not RootPart or not Humanoid then
        FlyEnabled = false
        return
    end

    destroyFlyObjects()

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "AOVFlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = RootPart

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "AOVFlyGyro"
    FlyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    FlyGyro.P = 9000
    FlyGyro.CFrame = RootPart.CFrame
    FlyGyro.Parent = RootPart

    Humanoid.PlatformStand = true
    Humanoid.AutoRotate = false
    FlyControl.Visible = true
end

createToggle("Enable Fly", false, function(state)
    FlyEnabled = state

    if state then
        startFly()
    else
        stopFly()
    end
end)

createSlider("Fly Speed", 1, 200, FlySpeedValue, function(value)
    FlySpeedValue = value
end)

-- =========================================================
-- FLY UPDATE
-- =========================================================
RunService.RenderStepped:Connect(function()
    if not FlyEnabled or not RootPart or not FlyVelocity or not FlyGyro then
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local moveDirection = Humanoid and Humanoid.MoveDirection or Vector3.zero

    -- Horizontal movement comes from the mobile thumbstick / normal movement.
    local horizontal = Vector3.new(moveDirection.X, 0, moveDirection.Z)

    -- Vertical movement comes from the mobile buttons.
    local vertical = 0
    if upHeld then vertical += 1 end
    if downHeld then vertical -= 1 end

    FlyVelocity.Velocity =
        horizontal * FlySpeedValue
        + Vector3.new(0, vertical * FlySpeedValue, 0)

    -- Face the camera's horizontal direction.
    local look = camera.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)

    if flatLook.Magnitude > 0.01 then
        FlyGyro.CFrame = CFrame.lookAt(
            RootPart.Position,
            RootPart.Position + flatLook.Unit
        )
    end
end)

-- =========================================================
-- SPEED UPDATE
-- =========================================================
RunService.Heartbeat:Connect(function()
    if SpeedEnabled and Humanoid and Humanoid.Health > 0 then
        Humanoid.WalkSpeed = WalkSpeedValue
    end
end)

-- =========================================================
-- CHARACTER / FLY RECOVERY
-- =========================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    stopFly()
    refreshCharacter(char)

    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = WalkSpeedValue
    end

    -- Fly must be started again manually after respawn.
    FlyEnabled = false
end)

-- =========================================================
-- CAMERA / FOV UPDATE
-- =========================================================
RunService.RenderStepped:Connect(function()
    if FOVEnabled then
        updateFOV()
    end
end)

local camera = workspace.CurrentCamera
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFOV)
end

-- Initial state
updateFOV()

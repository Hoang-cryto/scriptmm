--[[
    AIM MENU
    - Logo nổi mở/đóng menu
    - Menu kéo được bằng chuột hoặc cảm ứng mobile
    - Auto Attack ON/OFF (chỉ giao diện/trạng thái)
    - Chase + Aim ON/OFF (chỉ giao diện/trạng thái)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Xóa GUI cũ nếu script được chạy lại
local oldGui = playerGui:FindFirstChild("FloatingAimMenu")
if oldGui then
    oldGui:Destroy()
end

--========================
-- GUI
--========================

local gui = Instance.new("ScreenGui")
gui.Name = "FloatingAimMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--========================
-- LOGO NỔI
--========================

local logo = Instance.new("TextButton")
logo.Name = "Logo"
logo.Size = UDim2.fromOffset(55, 55)
logo.Position = UDim2.new(0, 20, 0.5, -30)
logo.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
logo.Text = "A"
logo.TextColor3 = Color3.fromRGB(255, 255, 255)
logo.TextSize = 25
logo.Font = Enum.Font.GothamBold
logo.AutoButtonColor = true
logo.Parent = gui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = logo

--========================
-- MENU
--========================

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.fromOffset(280, 190)
menu.Position = UDim2.new(0.5, -140, 0.5, -95)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menu.Visible = false
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menu

--========================
-- HEADER
--========================

local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundTransparency = 1
header.Text = "AIM MENU"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextSize = 20
header.Font = Enum.Font.GothamBold
header.Parent = menu

--========================
-- NÚT AUTO ATTACK
--========================

local autoAttack = false

local attackButton = Instance.new("TextButton")
attackButton.Name = "AutoAttack"
attackButton.Size = UDim2.new(1, -30, 0, 50)
attackButton.Position = UDim2.new(0, 15, 0, 55)
attackButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
attackButton.Text = "Auto Attack: OFF"
attackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
attackButton.TextSize = 17
attackButton.Font = Enum.Font.GothamBold
attackButton.AutoButtonColor = true
attackButton.Parent = menu

local attackCorner = Instance.new("UICorner")
attackCorner.CornerRadius = UDim.new(0, 8)
attackCorner.Parent = attackButton

attackButton.Activated:Connect(function()
    autoAttack = not autoAttack

    if autoAttack then
        attackButton.Text = "Auto Attack: ON"
        attackButton.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
    else
        attackButton.Text = "Auto Attack: OFF"
        attackButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

--========================
-- NÚT CHASE + AIM
--========================

local chaseAim = false

local chaseButton = Instance.new("TextButton")
chaseButton.Name = "ChaseAim"
chaseButton.Size = UDim2.new(1, -30, 0, 50)
chaseButton.Position = UDim2.new(0, 15, 0, 115)
chaseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
chaseButton.Text = "Chase + Aim: OFF"
chaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
chaseButton.TextSize = 17
chaseButton.Font = Enum.Font.GothamBold
chaseButton.AutoButtonColor = true
chaseButton.Parent = menu

local chaseCorner = Instance.new("UICorner")
chaseCorner.CornerRadius = UDim.new(0, 8)
chaseCorner.Parent = chaseButton

chaseButton.Activated:Connect(function()
    chaseAim = not chaseAim

    if chaseAim then
        chaseButton.Text = "Chase + Aim: ON"
        chaseButton.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
    else
        chaseButton.Text = "Chase + Aim: OFF"
        chaseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

--========================
-- KÉO MENU: PC + MOBILE
--========================

local dragging = false
local dragStart = nil
local startPosition = nil

local function updateDrag(input)
    if not dragStart or not startPosition then
        return
    end

    local delta = input.Position - dragStart

    menu.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = menu.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragStart = nil
                startPosition = nil
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

--========================
-- LOGO MỞ / ĐÓNG MENU
--========================

logo.Activated:Connect(function()
    menu.Visible = not menu.Visible
end)

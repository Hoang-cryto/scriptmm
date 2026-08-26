-- Roblox Greedy Growers: Professional Lightning Countdown & Auto-Collect
-- Refactored & Optimized Pro Version
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = Library:MakeWindow({
    Name = "Greedy Growers Pro Hub | Van Kiều", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "GreedyGrowersPro"
})

-- Configuration States
local Config = {
    AutoCollect = false,
    Countdown = true,
    ScanRadius = 25,
    TriggerOffset = 1.0 -- Thời gian lấy cây trước khi sét đánh (giây)
}

-- Notification Helper
local function Notify(title, content, duration)
    Library:MakeNotification({
        Name = title,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = duration or 2
    })
end

Notify("Greedy Growers Pro", "Script Pro đã được khởi chạy thành công!", 3)

-- Lấy vị trí CFrame/Vector3 an toàn từ mọi loại Instance
local function GetObjectPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end
        return obj:GetPivot().Position
    end
    return nil
end

-- Lấy thời gian còn lại của sét bằng cách truy quét thông minh
local function GetLightningDuration(lightningObj)
    -- 1. Kiểm tra Attributes
    local attrs = {"Time", "Duration", "Delay", "Timer"}
    for _, attr in ipairs(attrs) do
        local val = lightningObj:GetAttribute(attr)
        if val and tonumber(val) then
            return tonumber(val)
        end
    end
    
    -- 2. Kiểm tra TextLabel/BillboardGui
    local timerLabel = lightningObj:FindFirstChildWhichIsA("TextLabel", true)
    if timerLabel and timerLabel.Text then
        local timeText = string.match(timerLabel.Text, "%d+%.?%d*")
        if timeText then
            return tonumber(timeText)
        end
    end
    
    return 3.0 -- Mặc định nếu không tìm thấy
end

-- Hàm kích hoạt ProximityPrompt chuẩn xác
local function InteractPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    if fireproximityprompt then
        fireproximityprompt(prompt)
        return true
    end
    return false
end

-- Hàm xử lý thu thập cây xung quanh điểm sét đánh
local function ProcessAutoCollect(lightningPos)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Tối ưu: Chỉ tìm kiếm trong Folder chứa nông sản/cây thay vì quét toàn bộ Workspace
    local targetsContainer = Workspace:FindFirstChild("Crops") 
        or Workspace:FindFirstChild("Plants") 
        or Workspace:FindFirstChild("Trees") 
        or Workspace

    local foundTarget = false

    for _, obj in ipairs(targetsContainer:GetChildren()) do
        local nameLower = string.lower(obj.Name)
        if string.find(nameLower, "tree") or string.find(nameLower, "crop") or string.find(nameLower, "plant") or obj:FindFirstChild("Harvest") then
            local pos = GetObjectPosition(obj)
            if pos and (pos - lightningPos).Magnitude <= Config.ScanRadius then
                -- Tìm Prompt kích hoạt
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    InteractPrompt(prompt)
                else
                    -- Fallback: Teleport nhân vật đến vị trí thu hoạch nếu không có prompt
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
                
                Notify("PRO AUTO-COLLECT", "Đã thu hoạch cây thành công!", 2)
                foundTarget = true
                break
            end
        end
    end
end

-- Hệ thống theo dõi Sét Đánh (Event-Driven Pipeline)
local function OnInstanceAdded(child)
    if not Config.AutoCollect and not Config.Countdown then return end

    local nameLower = string.lower(child.Name)
    local isLightning = string.find(nameLower, "lightning") 
        or string.find(nameLower, "strike") 
        or string.find(nameLower, "warning") 
        or child:FindFirstChild("LightningEffect")

    if not isLightning then return end

    -- Đợi 1 frame để đảm bảo dữ liệu Position/Attributes của Object đã load đủ
    RunService.Heartbeat:Wait()
    
    local lightningPos = GetObjectPosition(child)
    if not lightningPos then return end

    local exactTime = GetLightningDuration(child)

    -- Chức năng đếm ngược
    if Config.Countdown then
        task.spawn(function()
            local remaining = math.floor(exactTime)
            for i = remaining, 1, -1 do
                Notify("CẢNH BÁO SÉT!", "Sét đánh sau: " .. i .. "s", 1)
                task.wait(1)
            end
        end)
    end

    -- Chức năng Tự động Nhặt Cây
    if Config.AutoCollect then
        local waitDuration = math.max(0, exactTime - Config.TriggerOffset)
        task.delay(waitDuration, function()
            ProcessAutoCollect(lightningPos)
        end)
    end
end

-- Lắng nghe tất cả các vùng xuất hiện sét có thể có
Workspace.ChildAdded:Connect(OnInstanceAdded)
if Workspace:FindFirstChild("Effects") then
    Workspace.Effects.ChildAdded:Connect(OnInstanceAdded)
end

-- Giao diện điều khiển (UI Tab)
local MainTab = Window:MakeTab({
    Name = "Chức Năng Chính",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddLabel("Hệ thống Auto Greedy Growers - Pro Edition")

MainTab:AddToggle({
    Name = "Auto Nhặt Cây Trước Sét (Pro)",
    Default = false,
    Callback = function(Value)
        Config.AutoCollect = Value
    end    
})

MainTab:AddToggle({
    Name = "Bộ Đếm Ngược Chuẩn (Countdown)",
    Default = true,
    Callback = function(Value)
        Config.Countdown = Value
    end    
})

MainTab:AddSlider({
    Name = "Bán kính quét cây (Studs)",
    Min = 10,
    Max = 50,
    Default = 25,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        Config.ScanRadius = Value
    end    
})

Library:Init()

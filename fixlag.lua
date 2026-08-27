-- VAN KIEU LOW GRAPHICS
-- Không menu

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

--==================================================
-- LOW GRAPHICS
--==================================================

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Technology = Enum.Technology.Compatibility
end)

local function Optimize(obj)
    pcall(function()

        -- Tắt bóng
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end

        -- Tắt đèn
        if obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then
            obj.Enabled = false
            obj.Shadows = false
        end

        -- Tắt hiệu ứng nặng
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then
            obj.Enabled = false
        end

        -- Tắt hậu kỳ
        if obj:IsA("BloomEffect")
        or obj:IsA("BlurEffect")
        or obj:IsA("ColorCorrectionEffect")
        or obj:IsA("DepthOfFieldEffect")
        or obj:IsA("SunRaysEffect") then
            obj.Enabled = false
        end

    end)
end

-- Tối ưu map hiện tại
for _, obj in ipairs(Workspace:GetDescendants()) do
    Optimize(obj)
end

-- Tối ưu vật thể mới xuất hiện
Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        Optimize(obj)
    end)
end)

-- Giảm chất lượng render
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- Giảm hiệu ứng nước
pcall(function()
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
    end
end)

--==================================================
-- THÔNG BÁO
--==================================================

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Văn Kiều",
        Text = "Script đã được bật!",
        Duration = 3
    })
end)

print("Văn Kiều Low Graphics: ON")

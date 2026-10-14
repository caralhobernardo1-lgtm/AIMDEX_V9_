--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- AIMDEX V9 - ESP Jarvis com FOV NO CENTRO EXATO (SCRIPT COMPLETO)
local success, err = pcall(function()

-- ============================================================
-- PARTE 1/4 — INICIALIZAÇÃO, SERVIÇOS, VARIÁVEIS E ESP
-- ============================================================

local Rayfield
local ok, result = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if ok and result then
    Rayfield = result
else
    ok, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)
    if ok and result then Rayfield = result end
end

if not Rayfield then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Erro", Text="Não foi possível carregar o painel.", Duration=5})
    return
end

local Window = Rayfield:CreateWindow({
    Name = "AIMDEX V9",
    LoadingTitle = "AIMDEX V9",
    LoadingSubtitle = "Bernardo Pereira Carvalho",
    TouchCompatible = true
})

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

-- VARIÁVEIS DE ESTADO
local aimbot         = false
local showfov        = false
local spin           = false
local fov            = 150
local spinspeed      = 10
local esp            = false
local espcolor       = Color3.fromRGB(255, 255, 255)
local noclip         = false
local aimPartName    = "Head"
local speedValue     = 16
local aimSquadGM     = false
local raioX          = false
local kilStricks     = false
local infiniteJump   = false
local trollCost      = false
local lightVision    = false
local htbxVisible    = true
local espLines       = true
local espSkeleton    = true
local ignoreWalls    = true

local killNotificationGui = nil
local trollTarget         = nil
local jumpConnection      = nil
local uiRefs              = {}
local tlstcdEnabled       = false
local joystickEnabled     = false
local joystickGui         = nil
local joystickConnections = {}

-- ============================================================
-- SISTEMA ESP
-- ============================================================
local ESPConfig = {
    Enabled          = false,
    ToggleKey        = Enum.KeyCode.RightControl,
    MaxDistance      = math.huge,
    StudsToMeters    = 0.28,
    TeamCheck        = false,
    ShowLine         = true,
    ShowName         = true,
    ShowDistance     = true,
    ShowTool         = true,
    ShowBox          = true,
    ShowSkeleton     = true,
    ShowHealth       = true,
    LineColor        = Color3.fromRGB(255, 255, 255),
    BoxColor         = Color3.fromRGB(255, 255, 255),
    SkeletonColor    = Color3.fromRGB(255, 255, 255),
    TextColor        = Color3.fromRGB(255, 255, 255),
    LineThickness    = 1,
    TextSize         = 13,
    BoxWidthRatio    = 0.55,
}

local espGui = Instance.new("ScreenGui")
espGui.Name = "ESP_Teste"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 999
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local R15Bones = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

local R6Bones = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}

local MAX_BONES = #R15Bones

local function newFrame(parent, color)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundColor3 = color
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Visible = false
    f.Parent = parent
    return f
end

local function newLabel(parent, anchorY, height, yAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.AnchorPoint = Vector2.new(0.5, anchorY)
    l.Size = UDim2.fromOffset(300, height)
    l.Font = Enum.Font.Gotham
    l.TextSize = ESPConfig.TextSize
    l.TextColor3 = ESPConfig.TextColor
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3 = Color3.new(0, 0, 0)
    l.TextYAlignment = yAlign
    l.Visible = false
    l.Parent = parent
    return l
end

local function createESP()
    local espObj = {}
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Size = UDim2.fromScale(1, 1)
    container.Visible = false
    container.Parent = espGui
    espObj.Container = container

    espObj.Line = newFrame(container, ESPConfig.LineColor)
    espObj.Bones = {}
    for i = 1, MAX_BONES do
        espObj.Bones[i] = newFrame(container, ESPConfig.SkeletonColor)
    end

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.AnchorPoint = Vector2.new(0, 0)
    box.Visible = false
    box.Parent = container
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = ESPConfig.BoxColor
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = box
    espObj.Box = box

    local healthBG = newFrame(container, Color3.new(0, 0, 0))
    healthBG.AnchorPoint = Vector2.new(0, 0)
    espObj.HealthBG = healthBG
    local healthFill = newFrame(container, Color3.fromRGB(0, 255, 0))
    healthFill.AnchorPoint = Vector2.new(0, 0)
    espObj.HealthFill = healthFill

    espObj.Name = newLabel(container, 1, 16, Enum.TextYAlignment.Bottom)
    espObj.Info = newLabel(container, 0, 30, Enum.TextYAlignment.Top)

    return espObj
end

local function drawLine(line, a, b)
    local delta = b - a
    line.Size = UDim2.fromOffset(delta.Magnitude, ESPConfig.LineThickness)
    line.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    line.Visible = true
end

local function updateESP(player, espObj)
    local container = espObj.Container
    if not ESPConfig.Enabled then container.Visible = false return end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) or hum.Health <= 0 then container.Visible = false return end

    if ESPConfig.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
        container.Visible = false return
    end

    local camera = workspace.CurrentCamera
    if not camera then container.Visible = false return end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local origin = myRoot and myRoot.Position or camera.CFrame.Position
    local studs = (origin - root.Position).Magnitude
    if studs > ESPConfig.MaxDistance then container.Visible = false return end

    local rootPos = camera:WorldToViewportPoint(root.Position)
    if rootPos.Z <= 0 then container.Visible = false return end

    local top = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.7, 0))
    local bottom = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.1, 0))

    local height = math.max(bottom.Y - top.Y, 2)
    local width = height * ESPConfig.BoxWidthRatio
    local centerX = rootPos.X
    local left = math.floor(centerX - width / 2)
    local topY = math.floor(top.Y)
    height = math.floor(height)
    width = math.floor(width)

    container.Visible = true

    espObj.Box.Visible = ESPConfig.ShowBox
    espObj.Box.Position = UDim2.fromOffset(left, topY)
    espObj.Box.Size = UDim2.fromOffset(width, height)

    if ESPConfig.ShowLine then
        local viewport = camera.ViewportSize
        drawLine(espObj.Line, Vector2.new(viewport.X / 2, viewport.Y), Vector2.new(centerX, topY + height))
    else
        espObj.Line.Visible = false
    end

    if ESPConfig.ShowHealth then
        local ratio = hum.MaxHealth > 0 and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 0
        espObj.HealthBG.Visible = true
        espObj.HealthBG.Position = UDim2.fromOffset(left - 6, topY - 1)
        espObj.HealthBG.Size = UDim2.fromOffset(4, height + 2)
        espObj.HealthFill.Visible = true
        espObj.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), ratio)
        espObj.HealthFill.Position = UDim2.fromOffset(left - 5, topY + height * (1 - ratio))
        espObj.HealthFill.Size = UDim2.fromOffset(2, height * ratio)
    else
        espObj.HealthBG.Visible = false
        espObj.HealthFill.Visible = false
    end

    if ESPConfig.ShowName then
        espObj.Name.Visible = true
        espObj.Name.Position = UDim2.fromOffset(centerX, topY - 2)
        espObj.Name.Text = string.format("[%s]", player.DisplayName)
    else
        espObj.Name.Visible = false
    end

    if ESPConfig.ShowDistance or ESPConfig.ShowTool then
        local lines = {}
        if ESPConfig.ShowDistance then
            table.insert(lines, string.format("[%dM]", math.floor(studs * ESPConfig.StudsToMeters + 0.5)))
        end
        if ESPConfig.ShowTool then
            local tool = char:FindFirstChildOfClass("Tool")
            table.insert(lines, string.format("[Holding: %s]", tool and tool.Name or "No tool"))
        end
        espObj.Info.Visible = true
        espObj.Info.Position = UDim2.fromOffset(centerX, topY + height + 2)
        espObj.Info.Text = table.concat(lines, "\n")
    else
        espObj.Info.Visible = false
    end

    if ESPConfig.ShowSkeleton then
        local bones = hum.RigType == Enum.HumanoidRigType.R15 and R15Bones or R6Bones
        for i = 1, MAX_BONES do
            local line = espObj.Bones[i]
            local bone = bones[i]
            if bone then
                local p1 = char:FindFirstChild(bone[1])
                local p2 = char:FindFirstChild(bone[2])
                if p1 and p2 then
                    local a = camera:WorldToViewportPoint(p1.Position)
                    local b = camera:WorldToViewportPoint(p2.Position)
                    if a.Z > 0 and b.Z > 0 then
                        drawLine(line, Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y))
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    else
        for i = 1, MAX_BONES do
            espObj.Bones[i].Visible = false
        end
    end
end

local ESPs = {}

local function addPlayerESP(player)
    if player == LocalPlayer or ESPs[player] then return end
    ESPs[player] = createESP()
end

local function removePlayerESP(player)
    local espObj = ESPs[player]
    if espObj then
        espObj.Container:Destroy()
        ESPs[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do addPlayerESP(player) end
Players.PlayerAdded:Connect(addPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

RunService.RenderStepped:Connect(function()
    for player, espObj in pairs(ESPs) do
        updateESP(player, espObj)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == ESPConfig.ToggleKey then
        ESPConfig.Enabled = not ESPConfig.Enabled
        if uiRefs.esp then uiRefs.esp:Set(ESPConfig.Enabled) end
    end
end)

local function updateESPColors(color)
    ESPConfig.LineColor     = color
    ESPConfig.BoxColor      = color
    ESPConfig.SkeletonColor = color
    ESPConfig.TextColor     = color
    for _, espObj in pairs(ESPs) do
        if espObj.Line then espObj.Line.BackgroundColor3 = color end
        for i = 1, MAX_BONES do
            if espObj.Bones[i] then espObj.Bones[i].BackgroundColor3 = color end
        end
        if espObj.Box then espObj.Box.UIStroke.Color = color end
        if espObj.Name then espObj.Name.TextColor3 = color end
        if espObj.Info then espObj.Info.TextColor3 = color end
    end
end-- ============================================================
-- PARTE 2/4 — HELPERS, FOV, JOYSTICK E LIGHT VISION
-- ============================================================

local function isTargetVisible(head)
    local camPos = workspace.CurrentCamera.CFrame.Position
    local targetPos = head.Position
    local dir = (targetPos - camPos).Unit
    local dist = (targetPos - camPos).Magnitude - 0.5
    if dist <= 0 then return true end
    local ignoreList = { LocalPlayer.Character, head.Parent }
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true
    local hit = workspace:Raycast(camPos, dir * dist, params)
    return hit == nil
end

local function getTeamIdentifier(plr)
    if not plr then return nil end
    if plr.Team ~= nil then return "team_" .. tostring(plr.Team) end

    local tc = plr.TeamColor
    if tc ~= nil and tc.Name then
        local neutral = {
            ["White"] = true, ["Institutional white"] = true,
            ["Medium stone grey"] = true, ["Neutral"] = true,
            ["Really black"] = true, ["Black"] = true,
            ["Dark stone grey"] = true,
        }
        if not neutral[tc.Name] then return "color_" .. tc.Name end
    end

    for _, attr in ipairs({"Team", "team", "TeamId", "teamId", "TeamName", "teamName", "Squad", "squad"}) do
        local ok, val = pcall(function() return plr:GetAttribute(attr) end)
        if ok and val ~= nil then return "attr_" .. attr .. "_" .. tostring(val) end
    end

    for _, child in ipairs(plr:GetChildren()) do
        if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") then
            local n = child.Name:lower()
            if n:find("team") or n:find("squad") or n:find("grupo") or n:find("equipe") then
                return "value_" .. child.Name .. "_" .. tostring(child.Value)
            end
        end
    end
    return nil
end

local function isTeammate(player)
    if not player or player == LocalPlayer then return false end
    local myId = getTeamIdentifier(LocalPlayer)
    local theirId = getTeamIdentifier(player)
    if myId ~= nil and theirId ~= nil and myId == theirId then return true end
    return false
end

local function getAimPart(character)
    if not character then return nil end
    if aimPartName == "Head" then
        return character:FindFirstChild("Head")
    elseif aimPartName == "Peito" then
        local candidates = {"UpperTorso", "Torso", "Chest", "HumanoidRootPart"}
        for _, name in ipairs(candidates) do
            local p = character:FindFirstChild(name)
            if p then return p end
        end
        return character:FindFirstChild("Head")
    elseif aimPartName == "Perna" then
        local candidates = {"LeftLowerLeg", "RightLowerLeg", "Left Leg", "Right Leg", "LeftUpperLeg", "RightUpperLeg", "LeftFoot", "RightFoot"}
        for _, name in ipairs(candidates) do
            local p = character:FindFirstChild(name)
            if p then return p end
        end
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("Head")
    end
end

local originalTransparencies = {}

local function setRaioX(enabled)
    raioX = enabled
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent ~= LocalPlayer.Character then
            if enabled then
                if not originalTransparencies[part] then
                    originalTransparencies[part] = part.LocalTransparencyModifier
                end
                part.LocalTransparencyModifier = 0.5
            else
                if originalTransparencies[part] then
                    part.LocalTransparencyModifier = originalTransparencies[part]
                    originalTransparencies[part] = nil
                else
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

local lightVisionOriginals = nil
local lightVisionConnection = nil

local function applyLightVision()
    pcall(function()
        local l = game:GetService("Lighting")
        l.Brightness = 3
        l.ClockTime = 14
        l.GeographicLatitude = 0
        l.GlobalShadows = false
        l.FogEnd = 1000000
        l.FogStart = 0
        l.Ambient = Color3.fromRGB(220, 220, 220)
        l.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
        l.EnvironmentDiffuseScale = 1
        l.EnvironmentSpecularScale = 1
        l.ExposureCompensation = 0.5

        local atmo = l:FindFirstChildOfClass("Atmosphere")
        if atmo then
            atmo.Density = 0
            atmo.Offset = 0
            atmo.Glare = 0
            atmo.Haze = 0
        end

        for _, v in ipairs(l:GetChildren()) do
            if v:IsA("Sky") then
                v.SunAngularSize = 21
                v.MoonAngularSize = 11
            end
            if v:IsA("ColorCorrectionEffect") then
                v.Brightness = 0.2
                v.Contrast = 0
                v.TintColor = Color3.fromRGB(255,255,255)
            end
            if v:IsA("BlurEffect") then v.Enabled = false end
            if v:IsA("BloomEffect") then v.Enabled = false end
        end
    end)
end

local function setLightVision(enabled)
    lightVision = enabled
    if enabled then
        pcall(function()
            local l = game:GetService("Lighting")
            if not lightVisionOriginals then
                lightVisionOriginals = {
                    Brightness = l.Brightness,
                    ClockTime = l.ClockTime,
                    GlobalShadows = l.GlobalShadows,
                    FogEnd = l.FogEnd,
                    FogStart = l.FogStart,
                    Ambient = l.Ambient,
                    OutdoorAmbient = l.OutdoorAmbient,
                    EnvironmentDiffuseScale = l.EnvironmentDiffuseScale,
                    EnvironmentSpecularScale = l.EnvironmentSpecularScale,
                    ExposureCompensation = l.ExposureCompensation,
                }
            end
        end)
        applyLightVision()
        if not lightVisionConnection then
            lightVisionConnection = RunService.RenderStepped:Connect(function()
                if lightVision then applyLightVision() end
            end)
        end
    else
        if lightVisionConnection then
            lightVisionConnection:Disconnect()
            lightVisionConnection = nil
        end
        pcall(function()
            local l = game:GetService("Lighting")
            if lightVisionOriginals then
                l.Brightness = lightVisionOriginals.Brightness
                l.ClockTime = lightVisionOriginals.ClockTime
                l.GlobalShadows = lightVisionOriginals.GlobalShadows
                l.FogEnd = lightVisionOriginals.FogEnd
                l.FogStart = lightVisionOriginals.FogStart
                l.Ambient = lightVisionOriginals.Ambient
                l.OutdoorAmbient = lightVisionOriginals.OutdoorAmbient
                l.EnvironmentDiffuseScale = lightVisionOriginals.EnvironmentDiffuseScale
                l.EnvironmentSpecularScale = lightVisionOriginals.EnvironmentSpecularScale
                l.ExposureCompensation = lightVisionOriginals.ExposureCompensation
                lightVisionOriginals = nil
            end
        end)
    end
end

local fovGui = Instance.new("ScreenGui", game.CoreGui)
local fovCircle = Instance.new("Frame", fovGui)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
local uiCorner = Instance.new("UICorner", fovCircle)
uiCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.new(1,1,1)
fovStroke.Thickness = 1
fovStroke.Transparency = 0.3

local function restoreDefaultJoystick()
    local StarterGuiSvc = game:GetService("StarterGui")
    pcall(function() StarterGuiSvc:SetCore("TouchControlsEnabled", true) end)
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local touchGui = playerGui:FindFirstChild("TouchGui")
        if touchGui then
            local controlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if controlFrame then
                local jumpButton = controlFrame:FindFirstChild("JumpButton")
                if jumpButton then jumpButton.Visible = true end
                local thumbstick = controlFrame:FindFirstChild("DynamicThumbstickFrame")
                if thumbstick then thumbstick.Visible = true end
                local thumbstick2 = controlFrame:FindFirstChild("ThumbstickFrame")
                if thumbstick2 then thumbstick2.Visible = true end
                local controlFrame2 = touchGui:FindFirstChild("ControlFrame")
                if controlFrame2 then controlFrame2.Visible = true end
            end
        end
    end
end

local function destroyJoystick()
    for _, conn in ipairs(joystickConnections) do
        pcall(function() conn:Disconnect() end)
    end
    joystickConnections = {}
    if joystickGui then
        pcall(function() joystickGui:Destroy() end)
        joystickGui = nil
    end
    restoreDefaultJoystick()
end

local function setupJoystick()
    destroyJoystick()
    local TweenService2 = game:GetService("TweenService")
    local StarterGui = game:GetService("StarterGui")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local JOYSTICK_SIZE = 190
    local KNOB_SIZE = 80
    local RING_THICKNESS = 3
    local DEAD_ZONE = 0.12
    local MAX_DISTANCE = JOYSTICK_SIZE/2 - RING_THICKNESS - KNOB_SIZE/2

    local WHITE_SOFT   = Color3.fromRGB(255, 255, 255)
    local WHITE_GLOW   = Color3.fromRGB(230, 240, 255)
    local WHITE_BRIGHT = Color3.fromRGB(255, 255, 255)
    local RING_BG_TRANSP     = 0.80
    local RING_STROKE_TRANSP = 0.10
    local KNOB_TRANSP        = 0.35

    pcall(function() StarterGui:SetCore("TouchControlsEnabled", false) end)

    local function hideDefaultJoystick()
        local touchGui = playerGui:FindFirstChild("TouchGui")
        if touchGui then
            local controlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if controlFrame then
                local jumpButton = controlFrame:FindFirstChild("JumpButton")
                if jumpButton then jumpButton.Visible = true end
                local thumbstick = controlFrame:FindFirstChild("DynamicThumbstickFrame")
                if thumbstick then thumbstick.Visible = false end
                local thumbstick2 = controlFrame:FindFirstChild("ThumbstickFrame")
                if thumbstick2 then thumbstick2.Visible = false end
            end
        end
    end

    table.insert(joystickConnections, playerGui.ChildAdded:Connect(function(child)
        if child.Name == "TouchGui" then task.wait(0.1) hideDefaultJoystick() end
    end))
    hideDefaultJoystick()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomJoystick"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = playerGui
    joystickGui = screenGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, JOYSTICK_SIZE, 0, JOYSTICK_SIZE)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = screenGui

    local outerRing = Instance.new("Frame")
    outerRing.Name = "OuterRing"
    outerRing.Size = UDim2.new(1, 0, 1, 0)
    outerRing.BackgroundColor3 = WHITE_SOFT
    outerRing.BackgroundTransparency = RING_BG_TRANSP
    outerRing.BorderSizePixel = 0
    outerRing.Parent = container

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outerRing

    local outerGlow = Instance.new("UIStroke")
    outerGlow.Color = WHITE_GLOW
    outerGlow.Thickness = 8
    outerGlow.Transparency = 0.75
    outerGlow.Parent = outerRing

    local outerStroke = Instance.new("UIStroke")
    outerStroke.Color = WHITE_BRIGHT
    outerStroke.Thickness = RING_THICKNESS
    outerStroke.Transparency = RING_STROKE_TRANSP
    outerStroke.Parent = outerRing

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
    knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    knob.BackgroundColor3 = WHITE_SOFT
    knob.BackgroundTransparency = KNOB_TRANSP
    knob.BorderSizePixel = 0
    knob.Parent = container

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local knobGlow = Instance.new("UIStroke")
    knobGlow.Color = WHITE_GLOW
    knobGlow.Thickness = 6
    knobGlow.Transparency = 0.7
    knobGlow.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = WHITE_BRIGHT
    knobStroke.Thickness = 2
    knobStroke.Transparency = 0.15
    knobStroke.Parent = knob

    local activeTouch = nil
    local joystickCenter = Vector2.new(0, 0)
    local moveVector = Vector2.new(0, 0)

    local function updateKnob(inputPos)
        local delta = inputPos - joystickCenter
        local mag = delta.Magnitude
        if mag > MAX_DISTANCE then
            delta = delta.Unit * MAX_DISTANCE
            mag = MAX_DISTANCE
        end
        knob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
        local norm = mag / MAX_DISTANCE
        if norm < DEAD_ZONE then
            moveVector = Vector2.new(0, 0)
        else
            local remapped = (norm - DEAD_ZONE) / (1 - DEAD_ZONE)
            moveVector = delta.Unit * remapped
        end
    end

    local function resetJoystick()
        activeTouch = nil
        container.Visible = false
        knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        moveVector = Vector2.new(0, 0)
    end

    table.insert(joystickConnections, RunService.RenderStepped:Connect(function()
        if not joystickEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum:Move(Vector3.new(moveVector.X, 0, moveVector.Y), true)
        end
    end))

    local function animateAppear()
        container.Size = UDim2.new(0, JOYSTICK_SIZE * 0.7, 0, JOYSTICK_SIZE * 0.7)
        TweenService2:Create(
            container,
            TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, JOYSTICK_SIZE, 0, JOYSTICK_SIZE)}
        ):Play()
    end

    table.insert(joystickConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        if activeTouch then return end
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        local screenSize = workspace.CurrentCamera.ViewportSize
        if pos.X >= screenSize.X / 2 then return end
        if UserInputService:GetFocusedTextBox() then return end
        activeTouch = input
        joystickCenter = pos
        container.Position = UDim2.new(0, pos.X - JOYSTICK_SIZE/2, 0, pos.Y - JOYSTICK_SIZE/2)
        container.Visible = true
        knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        moveVector = Vector2.new(0, 0)
        animateAppear()
    end))

    table.insert(joystickConnections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if input == activeTouch and input.UserInputType == Enum.UserInputType.Touch then
            updateKnob(Vector2.new(input.Position.X, input.Position.Y))
        end
    end))

    table.insert(joystickConnections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input == activeTouch then resetJoystick() end
    end))

    table.insert(joystickConnections, player.CharacterAdded:Connect(function()
        resetJoystick()
        task.wait(1)
        if joystickEnabled then hideDefaultJoystick() end
    end))
end-- ============================================================
-- PARTE 3/4 — LOOPS, UI (ABAS 1/2/3) E HTBX
-- ============================================================

RunService.RenderStepped:Connect(function(delta)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= speedValue then hum.WalkSpeed = speedValue end
    end

    if trollCost and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            if trollTarget and trollTarget.Character and trollTarget.Character:FindFirstChild("HumanoidRootPart") and trollTarget.Character:FindFirstChild("Humanoid") and trollTarget.Character.Humanoid.Health > 0 then
                local targetRoot = trollTarget.Character.HumanoidRootPart
                local pos = targetRoot.Position - targetRoot.CFrame.LookVector * 7
                pos = Vector3.new(pos.X, targetRoot.Position.Y, pos.Z)
                myRoot.CFrame = CFrame.new(pos, targetRoot.Position)
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetRoot.Position)
            else
                local alivePlayers = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        table.insert(alivePlayers, p)
                    end
                end
                if #alivePlayers > 0 then
                    trollTarget = alivePlayers[math.random(1, #alivePlayers)]
                else
                    trollTarget = nil
                end
            end
        end
    else
        trollTarget = nil
    end

    if aimbot then
        local cam = workspace.CurrentCamera
        local myChar = LocalPlayer.Character
        if cam and myChar and myChar:FindFirstChild("HumanoidRootPart") then
            local closest = nil
            local minDist = fov
            local viewportCenter = cam.ViewportSize / 2

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not (aimSquadGM and isTeammate(p)) then
                    local targetPart = getAimPart(p.Character)
                    if targetPart then
                        local vec = cam:WorldToViewportPoint(targetPart.Position)
                        if vec.Z > 0 then
                            local screenPos = Vector2.new(vec.X, vec.Y)
                            local d = (screenPos - viewportCenter).Magnitude
                            if d < minDist then
                                if (not ignoreWalls) or isTargetVisible(targetPart) then
                                    minDist = d
                                    closest = targetPart
                                end
                            end
                        end
                    end
                end
            end

            if closest then
                local targetPos = closest.Position
                cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
            end
        end
    end

    if showfov then
        local diameter = fov * 2
        fovCircle.Size = UDim2.new(0, diameter, 0, diameter)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    if tlstcdEnabled then
        local cam = workspace.CurrentCamera
        cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.45, 0, 0, 0, 1)
    end
end)

RunService.RenderStepped:Connect(function(delta)
    if spin then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                if hum.AutoRotate then hum.AutoRotate = false end
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinspeed * 60 * delta), 0)
            end
        end
    else
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and not hum.AutoRotate then hum.AutoRotate = true end
        end
    end
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)

local t1 = Window:CreateTab("⚔️ Combate")
uiRefs.aimbot = t1:CreateToggle({Name="AIMBOT Principal", Callback=function(v) aimbot=v end})
uiRefs.aimSquadGM = t1:CreateToggle({Name="AIM SQUAD GM", Callback=function(v) aimSquadGM=v end})
uiRefs.fov = t1:CreateSlider({Name="FOV do Aimbot", Range={0,300}, Increment=1, Suffix=" studs", CurrentValue=150, Callback=function(v) fov=v end})
uiRefs.showfov = t1:CreateToggle({Name="Mostrar FOV", Callback=function(v) showfov=v end})
uiRefs.spin = t1:CreateToggle({Name="Spin Bot (Giro)", Callback=function(v) spin=v end})
uiRefs.spinspeed = t1:CreateSlider({Name="Velocidade do Spin", Range={1,50}, Increment=1, Suffix="x", CurrentValue=10, Callback=function(v) spinspeed=v end})
t1:CreateButton({Name="Cabeça", Callback=function() aimPartName = "Head" Rayfield:Notify({Title="Aimbot", Content="Mira direcionada para Cabeça", Duration=2}) end})
t1:CreateButton({Name="Peito", Callback=function() aimPartName = "Peito" Rayfield:Notify({Title="Aimbot", Content="Mira direcionada para Peito", Duration=2}) end})
t1:CreateButton({Name="Perna", Callback=function() aimPartName = "Perna" Rayfield:Notify({Title="Aimbot", Content="Mira direcionada para Perna", Duration=2}) end})
uiRefs.trollCost = t1:CreateToggle({Name="TROLL-COST", Callback=function(v) trollCost = v if not trollCost then trollTarget = nil end end})

local t2 = Window:CreateTab("👁️ Visuais")
uiRefs.esp = t2:CreateToggle({Name="Master ESP", Callback=function(v) esp=v ESPConfig.Enabled=v end})
uiRefs.espLines = t2:CreateToggle({Name="Linhas do ESP", CurrentValue=true, Callback=function(v) espLines=v ESPConfig.ShowLine=v end})
uiRefs.espSkeleton = t2:CreateToggle({Name="Esqueleto do ESP", CurrentValue=true, Callback=function(v) espSkeleton=v ESPConfig.ShowSkeleton=v end})
uiRefs.espcolor = t2:CreateColorPicker({Name="Cor do ESP", Color=espcolor, Callback=function(v) espcolor=v updateESPColors(v) end})
uiRefs.tlstcd = t2:CreateToggle({Name="TL-STCD", Callback=function(v) tlstcdEnabled=v end})
uiRefs.lightVision = t2:CreateToggle({Name="Light Vision", Callback=function(v) setLightVision(v) end})

local t3 = Window:CreateTab("🏃 Movimentação")
uiRefs.noclip = t3:CreateToggle({Name="Noclip", Callback=function(v) noclip=v end})
uiRefs.speed = t3:CreateSlider({Name="Velocidade", Range={0,300}, Increment=1, Suffix=" studs/s", CurrentValue=16, Callback=function(v) speedValue=v end})
uiRefs.raioX = t3:CreateToggle({Name="Raio-X", Callback=function(v) setRaioX(v) end})
uiRefs.joystick = t3:CreateToggle({Name="JOYSTICK AVANÇADO", Callback=function(v) joystickEnabled=v if v then setupJoystick() else destroyJoystick() end end})
uiRefs.infiniteJump = t3:CreateToggle({Name="Infinit-Pulos", Callback=function(v)
    infiniteJump=v
    if v then
        if not jumpConnection then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJump and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        end
    elseif jumpConnection then jumpConnection:Disconnect() jumpConnection=nil end
end})

local htbxExpan = false
local EXPAND_SIZE = 20
local HTBX_COLOR = Color3.new(1, 1, 1)
local selectionBoxes = {}
local targetSize = Vector3.new(EXPAND_SIZE, EXPAND_SIZE, EXPAND_SIZE)

local function setHtbxSize(newSize)
    EXPAND_SIZE = newSize
    targetSize = Vector3.new(newSize, newSize, newSize)
end

local function clearHtbxBoxes()
    for plr, sb in pairs(selectionBoxes) do
        pcall(function() sb:Destroy() end)
        selectionBoxes[plr] = nil
    end
end

local function ensureBox(player, head)
    if not htbxVisible then
        if selectionBoxes[player] then
            pcall(function() selectionBoxes[player]:Destroy() end)
            selectionBoxes[player] = nil
        end
        return
    end
    if selectionBoxes[player] and selectionBoxes[player].Parent == head then return end
    if selectionBoxes[player] then
        pcall(function() selectionBoxes[player]:Destroy() end)
        selectionBoxes[player] = nil
    end
    local sb = Instance.new("SelectionBox")
    sb.Name = "HitboxSelection"
    sb.Adornee = head
    sb.Color3 = HTBX_COLOR
    sb.LineThickness = 0.15
    sb.SurfaceTransparency = 0.7
    sb.SurfaceColor3 = HTBX_COLOR
    sb.Transparency = 0
    sb.Parent = head
    selectionBoxes[player] = sb
end

local function forceExpand(player, head)
    pcall(function()
        if head.Size ~= targetSize then head.Size = targetSize end
        if head.Transparency ~= 1 then head.Transparency = 1 end
        if head.Color ~= HTBX_COLOR then head.Color = HTBX_COLOR end
        if head.Material ~= Enum.Material.SmoothPlastic then head.Material = Enum.Material.SmoothPlastic end
        if head.CanCollide then head.CanCollide = false end
        if not head.Massless then head.Massless = true end
        if head.Shape ~= Enum.PartType.Block then head.Shape = Enum.PartType.Block end
    end)
end

RunService.RenderStepped:Connect(function()
    if not htbxExpan then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char.Parent then
                local head = char:FindFirstChild("Head")
                if head then
                    if htbxVisible then
                        ensureBox(player, head)
                    else
                        if selectionBoxes[player] then
                            pcall(function() selectionBoxes[player]:Destroy() end)
                            selectionBoxes[player] = nil
                        end
                    end
                    forceExpand(player, head)
                end
            end
        end
    end
end)

uiRefs.htbxExpan = t3:CreateToggle({Name="HTBX-EXPAN", Callback=function(v) htbxExpan=v if not v then clearHtbxBoxes() end end})
uiRefs.htbxSize = t3:CreateSlider({Name="Tamanho do HTBX", Range={10,70}, Increment=1, Suffix=" studs", CurrentValue=20, Callback=function(v) setHtbxSize(v) end})
uiRefs.htbxVisible = t3:CreateToggle({Name="Mostra/Não Mostra", CurrentValue=true, Callback=function(v) htbxVisible=v if not v then clearHtbxBoxes() end end})-- ============================================================
-- PARTE 4/4 — SISTEMA & IA, KIL-STRICKS, FPS E CONFIG
-- ============================================================

local t4 = Window:CreateTab("⚙️ Sistema & IA")

t4:CreateButton({Name="Modo Rápido (Fast Mode)", Callback=function()
    pcall(function()
        local l = game:GetService("Lighting")
        l.GlobalShadows = false
        l.Brightness = 2
        for _, v in ipairs(l:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then v.Enabled = false end
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end
            if v:IsA("BasePart") and v.Material ~= Enum.Material.SmoothPlastic then v.Material = Enum.Material.SmoothPlastic end
        end
    end)
    Rayfield:Notify({Title="Fast Mode", Content="Otimização aplicada.", Duration=3})
end})

t4:CreateButton({Name="MODO IA DEX", Callback=function()
    pcall(function()
        collectgarbage()
        local l = game:GetService("Lighting")
        l.GlobalShadows = false
        l.Brightness = 2
        l.FogEnd = 10000
        l.ClockTime = 14
        l.Ambient = Color3.new(1,1,1)
        l.OutdoorAmbient = Color3.new(1,1,1)
        for _, v in ipairs(l:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled = false end
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        end
    end)
    Rayfield:Notify({Title="IA DEX Ativado", Content="Otimização máxima estabelecida, senhor.", Duration=4})
end})

killNotificationGui = Instance.new("ScreenGui", game.CoreGui)
killNotificationGui.Name = "KillNotificationGui"
killNotificationGui.ResetOnSpawn = false
killNotificationGui.IgnoreGuiInset = true
killNotificationGui.Enabled = false

local currentKillNotif = nil

local function exitCurrentNotification()
    if currentKillNotif then
        local data = currentKillNotif
        currentKillNotif = nil
        if data.slideInTween then data.slideInTween:Cancel() end
        if data.slideOutTween then data.slideOutTween:Cancel() end
        if data.autoExitThread then pcall(task.cancel, data.autoExitThread) end
        local tween = TweenService:Create(data.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 220, 0, data.frame.Position.Y.Offset)})
        data.slideOutTween = tween
        tween:Play()
        tween.Completed:Connect(function() data.frame:Destroy() end)
        task.delay(0.3, function()
            if data.frame and data.frame.Parent then data.frame:Destroy() end
        end)
    end
end

local funnyMessages = {
    "eliminou o gay", "eliminou o cachorro", "eliminou o palhaço",
    "eliminou o sem pai", "eliminou a bixinha", "eliminou o sem mãe",
    "eliminou o arrombado", "eliminou o banana", "eliminou o bobão",
    "eliminou o jumento", "eliminou o perdedor", "eliminou o chorão",
    "eliminou o sem futuro", "eliminou o vacilão"
}

local function showKillNotification(victimName)
    if not kilStricks then return end
    if currentKillNotif then exitCurrentNotification() task.wait(0.25) end
    local msg = funnyMessages[math.random(1, #funnyMessages)]

    local notif = Instance.new("Frame", killNotificationGui)
    notif.Size = UDim2.new(0, 200, 0, 30)
    notif.Position = UDim2.new(1, 200, 0, 120)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.5
    notif.BorderSizePixel = 0

    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel", notif)
    nameLabel.Size = UDim2.new(1, -10, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = victimName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local infoLabel = Instance.new("TextLabel", notif)
    infoLabel.Size = UDim2.new(1, -10, 0.4, 0)
    infoLabel.Position = UDim2.new(0, 5, 0.6, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = msg
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.Font = Enum.Font.SourceSansBold
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left

    local notifData = { frame = notif, slideInTween = nil, slideOutTween = nil, autoExitThread = nil }
    currentKillNotif = notifData

    notifData.slideInTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -210, 0, 120)})
    notifData.slideInTween:Play()
    notifData.slideInTween.Completed:Connect(function()
        notifData.slideInTween = nil
        notifData.autoExitThread = task.delay(4, function()
            if currentKillNotif == notifData then exitCurrentNotification() end
        end)
    end)
end

local deathsQueue = {}
local lastKillsValue = nil

local function connectDeath(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            table.insert(deathsQueue, { name = player.Name, time = os.clock() })
            local now = os.clock()
            local filtered = {}
            for _, entry in ipairs(deathsQueue) do
                if now - entry.time < 5 then table.insert(filtered, entry) end
            end
            deathsQueue = filtered
        end)
    end)
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                table.insert(deathsQueue, { name = player.Name, time = os.clock() })
            end)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do connectDeath(player) end
Players.PlayerAdded:Connect(connectDeath)

local function monitorKills()
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", 10)
    if not leaderstats then return end
    local killsValue = nil
    for _, child in ipairs(leaderstats:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local name = child.Name:lower()
            if name:find("kill") or name:find("ko") or name:find("score") or name:find("elimina") then
                killsValue = child
                break
            end
        end
    end
    if not killsValue then return end

    lastKillsValue = killsValue.Value
    killsValue.Changed:Connect(function(newValue)
        local delta = newValue - lastKillsValue
        lastKillsValue = newValue
        if delta > 0 and kilStricks then
            for i = 1, delta do
                local death = table.remove(deathsQueue, 1)
                if death then showKillNotification(death.name) else showKillNotification("Player") end
            end
        end
    end)
end

task.spawn(monitorKills)

uiRefs.kilStricks = t2:CreateToggle({Name="KIL-STRICKS", Callback=function(v)
    kilStricks = v
    killNotificationGui.Enabled = kilStricks
end})

local fpsGui = Instance.new("ScreenGui", game.CoreGui)
local fpsFrame = Instance.new("Frame", fpsGui)
fpsFrame.Size = UDim2.new(0,120,0,24)
fpsFrame.Position = UDim2.new(1,-130,0,10)
fpsFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
fpsFrame.BackgroundTransparency = 0.4
fpsFrame.BorderSizePixel = 0
local fpsStroke = Instance.new("UIStroke", fpsFrame)
fpsStroke.Color = Color3.fromRGB(255,255,255)
fpsStroke.Thickness = 1
fpsStroke.Transparency = 0.7
local fpsLabel = Instance.new("TextLabel", fpsFrame)
fpsLabel.Size = UDim2.new(1,-4,1,0)
fpsLabel.Position = UDim2.new(0,2,0,0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 12
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.Text = "FPS: -- | Ping: --"
fpsFrame.Visible = false

t4:CreateToggle({Name="Monitor de FPS", Callback=function(v) fpsFrame.Visible=v end})

local fpsCount, fpsTime = 0, 0
RunService.Heartbeat:Connect(function(delta)
    fpsCount = fpsCount + 1
    fpsTime = fpsTime + delta
    if fpsTime >= 0.5 then
        local fps = math.floor(fpsCount / fpsTime)
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        fpsLabel.Text = string.format("FPS: %d | Ping: %d ms", fps, ping)
        fpsCount, fpsTime = 0, 0
    end
end)

local configFileName = "AIMDEX_V9_Config.txt"

local function saveConfig()
    local data = {
        aimbot = aimbot, aimSquadGM = aimSquadGM, showfov = showfov, spin = spin,
        fov = fov, spinspeed = spinspeed, esp = esp,
        espcolor = {espcolor.R, espcolor.G, espcolor.B},
        noclip = noclip, aimPartName = aimPartName, speedValue = speedValue,
        raioX = raioX, kilStricks = kilStricks, infiniteJump = infiniteJump,
        trollCost = trollCost, htbxExpan = htbxExpan, htbxSize = EXPAND_SIZE,
        htbxVisible = htbxVisible, lightVision = lightVision,
        espLines = espLines, espSkeleton = espSkeleton, ignoreWalls = ignoreWalls,
    }
    if writefile then
        pcall(function()
            writefile(configFileName, game:GetService("HttpService"):JSONEncode(data))
            Rayfield:Notify({Title="Config", Content="Configuração salva com sucesso.", Duration=3})
        end)
    else
        Rayfield:Notify({Title="Erro", Content="Seu executor não suporta writefile.", Duration=3})
    end
end

local function updateInfiniteJump()
    if infiniteJump then
        if not jumpConnection then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJump and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        end
    else
        if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
    end
end

local function loadConfig()
    if not readfile then return end
    local successLoad, content = pcall(readfile, configFileName)
    if successLoad and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        if data then
            aimbot = data.aimbot or false
            aimSquadGM = data.aimSquadGM or false
            showfov = data.showfov or false
            spin = data.spin or false
            fov = data.fov or 150
            spinspeed = data.spinspeed or 10
            esp = data.esp or false
            if data.espcolor then espcolor = Color3.new(data.espcolor[1], data.espcolor[2], data.espcolor[3]) end
            noclip = data.noclip or false
            aimPartName = data.aimPartName or "Head"
            speedValue = data.speedValue or 16
            raioX = data.raioX or false
            kilStricks = data.kilStricks or false
            infiniteJump = data.infiniteJump or false
            trollCost = data.trollCost or false
            htbxExpan = data.htbxExpan or false
            htbxVisible = data.htbxVisible
            if htbxVisible == nil then htbxVisible = true end
            lightVision = data.lightVision or false
            espLines = data.espLines
            if espLines == nil then espLines = true end
            espSkeleton = data.espSkeleton
            if espSkeleton == nil then espSkeleton = true end
            ignoreWalls = data.ignoreWalls
            if ignoreWalls == nil then ignoreWalls = true end
            if data.htbxSize then setHtbxSize(data.htbxSize) end

            ESPConfig.ShowLine = espLines
            ESPConfig.ShowSkeleton = espSkeleton

            if uiRefs.aimbot then uiRefs.aimbot:Set(aimbot) end
            if uiRefs.aimSquadGM then uiRefs.aimSquadGM:Set(aimSquadGM) end
            if uiRefs.showfov then uiRefs.showfov:Set(showfov) end
            if uiRefs.spin then uiRefs.spin:Set(spin) end
            if uiRefs.fov then uiRefs.fov:Set(fov) end
            if uiRefs.spinspeed then uiRefs.spinspeed:Set(spinspeed) end
            if uiRefs.esp then uiRefs.esp:Set(esp) end
            if uiRefs.espLines then uiRefs.espLines:Set(espLines) end
            if uiRefs.espSkeleton then uiRefs.espSkeleton:Set(espSkeleton) end
            if uiRefs.espcolor then uiRefs.espcolor:Set(espcolor) end
            if uiRefs.noclip then uiRefs.noclip:Set(noclip) end
            if uiRefs.speed then uiRefs.speed:Set(speedValue) end
            if uiRefs.raioX then uiRefs.raioX:Set(raioX) end
            if uiRefs.kilStricks then uiRefs.kilStricks:Set(kilStricks) end
            if uiRefs.infiniteJump then uiRefs.infiniteJump:Set(infiniteJump) end
            if uiRefs.trollCost then uiRefs.trollCost:Set(trollCost) end
            if uiRefs.htbxExpan then uiRefs.htbxExpan:Set(htbxExpan) end
            if uiRefs.htbxSize then uiRefs.htbxSize:Set(EXPAND_SIZE) end
            if uiRefs.htbxVisible then uiRefs.htbxVisible:Set(htbxVisible) end
            if uiRefs.lightVision then uiRefs.lightVision:Set(lightVision) end

            ESPConfig.Enabled = esp
            updateESPColors(espcolor)
            if raioX then setRaioX(true) end
            if lightVision then setLightVision(true) end
            killNotificationGui.Enabled = kilStricks
            if trollCost then trollTarget = nil end
            updateInfiniteJump()
        end
    end
end

t4:CreateButton({Name="Salvar Configuração", Callback=saveConfig})

Rayfield:Notify({Title="AIMDEX V9", Content="AIMDEX V9 CRIADO POR BERNARDO PEREIRA CARVALHO EMPRESA DEX.", Duration=5})

loadConfig()

end)

if not success then
    warn("Erro: "..tostring(err))
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Erro AIMDEX", Text=tostring(err), Duration=10})
end

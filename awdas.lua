local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = "Souls Hub | Made by RAT!_KarmA",
   LoadingTitle = "Souls Hub",
   LoadingSubtitle = "by KarmA",
   ConfigurationSaving = {Enabled = false},
   Discord = {Enabled = false},
   KeySystem = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local PhysicsService = game:GetService("PhysicsService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espEnabled = false
local namesEspEnabled = false
local lineEspEnabled = false
local boxEspEnabled = false
local fullBrightEnabled = false
local customLightingEnabled = false
local infJumpEnabled = false
local spinbotEnabled = false
local noClipEnabled = false
local autoReloadEnabled = false
local spinbotSpeed = 360
local playerSpeed = 16
local infJumpConnection
local spinbotConnection
local noClipConnection
local noClipChildConnection
local triggerBotEnabled = false
local triggerBotConnection
local lastShotTime = 0
local fireRate = 0.1
local crosshairRadius = 10
local isMobile = UserInputService.TouchEnabled and not (UserInputService.MouseEnabled or UserInputService.KeyboardEnabled)

local aimbotEnabled = false
local aimbotMobileEnabled = false
local blatantAimbotEnabled = false
local showFovCircle = true
local fovRadius = 120
local aiming = false
local aimbotLocked = false
local aimbotGui = nil
local touchStartPos = nil
local isTouchAiming = false
local wallCheckEnabled = false
local teamCheckEnabled = false

local customCrosshairEnabled = false
local crosshairSize = 10
local crosshairColor = Color3.fromRGB(255, 0, 0)
local cameraFov = 70

local defaultLightingSettings = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    FogColor = Lighting.FogColor,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    Ambient = Lighting.Ambient,
    ExposureCompensation = Lighting.ExposureCompensation
}
local defaultSky = Lighting:FindFirstChild("Sky") and Lighting:FindFirstChild("Sky"):Clone()

local function toggleSpinbot(state)
    spinbotEnabled = state
    if spinbotConnection then spinbotConnection:Disconnect() end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local existingGyro = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SpinbotGyro")
        if existingGyro then existingGyro:Destroy() end
    end
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local gyro = Instance.new("BodyGyro")
        gyro.Name = "SpinbotGyro"
        gyro.MaxTorque = Vector3.new(0, math.huge, 0)
        gyro.P = 10000
        gyro.D = 100
        gyro.Parent = root
        spinbotConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if spinbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not humanoid.Sit then
                    local randomVariation = math.random(-50, 50)
                    local effectiveSpeed = spinbotSpeed + randomVariation
                    local angle = deltaTime * math.rad(effectiveSpeed)
                    gyro.CFrame = gyro.CFrame * CFrame.Angles(0, -angle, 0)
                end
            end
        end)
    end
end

local function toggleNoClip(state)
    noClipEnabled = state
    if noClipConnection then noClipConnection:Disconnect() end
    if noClipChildConnection then noClipChildConnection:Disconnect() end

    local function applyNoClip(character)
        if not character then return end
        if state then
            local success, canUseGroups = pcall(function() return PhysicsService:CollisionGroupExists("Default") end)
            if success and canUseGroups then
                if not pcall(function() return PhysicsService:CollisionGroupExists("NoClipPlayer") end) then
                    PhysicsService:CreateCollisionGroup("NoClipPlayer")
                    PhysicsService:CollisionGroupSetCollidable("NoClipPlayer", "Default", false)
                end
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            PhysicsService:SetPartCollisionGroup(part, "NoClipPlayer")
                            part.CanCollide = false
                        end)
                    end
                end
                noClipChildConnection = character.ChildAdded:Connect(function(child)
                    if noClipEnabled and child:IsA("BasePart") then
                        pcall(function()
                            PhysicsService:SetPartCollisionGroup(child, "NoClipPlayer")
                            child.CanCollide = false
                        end)
                    end
                end)
            else
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                noClipChildConnection = character.ChildAdded:Connect(function(child)
                    if noClipEnabled and child:IsA("BasePart") then child.CanCollide = false end
                end)
            end
        else
            local success, canUseGroups = pcall(function() return PhysicsService:CollisionGroupExists("Default") end)
            if success and canUseGroups then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            PhysicsService:SetPartCollisionGroup(part, "Default")
                            part.CanCollide = true
                        end)
                    end
                end
                pcall(function() PhysicsService:RemoveCollisionGroup("NoClipPlayer") end)
            else
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    if state then
        if LocalPlayer.Character then applyNoClip(LocalPlayer.Character) end
        noClipConnection = RunService.Stepped:Connect(function()
            if noClipEnabled and LocalPlayer.Character then
                local success, canUseGroups = pcall(function() return PhysicsService:CollisionGroupExists("Default") end)
                if success and canUseGroups then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            pcall(function()
                                PhysicsService:SetPartCollisionGroup(part, "NoClipPlayer")
                                part.CanCollide = false
                            end)
                        end
                    end
                else
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end
        end)
    else
        if LocalPlayer.Character then applyNoClip(LocalPlayer.Character) end
    end
end

local ESP = {Highlights = {}, Names = {}, Lines = {}, Boxes = {}}

function ESP:CreateHighlight(player)
    if player == LocalPlayer then return end
    local function applyHighlight(character)
        if not character then return end
        if character:FindFirstChild("ESP_Highlight") then character.ESP_Highlight:Destroy() end
        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillColor = teamColor
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.3
        highlight.Parent = character
        ESP.Highlights[player] = highlight
    end
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(function(character) wait(1); applyHighlight(character) end)
    player:GetPropertyChangedSignal("Team"):Connect(function() if player.Character then applyHighlight(player.Character) end end)
end

function ESP:CreateNames(player)
    if player == LocalPlayer then return end
    local function applyNames(character)
        if not character or not character:FindFirstChild("Head") then return end
        if character:FindFirstChild("ESP_Name") then character.ESP_Name:Destroy() end
        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_Name"
        billboardGui.Adornee = character.Head
        billboardGui.Size = UDim2.new(0, 100, 0, 30)
        billboardGui.StudsOffset = Vector3.new(0, 2, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = character
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = player.Name
        textLabel.TextColor3 = teamColor
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = billboardGui
        ESP.Names[player] = billboardGui
    end
    if player.Character then applyNames(player.Character) end
    player.CharacterAdded:Connect(function(character) wait(1); applyNames(character) end)
end

function ESP:CreateLine(player)
    if player == LocalPlayer then return end
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
    line.Thickness = 1
    line.Transparency = 0.8
    ESP.Lines[player] = line
end

function ESP:CreateBox(player)
    if player == LocalPlayer then return end
    local boxLines = {Top = Drawing.new("Line"), Bottom = Drawing.new("Line"), Left = Drawing.new("Line"), Right = Drawing.new("Line")}
    for _, line in pairs(boxLines) do
        line.Visible = false
        line.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 0.8
    end
    ESP.Boxes[player] = boxLines
end

function ESP:EnableHighlight(state)
    espEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do ESP:CreateHighlight(player) end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character) wait(1); ESP:CreateHighlight(player) end)
        end)
    else
        for player, highlight in pairs(ESP.Highlights) do if highlight then highlight:Destroy() end end
        ESP.Highlights = {}
    end
end

function ESP:EnableNames(state)
    namesEspEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do ESP:CreateNames(player) end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character) wait(1); ESP:CreateNames(player) end)
        end)
    else
        for player, billboard in pairs(ESP.Names) do if billboard then billboard:Destroy() end end
        ESP.Names = {}
    end
end

function ESP:EnableLines(state)
    lineEspEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do ESP:CreateLine(player) end
        Players.PlayerAdded:Connect(function(player) ESP:CreateLine(player) end)
    else
        for player, line in pairs(ESP.Lines) do if line then line:Remove() end end
        ESP.Lines = {}
    end
end

function ESP:EnableBoxes(state)
    boxEspEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do ESP:CreateBox(player) end
        Players.PlayerAdded:Connect(function(player) ESP:CreateBox(player) end)
    else
        for player, boxLines in pairs(ESP.Boxes) do
            for _, line in pairs(boxLines) do if line then line:Remove() end end
        end
        ESP.Boxes = {}
    end
end

RunService.RenderStepped:Connect(function()
    for player, line in pairs(ESP.Lines) do
        if lineEspEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 50)
            if onScreen then
                line.Visible = true
                line.From = screenCenter
                line.To = Vector2.new(screenPos.X, screenPos.Y)
                line.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
            else line.Visible = false end
        else line.Visible = false end
    end

    for player, boxLines in pairs(ESP.Boxes) do
        if boxEspEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            if head then
                local scale = 2
                local topPos = head.Position + Vector3.new(0, scale, 0)
                local bottomPos = root.Position - Vector3.new(0, scale, 0)
                local leftPos = root.Position - Vector3.new(scale * 0.5, 0, 0)
                local rightPos = root.Position + Vector3.new(scale * 0.5, 0, 0)
                local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPos)
                local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos)
                local leftScreen = Camera:WorldToViewportPoint(leftPos)
                local rightScreen = Camera:WorldToViewportPoint(rightPos)
                if topOnScreen and bottomOnScreen then
                    local topLeft = Vector2.new(leftScreen.X, topScreen.Y)
                    local topRight = Vector2.new(rightScreen.X, topScreen.Y)
                    local bottomLeft = Vector2.new(leftScreen.X, bottomScreen.Y)
                    local bottomRight = Vector2.new(rightScreen.X, bottomScreen.Y)
                    boxLines.Top.From = topLeft; boxLines.Top.To = topRight
                    boxLines.Bottom.From = bottomLeft; boxLines.Bottom.To = bottomRight
                    boxLines.Left.From = topLeft; boxLines.Left.To = bottomLeft
                    boxLines.Right.From = topRight; boxLines.Right.To = bottomRight
                    for _, line in pairs(boxLines) do
                        line.Visible = true
                        line.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
                    end
                else for _, line in pairs(boxLines) do line.Visible = false end end
            else for _, line in pairs(boxLines) do line.Visible = false end end
        else for _, line in pairs(boxLines) do line.Visible = false end end
    end
end)

local function enableFullBright(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ExposureCompensation = 0
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.ExposureCompensation = 0.1
        Lighting.GlobalShadows = true
    end
end

local function toggleCustomLighting(state)
    customLightingEnabled = state
    if state then
        Lighting.ClockTime = 16
        Lighting.Brightness = 2.5
        Lighting.FogEnd = 1000
        Lighting.FogStart = 50
        Lighting.FogColor = Color3.fromRGB(200, 200, 200)
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.Ambient = Color3.fromRGB(60, 60, 60)
        Lighting.ExposureCompensation = 0.3

        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
                v:Destroy()
            end
        end

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.7
        bloom.Size = 56
        bloom.Threshold = 1
        bloom.Parent = Lighting

        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Brightness = 0.05
        colorCorrection.Contrast = 0.1
        colorCorrection.Saturation = 0.15
        colorCorrection.TintColor = Color3.fromRGB(255, 244, 214)
        colorCorrection.Parent = Lighting

        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Intensity = 0.15
        sunRays.Spread = 0.25
        sunRays.Parent = Lighting

        local depthOfField = Instance.new("DepthOfFieldEffect")
        depthOfField.FarIntensity = 0.2
        depthOfField.FocusDistance = 50
        depthOfField.InFocusRadius = 30
        depthOfField.NearIntensity = 0.3
        depthOfField.Parent = Lighting

        local sky = Instance.new("Sky")
        sky.Name = "RealSky"
        sky.SkyboxBk = "rbxassetid://600830446"
        sky.SkyboxDn = "rbxassetid://600831635"
        sky.SkyboxFt = "rbxassetid://600832720"
        sky.SkyboxLf = "rbxassetid://600835142"
        sky.SkyboxRt = "rbxassetid://600836180"
        sky.SkyboxUp = "rbxassetid://600837470"
        sky.StarCount = 3000
        sky.MoonAngularSize = 11
        sky.SunAngularSize = 21
        sky.CelestialBodiesShown = true
        sky.Parent = Lighting

        spawn(function()
            while customLightingEnabled do
                wait(2)
                if not Lighting:FindFirstChild("RealSky") then
                    sky:Clone().Parent = Lighting
                end
            end
        end)
    else
        for key, value in pairs(defaultLightingSettings) do
            Lighting[key] = value
        end
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Sky") then
                v:Destroy()
            end
        end
        if defaultSky then defaultSky:Clone().Parent = Lighting end
    end
end

local function toggleInfJump(state)
    infJumpEnabled = state
    if infJumpConnection then infJumpConnection:Disconnect() end
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end

local function getCrosshairPosition()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function isHeadUnderCrosshair()
    local crosshairPos = getCrosshairPosition()
    local closestHead = nil
    local closestDistance = crosshairRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health <= 0 then continue end
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - crosshairPos).Magnitude
                if distance < closestDistance then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    local raycastResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * (head.Position - Camera.CFrame.Position).Magnitude, raycastParams)
                    local isVisible = not raycastResult or raycastResult.Instance == head
                    local isSameTeam = teamCheckEnabled and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
                    if isVisible and not isSameTeam then
                        closestDistance = distance
                        closestHead = head
                    end
                end
            end
        end
    end
    return closestHead ~= nil
end

local function simulateFire()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
        local fireEvent = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
        if fireEvent and fireEvent:IsA("RemoteEvent") then
            fireEvent:FireServer(Camera.CFrame.Position, Camera.CFrame.LookVector)
            return
        end
    end
    if isMobile then
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0), Camera.CFrame)
        wait(0.01)
        VirtualUser:Button1Up(Vector2.new(0, 0), Camera.CFrame)
    else
        if pcall(function() mouse1press(); wait(0.01); mouse1release() end) then else
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        end
    end
end

local function toggleTriggerBot(state)
    triggerBotEnabled = state
    if triggerBotConnection then triggerBotConnection:Disconnect() end
    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            if triggerBotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                local currentTime = tick()
                if isHeadUnderCrosshair() and (currentTime - lastShotTime) >= (fireRate + math.random(0.05, 0.15)) then
                    simulateFire()
                    lastShotTime = currentTime
                end
            end
        end)
    end
end

local function toggleAutoReload(state)
    autoReloadEnabled = state
    if autoReloadEnabled then
        spawn(function()
            while autoReloadEnabled do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local ammo = tool:FindFirstChild("Ammo")
                        local maxAmmo = tool:FindFirstChild("MaxAmmo")
                        if ammo and maxAmmo and ammo.Value <= 0 then
                            local reloadEvent = tool:FindFirstChild("Reload")
                            if reloadEvent and reloadEvent:IsA("RemoteEvent") then
                                reloadEvent:FireServer()
                            elseif tool:FindFirstChild("ReloadAnimation") then
                                LocalPlayer.Character.Humanoid:LoadAnimation(tool.ReloadAnimation):Play()
                            end
                            wait(0.1 + math.random(0, 0.1))
                        end
                    end
                end
                wait(0.1)
            end
        end)
    end
end

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fovRadius
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.Transparency = 0.75
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Visible = showFovCircle

local crosshairHorizontal = Drawing.new("Line")
crosshairHorizontal.Thickness = 2
crosshairHorizontal.Transparency = 0.9
crosshairHorizontal.Visible = false

local crosshairVertical = Drawing.new("Line")
crosshairVertical.Thickness = 2
crosshairVertical.Transparency = 0.9
crosshairVertical.Visible = false

local function updateCrosshair()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    crosshairHorizontal.Color = crosshairColor
    crosshairVertical.Color = crosshairColor
    crosshairHorizontal.From = screenCenter - Vector2.new(crosshairSize, 0)
    crosshairHorizontal.To = screenCenter + Vector2.new(crosshairSize, 0)
    crosshairVertical.From = screenCenter - Vector2.new(0, crosshairSize)
    crosshairVertical.To = screenCenter + Vector2.new(0, crosshairSize)
    crosshairHorizontal.Visible = customCrosshairEnabled
    crosshairVertical.Visible = customCrosshairEnabled
end

local function toggleCustomCrosshair(state)
    customCrosshairEnabled = state
    updateCrosshair()
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local aimPos = isMobile and touchStartPos or UserInputService:GetMouseLocation()
    if not aimPos then aimPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health <= 0 or humanoid.Sit then continue end
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - aimPos).Magnitude
                if distance < shortestDistance then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    local raycastResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * (head.Position - Camera.CFrame.Position).Magnitude, raycastParams)
                    local isVisible = not wallCheckEnabled or (not raycastResult or raycastResult.Instance == head)
                    local isSameTeam = teamCheckEnabled and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
                    if isVisible and not isSameTeam then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local activeTouchId = nil

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    elseif isMobile and input.UserInputType == Enum.UserInputType.Touch then
        if not activeTouchId then
            activeTouchId = input.InputId
            touchStartPos = Vector2.new(input.Position.X, input.Position.Y)
            isTouchAiming = true
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if isMobile and input.UserInputType == Enum.UserInputType.Touch and input.InputId == activeTouchId then
        touchStartPos = Vector2.new(input.Position.X, input.Position.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    elseif isMobile and input.UserInputType == Enum.UserInputType.Touch and input.InputId == activeTouchId then
        activeTouchId = nil
        touchStartPos = nil
        isTouchAiming = false
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    local aimPos = isMobile and touchStartPos or UserInputService:GetMouseLocation()
    if not aimPos then aimPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end
    fovCircle.Position = aimPos
    fovCircle.Visible = showFovCircle and (aimbotEnabled or aimbotMobileEnabled or blatantAimbotEnabled)
    fovCircle.Radius = fovRadius
    updateCrosshair()

    local isAimingActive = (not isMobile and aiming) or (isMobile and isTouchAiming) or aimbotLocked
    if isAimingActive and (aimbotEnabled or blatantAimbotEnabled or aimbotMobileEnabled) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position + Vector3.new(0, 0.5, 0)
            local targetCFrame = CFrame.new(Camera.CFrame.Position, headPos)
            if blatantAimbotEnabled then
                Camera.CFrame = targetCFrame
            elseif aimbotEnabled or aimbotMobileEnabled then
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.2)
            end
        end
    end
    Camera.FieldOfView = cameraFov
end)

local function createAimbotLockGui()
    if aimbotGui then aimbotGui.Enabled = true; return end
    aimbotGui = Instance.new("ScreenGui")
    aimbotGui.Name = "AimbotLockGui"
    aimbotGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    aimbotGui.ResetOnSpawn = false

    local lockButton = Instance.new("TextButton")
    lockButton.Name = "AimbotAutoLockButton"
    lockButton.Text = "Aimbot Auto Lock: OFF"
    lockButton.Size = UDim2.new(0, 250, 0, 60)
    lockButton.Position = UDim2.new(0.5, -125, 0.5, -30)
    lockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockButton.Font = Enum.Font.SourceSansBold
    lockButton.TextSize = 20
    lockButton.Parent = aimbotGui

    local dragging = false
    local dragStart = nil
    local startPos = nil

    lockButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = lockButton.Position
        end
    end)

    lockButton.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            lockButton.Position = newPos
        end
    end)

    lockButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    lockButton.Activated:Connect(function()
        aimbotLocked = not aimbotLocked
        lockButton.Text = aimbotLocked and "Aimbot Auto Lock: ON" or "Aimbot Auto Lock: OFF"
        lockButton.BackgroundColor3 = aimbotLocked and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visual")
local PlayerTab = Window:CreateTab("Player")

Rayfield:CreateSection(CombatTab, "Aimbot Controls")

Rayfield:CreateButton(CombatTab, "Show Aimbot Lock GUI", function()
    createAimbotLockGui()
end)

Rayfield:CreateToggle(CombatTab, "Aimbot (Smooth)", aimbotEnabled, function(state)
    if not isMobile then
        aimbotEnabled = state
        blatantAimbotEnabled = false
        fovCircle.Visible = showFovCircle and aimbotEnabled
    end
end)

Rayfield:CreateToggle(CombatTab, "Aimbot (Blatant)", blatantAimbotEnabled, function(state)
    if not isMobile then
        blatantAimbotEnabled = state
        aimbotEnabled = false
        fovCircle.Visible = showFovCircle and blatantAimbotEnabled
    end
end)

Rayfield:CreateToggle(CombatTab, "Aimbot (Mobile Manual)", aimbotMobileEnabled, function(state)
    if isMobile then
        aimbotMobileEnabled = state
        fovCircle.Visible = showFovCircle and aimbotMobileEnabled
    end
end)

Rayfield:CreateToggle(CombatTab, "Show FOV Circle", showFovCircle, function(state)
    showFovCircle = state
    fovCircle.Visible = showFovCircle and (aimbotEnabled or aimbotMobileEnabled or blatantAimbotEnabled)
end)

Rayfield:CreateSlider(CombatTab, "FOV Radius", 50, 300, 120, function(value)
    fovRadius = value
end)

Rayfield:CreateToggle(CombatTab, "Wall Check", wallCheckEnabled, function(state)
    wallCheckEnabled = state
end)

Rayfield:CreateToggle(CombatTab, "Team Check", teamCheckEnabled, function(state)
    teamCheckEnabled = state
end)

Rayfield:CreateToggle(CombatTab, "TriggerBot", triggerBotEnabled, function(state)
    toggleTriggerBot(state)
end)

Rayfield:CreateToggle(CombatTab, "Auto Reload", autoReloadEnabled, function(state)
    toggleAutoReload(state)
end)

Rayfield:CreateSection(VisualTab, "ESP and Lighting")

Rayfield:CreateToggle(VisualTab, "Highlight ESP", espEnabled, function(state)
    espEnabled = state
    ESP:EnableHighlight(state)
end)

Rayfield:CreateToggle(VisualTab, "Names ESP", namesEspEnabled, function(state)
    namesEspEnabled = state
    ESP:EnableNames(state)
end)

Rayfield:CreateToggle(VisualTab, "Line ESP", lineEspEnabled, function(state)
    lineEspEnabled = state
    ESP:EnableLines(state)
end)

Rayfield:CreateToggle(VisualTab, "Box ESP", boxEspEnabled, function(state)
    boxEspEnabled = state
    ESP:EnableBoxes(state)
end)

Rayfield:CreateToggle(VisualTab, "Full Bright", fullBrightEnabled, function(state)
    fullBrightEnabled = state
    enableFullBright(state)
end)

Rayfield:CreateToggle(VisualTab, "RTX Lighting", customLightingEnabled, function(state)
    toggleCustomLighting(state)
end)

Rayfield:CreateToggle(VisualTab, "Custom Crosshair", customCrosshairEnabled, function(state)
    toggleCustomCrosshair(state)
end)

Rayfield:CreateSlider(VisualTab, "Crosshair Size", 5, 20, 10, function(value)
    crosshairSize = value
    updateCrosshair()
end)

Rayfield:CreateColorPicker(VisualTab, "Crosshair Color", crosshairColor, function(color)
    crosshairColor = color
    updateCrosshair()
end)

Rayfield:CreateSlider(VisualTab, "Camera FOV", 70, 120, 70, function(value)
    cameraFov = value
end)

Rayfield:CreateSection(PlayerTab, "Movement and Speed")

Rayfield:CreateToggle(PlayerTab, "Infinite Jump", infJumpEnabled, function(state)
    toggleInfJump(state)
end)

Rayfield:CreateToggle(PlayerTab, "Spinbot", spinbotEnabled, function(state)
    toggleSpinbot(state)
end)

Rayfield:CreateSlider(PlayerTab, "Spinbot Speed", 100, 1000, 360, function(value)
    spinbotSpeed = value
end)

Rayfield:CreateSlider(PlayerTab, "Player Speed", 16, 100, 16, function(value)
    playerSpeed = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = playerSpeed
    end
end)

Rayfield:CreateToggle(PlayerTab, "No Clip", noClipEnabled, function(state)
    toggleNoClip(state)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if infJumpEnabled then toggleInfJump(true) end
    if spinbotEnabled then toggleSpinbot(true) end
    if noClipEnabled then toggleNoClip(true) end
    if playerSpeed ~= 16 and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = playerSpeed
    end
    if cameraFov ~= 70 then Camera.FieldOfView = cameraFov end
end)

Rayfield:LoadConfiguration()

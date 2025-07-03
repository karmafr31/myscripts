local defaultScriptContent = [[
local libraryUrl = "https://pandadevelopment.net/virtual/file/8aae538fa43d8ab7"

local success, libraryCode = pcall(game.HttpGet, game, libraryUrl)

if not success or not libraryCode then
    warn("Error: Failed to download Souls Hub Library! Check URL: " .. libraryUrl .. " and ensure HttpService is enabled.")
    return
end

local successLoad, Library = pcall(loadstring(libraryCode))
print("um")
print("um")
print("um")
print("um")
print("um")
print("um")
print("um")
print("um")
print("um")
print("Karma is cool")

if not successLoad or typeof(Library) ~= "table" then
    warn("Error: Failed to load Souls Hub Library from downloaded code! Error: ", Library) 
    return
end

local Window = Library:Init({
    Title = "Made with love by RAT!_KarmA",
    Width = 600,
    Height = 450,
    ToggleKey = Enum.KeyCode.RightShift
})

local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visual")
local PlayerTab = Window:CreateTab("Player")

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
local crosshairColorR = 255
local crosshairColorG = 0
local crosshairColorB = 0
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

    if spinbotConnection then
        spinbotConnection:Disconnect()
        spinbotConnection = nil
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local existingGyro = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SpinbotGyro")
        if existingGyro then
            existingGyro:Destroy()
        end
    end

    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local gyro = Instance.new("BodyGyro")
        gyro.Name = "SpinbotGyro"
        gyro.MaxTorque = Vector3.new(0, math.huge, 0)
        gyro.P = 10000
        gyro.D = 100
        gyro.Parent = root

        spinbotConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if spinbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = LocalPlayer.Character.Humanoid
                if humanoid.Health <= 0 or humanoid.Sit then
                    return
                end

                local randomVariation = math.random(-50, 50)
                local effectiveSpeed = spinbotSpeed + randomVariation
                local angle = deltaTime * math.rad(effectiveSpeed)

                gyro.CFrame = gyro.CFrame * CFrame.Angles(0, -angle, 0)
            end
        end)
    end
end

local function toggleNoClip(state)
    noClipEnabled = state

    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    if noClipChildConnection then
        noClipChildConnection:Disconnect()
        noClipChildConnection = nil
    end

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
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                noClipChildConnection = character.ChildAdded:Connect(function(child)
                    if noClipEnabled and child:IsA("BasePart") then
                        child.CanCollide = false
                    end
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
                pcall(function()
                    PhysicsService:RemoveCollisionGroup("NoClipPlayer")
                end)
            else
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end

    if state then
        if LocalPlayer.Character then
            applyNoClip(LocalPlayer.Character)
        end
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
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if LocalPlayer.Character then
            applyNoClip(LocalPlayer.Character)
        end
    end
end

local ESP = {
    Highlights = {},
    Names = {},
    Lines = {},
    Boxes = {}
}

function ESP:CreateHighlight(player)
    if player == LocalPlayer then return end

    local function applyHighlight(character)
        if not character then return end

        if character:FindFirstChild("ESP_Highlight") then
            character.ESP_Highlight:Destroy()
        end

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

    if player.Character then
        applyHighlight(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        wait(1)
        applyHighlight(character)
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            applyHighlight(player.Character)
        end
    end)
end

function ESP:CreateNames(player)
    if player == LocalPlayer then return end

    local function applyNames(character)
        if not character or not character:FindFirstChild("Head") then return end

        if character:FindFirstChild("ESP_Name") then
            character.ESP_Name:Destroy()
        end

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

    if player.Character then
        applyNames(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        wait(1)
        applyNames(character)
    end)
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

    local boxLines = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line")
    }

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
        for _, player in pairs(Players:GetPlayers()) do
            ESP:CreateHighlight(player)
        end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                wait(1)
                ESP:CreateHighlight(player)
            end)
        end)
    else
        for player, highlight in pairs(ESP.Highlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        ESP.Highlights = {}
    end
end

function ESP:EnableNames(state)
    namesEspEnabled = state

    if state then
        for _, player in pairs(Players:GetPlayers()) do
            ESP:CreateNames(player)
        end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                wait(1)
                ESP:CreateNames(player)
            end)
        end)
    else
        for player, billboard in pairs(ESP.Names) do
            if billboard then
                billboard:Destroy()
            end
        end
        ESP.Names = {}
    end
end

function ESP:EnableLines(state)
    lineEspEnabled = state

    if state then
        for _, player in pairs(Players:GetPlayers()) do
            ESP:CreateLine(player)
        end
        Players.PlayerAdded:Connect(function(player)
            ESP:CreateLine(player)
        end)
    else
        for player, line in pairs(ESP.Lines) do
            if line then
                line:Remove()
            end
        end
        ESP.Lines = {}
    end
end

function ESP:EnableBoxes(state)
    boxEspEnabled = state

    if state then
        for _, player in pairs(Players:GetPlayers()) do
            ESP:CreateBox(player)
        end
        Players.PlayerAdded:Connect(function(player)
            ESP:CreateBox(player)
        end)
    else
        for player, boxLines in pairs(ESP.Boxes) do
            for _, line in pairs(boxLines) do
                if line then
                    line:Remove()
                end
            end
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
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end

    for player, boxLines in pairs(ESP.Boxes) do
        if boxEspEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local humanoid = player.Character.Humanoid

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

                boxLines.Top.From = topLeft
                boxLines.Top.To = topRight
                boxLines.Bottom.From = bottomLeft
                boxLines.Bottom.To = bottomRight
                boxLines.Left.From = topLeft
                boxLines.Left.To = bottomLeft
                boxLines.Right.From = topRight
                boxLines.Right.To = bottomRight

                for _, line in pairs(boxLines) do
                    line.Visible = true
                    line.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
                end
            else
                for _, line in pairs(boxLines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(boxLines) do
                line.Visible = false
            end
        end
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
        Lighting.ClockTime = defaultLightingSettings.ClockTime
        Lighting.Brightness = defaultLightingSettings.Brightness
        Lighting.FogEnd = defaultLightingSettings.FogEnd
        Lighting.FogStart = defaultLightingSettings.FogStart
        Lighting.FogColor = defaultLightingSettings.FogColor
        Lighting.GlobalShadows = defaultLightingSettings.GlobalShadows
        Lighting.OutdoorAmbient = defaultLightingSettings.OutdoorAmbient
        Lighting.EnvironmentDiffuseScale = defaultLightingSettings.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = defaultLightingSettings.EnvironmentSpecularScale
        Lighting.Ambient = defaultLightingSettings.Ambient
        Lighting.ExposureCompensation = defaultLightingSettings.ExposureCompensation

        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Sky") then
                v:Destroy()
            end
        end

        if defaultSky then
            defaultSky:Clone().Parent = Lighting
        end
    end
end

local function toggleInfJump(state)
    infJumpEnabled = state

    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end

    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
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
            if humanoid.Health <= 0 then
                continue
            end
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
        if pcall(function()
            mouse1press()
            wait(0.01)
            mouse1release()
        end) then
        else
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        end
    end
end

local function toggleTriggerBot(state)
    triggerBotEnabled = state

    if triggerBotConnection then
        triggerBotConnection:Disconnect()
        triggerBotConnection = nil
    end

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
    crosshairHorizontal.Color = Color3.fromRGB(crosshairColorR, crosshairColorG, crosshairColorB)
    crosshairVertical.Color = Color3.fromRGB(crosshairColorR, crosshairColorG, crosshairColorB)
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

    if not aimPos then
        aimPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health <= 0 or humanoid.Sit then
                continue
            end
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
    if not aimPos then
        aimPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
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
    if aimbotGui then
        aimbotGui.Enabled = true
        return
    end

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
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
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

Window:AddCategory(CombatTab, "Aimbot Controls")

Window:CreateButton(CombatTab, "Show Aimbot Lock GUI", function()
    createAimbotLockGui()
end)

Window:CreateToggle(CombatTab, "Aimbot (Smooth): ", "ON", "OFF", function()
    if not isMobile then
        aimbotEnabled = true
        blatantAimbotEnabled = false
        fovCircle.Visible = showFovCircle and aimbotEnabled
    end
end, function()
    if not isMobile then
        aimbotEnabled = false
        if not blatantAimbotEnabled then
            aimbotLocked = false
            if aimbotGui and aimbotGui:FindFirstChild("AimbotAutoLockButton") then
                aimbotGui.AimbotAutoLockButton.Text = "Aimbot Auto Lock: OFF"
                aimbotGui.AimbotAutoLockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
            fovCircle.Visible = false
        end
    end
end)

Window:CreateToggle(CombatTab, "Aimbot (Blatant): ", "ON", "OFF", function()
    if not isMobile then
        blatantAimbotEnabled = true
        aimbotEnabled = false
        fovCircle.Visible = showFovCircle and blatantAimbotEnabled
    end
end, function()
    if not isMobile then
        blatantAimbotEnabled = false
        if not aimbotEnabled then
            aimbotLocked = false
            if aimbotGui and aimbotGui:FindFirstChild("AimbotAutoLockButton") then
                aimbotGui.AimbotAutoLockButton.Text = "Aimbot Auto Lock: OFF"
                aimbotGui.AimbotAutoLockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
            fovCircle.Visible = false
        end
    end
end)

Window:CreateToggle(CombatTab, "Aimbot (Mobile Manual): ", "ON", "OFF", function()
    if isMobile then
        aimbotMobileEnabled = true
        fovCircle.Visible = showFovCircle and aimbotMobileEnabled
    end
end, function()
    if isMobile then
        aimbotMobileEnabled = false
        aimbotLocked = false
        if aimbotGui and aimbotGui:FindFirstChild("AimbotAutoLockButton") then
            aimbotGui.AimbotAutoLockButton.Text = "Aimbot Auto Lock: OFF"
            aimbotGui.AimbotAutoLockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        fovCircle.Visible = false
    end
end)

Window:CreateToggle(CombatTab, "Show FOV Circle: ", "ON", "OFF", function()
    showFovCircle = true
    fovCircle.Visible = showFovCircle and (aimbotEnabled or aimbotMobileEnabled or blatantAimbotEnabled)
end, function()
    showFovCircle = false
    fovCircle.Visible = false
end)

Window:CreateSlider(CombatTab, "FOV Radius:", 50, 300, 120, function(value)
    fovRadius = value
end, {Increment = 10, Suffix = " Pixels"})

Window:CreateToggle(CombatTab, "Wall Check: ", "ON", "OFF", function()
    wallCheckEnabled = true
end, function()
    wallCheckEnabled = false
end)

Window:CreateToggle(CombatTab, "Team Check: ", "ON", "OFF", function()
    teamCheckEnabled = true
end, function()
    teamCheckEnabled = false
end)

Window:CreateToggle(CombatTab, "TriggerBot: ", "ON", "OFF", function()
    toggleTriggerBot(true)
end, function()
    toggleTriggerBot(false)
end)

Window:CreateToggle(CombatTab, "Auto Reload: ", "ON", "OFF", function()
    toggleAutoReload(true)
end, function()
    toggleAutoReload(false)
end)

Window:AddCategory(VisualTab, "ESP and Lighting")

Window:CreateToggle(VisualTab, "Highlight ESP: ", "ON", "OFF", function()
    espEnabled = true
    ESP:EnableHighlight(true)
end, function()
    espEnabled = false
    ESP:EnableHighlight(false)
end)

Window:CreateToggle(VisualTab, "Names ESP: ", "ON", "OFF", function()
    namesEspEnabled = true
    ESP:EnableNames(true)
end, function()
    namesEspEnabled = false
    ESP:EnableNames(false)
end)

Window:CreateToggle(VisualTab, "Line ESP: ", "ON", "OFF", function()
    lineEspEnabled = true
    ESP:EnableLines(true)
end, function()
    lineEspEnabled = false
    ESP:EnableLines(false)
end)

Window:CreateToggle(VisualTab, "Box ESP: ", "ON", "OFF", function()
    boxEspEnabled = true
    ESP:EnableBoxes(true)
end, function()
    boxEspEnabled = false
    ESP:EnableBoxes(false)
end)

Window:CreateToggle(VisualTab, "Full Bright: ", "ON", "OFF", function()
    fullBrightEnabled = true
    enableFullBright(true)
end, function()
    fullBrightEnabled = false
    enableFullBright(false)
end)

Window:CreateToggle(VisualTab, "RTX Lighting: ", "ON", "OFF", function()
    toggleCustomLighting(true)
end, function()
    toggleCustomLighting(false)
end)

Window:CreateToggle(VisualTab, "Custom Crosshair: ", "ON", "OFF", function()
    toggleCustomCrosshair(true)
end, function()
    toggleCustomCrosshair(false)
end)

Window:CreateSlider(VisualTab, "Crosshair Size:", 5, 20, 10, function(value)
    crosshairSize = value
    updateCrosshair()
end, {Increment = 1, Suffix = " Pixels"})

Window:CreateSlider(VisualTab, "Crosshair Red:", 0, 255, 255, function(value)
    crosshairColorR = value
    updateCrosshair()
end, {Increment = 5, Suffix = " Value"})

Window:CreateSlider(VisualTab, "Crosshair Green:", 0, 255, 0, function(value)
    crosshairColorG = value
    updateCrosshair()
end, {Increment = 5, Suffix = " Value"})

Window:CreateSlider(VisualTab, "Crosshair Blue:", 0, 255, 0, function(value)
    crosshairColorB = value
    updateCrosshair()
end, {Increment = 5, Suffix = " Value"})

Window:CreateSlider(VisualTab, "Camera FOV:", 70, 120, 70, function(value)
    cameraFov = value
end, {Increment = 1, Suffix = " Degrees"})

Window:AddCategory(PlayerTab, "Movement and Speed")

Window:CreateToggle(PlayerTab, "Infinite Jump: ", "ON", "OFF", function()
    toggleInfJump(true)
end, function()
    toggleInfJump(false)
end)

Window:CreateToggle(PlayerTab, "Spinbot: ", "ON", "OFF", function()
    toggleSpinbot(true)
end, function()
    toggleSpinbot(false)
end)

Window:CreateSlider(PlayerTab, "Spinbot Speed:", 100, 1000, 360, function(value)
    spinbotSpeed = value
end, {Increment = 10, Suffix = " Deg/s"})

Window:CreateSlider(PlayerTab, "Player Speed:", 16, 100, 16, function(value)
    playerSpeed = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = playerSpeed
    end
end, {Increment = 1, Suffix = " Studs/s"})

Window:CreateToggle(PlayerTab, "No Clip: ", "ON", "OFF", function()
    toggleNoClip(true)
end, function()
    toggleNoClip(false)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if infJumpEnabled then
        toggleInfJump(true)
    end
    if spinbotEnabled then
        toggleSpinbot(true)
    end
    if noClipEnabled then
        toggleNoClip(true)
    end
    if playerSpeed ~= 16 and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = playerSpeed
    end
    if cameraFov ~= 70 then
        Camera.FieldOfView = cameraFov
    end
end)]]

game.Players.LocalPlayer.CameraMaxZoomDistance=99999999999999999
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Alive = workspace:WaitForChild("Alive")
local Remote
local ParrySuccess
local pps=0
local BallFolder = workspace:WaitForChild("Balls")
local player = Players.LocalPlayer
local Parried = false
local IsSpamming=false
local ScriptDisabled=false
local cam = workspace.CurrentCamera
local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NEVERLOSE-UI-Nightly/main/source.lua"))()
local RandomPlayerChosen

NEVERLOSE:Theme("dark")

local Notification = NEVERLOSE:Notification()
Notification:Notify("success", "SUCCESS!", "Successfully started script.\nJoin the discord! discord.gg/nexam", 4)

local Visualiser = Instance.new("Part")
Visualiser.Shape=Enum.PartType.Ball
Visualiser.Material=Enum.Material.ForceField
Visualiser.Size=Vector3.new(30,30,30)
Visualiser.Color=Color3.new(1,1,1)
Visualiser.CastShadow=false
Visualiser.Anchored=true
Visualiser.CanCollide=false
Visualiser.CanTouch=false
Visualiser.CanQuery=false
Visualiser.Parent=workspace

local DebugVisualiser = Instance.new("Part")
DebugVisualiser.Shape=Enum.PartType.Ball
DebugVisualiser.Material=Enum.Material.ForceField
DebugVisualiser.Size=Vector3.new(30,30,30)
DebugVisualiser.Color=Color3.new(0.5,1,0.5)
DebugVisualiser.CastShadow=false
DebugVisualiser.Anchored=true
DebugVisualiser.CanCollide=false
DebugVisualiser.CanTouch=false
DebugVisualiser.CanQuery=false
DebugVisualiser.Transparency=0
DebugVisualiser.Parent=workspace

local Highlight = Instance.new("Highlight")
Highlight.Parent=Visualiser
Highlight.Adornee=Visualiser
Highlight.DepthMode=Enum.HighlightDepthMode.Occluded
Highlight.FillTransparency=1
Highlight.OutlineTransparency=0
Highlight.OutlineColor=Color3.fromRGB(255,255,255)

local ESPHighlight = Instance.new("Highlight")
ESPHighlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
ESPHighlight.FillTransparency=0.5
ESPHighlight.OutlineColor = Color3.fromRGB(0, 0, 0)
ESPHighlight.FillColor=Color3.fromRGB(255,125,125)
ESPHighlight.OutlineColor=Color3.fromRGB(255,255,255)
ESPHighlight.Name="ESP Highlight"

local ESPGui = Instance.new("BillboardGui")
ESPGui.ExtentsOffset=Vector3.new(0,5,0)
ESPGui.AlwaysOnTop=true

local ESPFrame = Instance.new("Frame")
ESPFrame.Parent=ESPGui
ESPFrame.Size=UDim2.fromScale(1,1)
ESPFrame.BackgroundTransparency=1

local ESPText = Instance.new("TextLabel")
ESPText.Parent=ESPFrame
ESPText.Size=UDim2.fromScale(1,1)
ESPText.BackgroundTransparency=1
ESPText.TextColor3=Color3.fromRGB(255,255,255)
ESPText.TextScaled=true
ESPText.TextXAlignment=Enum.TextXAlignment.Center

local HubData = {
    Combat = {
        AutoParry=true,
        AutoSpam=false,
        Visualiser=false,
        AntiCurve=false,
        QuickSpamWin=false,
        SpamCount=2,
        SpamSensitivity=5,
        ParryDistance1=20,
        TargetingMethod="Selective",
        CurveType="Camera",
    },
    Misc = {
        LookAtBall=false,
        MoveToBall=false,
        PlayerCharLookAtBall=false,
        DebugMode=false
    },
    Player = {
        PlayerChangesEnabled=false,
        WalkSpeed=35,
        JumpPower=50,
        FieldOfView=70
    },
    ESP = {
        BallESP=false,
        PlayerESP=false,
        TargetESP=false,
    },
    Trolls = {
        FollowBall=false,
        FollowBallDistanceDivider=1
    }
}

local OldHubData

local configFile = "NEXAM_HUB_BLADE_BALL.json"

local function SaveConfig()
    local encoded = game:GetService('HttpService'):JSONEncode(HubData)
    writefile(configFile, encoded)
end

function GetBall()
    for _,v in pairs(workspace:FindFirstChild("Balls"):GetChildren()) do
        if v:GetAttribute("realBall") then
            return v
        end
    end
end

function CreateGui()
    local Window = NEVERLOSE:AddWindow("NEXAM HUB", "BLADE BALL - V0.4.0 - discord.gg/nexam")

    local Main = Window:AddTab("Main","earth")
    local Other = Window:AddTab("Other","list")

    local AP = Main:AddSection("Auto Parry")
    local AS = Main:AddSection("Auto Spam")
    local OTHER = Main:AddSection("Other")
    local Misc = Main:AddSection("Misc", "right")
    local Trolling = Main:AddSection("Trolling", "right")
    local PlayerSection = Main:AddSection("Player", "right")
    --local ESP_Stuff = Main:AddSection("ESP", "right")

    local Stop = Other:AddSection("STOP", "right")
    local Info = Other:AddSection("INFO", "left")
    local Debug = Other:AddSection("DEBUG", "right")
    local InfYield = Other:AddSection("INFINITE YIELD", "left")
    local Discord = Other:AddSection("DISCORD (Updates, configs, etc.)", "left")
    local Reset = Other:AddSection("RESET", "right")

    Stop:AddButton("Close and stop script", function()
        ScriptDisabled=true
        Visualiser:Destroy()
        DebugVisualiser:Destroy()
        Window:Delete()
    end)
    
    Reset:AddButton("Reset Config", function()
        HubData=OldHubData
        SaveConfig()
        Notification:Notify("success", "Config", "Configuration reset successfully.\nPlease re-execute to fix any errors.", 3)
    end)

    APToggle = AP:AddToggle("Auto Parry", HubData.Combat.AutoParry, function(val)
        HubData.Combat.AutoParry=val
        SaveConfig()
    end)

    ACToggle = AP:AddToggle("Anti Curve", HubData.Combat.AntiCurve, function(val)
        HubData.Combat.AntiCurve=val
        SaveConfig()
    end)

    TMDrowpdown = AP:AddDropdown("Targeting Method", {"Selective", "Random", "Closest"}, HubData.Combat.TargetingMethod, function(val)
        HubData.Combat.TargetingMethod=val
        SaveConfig()
    end)

    PD1Slider = AP:AddSlider("Base Distance",1,30,HubData.Combat.ParryDistance1,function(val)
        HubData.Combat.ParryDistance1=val
        SaveConfig()
    end)

    ASToggle = AS:AddToggle("Auto Spam", HubData.Combat.AutoSpam, function(val)
        HubData.Combat.AutoSpam=val
        SaveConfig()
    end)

    QWToggle = AS:AddToggle("Teleport Spam (BLATANT)", HubData.Combat.QuickSpamWin, function(val)
        HubData.Combat.QuickSpamWin=val
        SaveConfig()
    end)

    VSToggle = OTHER:AddToggle("Visualiser", HubData.Combat.Visualiser, function(val)
        HubData.Combat.Visualiser=val
        SaveConfig()
    end)

    CurveType = OTHER:AddDropdown("Curve Type", {"Camera", "Random", "Closest"}, HubData.Combat.CurveType, function(val)
        HubData.Combat.CurveType=val
        SaveConfig()
    end)

    SpamCountSlider = AS:AddSlider("Spam Count",1,10,HubData.Combat.SpamCount,function(val)
        HubData.Combat.SpamCount=val
        SaveConfig()
    end)

    PCEToggle = PlayerSection:AddToggle("Changes Enabled", HubData.Player.PlayerChangesEnabled, function(val)
        HubData.Player.PlayerChangesEnabled=val
        SaveConfig()
    end)

    WSSlider = PlayerSection:AddSlider("Walk Speed", 35, 200, HubData.Player.WalkSpeed, function(val)
        HubData.Player.WalkSpeed = val
        SaveConfig()
    end)

    JPSlider = PlayerSection:AddSlider("Jump Power", 50, 200, HubData.Player.JumpHeight, function(val)
        HubData.Player.JumpHeight = val
        SaveConfig()
    end)

    FOVSlider = PlayerSection:AddSlider("Field Of View", 70, 120, HubData.Player.FieldOfView, function(val)
        HubData.Player.FieldOfView = val
        SaveConfig()
    end)


    Info:AddLabel("High spam count can cause high ping.")
    Info:AddLabel("Recommended count is 3.")

    SpamSensitivitySlider = AS:AddSlider("Spam Sensitivity",1,10,HubData.Combat.SpamSensitivity,function(val)
        HubData.Combat.SpamSensitivity=val
        SaveConfig()
    end)

    ParriesPerSecond = Debug:AddLabel("Parries Per Second: "..pps)
    isSpamming = Debug:AddLabel("Spamming: "..tostring(IsSpamming))

    LABToggle = Misc:AddToggle("Look at the Ball", HubData.Misc.LookAtBall, function(val)
        HubData.Misc.LookAtBall=val
        SaveConfig()
    end)

    MOToggle = Misc:AddToggle("Follow Ball", HubData.Misc.MoveToBall, function(val)
        HubData.Misc.MoveToBall=val
        SaveConfig()
    end)

    PFBToggle = Misc:AddToggle("Face Ball", HubData.Misc.PlayerCharLookAtBall, function(val)
        HubData.Misc.PlayerCharLookAtBall=val
        SaveConfig()
    end)

    Trolling:AddToggle("Teleport Around Ball", HubData.Trolls.FollowBall, function(val)
        HubData.Trolls.FollowBall=val
        SaveConfig()
    end)
    --[[
    Trolling:AddSlider("Radius", 1, 10, HubData.Trolls.FollowBallDistanceDivider, function(val)
        HubData.Trolls.FollowBallDistanceDivider=val
        SaveConfig()
    end)
    ]]

    --[[
    BallESPToggle = ESP_Stuff:AddToggle("Ball ESP", false, function(val)
        HubData.ESP.BallESP=val
        SaveConfig()
    end)

    PlayerESPToggle = ESP_Stuff:AddToggle("Player ESP", false, function(val)
        HubData.ESP.PlayerESP=val
        SaveConfig()
    end)

    TargetESPToggle = ESP_Stuff:AddToggle("Target ESP", false, function(val)
        HubData.ESP.TargetESP=val
        SaveConfig()
    end)
    ]]

    Stop:AddButton("Stop Spamming", function()
        IsSpamming=false
        Visualiser.Color=Color3.new(1,1,1)
    end)

    InfYield:AddButton("Infinite Yield", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    Discord:AddButton("Copy Discord Invite", function()
        setclipboard("discord.gg/nexam")
        Notification:Notify("success", "SUCCESS!", "Successfully copied discord invite.")
    end)

    Debug:AddToggle("Debug Mode", HubData.Misc.DebugMode, function(val)
        HubData.Misc.DebugMode=val
        SaveConfig()
    end)
end

local function LoadConfig()
    local standarddata = table.clone(HubData)
    OldHubData = standarddata
    if isfile(configFile) then
        local success, decoded = pcall(function()
            return Game:GetService("HttpService"):JSONDecode(readfile(configFile))
        end)
        print(success, decoded)
        if success and decoded then

            HubData=decoded
            Notification:Notify("success", "Config", "Configuration loaded successfully.", 3)
        else
            warn("Failed to decode configuration data.")
            Notification:Notify("error", "Config", "Failed to decode configuration data.", 3)
            HubData=OldHubData
        end
    else
        warn("Configuration file not found. Using default settings.")
        Notification:Notify("warning", "Config", "Configuration file not found. Using default settings.", 3)
    end
end
LoadConfig()
CreateGui()

local function Stop()
    Visualiser.Color=Color3.new(1,1,1)
    for i=1,10,1 do
        IsSpamming=false
        task.wait(1/20)
        workspace.CurrentCamera.CameraSubject=player.Character:FindFirstChild("Humanoid")
    end
end

BallFolder.ChildAdded:Connect(Stop)
BallFolder.ChildRemoved:Connect(Stop)

local function getclosestplr()
    local bot_position = workspace.CurrentCamera.Focus.Position

    local distance = math.huge
    local closest_player_character = nil

    for i, player in pairs(Alive:GetChildren()) do
        if player:FindFirstChild("Humanoid") and player.Name~=Players.LocalPlayer.Name then

            local player_position = player.HumanoidRootPart.Position
            local distance_from_bot = (bot_position - player_position).magnitude
        
            if distance_from_bot < distance then
                distance = distance_from_bot
                closest_player_character = player
            end
        end
    end

    return closest_player_character
end

local function isAerodynamicSlash(ball)
    local currentVel = ball.AssemblyLinearVelocity
    local verticalSpeed = math.abs(currentVel.Y)
    local horizontalSpeed = (Vector3.new(currentVel.X, 0, currentVel.Z)).Magnitude
    local cframeYChange = math.abs(ball.CFrame.Y)
    return verticalSpeed > 200 and horizontalSpeed < verticalSpeed / 2 and cframeYChange > 70
end

local function lerp(start, _end, alpha)
    return (1 - alpha) * start + alpha * _end
end

function GetClosestPlayerDistance(plr)
    local a = plr.Character:FindFirstChild("HumanoidRootPart").Position-getclosestplr():FindFirstChild("HumanoidRootPart").Position
    return a.Magnitude
end

local function GetBallSpeed(ball, plr)
    local vel = ball.Velocity
    local speed = vel.Magnitude
    return speed+(speed*plr:GetNetworkPing())
end

local function CheckRemote()
    if not Remote then
        if game:GetService("SocialService"):WaitForChild("\n\n") then
            Remote = game:GetService("SocialService"):WaitForChild("\n\n")
        end
        if game:GetService("AdService"):WaitForChild("\n\n") then
            Remote = game:GetService("AdService"):WaitForChild("\n\n")
        end
    end
end

local function CheckRemote2()
    if not ParrySuccess then
        if game:GetService("ReplicatedStorage"):WaitForChild("Remotes") then
            ParrySuccess = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ParrySuccess")
        end
    end
end

local function TryFollowBall(ball, player)
    if HubData.Trolls.FollowBall and Alive:FindFirstChild(player.Name) and ball:FindFirstChild("zoomies") then
        local velocity = math.max(ball:FindFirstChild("zoomies").VectorVelocity.Magnitude/10*HubData.Trolls.FollowBallDistanceDivider,12.5)
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        workspace.CurrentCamera.CameraSubject=ball
        local r = math.rad(math.random(-180,180))
        local newcframe = ball.CFrame*CFrame.Angles(0,r,0)*CFrame.new(0,0,velocity)
        rot=math.random(-180,180)
        hrp.AssemblyLinearVelocity=Vector3.zero
        hrp.CFrame=newcframe
    elseif not HubData.Trolls.FollowBall or not Alive:FindFirstChild(player.Name) then
        workspace.CurrentCamera.CameraSubject=player.Character:FindFirstChild("Humanoid")
    end
end

local function TryLookAtBall(ball, player)
    if HubData.Misc.LookAtBall and Alive:FindFirstChild(player.Name) then
        local newcf = CFrame.new(workspace.CurrentCamera.CFrame.Position,ball.Position)
        workspace.CurrentCamera.CFrame=workspace.CurrentCamera.CFrame:Lerp(newcf,0.075)
    end
end

local function TryMoveToBall(ball, player)
    if HubData.Misc.MoveToBall and Alive:FindFirstChild(player.Name) then
        player.Character:FindFirstChild("Humanoid"):MoveTo(ball.Position)
    end
end

local function TryPlayerCharLookAtBall(ball, player)
    if HubData.Misc.PlayerCharLookAtBall and Alive:FindFirstChild(player.Name) then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local goalpos = ball.Position
        local hrpPos = hrp.Position
        local newcf = CFrame.new(hrpPos, Vector3.new(goalpos.X, hrpPos.Y, goalpos.Z))
        hrp.CFrame = hrp.CFrame:Lerp(newcf,0.02)
    end
end

function GetBallDistance(ball, player)
    local a = ball.Position - player.Character:FindFirstChild("HumanoidRootPart").Position
    return a.Magnitude
end

local function UpdatePlayerStuff(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") and cam then
        local hum = player.Character:FindFirstChild("Humanoid")
        hum.UseJumpPower=true
        if HubData.Player.PlayerChangesEnabled then
            hum.WalkSpeed=HubData.Player.WalkSpeed
            hum.JumpPower=HubData.Player.JumpHeight
        end
        cam.FieldOfView=HubData.Player.FieldOfView
    end
end

local function UpdateBallESPText(ball)
    if ball:FindFirstChild("Ball ESP") and ball:FindFirstChild("Ball ESP"):FindFirstChild("Frame") and ball:FindFirstChild("Ball ESP"):FindFirstChild("Frame"):FindFirstChild("TextLabel") then
        local label = ball:FindFirstChild("Ball ESP"):FindFirstChild("Frame"):FindFirstChild("TextLabel")
        local speed = 10
        label.Text="BALL • "..tostring(speed)
    end
end

local function TryCreateBallESPGui(ball)
    if not ball:FindFirstChild("Ball ESP") then
        if ball:IsA("BasePart") and ball:GetAttribute("realBall") then
            local Gui = ESPGui:Clone()
            Gui.Parent=ball
            Gui.Name="Ball ESP"
        end
    end
end

local function AddPps()
    pps+=1
    task.delay(1,function()
        pps-=1
    end)
end

local function GetPlayersScreenPositions()
    local positions = {}
    if HubData.Combat.TargetingMethod=="Selective" then
        for _, player in pairs(Alive:GetChildren()) do
            local humanoidRootPart = player and player:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                positions[player.Name] = cam:WorldToScreenPoint(humanoidRootPart.Position)
            end
        end
    elseif HubData.Combat.TargetingMethod=="Closest" then
        local ClosestPlayer = getclosestplr()
        if ClosestPlayer then
            positions[ClosestPlayer.Name] = cam:WorldToScreenPoint(ClosestPlayer:FindFirstChild("HumanoidRootPart").Position)
        end
    elseif HubData.Combat.TargetingMethod=="Random" then
        local players = {}
        for _, rndplr in pairs(Alive:GetChildren()) do
            if rndplr.Name ~= player.Name then
                table.insert(players, rndplr)
            end
        end
        RandomPlayerChosen = players[math.random(1, #players)]
        if RandomPlayerChosen then
            positions[RandomPlayerChosen.Name] = cam:WorldToScreenPoint(RandomPlayerChosen:FindFirstChild("HumanoidRootPart").Position)
        end
    end
    return positions
end

local function GetMousePosition()
    local mousepos = {}
    local mouse = player:GetMouse()
    if HubData.Combat.TargetingMethod=="Selective" then
        mousepos[1]=mouse.x
        mousepos[2]=mouse.Y
    elseif HubData.Combat.TargetingMethod=="Closest" then
        local ClosestPlayer = getclosestplr()
        if ClosestPlayer then
            local plrpos = cam:WorldToScreenPoint(ClosestPlayer:FindFirstChild("HumanoidRootPart").Position)
            mousepos[1] = plrpos.X
            mousepos[2] = plrpos.Y
        end
    elseif HubData.Combat.TargetingMethod=="Random" then
        if RandomPlayerChosen then
            local plrpos = cam:WorldToScreenPoint(RandomPlayerChosen:FindFirstChild("HumanoidRootPart").Position)
            mousepos[1] = plrpos.X
            mousepos[2] = plrpos.Y
        end
    end
    return mousepos
end

local function GetCameraCFrame()
    local rand = Random.new()
    local cf
    local function randomVector()
        x = rand:NextNumber(-1, 1)
        y = rand:NextNumber(-1, 1)
        z = rand:NextNumber(-1, 1)
        return Vector3.new(x, y, z)
    end
    if HubData.Combat.CurveType=="Closest" then
        local closestplr = getclosestplr()
        cf = CFrame.new(player.Character:FindFirstChild("HumanoidRootPart").Position, closestplr:FindFirstChild("HumanoidRootPart").Position)
    elseif HubData.Combat.CurveType=="Random" then
        local up = randomVector().Unit
        local right = randomVector().Unit
        local look = randomVector().Unit
        
        cf = CFrame.fromMatrix(cam.CFrame.Position, right, up, -look)
    else
        cf = cam.CFrame
    end
    return cf
end

local function parry(playerpositions)
    local args = {
        0.5,
        GetCameraCFrame(),
        GetPlayersScreenPositions(),
        GetMousePosition(),
        false
    }
    if Remote then
        Remote:FireServer(unpack(args))
    end
end

local function GetBallDot(ball, player)
    local ballToPlayerDir = (player.Character:FindFirstChild("HumanoidRootPart").Position - ball.Position).unit
    local dot = ball.Velocity.unit:Dot(ballToPlayerDir)
    if ball:GetAttribute("target")==player.Name and not IsSpamming then
        return math.min(dot*3,1)
    else
        return 1
    end
end

local function checkProximityToPlayer(ball, player)
    local Distance = (ball.Position-Visualiser.Position).Magnitude+(ball.Velocity.Magnitude/15)
    local realBallAttribute = ball:GetAttribute("realBall")
    local target = ball:GetAttribute("target")
    local from = ball:GetAttribute("from")
    local ping = player:GetNetworkPing()

    TryLookAtBall(ball, player)
    TryMoveToBall(ball, player)
    TryPlayerCharLookAtBall(ball, player)
    TryFollowBall(ball, player)

    function CheckColor()
        if IsSpamming then
            Visualiser.Color=Visualiser.Color:Lerp(Color3.new(1,0,0),0.0125)
            Highlight.OutlineColor=Visualiser.Color
        else
            Visualiser.Color=Visualiser.Color:Lerp(Color3.new(1,1,1),0.015)
            Highlight.OutlineColor=Visualiser.Color
        end
    end
    
    ParriesPerSecond:Text("Parries Per Second: "..pps)
    isSpamming:Text("Spamming: "..tostring(IsSpamming))

    if Distance and realBallAttribute and target then
        local BallSpeed = math.max(GetBallSpeed(ball, player)/3, HubData.Combat.ParryDistance1) * (1 + player:GetNetworkPing())
        local BallDir = GetBallDot(ball, player)
        local SpamSpeedRequirement = math.max((GetBallSpeed(ball, player) * (0.15 / 5 * HubData.Combat.SpamSensitivity)), (15 / 5 * HubData.Combat.SpamSensitivity)) * (1 + ping)
        local ClosestPlayerDistance = GetClosestPlayerDistance(player)
        
        if HubData.Combat.AntiCurve then
            BallSpeed = math.max(BallSpeed * BallDir, HubData.Combat.ParryDistance1)
        end
        
        local function TryParry()
            if HubData.Combat.AutoParry and not Parried then
                Parried = true
                parry()
                
                ball:GetAttributeChangedSignal("target"):Connect(function()
                    Parried = false
                end)
                
                local oldTick = tick()
                repeat
                    RunService.PreSimulation:Wait()
                until (tick() - oldTick) >= 0.2 or not Parried
                
                Parried = false
            end
        end
        
        
        if (Distance/BallSpeed)<=1 and target == player.Name and not isAerodynamicSlash(ball) then
            TryParry()
        end
        
        if HubData.Combat.AutoSpam then
            CheckColor()
            if Distance <= SpamSpeedRequirement and ClosestPlayerDistance <= SpamSpeedRequirement and pps >= math.max((10 - HubData.Combat.SpamSensitivity),3) then
                IsSpamming = true
            elseif Distance <= math.clamp(BallSpeed / 2.5, 15, math.huge) and ClosestPlayerDistance <= Visualiser.Size.Magnitude / 4 and pps>=3 then
                IsSpamming = true
            else
                IsSpamming = false
            end
        end
        
        if IsSpamming and target == player.Name then
            coroutine.resume(coroutine.create(function()
                for i = 1, HubData.Combat.SpamCount do
                    parry()
                    player.PlayerGui.Hotbar.Block.UIGradient.Offset=Vector2.new(0,-0.5)
                    if HubData.Combat.QuickSpamWin then
                        player.Character:FindFirstChild("HumanoidRootPart").Position=GetBall().Position
                    end
                    task.wait(1 / 35)
                end
            end))
        end
        
        if not IsSpamming then
            local VisualiserSize = math.max(BallSpeed-(ball.Velocity.Magnitude*ping) * 2,HubData.Combat.ParryDistance1+2.5)
            Visualiser.Size = Vector3.new(VisualiserSize, VisualiserSize, VisualiserSize)
        else
            local VisualiserSize = SpamSpeedRequirement * 2
            Visualiser.Size = Vector3.new(VisualiserSize, VisualiserSize, VisualiserSize)
        end
        local DebugSize = math.max((BallSpeed-(ball.Velocity.Magnitude*ping))+(ball.Velocity.Magnitude*(ping*4)) * 2,HubData.Combat.ParryDistance1+2.5)
        DebugVisualiser.Size = Vector3.new(DebugSize, DebugSize, DebugSize)

        UpdateBallESPText(ball)
        TryCreateBallESPGui(ball)
    end
end

local function checkBallsProximity()
    if not ScriptDisabled then
        Visualiser.Material=Enum.Material.ForceField
        CheckRemote()
        CheckRemote2()
        UpdatePlayerStuff(player)
        if player and player.Character then
            Visualiser.Position=player.Character:FindFirstChild("HumanoidRootPart").Position-(player.Character:FindFirstChild("HumanoidRootPart").Velocity/15)
            DebugVisualiser.Position=player.Character:FindFirstChild("HumanoidRootPart").Position-(player.Character:FindFirstChild("HumanoidRootPart").Velocity/15)
            if HubData.Combat.Visualiser then
                Visualiser.Transparency=0
            else
                Visualiser.Transparency=1
            end
            if HubData.Misc.DebugMode then
                DebugVisualiser.Transparency=0.5
            else
                DebugVisualiser.Transparency=1
            end
            for _, ball in ipairs(BallFolder:GetChildren()) do
                if ball:IsA("BasePart") then
                    checkProximityToPlayer(ball, player)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(checkBallsProximity)
BallFolder.ChildAdded:Connect(checkBallsProximity)

repeat wait() until ParrySuccess

ParrySuccess.OnClientEvent:Connect(function()
    AddPps()
end)

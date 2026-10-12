
--[[
 FREAKHUB v2.0 - BEST EFFORT
 Compact mobile UI
 Universal client-side utilities

 Target Lock: NPC / dummy only
 Aura Hit: nearby NPC + equipped Tool
 Multi Action: ProximityPrompt interactions
 Health: local best-effort only
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local LP = Players.LocalPlayer
if not LP then return end

local PG = LP:WaitForChild("PlayerGui")

-- Remove previous interfaces
for _, name in ipairs({
    "FREAKHUB_V17",
    "FREAKHUB_V18",
    "FREAKHUB_V19",
    "FREAKHUB_V20"
}) do
    local previous = PG:FindFirstChild(name)
    if previous then
        previous:Destroy()
    end
end

local COLORS = {
    bg = Color3.fromRGB(12,13,19),
    panel = Color3.fromRGB(22,24,33),
    card = Color3.fromRGB(30,33,43),
    red = Color3.fromRGB(233,52,73),
    white = Color3.fromRGB(242,243,248),
    muted = Color3.fromRGB(151,156,172),
    green = Color3.fromRGB(75,205,144)
}

local enabled = {
    infiniteJump = false,
    noclip = false,
    fly = false,
    mountFly = false,
    health = false,
    playerESP = false,
    itemESP = false,
    playerRefresh = true,
    itemRefresh = false,
    targetLock = false,
    aura = false,
    multi = false,
    instant = false,
    fullbright = false
}

local config = {
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 55,
    mountSpeed = 65,
    scanRadius = 150,
    espInterval = 1.5,
    auraRadius = 12,
    auraInterval = 0.5,
    actionRadius = 15,
    actionInterval = 1,
    aimFOV = 180,
    aimSmooth = 0.15,
    aimPart = "Head",
    actionMode = "Auto"
}

local connections = {}
local playerESP = {}
local itemESP = {}
local scanResults = {}
local teleportSlots = {}
local originalPrompts = {}
local originalCollision = {}
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local activeFly = nil
local lockedTarget = nil
local vertical = 0
local forward = 0
local selectedTab = "Home"
local scanFilter = ""
local alive = true

local function listen(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function create(class, parent, properties)
    local obj = Instance.new(class)

    for k, v in pairs(properties or {}) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    create("UICorner", obj, {
        CornerRadius = UDim.new(0, radius or 8)
    })
end

local function humanoid()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function root()
    local ch = LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function distanceFrom(position)
    local r = root()
    if not r then return math.huge end
    return (r.Position - position).Magnitude
end

local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    elseif obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle")
        return handle and handle.Position
    end
end

-- ====================================
-- USER INTERFACE
-- ====================================

local gui = create("ScreenGui", PG, {
    Name = "FREAKHUB_V20",
    ResetOnSpawn = false,
    DisplayOrder = 500
})

local logo = create("TextButton", gui, {
    Size = UDim2.fromOffset(54,54),
    Position = UDim2.new(0,14,0.45,0),
    BackgroundColor3 = COLORS.bg,
    BorderSizePixel = 0,
    Text = "F",
    TextSize = 32,
    Font = Enum.Font.GothamBlack,
    TextColor3 = COLORS.red,
    Active = true,
    AutoButtonColor = false
})
corner(logo,17)

create("UIStroke",logo,{
    Color = COLORS.red,
    Thickness = 2
})

local window = create("Frame",gui,{
    Size = UDim2.fromOffset(390,400),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundColor3 = COLORS.bg,
    BorderSizePixel = 0,
    Visible = false,
    Active = true
})
corner(window,16)

create("UIStroke",window,{
    Color = COLORS.card
})

local header = create("Frame",window,{
    Size = UDim2.new(1,0,0,55),
    BackgroundTransparency = 1,
    Active = true
})

local function text(parent,value,size,color)
    return create("TextLabel",parent,{
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,20),
        Text = value,
        TextColor3 = color or COLORS.white,
        TextSize = size or 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
end

local title = text(header,"FREAKHUB",18)
title.Position = UDim2.fromOffset(15,5)
title.Font = Enum.Font.GothamBold

local subtitle = text(
    header,
    "UNIVERSAL  •  v2.0",
    10,
    COLORS.red
)
subtitle.Position = UDim2.fromOffset(16,31)

local close = create("TextButton",header,{
    Position = UDim2.new(1,-41,0,12),
    Size = UDim2.fromOffset(31,31),
    BackgroundColor3 = COLORS.red,
    BorderSizePixel = 0,
    Text = "×",
    TextSize = 23,
    TextColor3 = COLORS.white
})
corner(close,9)

local sidebar = create("ScrollingFrame",window,{
    Position = UDim2.fromOffset(10,60),
    Size = UDim2.new(0,106,1,-70),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})
corner(sidebar,12)

create("UIPadding",sidebar,{
    PaddingTop = UDim.new(0,7),
    PaddingLeft = UDim.new(0,5),
    PaddingRight = UDim.new(0,5)
})

create("UIListLayout",sidebar,{
    Padding = UDim.new(0,5),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local body = create("ScrollingFrame",window,{
    Position = UDim2.fromOffset(124,60),
    Size = UDim2.new(1,-134,1,-70),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = COLORS.red,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})

create("UIListLayout",body,{
    Padding = UDim.new(0,5),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local function clearBody()
    for _,obj in ipairs(body:GetChildren()) do
        if obj:IsA("GuiObject") then
            obj:Destroy()
        end
    end
end

local function heading(value)
    local frame = create("Frame",body,{
        Size = UDim2.new(1,-3,0,27),
        BackgroundTransparency = 1
    })

    local label = text(frame,value,14)
    label.Font = Enum.Font.GothamBold
    label.Position = UDim2.fromOffset(3,2)
end

local function info(value)
    local frame = create("Frame",body,{
        Size = UDim2.new(1,-3,0,40),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0
    })
    corner(frame,8)

    local label = text(frame,value,10,COLORS.muted)
    label.Position = UDim2.fromOffset(8,4)
    label.Size = UDim2.new(1,-16,1,-8)
    label.TextWrapped = true
    label.TextTruncate = Enum.TextTruncate.None
end

local function button(value,callback)
    local b = create("TextButton",body,{
        Size = UDim2.new(1,-3,0,31),
        BackgroundColor3 = COLORS.card,
        BorderSizePixel = 0,
        Text = value,
        TextColor3 = COLORS.white,
        TextSize = 11,
        Font = Enum.Font.GothamMedium
    })
    corner(b,8)
    listen(b.Activated,callback)
    return b
end

local function row(value)
    local frame = create("Frame",body,{
        Size = UDim2.new(1,-3,0,35),
        BackgroundColor3 = COLORS.card,
        BorderSizePixel = 0
    })
    corner(frame,8)

    local label = text(frame,value,11)
    label.Position = UDim2.fromOffset(9,7)
    label.Size = UDim2.new(0.55,-9,0,20)

    return frame
end

local function toggle(value,key,callback)
    local frame = row(value)

    local b = create("TextButton",frame,{
        Position = UDim2.new(1,-66,0,5),
        Size = UDim2.fromOffset(59,25),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
        TextColor3 = COLORS.white,
        TextSize = 10,
        Font = Enum.Font.GothamBold
    })
    corner(b,7)

    local function repaint()
        b.Text = enabled[key] and "ON" or "OFF"
        b.BackgroundColor3 =
            enabled[key] and COLORS.red or COLORS.panel
    end

    listen(b.Activated,function()
        enabled[key] = not enabled[key]

        if callback then
            callback(enabled[key])
        end

        repaint()
    end)

    repaint()
end

local function numberRow(value,current,callback)
    local frame = row(value)

    local input = create("TextBox",frame,{
        Position = UDim2.new(1,-105,0,5),
        Size = UDim2.fromOffset(52,25),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
        Text = tostring(current),
        TextColor3 = COLORS.white,
        TextSize = 11,
        ClearTextOnFocus = false
    })
    corner(input,6)

    local set = create("TextButton",frame,{
        Position = UDim2.new(1,-49,0,5),
        Size = UDim2.fromOffset(42,25),
        BackgroundColor3 = COLORS.red,
        BorderSizePixel = 0,
        Text = "SET",
        TextColor3 = COLORS.white,
        TextSize = 10
    })
    corner(set,6)

    listen(set.Activated,function()
        callback(tonumber(input.Text))
    end)

    return input
end

-- ====================================
-- PLAYER
-- ====================================

local function applyPlayer()
    local h = humanoid()

    if h then
        h.WalkSpeed = config.walkSpeed
        h.UseJumpPower = true
        h.JumpPower = config.jumpPower
    end
end

listen(LP.CharacterAdded,function(character)
    character:WaitForChild("Humanoid",10)
    task.defer(applyPlayer)
end)

listen(UIS.JumpRequest,function()
    if enabled.infiniteJump then
        local h = humanoid()

        if h then
            h:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
end)

local function restoreCollision()
    for part,oldValue in pairs(originalCollision) do
        if part.Parent then
            part.CanCollide = oldValue
        end
    end

    table.clear(originalCollision)
end

listen(RS.Stepped,function()
    if not enabled.noclip then return end

    local ch = LP.Character
    if not ch then return end

    for _,part in ipairs(ch:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalCollision[part] == nil then
                originalCollision[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end)

-- ====================================
-- INFINITE HEALTH - BEST EFFORT
-- ====================================

local healthBusy = false

local function maintainHealth()
    if not enabled.health or healthBusy then return end

    local h = humanoid()
    if not h or h.Health <= 0 then return end

    healthBusy = true

    pcall(function()
        if h.Health < h.MaxHealth then
            h.Health = h.MaxHealth
        end
    end)

    healthBusy = false
end

listen(RS.Heartbeat,function()
    if enabled.health then
        maintainHealth()
    end
end)

-- ====================================
-- FLY / MOUNT FLY
-- ====================================

local function stopFly()
    if activeFly then
        for _,obj in ipairs(activeFly.objects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        activeFly = nil
    end

    vertical = 0
    forward = 0
end

local function startFly(part,mode)
    stopFly()

    if not part or not part:IsA("BasePart") then
        return false
    end

    local attachment = create("Attachment",part,{
        Name = "FH_FlightAttachment"
    })

    local velocity = create("LinearVelocity",part,{
        Name = "FH_FlightVelocity",
        Attachment0 = attachment,
        RelativeTo = Enum.ActuatorRelativeTo.World,
        VelocityConstraintMode =
            Enum.VelocityConstraintMode.Vector,
        VectorVelocity = Vector3.zero,
        ForceLimitsEnabled = false,
        MaxForce = 1e9
    })

    local orientation = create("AlignOrientation",part,{
        Name = "FH_FlightOrientation",
        Attachment0 = attachment,
        Mode =
            Enum.OrientationAlignmentMode.OneAttachment,
        MaxTorque = 1e9,
        Responsiveness = 15
    })

    activeFly = {
        part = part,
        mode = mode,
        velocity = velocity,
        orientation = orientation,
        objects = {
            attachment,
            velocity,
            orientation
        }
    }

    return true
end

local function getMountPart()
    local h = humanoid()
    if not h or not h.SeatPart then return nil end

    local seat = h.SeatPart
    local model = seat:FindFirstAncestorOfClass("Model")

    if model and model.PrimaryPart then
        return model.PrimaryPart
    end

    return seat
end

local function setFly(on)
    if on then
        enabled.mountFly = false
        if not startFly(root(),"player") then
            enabled.fly = false
        end
    elseif activeFly and activeFly.mode == "player" then
        stopFly()
    end
end

local function setMountFly(on)
    if on then
        enabled.fly = false
        if not startFly(getMountPart(),"mount") then
            enabled.mountFly = false
        end
    elseif activeFly and activeFly.mode == "mount" then
        stopFly()
    end
end

listen(RS.Heartbeat,function()
    local a = activeFly
    if not a then return end

    if not a.part.Parent then
        stopFly()
        return
    end

    if a.mode == "player" and not enabled.fly then
        stopFly()
        return
    end

    if a.mode == "mount" then
        local h = humanoid()

        if not enabled.mountFly
            or not h
            or not h.SeatPart then
            enabled.mountFly = false
            stopFly()
            return
        end
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local h = humanoid()
    local move = h and h.MoveDirection or Vector3.zero

    local look = camera.CFrame.LookVector
    local flat = Vector3.new(look.X,0,look.Z)

    if flat.Magnitude > 0.01 then
        flat = flat.Unit
    else
        flat = Vector3.new(0,0,-1)
    end

    local currentSpeed =
        a.mode == "mount"
        and config.mountSpeed
        or config.flySpeed

    a.velocity.VectorVelocity =
        move * currentSpeed
        + flat * forward * currentSpeed
        + Vector3.new(
            0,
            vertical * currentSpeed,
            0
        )

    a.orientation.CFrame =
        CFrame.lookAt(Vector3.zero,flat)
end)

-- Flight buttons

local flightControls = create("Frame",gui,{
    Size = UDim2.fromOffset(180,112),
    Position = UDim2.new(1,-190,1,-175),
    BackgroundColor3 = COLORS.bg,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Visible = false
})
corner(flightControls,12)

local function flightButton(value,x,y,axis,amount)
    local b = create("TextButton",flightControls,{
        Position = UDim2.fromOffset(x,y),
        Size = UDim2.fromOffset(80,45),
        BackgroundColor3 = COLORS.red,
        BorderSizePixel = 0,
        Text = value,
        TextColor3 = COLORS.white,
        TextSize = 11,
        Font = Enum.Font.GothamBold
    })
    corner(b,8)

    local function set(value)
        if axis == "vertical" then
            vertical = value
        else
            forward = value
        end
    end

    listen(b.InputBegan,function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then
            set(amount)
        end
    end)

    listen(b.InputEnded,function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then
            set(0)
        end
    end)
end

flightButton("▲ UP",7,8,"vertical",1)
flightButton("FORWARD",93,8,"forward",1)
flightButton("▼ DOWN",7,59,"vertical",-1)
flightButton("BACK",93,59,"forward",-1)

-- ====================================
-- ESP + NAME TAGS
-- ====================================

local function removeESP(entry)
    if not entry then return end

    if entry.highlight then
        entry.highlight:Destroy()
    end

    if entry.tag then
        entry.tag:Destroy()
    end
end

local function clearESP(tbl)
    for _,entry in pairs(tbl) do
        removeESP(entry)
    end
    table.clear(tbl)
end

local function makeESP(obj,name,color)
    if not obj or not obj.Parent then return nil end

    local part

    if obj:IsA("BasePart") then
        part = obj
    elseif obj:IsA("Model") then
        part = obj:FindFirstChild("Head")
            or obj.PrimaryPart
            or obj:FindFirstChildWhichIsA(
                "BasePart",true
            )
    end

    if not part then return nil end

    local highlight = create("Highlight",gui,{
        Adornee = obj,
        FillColor = color,
        OutlineColor = COLORS.white,
        FillTransparency = 0.75,
        OutlineTransparency = 0,
        DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop
    })

    local tag = create("BillboardGui",gui,{
        Name = "FH_ESPTag",
        Adornee = part,
        Size = UDim2.fromOffset(140,35),
        StudsOffsetWorldSpace = Vector3.new(0,2.6,0),
        AlwaysOnTop = true,
        MaxDistance = 500
    })

    create("TextLabel",tag,{
        Size = UDim2.new(1,0,0,19),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = COLORS.white,
        TextStrokeColor3 = Color3.new(0,0,0),
        TextStrokeTransparency = 0.1,
        TextSize = 10,
        Font = Enum.Font.GothamBold
    })

    local distanceLabel = create("TextLabel",tag,{
        Position = UDim2.fromOffset(0,19),
        Size = UDim2.new(1,0,0,14),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = color,
        TextStrokeColor3 = Color3.new(0,0,0),
        TextStrokeTransparency = 0.1,
        TextSize = 9,
        Font = Enum.Font.GothamMedium
    })

    return {
        target = obj,
        part = part,
        highlight = highlight,
        tag = tag,
        distanceLabel = distanceLabel
    }
end

local function refreshPlayers()
    if not enabled.playerESP then
        clearESP(playerESP)
        return
    end

    for player,entry in pairs(playerESP) do
        if not player.Parent
            or not player.Character
            or entry.target ~= player.Character
            or not entry.part.Parent then
            removeESP(entry)
            playerESP[player] = nil
        end
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LP
            and player.Character
            and player.Character.Parent
            and not playerESP[player] then

            playerESP[player] = makeESP(
                player.Character,
                player.DisplayName,
                COLORS.red
            )
        end
    end
end

local function refreshItems()
    clearESP(itemESP)

    if not enabled.itemESP then return end

    for _,result in ipairs(scanResults) do
        local obj = result.obj

        if obj and obj.Parent then
            local target = obj

            if obj:IsA("Tool") then
                target = obj:FindFirstChild("Handle")
            end

            if target then
                local entry = makeESP(
                    target,
                    result.name,
                    COLORS.green
                )

                if entry then
                    table.insert(itemESP,entry)
                end
            end
        end
    end
end

local function updateESPDistances(tbl)
    local r = root()
    if not r then return end

    for _,entry in pairs(tbl) do
        if entry.part and entry.part.Parent then
            local d =
                (r.Position-entry.part.Position).Magnitude

            entry.distanceLabel.Text =
                math.floor(d).." studs"
        end
    end
end

-- ====================================
-- ITEM SCANNER
-- ====================================

local keywords = {
    "coin","gem","diamond","loot","drop",
    "chest","treasure","egg","collect",
    "pickup","reward","item","crystal",
    "fruit","key","token","orb","gift",
    "ore","rock","mineral","mine","dig"
}

local function hasKeyword(value)
    value = string.lower(value)

    for _,word in ipairs(keywords) do
        if string.find(value,word,1,true) then
            return true
        end
    end

    return false
end

local function collectible(obj)
    if obj:IsA("Tool") then return true end

    if not (
        obj:IsA("BasePart")
        or obj:IsA("Model")
    ) then
        return false
    end

    if hasKeyword(obj.Name) then return true end

    if obj:FindFirstChildWhichIsA(
        "ProximityPrompt",true
    ) then
        return true
    end

    for _,tag in ipairs(
        CollectionService:GetTags(obj)
    ) do
        if hasKeyword(tag) then
            return true
        end
    end

    return false
end

local function scanItems()
    table.clear(scanResults)

    local r = root()
    if not r then return end

    local seen = {}

    for _,obj in ipairs(workspace:GetDescendants()) do
        if #scanResults >= 150 then break end

        if collectible(obj) then
            local target = obj

            if obj:IsA("BasePart") then
                local model =
                    obj:FindFirstAncestorOfClass("Model")

                if model and collectible(model) then
                    target = model
                end
            end

            local ch = LP.Character

            if target.Parent
                and not seen[target]
                and not (
                    ch and target:IsDescendantOf(ch)
                )
                and not Players:GetPlayerFromCharacter(
                    target
                ) then

                local p = getPosition(target)

                if p then
                    local d =
                        (r.Position-p).Magnitude

                    local matches =
                        scanFilter == ""
                        or string.find(
                            string.lower(target.Name),
                            string.lower(scanFilter),
                            1,true
                        )

                    if d <= config.scanRadius
                        and matches then

                        seen[target] = true

                        table.insert(scanResults,{
                            obj = target,
                            name = target.Name,
                            distance = math.floor(d)
                        })
                    end
                end
            end
        end
    end

    table.sort(scanResults,function(a,b)
        return a.distance < b.distance
    end)
end

-- ====================================
-- INSTANT PROMPT
-- ====================================

local function setInstant(on)
    if on then
        for _,p in ipairs(
            workspace:GetDescendants()
        ) do
            if p:IsA("ProximityPrompt") then
                if originalPrompts[p] == nil then
                    originalPrompts[p] = p.HoldDuration
                end
                p.HoldDuration = 0
            end
        end
    else
        for p,value in pairs(originalPrompts) do
            if p.Parent then
                p.HoldDuration = value
            end
        end
        table.clear(originalPrompts)
    end
end

listen(workspace.DescendantAdded,function(obj)
    if enabled.instant
        and obj:IsA("ProximityPrompt") then

        task.defer(function()
            if obj.Parent then
                if originalPrompts[obj] == nil then
                    originalPrompts[obj] =
                        obj.HoldDuration
                end
                obj.HoldDuration = 0
            end
        end)
    end
end)

-- ====================================
-- TARGET LOCK - NPC / DUMMY
-- ====================================

local function isNPC(model)
    if not model or not model:IsA("Model") then
        return false
    end

    if Players:GetPlayerFromCharacter(model) then
        return false
    end

    local h =
        model:FindFirstChildOfClass("Humanoid")

    return h ~= nil and h.Health > 0
end

local function getAimPart(model)
    if not isNPC(model) then return nil end

    return model:FindFirstChild(config.aimPart)
        or model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

local function findTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize/2
    local best = nil
    local bestDistance = config.aimFOV

    for _,model in ipairs(
        workspace:GetDescendants()
    ) do
        if model:IsA("Model") and isNPC(model) then
            local part = getAimPart(model)

            if part then
                local screen,visible =
                    camera:WorldToViewportPoint(
                        part.Position
                    )

                if visible then
                    local d = (
                        Vector2.new(screen.X,screen.Y)
                        - center
                    ).Magnitude

                    if d < bestDistance then
                        bestDistance = d
                        best = model
                    end
                end
            end
        end
    end

    return best
end

listen(RS.RenderStepped,function(dt)
    if not enabled.targetLock then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    if not getAimPart(lockedTarget) then
        lockedTarget = findTarget()
    end

    local part = getAimPart(lockedTarget)
    if not part then return end

    local current = camera.CFrame
    local desired = CFrame.lookAt(
        current.Position,
        part.Position
    )

    local smooth = math.clamp(
        config.aimSmooth,
        0.01,1
    )

    local alpha =
        1-math.pow(1-smooth,dt*60)

    camera.CFrame =
        current:Lerp(desired,alpha)
end)

-- ====================================
-- AURA HIT - BEST EFFORT
-- ====================================

local function equippedTool()
    local ch = LP.Character
    if not ch then return nil end

    return ch:FindFirstChildOfClass("Tool")
end

local function nearestNPC(range)
    local best = nil
    local bestDistance = range

    for _,obj in ipairs(
        workspace:GetDescendants()
    ) do
        if obj:IsA("Model") and isNPC(obj) then
            local p = getAimPart(obj)

            if p then
                local d = distanceFrom(p.Position)

                if d < bestDistance then
                    bestDistance = d
                    best = obj
                end
            end
        end
    end

    return best
end

local function auraTick()
    if not enabled.aura then return end

    local target = nearestNPC(config.auraRadius)
    if not target then return end

    local tool = equippedTool()
    if not tool then return end

    -- Activates the equipped tool normally.
    -- Whether a hit occurs is decided by the game.
    pcall(function()
        tool:Activate()
    end)
end

-- ====================================
-- MULTI ACTION - BEST EFFORT
-- ====================================

local function promptMatches(prompt)
    local mode = config.actionMode

    if mode == "Auto" then
        return true
    end

    local value = string.lower(
        prompt.Name.." "..
        prompt.ActionText.." "..
        prompt.ObjectText
    )

    local patterns = {
        Collect = {
            "collect","pickup","take","grab",
            "claim","loot","harvest"
        },
        Dig = {
            "dig","excavate","shovel"
        },
        Mine = {
            "mine","mining","ore","rock",
            "break"
        },
        Interact = {
            "interact","open","use","activate"
        }
    }

    for _,word in ipairs(patterns[mode] or {}) do
        if string.find(value,word,1,true) then
            return true
        end
    end

    return false
end

local function promptPosition(prompt)
    local parent = prompt.Parent
    if not parent then return nil end

    if parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Attachment") then
        return parent.WorldPosition
    elseif parent:IsA("Model") then
        return parent:GetPivot().Position
    end
end

local function multiTick()
    if not enabled.multi then return end

    local count = 0

    for _,obj in ipairs(
        workspace:GetDescendants()
    ) do
        if count >= 8 then break end

        if obj:IsA("ProximityPrompt")
            and obj.Enabled
            and promptMatches(obj) then

            local p = promptPosition(obj)

            if p then
                local allowedRange = math.min(
                    config.actionRadius,
                    obj.MaxActivationDistance
                )

                if distanceFrom(p) <= allowedRange then
                    count = count+1

                    pcall(function()
                        obj:InputHoldBegin()

                        task.delay(
                            math.max(
                                obj.HoldDuration,
                                0.05
                            ),
                            function()
                                if obj.Parent then
                                    obj:InputHoldEnd()
                                end
                            end
                        )
                    end)
                end
            end
        end
    end
end

-- ====================================
-- PERIODIC TASKS
-- ====================================

local espTimer = 0
local itemTimer = 0
local auraTimer = 0
local actionTimer = 0

listen(RS.Heartbeat,function(dt)
    espTimer = espTimer+dt
    itemTimer = itemTimer+dt
    auraTimer = auraTimer+dt
    actionTimer = actionTimer+dt

    if espTimer >= config.espInterval then
        espTimer = 0

        if enabled.playerESP
            and enabled.playerRefresh then
            refreshPlayers()
        end

        updateESPDistances(playerESP)
        updateESPDistances(itemESP)
    end

    if itemTimer >= 4 then
        itemTimer = 0

        if enabled.itemESP
            and enabled.itemRefresh then
            scanItems()
            refreshItems()
        end
    end

    if auraTimer >= config.auraInterval then
        auraTimer = 0
        auraTick()
    end

    if actionTimer >= config.actionInterval then
        actionTimer = 0
        multiTick()
    end
end)

-- ====================================
-- FULLBRIGHT
-- ====================================

local function setFullbright(on)
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        for k,v in pairs(originalLighting) do
            Lighting[k] = v
        end
    end
end

-- ====================================
-- PAGES
-- ====================================

local pages = {}
local switch

pages.Home = function()
    heading("Dashboard")

    info("FREAKHUB UNIVERSAL v2.0")
    info("Player: "..LP.Name)
    info("Compact UI • Flight • ESP • Automation")

    button("PLAYER SETTINGS",function()
        switch("Player")
    end)

    button("ESP CENTER",function()
        switch("ESP")
    end)

    button("AUTOMATION",function()
        switch("Automation")
    end)
end

pages.Player = function()
    heading("Player")

    toggle("Infinite Jump","infiniteJump")

    toggle("Noclip","noclip",function(on)
        if not on then
            restoreCollision()
        end
    end)

    toggle("Infinite Health","health")

    numberRow(
        "Walk Speed",
        config.walkSpeed,
        function(v)
            config.walkSpeed =
                math.clamp(v or 16,16,200)
            applyPlayer()
        end
    )

    numberRow(
        "Jump Power",
        config.jumpPower,
        function(v)
            config.jumpPower =
                math.clamp(v or 50,50,200)
            applyPlayer()
        end
    )

    heading("Flight")

    toggle("Fly","fly",function(on)
        setFly(on)
        flightControls.Visible =
            enabled.fly or enabled.mountFly
        switch("Player")
    end)

    numberRow(
        "Fly Speed",
        config.flySpeed,
        function(v)
            config.flySpeed =
                math.clamp(v or 55,10,200)
        end
    )

    toggle("Mount Fly","mountFly",function(on)
        setMountFly(on)
        flightControls.Visible =
            enabled.fly or enabled.mountFly
        switch("Player")
    end)

    numberRow(
        "Mount Speed",
        config.mountSpeed,
        function(v)
            config.mountSpeed =
                math.clamp(v or 65,10,200)
        end
    )

    button("STOP FLIGHT",function()
        enabled.fly = false
        enabled.mountFly = false
        stopFly()
        flightControls.Visible = false
        switch("Player")
    end)

    info("Flight: UP / DOWN / FORWARD / BACK.")
end

pages.ESP = function()
    heading("ESP Center")

    toggle("Player ESP","playerESP",function()
        refreshPlayers()
    end)

    toggle("Player Auto Refresh","playerRefresh")

    toggle("Item ESP","itemESP",function()
        if enabled.itemESP
            and #scanResults == 0 then
            scanItems()
        end
        refreshItems()
    end)

    toggle("Item Auto Refresh","itemRefresh")

    numberRow(
        "Refresh (sec)",
        config.espInterval,
        function(v)
            config.espInterval =
                math.clamp(v or 1.5,0.5,10)
        end
    )

    button("REFRESH PLAYER ESP",refreshPlayers)

    button("REFRESH ITEM ESP",function()
        scanItems()
        refreshItems()
    end)

    button("CLEAR ALL ESP",function()
        enabled.playerESP = false
        enabled.itemESP = false

        clearESP(playerESP)
        clearESP(itemESP)

        switch("ESP")
    end)

    info("Name: 10px • Distance: 9px")
end

pages.Scanner = function()
    heading("Universal Scanner")

    numberRow(
        "Scan Radius",
        config.scanRadius,
        function(v)
            config.scanRadius =
                math.clamp(v or 150,25,500)
        end
    )

    local f = row("Name Filter")

    local input = create("TextBox",f,{
        Position = UDim2.new(0.44,0,0,5),
        Size = UDim2.new(0.53,0,0,25),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
        Text = scanFilter,
        PlaceholderText = "All items",
        PlaceholderColor3 = COLORS.muted,
        TextColor3 = COLORS.white,
        TextSize = 10,
        ClearTextOnFocus = false
    })
    corner(input,6)

    button("SCAN NOW",function()
        scanFilter = input.Text
        scanItems()
        refreshItems()
        switch("Results")
    end)

    toggle("Instant Prompt","instant",setInstant)

    info("Deteksi berdasarkan nama, tag, dan prompt.")
end

pages.Results = function()
    heading("Scan Results")

    info("Found: "..#scanResults.." candidates")

    button("SCAN AGAIN",function()
        scanItems()
        refreshItems()
        switch("Results")
    end)

    for index,result in ipairs(scanResults) do
        if index > 45 then break end

        button(
            result.name.." • "..
            result.distance.." studs",
            function()
                local obj = result.obj

                if obj and obj.Parent then
                    local target = obj

                    if obj:IsA("Tool") then
                        target =
                            obj:FindFirstChild("Handle")
                    end

                    if target then
                        local entry = makeESP(
                            target,
                            result.name,
                            COLORS.green
                        )

                        if entry then
                            table.insert(itemESP,entry)
                        end
                    end
                end
            end
        )
    end
end

pages.Aim = function()
    heading("NPC Target Lock")

    toggle("Target Lock","targetLock",function(on)
        if on then
            lockedTarget = findTarget()

            if not lockedTarget then
                enabled.targetLock = false
            end
        else
            lockedTarget = nil
        end

        switch("Aim")
    end)

    numberRow(
        "FOV Radius",
        config.aimFOV,
        function(v)
            config.aimFOV =
                math.clamp(v or 180,40,500)
        end
    )

    numberRow(
        "Smooth %",
        config.aimSmooth*100,
        function(v)
            config.aimSmooth =
                math.clamp((v or 15)/100,0.01,1)
        end
    )

    button(
        "TARGET: "..config.aimPart,
        function()
            config.aimPart =
                config.aimPart == "Head"
                and "HumanoidRootPart"
                or "Head"

            lockedTarget = nil
            switch("Aim")
        end
    )

    button("FIND NEAREST NPC",function()
        lockedTarget = findTarget()
    end)

    button("UNLOCK TARGET",function()
        enabled.targetLock = false
        lockedTarget = nil
        switch("Aim")
    end)

    info("Target Lock hanya untuk NPC/dummy.")
end

pages.Automation = function()
    heading("Automation")

    toggle("Aura Hit","aura")

    numberRow(
        "Aura Radius",
        config.auraRadius,
        function(v)
            config.auraRadius =
                math.clamp(v or 12,5,40)
        end
    )

    numberRow(
        "Aura Delay",
        config.auraInterval,
        function(v)
            config.auraInterval =
                math.clamp(v or 0.5,0.2,5)
        end
    )

    heading("Multi Action")

    toggle("Multi Action","multi")

    button(
        "MODE: "..config.actionMode,
        function()
            local modes = {
                "Auto",
                "Collect",
                "Dig",
                "Mine",
                "Interact"
            }

            for i,mode in ipairs(modes) do
                if mode == config.actionMode then
                    config.actionMode =
                        modes[i % #modes + 1]
                    break
                end
            end

            switch("Automation")
        end
    )

    numberRow(
        "Action Radius",
        config.actionRadius,
        function(v)
            config.actionRadius =
                math.clamp(v or 15,3,50)
        end
    )

    numberRow(
        "Action Delay",
        config.actionInterval,
        function(v)
            config.actionInterval =
                math.clamp(v or 1,0.5,10)
        end
    )

    button("STOP AUTOMATION",function()
        enabled.aura = false
        enabled.multi = false
        switch("Automation")
    end)

    info(
        "Best effort: aksi hanya berhasil jika "..
        "mekanisme game mengizinkannya."
    )
end

pages.Teleport = function()
    heading("Teleport Slots")

    for i=1,5 do
        local index = i
        local frame = row("Slot "..index)

        local save = create("TextButton",frame,{
            Position = UDim2.new(1,-102,0,5),
            Size = UDim2.fromOffset(46,25),
            BackgroundColor3 = COLORS.red,
            BorderSizePixel = 0,
            Text = "SAVE",
            TextColor3 = COLORS.white,
            TextSize = 10
        })
        corner(save,6)

        local go = create("TextButton",frame,{
            Position = UDim2.new(1,-52,0,5),
            Size = UDim2.fromOffset(45,25),
            BackgroundColor3 = COLORS.panel,
            BorderSizePixel = 0,
            Text = "GO",
            TextColor3 = COLORS.white,
            TextSize = 10
        })
        corner(go,6)

        listen(save.Activated,function()
            local r = root()
            if r then
                teleportSlots[index] = r.CFrame
            end
        end)

        listen(go.Activated,function()
            local saved = teleportSlots[index]

            if saved and LP.Character then
                LP.Character:PivotTo(saved)
            end
        end)
    end

    button("CLEAR ALL SLOTS",function()
        table.clear(teleportSlots)
    end)
end

pages.Utility = function()
    heading("Utility")

    toggle("Fullbright","fullbright",setFullbright)

    button("RESET LOGO POSITION",function()
        logo.Position =
            UDim2.new(0,14,0.45,0)
    end)

    button("HIDE MENU",function()
        window.Visible = false
    end)

    info("Drag tombol F. Tap untuk buka/tutup.")
end

-- ====================================
-- SIDEBAR NAVIGATION
-- ====================================

local tabs = {}

for i,name in ipairs({
    "Home",
    "Player",
    "ESP",
    "Scanner",
    "Results",
    "Aim",
    "Automation",
    "Teleport",
    "Utility"
}) do
    local b = create("TextButton",sidebar,{
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = COLORS.card,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = COLORS.white,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = i
    })
    corner(b,8)

    tabs[name] = b

    listen(b.Activated,function()
        switch(name)
    end)
end

switch = function(name)
    selectedTab = name
    clearBody()

    pages[name]()

    for tab,b in pairs(tabs) do
        b.BackgroundColor3 =
            tab == name
            and COLORS.red
            or COLORS.card
    end
end

-- ====================================
-- MOBILE DRAG
-- ====================================

local function draggable(handle,target,tap)
    local active = nil
    local start = nil
    local origin = nil
    local moved = false

    listen(handle.InputBegan,function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            active = input
            start = input.Position
            origin = target.Position
            moved = false
        end
    end)

    listen(UIS.InputChanged,function(input)
        if not active then return end

        local mouse =
            active.UserInputType ==
                Enum.UserInputType.MouseButton1
            and input.UserInputType ==
                Enum.UserInputType.MouseMovement

        if input ~= active and not mouse then
            return
        end

        local delta = input.Position-start

        if delta.Magnitude > 8 then
            moved = true
        end

        if moved then
            target.Position = UDim2.new(
                origin.X.Scale,
                origin.X.Offset+delta.X,
                origin.Y.Scale,
                origin.Y.Offset+delta.Y
            )
        end
    end)

    listen(UIS.InputEnded,function(input)
        if input ~= active then return end

        active = nil

        if not moved and tap then
            tap()
        end
    end)
end

draggable(logo,logo,function()
    window.Visible = not window.Visible
end)

draggable(header,window)

listen(close.Activated,function()
    window.Visible = false
end)

local function fitWindow()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local v = camera.ViewportSize

    window.Size = UDim2.fromOffset(
        math.min(390,math.max(220,v.X-12)),
        math.min(400,math.max(240,v.Y-28))
    )
end

fitWindow()

if workspace.CurrentCamera then
    listen(
        workspace.CurrentCamera:
            GetPropertyChangedSignal("ViewportSize"),
        fitWindow
    )
end

-- ====================================
-- CLEANUP
-- ====================================

listen(gui.Destroying,function()
    alive = false

    for key in pairs(enabled) do
        enabled[key] = false
    end

    lockedTarget = nil

    stopFly()
    restoreCollision()
    clearESP(playerESP)
    clearESP(itemESP)

    setInstant(false)
    setFullbright(false)

    for _,connection in ipairs(connections) do
        connection:Disconnect()
    end
end)

switch("Home")

print("FREAKHUB v2.0 BEST EFFORT LOADED")

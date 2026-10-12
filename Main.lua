
-- FREAKHUB v2.2 FULL INTEGRATED
-- Mobile UI | Automation + Clicker
-- Client-side best effort

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Tags = game:GetService("CollectionService")

local LP = Players.LocalPlayer
if not LP then return end

local PG = LP:WaitForChild("PlayerGui")

if _G.FREAKHUB_CLEANUP then
    pcall(_G.FREAKHUB_CLEANUP)
end

for _, name in ipairs({
    "FREAKHUB_V17",
    "FREAKHUB_V18",
    "FREAKHUB_V19",
    "FREAKHUB_V20",
    "FREAKHUB_V22"
}) do
    local old = PG:FindFirstChild(name)
    if old then old:Destroy() end
end

local C = {
    bg = Color3.fromRGB(12,13,19),
    panel = Color3.fromRGB(22,24,33),
    card = Color3.fromRGB(35,38,49),
    red = Color3.fromRGB(233,52,73),
    white = Color3.fromRGB(245,246,250),
    muted = Color3.fromRGB(167,172,187),
    green = Color3.fromRGB(75,205,144)
}

local state = {
    jump = false,
    noclip = false,
    health = false,
    fly = false,
    mount = false,
    pesp = false,
    iesp = false,
    prefresh = true,
    irefresh = false,
    aim = false,
    aura = false,
    multi = false,
    instant = false,
    bright = false,
    auto = false,
    burst = false,
    holdButton = false
}

local cfg = {
    speed = 16,
    jump = 50,
    fly = 55,
    mount = 65,
    scan = 150,
    refresh = 2,
    auraRadius = 12,
    auraDelay = 0.5,
    actionRadius = 15,
    actionDelay = 1,
    actionMode = "Auto",
    fov = 180,
    smooth = 0.15,
    aimPart = "Head",
    clickMs = 100,
    burstCount = 5,
    burstGapMs = 1000,
    ui = "Normal"
}

local conns = {}
local playerMarks = {}
local itemMarks = {}
local results = {}
local slots = {}
local oldCollisions = {}
local oldPrompts = {}

local lightingOld = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local active = true
local flyData = nil
local moveUp = 0
local moveForward = 0
local aimTarget = nil
local clickToken = 0
local heldInput = nil
local currentTab = "Home"
local filter = ""

local function bind(signal, fn)
    local connection = signal:Connect(fn)
    table.insert(conns, connection)
    return connection
end

local function new(class, parent, props)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    new("UICorner", obj, {
        CornerRadius = UDim.new(0, radius or 8)
    })
end

local function hum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function root()
    local ch = LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function pos(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    elseif obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle")
        return handle and handle.Position
    end
end

local function dist(position)
    local r = root()

    return r
        and (r.Position - position).Magnitude
        or math.huge
end

-- =====================================
-- GUI
-- =====================================

local gui = new("ScreenGui", PG, {
    Name = "FREAKHUB_V22",
    ResetOnSpawn = false,
    DisplayOrder = 500
})

local logo = new("TextButton", gui, {
    Size = UDim2.fromOffset(54,54),
    Position = UDim2.new(0,14,0.45,0),
    BackgroundColor3 = C.bg,
    Text = "F",
    TextSize = 32,
    Font = Enum.Font.GothamBlack,
    TextColor3 = C.red,
    BorderSizePixel = 0,
    Active = true
})
round(logo,17)

new("UIStroke", logo, {
    Color = C.red,
    Thickness = 2
})

local win = new("Frame", gui, {
    Size = UDim2.fromOffset(390,410),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Visible = false,
    Active = true
})
round(win,16)

new("UIStroke", win, {
    Color = C.card
})

local header = new("Frame", win, {
    Size = UDim2.new(1,0,0,55),
    BackgroundTransparency = 1,
    Active = true
})

local function label(parent, value, size, color)
    return new("TextLabel", parent, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,22),
        Text = value,
        TextSize = size or 13,
        TextColor3 = color or C.white,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
end

local title = label(header,"FREAKHUB",20)
title.Position = UDim2.fromOffset(15,4)
title.Font = Enum.Font.GothamBold

local subtitle = label(
    header,
    "UNIVERSAL  •  v2.2",
    11,
    C.red
)
subtitle.Position = UDim2.fromOffset(16,31)

local close = new("TextButton", header, {
    Position = UDim2.new(1,-41,0,12),
    Size = UDim2.fromOffset(31,31),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
    Text = "×",
    TextSize = 24,
    TextColor3 = C.white
})
round(close,8)

local sidebar = new("ScrollingFrame", win, {
    Position = UDim2.fromOffset(9,60),
    Size = UDim2.new(0,109,1,-69),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})
round(sidebar,10)

new("UIPadding", sidebar, {
    PaddingTop = UDim.new(0,6),
    PaddingLeft = UDim.new(0,5),
    PaddingRight = UDim.new(0,5),
    PaddingBottom = UDim.new(0,6)
})

new("UIListLayout", sidebar, {
    Padding = UDim.new(0,5),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local body = new("ScrollingFrame", win, {
    Position = UDim2.fromOffset(125,60),
    Size = UDim2.new(1,-135,1,-69),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.red,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})

new("UIListLayout", body, {
    Padding = UDim.new(0,6),
    SortOrder = Enum.SortOrder.LayoutOrder
})

-- =====================================
-- UI SCALING
-- =====================================

local uiBase = setmetatable({}, {
    __mode = "k"
})

local function applyUI()
    local factor = ({
        Small = 0.95,
        Normal = 1.12,
        Large = 1.30
    })[cfg.ui] or 1.12

    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

            if not uiBase[obj] then
                uiBase[obj] = obj.TextSize
            end

            obj.TextSize = math.max(
                11,
                math.floor(uiBase[obj] * factor + 0.5)
            )
        end
    end

    local cam = workspace.CurrentCamera

    if cam then
        local viewport = cam.ViewportSize

        local scale = ({
            Small = 0.93,
            Normal = 1,
            Large = 1.06
        })[cfg.ui] or 1

        win.Size = UDim2.fromOffset(
            math.min(
                math.floor(390 * scale),
                math.max(220, viewport.X - 12)
            ),
            math.min(
                math.floor(410 * scale),
                math.max(240, viewport.Y - 20)
            )
        )
    end
end

local function clearBody()
    for _, obj in ipairs(body:GetChildren()) do
        if obj:IsA("GuiObject") then
            obj:Destroy()
        end
    end
end

local function heading(value)
    local frame = new("Frame", body, {
        Size = UDim2.new(1,-3,0,30),
        BackgroundTransparency = 1
    })

    local text = label(frame,value,16)
    text.Font = Enum.Font.GothamBold
    text.Position = UDim2.fromOffset(3,3)
end

local function info(value)
    local frame = new("Frame", body, {
        Size = UDim2.new(1,-3,0,46),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0
    })
    round(frame,8)

    local text = label(frame,value,11,C.muted)
    text.Position = UDim2.fromOffset(8,4)
    text.Size = UDim2.new(1,-16,1,-8)
    text.TextWrapped = true
    text.TextTruncate = Enum.TextTruncate.None
end

local function button(value, callback)
    local obj = new("TextButton", body, {
        Size = UDim2.new(1,-3,0,37),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        Text = value,
        TextSize = 13,
        TextColor3 = C.white,
        Font = Enum.Font.GothamMedium
    })
    round(obj,8)

    bind(obj.Activated,callback)
    return obj
end

local function row(value)
    local frame = new("Frame", body, {
        Size = UDim2.new(1,-3,0,40),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0
    })
    round(frame,8)

    local text = label(frame,value,12)
    text.Position = UDim2.fromOffset(9,9)
    text.Size = UDim2.new(0.55,-9,0,22)

    return frame
end

local function toggle(value, key, callback)
    local frame = row(value)

    local obj = new("TextButton", frame, {
        Position = UDim2.new(1,-66,0,6),
        Size = UDim2.fromOffset(59,28),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        TextColor3 = C.white,
        TextSize = 11,
        Font = Enum.Font.GothamBold
    })
    round(obj,7)

    local function paint()
        obj.Text = state[key] and "ON" or "OFF"

        obj.BackgroundColor3 =
            state[key] and C.red or C.panel
    end

    bind(obj.Activated,function()
        state[key] = not state[key]

        if callback then
            callback(state[key])
        end

        paint()
    end)

    paint()
end

local function numberRow(value, current, callback)
    local frame = row(value)

    local input = new("TextBox", frame, {
        Position = UDim2.new(1,-109,0,6),
        Size = UDim2.fromOffset(59,28),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        Text = tostring(current),
        TextSize = 12,
        TextColor3 = C.white,
        ClearTextOnFocus = false
    })
    round(input,6)

    local set = new("TextButton", frame, {
        Position = UDim2.new(1,-47,0,6),
        Size = UDim2.fromOffset(40,28),
        BackgroundColor3 = C.red,
        BorderSizePixel = 0,
        Text = "SET",
        TextSize = 11,
        TextColor3 = C.white
    })
    round(set,6)

    bind(set.Activated,function()
        local value = tonumber(input.Text)

        if value then
            callback(value)
        else
            input.Text = tostring(current)
        end
    end)

    return input
end

-- =====================================
-- PLAYER
-- =====================================

local function applyPlayer()
    local h = hum()

    if h then
        pcall(function()
            h.WalkSpeed = cfg.speed
            h.UseJumpPower = true
            h.JumpPower = cfg.jump
        end)
    end
end

bind(LP.CharacterAdded,function(character)
    character:WaitForChild("Humanoid",10)
    task.defer(applyPlayer)
end)

bind(UIS.JumpRequest,function()
    if state.jump then
        local h = hum()

        if h then
            h:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
end)

local function restoreCollisions()
    for part, value in pairs(oldCollisions) do
        if part.Parent then
            pcall(function()
                part.CanCollide = value
            end)
        end
    end

    table.clear(oldCollisions)
end

bind(Run.Stepped,function()
    if not state.noclip then return end

    local character = LP.Character
    if not character then return end

    for _, part in ipairs(
        character:GetDescendants()
    ) do
        if part:IsA("BasePart") then
            if oldCollisions[part] == nil then
                oldCollisions[part] = part.CanCollide
            end

            part.CanCollide = false
        end
    end
end)

-- Infinite Health: local best effort only
bind(Run.Heartbeat,function()
    if not state.health then return end

    local h = hum()

    if h and h.Health > 0
        and h.Health < h.MaxHealth then

        pcall(function()
            h.Health = h.MaxHealth
        end)
    end
end)

-- =====================================
-- FLY / MOUNT FLY
-- =====================================

local flyData = nil

local function stopFly()
    if flyData then
        for _, obj in ipairs(flyData.objects) do
            if obj.Parent then
                obj:Destroy()
            end
        end
    end

    flyData = nil
    moveUp = 0
    moveForward = 0
end

local function beginFly(part, kind)
    stopFly()

    if not part or not part:IsA("BasePart") then
        return false
    end

    local attachment = new("Attachment", part, {
        Name = "FH_Attachment"
    })

    local velocity = new("LinearVelocity", part, {
        Name = "FH_Velocity",
        Attachment0 = attachment,
        RelativeTo = Enum.ActuatorRelativeTo.World,
        VelocityConstraintMode =
            Enum.VelocityConstraintMode.Vector,
        VectorVelocity = Vector3.zero,
        ForceLimitsEnabled = false
    })

    local orientation = new("AlignOrientation", part, {
        Name = "FH_Orientation",
        Attachment0 = attachment,
        Mode =
            Enum.OrientationAlignmentMode.OneAttachment,
        MaxTorque = 1e9,
        Responsiveness = 15
    })

    flyData = {
        part = part,
        kind = kind,
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

local function mountPart()
    local h = hum()

    if not h or not h.SeatPart then
        return nil
    end

    local seat = h.SeatPart
    local model = seat:FindFirstAncestorOfClass("Model")

    return model and model.PrimaryPart or seat
end

local controls = new("Frame", gui, {
    Size = UDim2.fromOffset(184,115),
    Position = UDim2.new(1,-194,1,-170),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Visible = false
})
round(controls,11)

local function control(value,x,y,axis,amount)
    local obj = new("TextButton", controls, {
        Position = UDim2.fromOffset(x,y),
        Size = UDim2.fromOffset(83,46),
        BackgroundColor3 = C.red,
        BorderSizePixel = 0,
        Text = value,
        TextSize = 12,
        TextColor3 = C.white,
        Font = Enum.Font.GothamBold
    })
    round(obj,8)

    local held = {}

    bind(obj.InputBegan,function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            held[input] = true

            if axis == "up" then
                moveUp = amount
            else
                moveForward = amount
            end
        end
    end)

    bind(UIS.InputEnded,function(input)
        if held[input] then
            held[input] = nil

            if axis == "up" then
                moveUp = 0
            else
                moveForward = 0
            end
        end
    end)
end

control("▲ UP",7,8,"up",1)
control("FORWARD",94,8,"forward",1)
control("▼ DOWN",7,60,"up",-1)
control("BACK",94,60,"forward",-1)

bind(Run.Heartbeat,function()
    local flight = flyData
    if not flight then return end

    if not flight.part.Parent
        or (
            flight.kind == "player"
            and not state.fly
        )
        or (
            flight.kind == "mount"
            and (
                not state.mount
                or not hum()
                or not hum().SeatPart
            )
        ) then

        state.fly = false
        state.mount = false
        controls.Visible = false
        stopFly()
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local look = cam.CFrame.LookVector
    local flat = Vector3.new(look.X,0,look.Z)

    flat = flat.Magnitude > 0.01
        and flat.Unit
        or Vector3.new(0,0,-1)

    local h = hum()

    local move = h
        and h.MoveDirection
        or Vector3.zero

    local speed = flight.kind == "mount"
        and cfg.mount
        or cfg.fly

    flight.velocity.VectorVelocity =
        move * speed
        + flat * moveForward * speed
        + Vector3.new(0,moveUp * speed,0)

    flight.orientation.CFrame =
        CFrame.lookAt(Vector3.zero,flat)
end)

-- =====================================
-- ESP
-- =====================================

local function removeMark(entry)
    if not entry then return end

    if entry.highlight then
        entry.highlight:Destroy()
    end

    if entry.tag then
        entry.tag:Destroy()
    end
end

local function clearMarks(tbl)
    for _, entry in pairs(tbl) do
        removeMark(entry)
    end

    table.clear(tbl)
end

local function makeMark(target,name,color)
    if not target or not target.Parent then
        return nil
    end

    local part

    if target:IsA("BasePart") then
        part = target
    else
        part = target:FindFirstChild("Head")
            or target.PrimaryPart
            or target:FindFirstChildWhichIsA(
                "BasePart",true
            )
    end

    if not part then return nil end

    local highlight = new("Highlight",workspace,{
        Adornee = target,
        FillColor = color,
        OutlineColor = C.white,
        FillTransparency = 0.75,
        OutlineTransparency = 0,
        DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop
    })

    local tag = new("BillboardGui",gui,{
        Name = "FH_NameTag",
        Adornee = part,
        Size = UDim2.fromOffset(160,42),
        StudsOffsetWorldSpace =
            Vector3.new(0,2.6,0),
        AlwaysOnTop = true,
        MaxDistance = 500
    })

    new("TextLabel",tag,{
        Size = UDim2.new(1,0,0,23),
        BackgroundTransparency = 1,
        Text = name,
        TextSize = 12,
        TextColor3 = C.white,
        TextStrokeColor3 = Color3.new(),
        TextStrokeTransparency = 0.1,
        Font = Enum.Font.GothamBold
    })

    local distanceLabel = new("TextLabel",tag,{
        Position = UDim2.fromOffset(0,23),
        Size = UDim2.new(1,0,0,17),
        BackgroundTransparency = 1,
        Text = "",
        TextSize = 10,
        TextColor3 = color,
        TextStrokeColor3 = Color3.new(),
        TextStrokeTransparency = 0.1
    })

    return {
        target = target,
        part = part,
        highlight = highlight,
        tag = tag,
        distance = distanceLabel
    }
end

local function refreshPlayers()
    if not state.pesp then
        clearMarks(playerMarks)
        return
    end

    for player, entry in pairs(playerMarks) do
        if not player.Parent
            or not player.Character
            or player.Character ~= entry.target
            or not entry.part.Parent then

            removeMark(entry)
            playerMarks[player] = nil
        end
    end

    for _, player in ipairs(
        Players:GetPlayers()
    ) do
        if player ~= LP
            and player.Character
            and player.Character.Parent
            and not playerMarks[player] then

            playerMarks[player] = makeMark(
                player.Character,
                player.DisplayName,
                C.red
            )
        end
    end
end

-- =====================================
-- SCANNER
-- =====================================

local words = {
    "coin","gem","diamond","loot",
    "drop","chest","treasure","egg",
    "collect","pickup","reward","item",
    "crystal","fruit","key","token",
    "orb","gift","ore","rock",
    "mineral","mine","dig"
}

local function hasWord(value)
    value = string.lower(value)

    for _, word in ipairs(words) do
        if string.find(value,word,1,true) then
            return true
        end
    end

    return false
end

local function isItem(obj)
    if obj:IsA("Tool") then
        return true
    end

    if not (
        obj:IsA("Model")
        or obj:IsA("BasePart")
    ) then
        return false
    end

    if hasWord(obj.Name)
        or obj:FindFirstChildWhichIsA(
            "ProximityPrompt",true
        ) then

        return true
    end

    for _, tag in ipairs(Tags:GetTags(obj)) do
        if hasWord(tag) then
            return true
        end
    end

    return false
end

local function belongsToPlayer(obj)
    for _, player in ipairs(
        Players:GetPlayers()
    ) do
        if player.Character
            and obj:IsDescendantOf(
                player.Character
            ) then

            return true
        end
    end

    return false
end

local function scanItems()
    table.clear(results)

    local seen = {}

    for _, obj in ipairs(
        workspace:GetDescendants()
    ) do
        if #results >= 120 then
            break
        end

        if isItem(obj)
            and not belongsToPlayer(obj) then

            local target = obj

            if obj:IsA("BasePart") then
                local model =
                    obj:FindFirstAncestorOfClass("Model")

                if model and isItem(model) then
                    target = model
                end
            end

            if not seen[target]
                and not belongsToPlayer(target) then

                local position = pos(target)

                if position
                    and dist(position) <= cfg.scan
                    and (
                        filter == ""
                        or string.find(
                            string.lower(target.Name),
                            string.lower(filter),
                            1,true
                        )
                    ) then

                    seen[target] = true

                    table.insert(results,{
                        obj = target,
                        name = target.Name,
                        distance =
                            math.floor(dist(position))
                    })
                end
            end
        end
    end

    table.sort(results,function(a,b)
        return a.distance < b.distance
    end)
end

local function refreshItems()
    clearMarks(itemMarks)

    if not state.iesp then return end

    for _, result in ipairs(results) do
        local target = result.obj

        if target and target.Parent then
            if target:IsA("Tool") then
                target =
                    target:FindFirstChild("Handle")
            end

            if target then
                local entry = makeMark(
                    target,
                    result.name,
                    C.green
                )

                if entry then
                    table.insert(itemMarks,entry)
                end
            end
        end
    end
end

local function updateDistance(tbl)
    for _, entry in pairs(tbl) do
        if entry.part
            and entry.part.Parent
            and entry.distance then

            entry.distance.Text =
                math.floor(
                    dist(entry.part.Position)
                ).." studs"
        end
    end
end

-- =====================================
-- INSTANT PROMPT
-- =====================================

local function instant(on)
    if on then
        for _, prompt in ipairs(
            workspace:GetDescendants()
        ) do
            if prompt:IsA("ProximityPrompt") then
                if oldPrompts[prompt] == nil then
                    oldPrompts[prompt] =
                        prompt.HoldDuration
                end

                prompt.HoldDuration = 0
            end
        end
    else
        for prompt, value in pairs(oldPrompts) do
            if prompt.Parent then
                pcall(function()
                    prompt.HoldDuration = value
                end)
            end
        end

        table.clear(oldPrompts)
    end
end

bind(workspace.DescendantAdded,function(obj)
    if state.instant
        and obj:IsA("ProximityPrompt") then

        task.defer(function()
            if obj.Parent then
                if oldPrompts[obj] == nil then
                    oldPrompts[obj] =
                        obj.HoldDuration
                end

                obj.HoldDuration = 0
            end
        end)
    end
end)

-- =====================================
-- NPC TARGET LOCK
-- =====================================

local function isNPC(model)
    if not model
        or not model:IsA("Model")
        or Players:GetPlayerFromCharacter(model) then

        return false
    end

    local h = model:FindFirstChildOfClass(
        "Humanoid"
    )

    return h ~= nil and h.Health > 0
end

local function aimPart(model)
    if not isNPC(model) then
        return nil
    end

    return model:FindFirstChild(cfg.aimPart)
        or model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

local function findNPC()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local center = cam.ViewportSize / 2
    local best = nil
    local bestDistance = cfg.fov

    for _, model in ipairs(
        workspace:GetDescendants()
    ) do
        if model:IsA("Model")
            and isNPC(model) then

            local part = aimPart(model)

            if part then
                local screen, visible =
                    cam:WorldToViewportPoint(
                        part.Position
                    )

                if visible then
                    local distance = (
                        Vector2.new(
                            screen.X,
                            screen.Y
                        ) - center
                    ).Magnitude

                    if distance < bestDistance then
                        bestDistance = distance
                        best = model
                    end
                end
            end
        end
    end

    return best
end

bind(Run.RenderStepped,function(dt)
    if not state.aim then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    if not aimPart(aimTarget) then
        aimTarget = findNPC()
    end

    local part = aimPart(aimTarget)
    if not part then return end

    local current = cam.CFrame

    local desired = CFrame.lookAt(
        current.Position,
        part.Position
    )

    local alpha = 1 - math.pow(
        1 - cfg.smooth,
        dt * 60
    )

    cam.CFrame = current:Lerp(
        desired,
        alpha
    )
end)

-- =====================================
-- TOOL / AURA HIT
-- =====================================

local function tool()
    local character = LP.Character

    return character
        and character:FindFirstChildOfClass("Tool")
end

local function activate()
    local current = tool()

    if current and current.Enabled then
        pcall(function()
            current:Activate()
        end)
    end
end

local function nearestNPC(radius)
    local best = nil
    local bestDistance = radius

    for _, model in ipairs(
        workspace:GetDescendants()
    ) do
        if model:IsA("Model")
            and isNPC(model) then

            local part = aimPart(model)

            if part then
                local distance =
                    dist(part.Position)

                if distance < bestDistance then
                    best = model
                    bestDistance = distance
                end
            end
        end
    end

    return best
end

local function auraTick()
    if state.aura
        and nearestNPC(cfg.auraRadius) then

        activate()
    end
end

-- =====================================
-- MULTI ACTION
-- =====================================

local function promptMatch(prompt)
    if cfg.actionMode == "Auto" then
        return true
    end

    local value = string.lower(
        prompt.Name.." "..
        prompt.ActionText.." "..
        prompt.ObjectText
    )

    local byMode = {
        Collect = {
            "collect","pickup","take",
            "grab","loot","harvest"
        },
        Dig = {
            "dig","excavate","shovel"
        },
        Mine = {
            "mine","ore","rock","break"
        },
        Interact = {
            "interact","open","use","activate"
        }
    }

    for _, word in ipairs(
        byMode[cfg.actionMode] or {}
    ) do
        if string.find(value,word,1,true) then
            return true
        end
    end

    return false
end

local function promptPos(prompt)
    local obj = prompt.Parent
    if not obj then return nil end

    if obj:IsA("Attachment") then
        return obj.WorldPosition
    elseif obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    end
end

local promptBusy = {}

local function multiTick()
    if not state.multi then return end

    local count = 0

    for _, prompt in ipairs(
        workspace:GetDescendants()
    ) do
        if count >= 6 then break end

        if prompt:IsA("ProximityPrompt")
            and prompt.Enabled
            and not promptBusy[prompt]
            and promptMatch(prompt) then

            local position = promptPos(prompt)

            if position
                and dist(position) <= math.min(
                    cfg.actionRadius,
                    prompt.MaxActivationDistance
                ) then

                count = count + 1
                promptBusy[prompt] = true

                pcall(function()
                    prompt:InputHoldBegin()
                end)

                task.delay(
                    math.max(
                        prompt.HoldDuration,
                        0.05
                    ),
                    function()
                        if prompt.Parent then
                            pcall(function()
                                prompt:InputHoldEnd()
                            end)
                        end

                        promptBusy[prompt] = nil
                    end
                )
            end
        end
    end
end

-- =====================================
-- FULLBRIGHT
-- =====================================

local function setBright(on)
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        for key, value in pairs(lightingOld) do
            Lighting[key] = value
        end
    end
end

-- =====================================
-- AUTO CLICK / KEEP / BURST
-- =====================================

local function stopClick()
    state.auto = false
    state.burst = false
    clickToken = clickToken + 1
end

local function clickWait(milliseconds)
    task.wait(
        math.max(1,milliseconds) / 1000
    )
end

local function startAuto()
    stopClick()

    state.auto = true
    local token = clickToken

    task.spawn(function()
        while active
            and state.auto
            and clickToken == token do

            activate()
            clickWait(cfg.clickMs)
        end
    end)
end

local function startBurst()
    stopClick()

    state.burst = true
    local token = clickToken

    task.spawn(function()
        while active
            and state.burst
            and clickToken == token do

            for i = 1, cfg.burstCount do
                if not active
                    or not state.burst
                    or clickToken ~= token then

                    break
                end

                activate()
                clickWait(cfg.clickMs)
            end

            if state.burst
                and clickToken == token then

                clickWait(cfg.burstGapMs)
            end
        end
    end)
end

local hold = new("TextButton",gui,{
    Size = UDim2.fromOffset(122,48),
    Position = UDim2.new(1,-136,1,-233),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
    Text = "HOLD CLICK",
    TextColor3 = C.white,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    Visible = false
})
round(hold,10)

bind(hold.InputBegan,function(input)
    if heldInput then return end

    if input.UserInputType ==
        Enum.UserInputType.Touch
        or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        heldInput = input
        stopClick()

        local token = clickToken

        task.spawn(function()
            while active
                and heldInput == input
                and clickToken == token do

                activate()
                clickWait(cfg.clickMs)
            end
        end)
    end
end)

bind(UIS.InputEnded,function(input)
    if input == heldInput then
        heldInput = nil
        clickToken = clickToken + 1
    end
end)

-- =====================================
-- AUTO REFRESH
-- =====================================

local playerTimer = 0
local itemTimer = 0
local auraTimer = 0
local actionTimer = 0

bind(Run.Heartbeat,function(dt)
    playerTimer = playerTimer + dt
    itemTimer = itemTimer + dt
    auraTimer = auraTimer + dt
    actionTimer = actionTimer + dt

    if playerTimer >= cfg.refresh then
        playerTimer = 0

        if state.pesp and state.prefresh then
            refreshPlayers()
        end

        updateDistance(playerMarks)
        updateDistance(itemMarks)
    end

    if itemTimer >= math.max(cfg.refresh,2) then
        itemTimer = 0

        if state.iesp and state.irefresh then
            scanItems()
            refreshItems()
        end
    end

    if auraTimer >= cfg.auraDelay then
        auraTimer = 0
        auraTick()
    end

    if actionTimer >= cfg.actionDelay then
        actionTimer = 0
        multiTick()
    end
end)

-- =====================================
-- PAGES
-- =====================================

local pages = {}
local switch

pages.Home = function()
    heading("Dashboard")

    info("FREAKHUB v2.2 • Full Integrated")
    info("Player: "..LP.Name.." | Mobile UI")

    button("PLAYER SETTINGS",function()
        switch("Player")
    end)

    button("ESP CENTER",function()
        switch("ESP")
    end)

    button("AUTOMATION + CLICKER",function()
        switch("Automation")
    end)
end

pages.Player = function()
    heading("Player")

    toggle("Infinite Jump","jump")

    toggle("Noclip","noclip",function(on)
        if not on then
            restoreCollisions()
        end
    end)

    toggle("Infinite Health","health")

    numberRow("Walk Speed",cfg.speed,function(v)
        cfg.speed = math.clamp(v,16,200)
        applyPlayer()
    end)

    numberRow("Jump Power",cfg.jump,function(v)
        cfg.jump = math.clamp(v,50,200)
        applyPlayer()
    end)

    heading("Flight")

    toggle("Fly","fly",function(on)
        if on then
            state.mount = false
            state.fly = beginFly(root(),"player")
        elseif flyData
            and flyData.kind == "player" then

            stopFly()
        end

        controls.Visible =
            state.fly or state.mount

        switch("Player")
    end)

    numberRow("Fly Speed",cfg.fly,function(v)
        cfg.fly = math.clamp(v,10,200)
    end)

    toggle("Mount Fly","mount",function(on)
        if on then
            state.fly = false
            state.mount = beginFly(
                mountPart(),
                "mount"
            )
        elseif flyData
            and flyData.kind == "mount" then

            stopFly()
        end

        controls.Visible =
            state.fly or state.mount

        switch("Player")
    end)

    numberRow("Mount Speed",cfg.mount,function(v)
        cfg.mount = math.clamp(v,10,200)
    end)

    button("STOP FLIGHT",function()
        state.fly = false
        state.mount = false

        stopFly()
        controls.Visible = false

        switch("Player")
    end)

    info("Flight: UP / DOWN / FORWARD / BACK.")
end

pages.ESP = function()
    heading("ESP Center")

    toggle(
        "Player ESP",
        "pesp",
        refreshPlayers
    )

    toggle(
        "Player Auto Refresh",
        "prefresh"
    )

    toggle("Item ESP","iesp",function(on)
        if on and #results == 0 then
            scanItems()
        end

        refreshItems()
    end)

    toggle(
        "Item Auto Refresh",
        "irefresh"
    )

    numberRow(
        "Refresh (sec)",
        cfg.refresh,
        function(v)
            cfg.refresh = math.clamp(v,0.5,10)
        end
    )

    button("REFRESH PLAYER ESP",refreshPlayers)

    button("REFRESH ITEM ESP",function()
        scanItems()
        refreshItems()
    end)

    button("CLEAR ALL ESP",function()
        state.pesp = false
        state.iesp = false

        clearMarks(playerMarks)
        clearMarks(itemMarks)

        switch("ESP")
    end)

    info("Player/item names + distance tags.")
end

pages.Scanner = function()
    heading("Universal Scanner")

    numberRow(
        "Scan Radius",
        cfg.scan,
        function(v)
            cfg.scan = math.clamp(v,25,500)
        end
    )

    local frame = row("Name Filter")

    local input = new("TextBox",frame,{
        Position = UDim2.new(0.44,0,0,6),
        Size = UDim2.new(0.53,0,0,28),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        Text = filter,
        PlaceholderText = "All items",
        TextSize = 12,
        TextColor3 = C.white,
        ClearTextOnFocus = false
    })
    round(input,6)

    button("SCAN NOW",function()
        filter = input.Text

        scanItems()
        refreshItems()

        switch("Results")
    end)

    toggle(
        "Instant Prompt",
        "instant",
        instant
    )

    info("Scanner uses names, tags and prompts.")
end

pages.Results = function()
    heading("Scan Results")

    info("Found: "..#results.." candidates")

    button("SCAN AGAIN",function()
        scanItems()
        refreshItems()
        switch("Results")
    end)

    for i, result in ipairs(results) do
        if i > 45 then break end

        button(
            result.name.." • "..
            result.distance.." studs",
            function()
                local obj = result.obj

                if obj and obj.Parent then
                    if obj:IsA("Tool") then
                        obj = obj:FindFirstChild(
                            "Handle"
                        )
                    end

                    if obj then
                        local entry = makeMark(
                            obj,
                            result.name,
                            C.green
                        )

                        if entry then
                            table.insert(
                                itemMarks,
                                entry
                            )
                        end
                    end
                end
            end
        )
    end
end

pages.Aim = function()
    heading("NPC Target Lock")

    toggle("Target Lock","aim",function(on)
        aimTarget = on and findNPC() or nil

        if on and not aimTarget then
            state.aim = false
        end

        switch("Aim")
    end)

    numberRow("FOV Radius",cfg.fov,function(v)
        cfg.fov = math.clamp(v,40,500)
    end)

    numberRow(
        "Smooth %",
        cfg.smooth * 100,
        function(v)
            cfg.smooth = math.clamp(
                v / 100,
                0.01,
                1
            )
        end
    )

    button("TARGET: "..cfg.aimPart,function()
        cfg.aimPart =
            cfg.aimPart == "Head"
            and "HumanoidRootPart"
            or "Head"

        aimTarget = nil
        switch("Aim")
    end)

    button("FIND NEAREST NPC",function()
        aimTarget = findNPC()
    end)

    button("UNLOCK",function()
        state.aim = false
        aimTarget = nil
        switch("Aim")
    end)

    info("Target Lock is limited to NPC/dummy.")
end

-- =====================================
-- AUTOMATION + CLICKER
-- =====================================

pages.Automation = function()
    heading("Automation")

    toggle("Aura Hit (NPC)","aura")

    numberRow(
        "Aura Radius",
        cfg.auraRadius,
        function(v)
            cfg.auraRadius =
                math.clamp(v,5,40)
        end
    )

    numberRow(
        "Aura Delay (s)",
        cfg.auraDelay,
        function(v)
            cfg.auraDelay =
                math.clamp(v,0.2,5)
        end
    )

    heading("Multi Action")

    toggle("Multi Action","multi")

    button("MODE: "..cfg.actionMode,function()
        local modes = {
            "Auto",
            "Collect",
            "Dig",
            "Mine",
            "Interact"
        }

        for i, mode in ipairs(modes) do
            if mode == cfg.actionMode then
                cfg.actionMode =
                    modes[i % #modes + 1]
                break
            end
        end

        switch("Automation")
    end)

    numberRow(
        "Action Radius",
        cfg.actionRadius,
        function(v)
            cfg.actionRadius =
                math.clamp(v,3,50)
        end
    )

    numberRow(
        "Action Delay (s)",
        cfg.actionDelay,
        function(v)
            cfg.actionDelay =
                math.clamp(v,0.5,10)
        end
    )

    heading("Auto Clicker")

    toggle("Auto Click","auto",function(on)
        if on then
            startAuto()
        else
            stopClick()
        end

        switch("Automation")
    end)

    toggle("Burst Click","burst",function(on)
        if on then
            startBurst()
        else
            stopClick()
        end

        switch("Automation")
    end)

    toggle(
        "Keep Click Button",
        "holdButton",
        function(on)
            hold.Visible = on

            if not on then
                heldInput = nil
                clickToken = clickToken + 1
            end
        end
    )

    numberRow(
        "Click Delay (ms)",
        cfg.clickMs,
        function(v)
            cfg.clickMs = math.clamp(
                math.floor(v),
                1,
                60000
            )
        end
    )

    numberRow(
        "Burst Count",
        cfg.burstCount,
        function(v)
            cfg.burstCount = math.clamp(
                math.floor(v),
                1,
                100
            )
        end
    )

    numberRow(
        "Burst Gap (ms)",
        cfg.burstGapMs,
        function(v)
            cfg.burstGapMs = math.clamp(
                math.floor(v),
                1,
                60000
            )
        end
    )

    button("STOP ALL AUTOMATION",function()
        state.aura = false
        state.multi = false

        stopClick()
        heldInput = nil

        switch("Automation")
    end)

    info(
        "Clicker activates equipped Tool. "..
        "Millisecond timing is approximate."
    )
end

-- =====================================
-- TELEPORT
-- =====================================

pages.Teleport = function()
    heading("Teleport Slots")

    for i = 1,5 do
        local index = i
        local frame = row("Slot "..i)

        local save = new("TextButton",frame,{
            Position = UDim2.new(1,-103,0,6),
            Size = UDim2.fromOffset(47,28),
            BackgroundColor3 = C.red,
            BorderSizePixel = 0,
            Text = "SAVE",
            TextSize = 11,
            TextColor3 = C.white
        })
        round(save,6)

        local go = new("TextButton",frame,{
            Position = UDim2.new(1,-52,0,6),
            Size = UDim2.fromOffset(45,28),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            Text = "GO",
            TextSize = 11,
            TextColor3 = C.white
        })
        round(go,6)

        bind(save.Activated,function()
            local r = root()

            if r then
                slots[index] = r.CFrame
            end
        end)

        bind(go.Activated,function()
            if slots[index]
                and LP.Character then

                LP.Character:PivotTo(
                    slots[index]
                )
            end
        end)
    end

    button("CLEAR SLOTS",function()
        table.clear(slots)
    end)
end

-- =====================================
-- UTILITY
-- =====================================

pages.Utility = function()
    heading("Utility")

    toggle(
        "Fullbright",
        "bright",
        setBright
    )

    button("UI SIZE: "..cfg.ui,function()
        cfg.ui = ({
            Small = "Normal",
            Normal = "Large",
            Large = "Small"
        })[cfg.ui]

        switch("Utility")
    end)

    button("RESET LOGO POSITION",function()
        logo.Position =
            UDim2.new(0,14,0.45,0)
    end)

    button("HIDE MENU",function()
        win.Visible = false
    end)

    info("Drag the F icon. Tap to open/close.")
end

-- =====================================
-- SIDEBAR
-- =====================================

local tabs = {}

for i, name in ipairs({
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
    local obj = new("TextButton",sidebar,{
        Size = UDim2.new(1,0,0,39),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        Text = name,
        TextSize = 13,
        TextColor3 = C.white,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = i
    })
    round(obj,8)

    tabs[name] = obj

    bind(obj.Activated,function()
        switch(name)
    end)
end

switch = function(name)
    currentTab = name
    clearBody()

    pages[name]()

    for key, obj in pairs(tabs) do
        obj.BackgroundColor3 =
            key == name
            and C.red
            or C.card
    end

    applyUI()
end

-- =====================================
-- DRAGGABLE UI
-- =====================================

local function drag(handle,target,tap)
    local activeInput = nil
    local start = nil
    local origin = nil
    local moved = false

    bind(handle.InputBegan,function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            activeInput = input
            start = input.Position
            origin = target.Position
            moved = false
        end
    end)

    bind(UIS.InputChanged,function(input)
        if not activeInput then return end

        local mouse =
            activeInput.UserInputType ==
                Enum.UserInputType.MouseButton1
            and input.UserInputType ==
                Enum.UserInputType.MouseMovement

        if input ~= activeInput
            and not mouse then

            return
        end

        local delta = input.Position - start

        if delta.Magnitude > 8 then
            moved = true
        end

        if moved then
            target.Position = UDim2.new(
                origin.X.Scale,
                origin.X.Offset + delta.X,
                origin.Y.Scale,
                origin.Y.Offset + delta.Y
            )
        end
    end)

    bind(UIS.InputEnded,function(input)
        if input ~= activeInput then
            return
        end

        activeInput = nil

        if not moved and tap then
            tap()
        end
    end)
end

drag(logo,logo,function()
    win.Visible = not win.Visible
end)

drag(header,win)

bind(close.Activated,function()
    win.Visible = false
end)

if workspace.CurrentCamera then
    bind(
        workspace.CurrentCamera:
            GetPropertyChangedSignal("ViewportSize"),
        applyUI
    )
end

-- =====================================
-- CLEANUP
-- =====================================

local cleaned = false

local function cleanup()
    if cleaned then return end
    cleaned = true

    active = false

    for key in pairs(state) do
        state[key] = false
    end

    heldInput = nil

    stopClick()
    stopFly()
    restoreCollisions()

    clearMarks(playerMarks)
    clearMarks(itemMarks)

    instant(false)
    setBright(false)

    for _, connection in ipairs(conns) do
        connection:Disconnect()
    end

    if gui.Parent then
        gui:Destroy()
    end
end

_G.FREAKHUB_CLEANUP = cleanup

bind(gui.Destroying,cleanup)

switch("Home")

print("FREAKHUB v2.2 FULL INTEGRATED LOADED")

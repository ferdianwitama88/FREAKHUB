
--[[
    FREAKHUB v2.3.1
    FULL INTEGRATED - MOBILE EDITION

    Tabs:
    Home, Player, ESP, Scanner, Results,
    Aim, Automation, Teleport, Utility

    Combat:
    Auto Click
    Keep Click
    Burst Click
    Tool / Screen / Hybrid
    Click Delay (ms)
    Swing Animation Speed
    Click Attempt Counter

    Note:
    Server-authoritative cooldowns and damage
    cannot be overridden by this client UI.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local LP = Players.LocalPlayer
if not LP then return end

local PG = LP:WaitForChild("PlayerGui")

-- =========================================
-- REMOVE PREVIOUS INSTANCE
-- =========================================

if type(_G.FREAKHUB_CLEANUP) == "function" then
    pcall(_G.FREAKHUB_CLEANUP)
end

for _, name in ipairs({
    "FREAKHUB_V20",
    "FREAKHUB_V22",
    "FREAKHUB_V23",
    "FREAKHUB_V231"
}) do
    local old = PG:FindFirstChild(name)
    if old then old:Destroy() end
end

-- =========================================
-- COLORS
-- =========================================

local C = {
    bg = Color3.fromRGB(13, 14, 20),
    panel = Color3.fromRGB(23, 25, 34),
    card = Color3.fromRGB(37, 39, 51),
    red = Color3.fromRGB(235, 52, 73),
    white = Color3.fromRGB(245, 246, 250),
    muted = Color3.fromRGB(170, 175, 190),
    green = Color3.fromRGB(75, 210, 145)
}

-- =========================================
-- CONFIG
-- =========================================

local cfg = {
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 55,
    mountSpeed = 65,

    scanRadius = 150,
    refreshTime = 2,

    clickMethod = "Tool",
    clickDelay = 150,
    burstCount = 5,
    burstGap = 1000,

    swingSpeed = 1,
    swingEnabled = false,

    auraRadius = 12,
    auraDelay = 0.5,

    actionRadius = 15,
    actionDelay = 1,
    actionMode = "Auto",

    aimFov = 180,
    aimSmooth = 0.15,

    uiSize = "Normal"
}

local state = {
    infJump = false,
    noclip = false,
    health = false,

    fly = false,
    mountFly = false,

    playerESP = false,
    itemESP = false,
    playerRefresh = true,
    itemRefresh = false,

    aim = false,
    aura = false,
    multi = false,

    instantPrompt = false,
    fullbright = false,

    autoClick = false,
    burstClick = false,
    keepButton = false,
    swingToggle = false
}

local connections = {}
local active = true
local cleaned = false

local playerMarks = {}
local itemMarks = {}
local scanResults = {}
local teleportSlots = {}

local savedCollisions = {}
local savedPrompts = {}

local clickAttempts = 0
local clickToken = 0
local heldInput = nil
local clickMode = "Idle"
local clickStatus = "Ready"
local clickSuccess = 0
local screenBlocked = true

local selectedTab = "Home"

local flyData = nil
local flyUp = 0
local flyForward = 0

local aimTarget = nil

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

-- =========================================
-- HELPERS
-- =========================================

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function create(className, parent, properties)
    local object = Instance.new(className)

    for key, value in pairs(properties or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function corner(object, radius)
    create("UICorner", object, {
        CornerRadius = UDim.new(0, radius or 8)
    })
end

local function humanoid()
    local character = LP.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function root()
    local character = LP.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function distance(position)
    local r = root()

    if not r then return math.huge end

    return (r.Position - position).Magnitude
end

local function getPosition(object)
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        return object:GetPivot().Position
    elseif object:IsA("Tool") then
        local handle = object:FindFirstChild("Handle")
        return handle and handle.Position
    end
end

local function equippedTool()
    local character = LP.Character

    return character and
        character:FindFirstChildOfClass("Tool")
end

-- =========================================
-- GUI
-- =========================================

local gui = create("ScreenGui", PG, {
    Name = "FREAKHUB_V231",
    ResetOnSpawn = false,
    DisplayOrder = 500
})

local logo = create("TextButton", gui, {
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.new(0, 14, 0.45, 0),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Text = "F",
    TextSize = 33,
    TextColor3 = C.red,
    Font = Enum.Font.GothamBlack,
    Active = true
})
corner(logo, 13)

create("UIGradient", logo, {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 35, 49)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 10, 16))
    })
})

local logoAccent = create("Frame", logo, {
    Size = UDim2.fromOffset(21, 3),
    Position = UDim2.new(0.5, -10, 1, -7),
    BorderSizePixel = 0,
    BackgroundColor3 = C.red
})
corner(logoAccent, 2)

create("UIStroke", logo, {
    Color = C.red,
    Thickness = 2
})

local window = create("Frame", gui, {
    Size = UDim2.fromOffset(390, 410),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Visible = false,
    Active = true
})
corner(window, 15)

create("UIStroke", window, {
    Color = C.card
})

local header = create("Frame", window, {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundTransparency = 1,
    Active = true
})

local function textLabel(parent, text, size, color)
    return create("TextLabel", parent, {
        Size = UDim2.new(1, 0, 0, 23),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = size or 13,
        TextColor3 = color or C.white,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
end

local title = textLabel(header, "FREAKHUB", 20)
title.Position = UDim2.fromOffset(14, 3)
title.Font = Enum.Font.GothamBlack

title.TextColor3 = C.white

local brandAccent = create("Frame", header, {
    Position = UDim2.fromOffset(15, 27),
    Size = UDim2.fromOffset(77, 2),
    BorderSizePixel = 0,
    BackgroundColor3 = C.red
})

local subtitle = textLabel(
    header,
    "UNIVERSAL  •  v2.3.1",
    11,
    C.red
)
subtitle.Position = UDim2.fromOffset(15, 32)

local close = create("TextButton", header, {
    Position = UDim2.new(1, -41, 0, 11),
    Size = UDim2.fromOffset(31, 31),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
    Text = "×",
    TextSize = 24,
    TextColor3 = C.white
})
corner(close, 8)

local sidebar = create("ScrollingFrame", window, {
    Position = UDim2.fromOffset(9, 60),
    Size = UDim2.new(0, 109, 1, -69),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})
corner(sidebar, 9)

create("UIPadding", sidebar, {
    PaddingTop = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 5),
    PaddingRight = UDim.new(0, 5),
    PaddingBottom = UDim.new(0, 6)
})

create("UIListLayout", sidebar, {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local body = create("ScrollingFrame", window, {
    Position = UDim2.fromOffset(125, 60),
    Size = UDim2.new(1, -135, 1, -69),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.red,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})

create("UIListLayout", body, {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local baseFonts = setmetatable({}, {
    __mode = "k"
})

local function applyUISize()
    local factor = ({
        Small = 1,
        Normal = 1.15,
        Large = 1.30
    })[cfg.uiSize] or 1.15

    for _, object in ipairs(gui:GetDescendants()) do
        if object:IsA("TextLabel")
            or object:IsA("TextButton")
            or object:IsA("TextBox") then

            if not baseFonts[object] then
                baseFonts[object] = object.TextSize
            end

            object.TextSize = math.max(
                12,
                math.floor(baseFonts[object] * factor + 0.5)
            )
        end
    end

    local camera = workspace.CurrentCamera

    if camera then
        local viewport = camera.ViewportSize

        local scale = ({
            Small = 0.93,
            Normal = 1,
            Large = 1.06
        })[cfg.uiSize] or 1

        window.Size = UDim2.fromOffset(
            math.min(390 * scale, viewport.X - 12),
            math.min(410 * scale, viewport.Y - 20)
        )
    end
end

local function clearBody()
    for _, object in ipairs(body:GetChildren()) do
        if object:IsA("GuiObject") then
            object:Destroy()
        end
    end
end

local function heading(value)
    local frame = create("Frame", body, {
        Size = UDim2.new(1, -3, 0, 31),
        BackgroundTransparency = 1
    })

    local label = textLabel(frame, value, 15)
    label.Position = UDim2.fromOffset(3, 4)
    label.Font = Enum.Font.GothamBold
end

local function info(value)
    local frame = create("Frame", body, {
        Size = UDim2.new(1, -3, 0, 49),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0
    })
    corner(frame, 8)

    local label = textLabel(frame, value, 11, C.muted)
    label.Position = UDim2.fromOffset(8, 4)
    label.Size = UDim2.new(1, -16, 1, -8)
    label.TextWrapped = true
    label.TextTruncate = Enum.TextTruncate.None
end

local function button(value, callback)
    local object = create("TextButton", body, {
        Size = UDim2.new(1, -3, 0, 39),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        Text = value,
        TextSize = 12,
        TextColor3 = C.white,
        Font = Enum.Font.GothamMedium
    })
    corner(object, 8)

    connect(object.Activated, callback)

    return object
end

local function row(value)
    local frame = create("Frame", body, {
        Size = UDim2.new(1, -3, 0, 42),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0
    })
    corner(frame, 8)

    local label = textLabel(frame, value, 11)
    label.Position = UDim2.fromOffset(8, 10)
    label.Size = UDim2.new(0.56, -8, 0, 22)

    return frame
end

local function toggle(value, key, callback)
    local frame = row(value)

    local control = create("TextButton", frame, {
        Position = UDim2.new(1, -66, 0, 7),
        Size = UDim2.fromOffset(59, 28),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        TextColor3 = C.white,
        TextSize = 11,
        Font = Enum.Font.GothamBold
    })
    corner(control, 7)

    local function repaint()
        control.Text = state[key] and "ON" or "OFF"
        control.BackgroundColor3 =
            state[key] and C.red or C.panel
    end

    connect(control.Activated, function()
        state[key] = not state[key]
        repaint()
        if callback then
            callback(state[key])
        end
    end)

    repaint()
end

local function numberRow(value, current, callback)
    local frame = row(value)

    local input = create("TextBox", frame, {
        Position = UDim2.new(1, -110, 0, 7),
        Size = UDim2.fromOffset(61, 28),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        Text = tostring(current),
        TextSize = 12,
        TextColor3 = C.white,
        ClearTextOnFocus = false
    })
    corner(input, 6)

    local set = create("TextButton", frame, {
        Position = UDim2.new(1, -46, 0, 7),
        Size = UDim2.fromOffset(39, 28),
        BackgroundColor3 = C.red,
        BorderSizePixel = 0,
        Text = "SET",
        TextSize = 11,
        TextColor3 = C.white
    })
    corner(set, 6)

    connect(set.Activated, function()
        local number = tonumber(input.Text)

        if number then
            callback(number)
        end
    end)
end

-- =========================================
-- UNIVERSAL SAFE CLICK ENGINE
-- =========================================
-- Native executor mouse functions are intentionally disabled:
-- pcall cannot catch a native executor crash.
-- Tool:Activate() is best effort, not a server hit guarantee.

local MIN_CLICK_MS = 100
local MIN_BURST_GAP_MS = 300
local MAX_BURST = 15
local lastClickMethod = "None"
local clickBusy = false

local function toolClick()
    local tool = equippedTool()
    if not tool or not tool.Enabled then
        return false
    end
    return pcall(function()
        tool:Activate()
    end)
end

local function performClick()
    if not active or clickBusy then return false end
    clickBusy = true
    clickAttempts = clickAttempts + 1

    local success = false
    if cfg.clickMethod == "Tool" or cfg.clickMethod == "Hybrid" then
        success = toolClick()
        lastClickMethod = success and "Tool" or "No equipped Tool"
    else
        -- Screen input is blocked in stable mode to avoid Delta crashes.
        lastClickMethod = "Screen disabled (safe mode)"
    end

    if success then clickSuccess = clickSuccess + 1 end
    clickBusy = false
    return success
end

local function waitMs(milliseconds)
    task.wait(math.max(MIN_CLICK_MS, milliseconds) / 1000)
end

local function stopClicker()
    clickToken = clickToken + 1
    state.autoClick = false
    state.burstClick = false
    clickMode = "Idle"
    heldInput = nil
    clickStatus = "Stopped"
end

local function startClicker(mode)
    stopClicker()
    if not active then return end
    clickMode = mode
    clickStatus = mode
    state.autoClick = mode == "Auto"
    state.burstClick = mode == "Burst"
    local token = clickToken

    task.spawn(function()
        local failures = 0
        while active and clickToken == token and clickMode == mode do
            if mode == "Hold" and not heldInput then break end

            local count = mode == "Burst"
                and math.clamp(cfg.burstCount, 1, MAX_BURST)
                or 1

            for _ = 1, count do
                if not active or clickToken ~= token or clickMode ~= mode then
                    break
                end
                if mode == "Hold" and not heldInput then break end

                if performClick() then
                    failures = 0
                else
                    failures = failures + 1
                end
                if failures >= 10 then break end
                waitMs(cfg.clickDelay)
            end

            if failures >= 10 then
                clickStatus = "Stopped: input unavailable"
                break
            end

            if mode == "Burst" then
                task.wait(math.max(cfg.burstGap, MIN_BURST_GAP_MS) / 1000)
            end
        end

        if clickToken == token then
            local status = clickStatus
            stopClicker()
            if status == "Stopped: input unavailable" then
                clickStatus = status
            end
        end
    end)
end

local function startAutoClick()
    startClicker("Auto")
end

local function startBurstClick()
    startClicker("Burst")
end

local function emergencyStop()
    stopClicker()
    state.aura = false
    state.multi = false
    state.swingToggle = false
    cfg.swingEnabled = false
    clickStatus = "EMERGENCY STOP"
end

-- =========================================
-- KEEP CLICK MOBILE BUTTON
-- =========================================

local holdButton = create("TextButton", gui, {
    Size = UDim2.fromOffset(125, 48),
    Position = UDim2.new(1, -138, 1, -235),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
    Text = "HOLD CLICK",
    TextSize = 13,
    TextColor3 = C.white,
    Font = Enum.Font.GothamBold,
    Visible = false,
    Active = true
})
corner(holdButton, 10)

connect(holdButton.InputBegan, function(input)
    if heldInput then return end
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        startClicker("Hold")
        heldInput = input
    end
end)

connect(UIS.InputEnded, function(input)
    if input == heldInput then
        stopClicker()
    end
end)

local emergencyButton = create("TextButton", gui, {
    Size = UDim2.fromOffset(125, 43),
    Position = UDim2.new(1, -138, 1, -283),
    BackgroundColor3 = Color3.fromRGB(170, 25, 46),
    BorderSizePixel = 0,
    Text = "STOP ALL",
    TextSize = 13,
    TextColor3 = C.white,
    Font = Enum.Font.GothamBold,
    Visible = true
})
corner(emergencyButton, 9)

connect(emergencyButton.Activated, function()
    emergencyStop()
end)

-- =========================================
-- SWING ANIMATION SPEED
-- =========================================

local savedTrackSpeeds = setmetatable({}, {
    __mode = "k"
})

local function applySwingSpeed()
    local h = humanoid()
    if not h then return end

    local animator = h:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(
        animator:GetPlayingAnimationTracks()
    ) do
        local name = string.lower(track.Name or "")

        local animation = track.Animation
        local animationName = animation
            and string.lower(animation.Name)
            or ""

        local isSwing =
            string.find(name, "swing", 1, true)
            or string.find(name, "attack", 1, true)
            or string.find(name, "hit", 1, true)
            or string.find(name, "slash", 1, true)
            or string.find(name, "tool", 1, true)
            or string.find(animationName, "swing", 1, true)
            or string.find(animationName, "attack", 1, true)
            or string.find(animationName, "hit", 1, true)

        if isSwing then
            if cfg.swingEnabled then
                if savedTrackSpeeds[track] == nil then
                    savedTrackSpeeds[track] = 1
                end

                pcall(function()
                    track:AdjustSpeed(cfg.swingSpeed)
                end)
            elseif savedTrackSpeeds[track] ~= nil then
                pcall(function()
                    track:AdjustSpeed(savedTrackSpeeds[track])
                end)

                savedTrackSpeeds[track] = nil
            end
        end
    end
end

-- =========================================
-- PLAYER FEATURES
-- =========================================

local function applyMovement()
    local h = humanoid()
    if not h then return end

    pcall(function()
        h.WalkSpeed = cfg.walkSpeed
        h.UseJumpPower = true
        h.JumpPower = cfg.jumpPower
    end)
end

connect(LP.CharacterAdded, function(character)
    character:WaitForChild("Humanoid", 10)
    task.defer(applyMovement)
end)

connect(UIS.JumpRequest, function()
    if state.infJump then
        local h = humanoid()

        if h then
            h:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
end)

local function restoreCollision()
    for part, value in pairs(savedCollisions) do
        if part.Parent then
            pcall(function()
                part.CanCollide = value
            end)
        end
    end

    table.clear(savedCollisions)
end

connect(Run.Stepped, function()
    if not state.noclip then return end

    local character = LP.Character
    if not character then return end

    for _, part in ipairs(
        character:GetDescendants()
    ) do
        if part:IsA("BasePart") then
            if savedCollisions[part] == nil then
                savedCollisions[part] = part.CanCollide
            end

            part.CanCollide = false
        end
    end
end)

connect(Run.Heartbeat, function()
    if not state.health then return end

    local h = humanoid()

    if h and h.Health > 0
        and h.Health < h.MaxHealth then

        pcall(function()
            h.Health = h.MaxHealth
        end)
    end
end)

-- =========================================
-- FLY
-- =========================================

local function stopFly()
    if flyData then
        for _, object in ipairs(flyData.objects) do
            if object.Parent then
                object:Destroy()
            end
        end
    end

    flyData = nil
    flyUp = 0
    flyForward = 0
end

local function beginFly(part, mode)
    stopFly()

    if not part or not part:IsA("BasePart") then
        return false
    end

    local attachment = create("Attachment", part, {
        Name = "FH_FlyAttachment"
    })

    local velocity = create("LinearVelocity", part, {
        Name = "FH_FlyVelocity",
        Attachment0 = attachment,
        RelativeTo = Enum.ActuatorRelativeTo.World,
        VelocityConstraintMode =
            Enum.VelocityConstraintMode.Vector,
        VectorVelocity = Vector3.zero,
        ForceLimitsEnabled = false
    })

    local orientation = create("AlignOrientation", part, {
        Name = "FH_FlyOrientation",
        Attachment0 = attachment,
        Mode =
            Enum.OrientationAlignmentMode.OneAttachment,
        MaxTorque = 1e9,
        Responsiveness = 15
    })

    flyData = {
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

    if not h or not h.SeatPart then
        return nil
    end

    local seat = h.SeatPart
    local model = seat:FindFirstAncestorOfClass("Model")

    return model and model.PrimaryPart or seat
end

local flyControls = create("Frame", gui, {
    Size = UDim2.fromOffset(184, 115),
    Position = UDim2.new(1, -194, 1, -170),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Visible = false
})
corner(flyControls, 10)

local function flyControl(text, x, y, axis, value)
    local control = create("TextButton", flyControls, {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(83, 46),
        BackgroundColor3 = C.red,
        BorderSizePixel = 0,
        Text = text,
        TextSize = 12,
        TextColor3 = C.white
    })
    corner(control, 8)

    local inputs = {}

    connect(control.InputBegan, function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            inputs[input] = true

            if axis == "up" then
                flyUp = value
            else
                flyForward = value
            end
        end
    end)

    connect(UIS.InputEnded, function(input)
        if inputs[input] then
            inputs[input] = nil

            if axis == "up" then
                flyUp = 0
            else
                flyForward = 0
            end
        end
    end)
end

flyControl("UP", 7, 8, "up", 1)
flyControl("FORWARD", 94, 8, "forward", 1)
flyControl("DOWN", 7, 60, "up", -1)
flyControl("BACK", 94, 60, "forward", -1)

connect(Run.Heartbeat, function()
    local flight = flyData
    if not flight then return end

    local valid =
        flight.part.Parent
        and (
            (flight.mode == "player" and state.fly)
            or
            (flight.mode == "mount" and state.mountFly)
        )

    if not valid then
        state.fly = false
        state.mountFly = false
        flyControls.Visible = false
        stopFly()
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local look = camera.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)

    if flat.Magnitude > 0.01 then
        flat = flat.Unit
    else
        flat = Vector3.new(0, 0, -1)
    end

    local h = humanoid()

    local movement = h
        and h.MoveDirection
        or Vector3.zero

    local speed = flight.mode == "mount"
        and cfg.mountSpeed
        or cfg.flySpeed

    flight.velocity.VectorVelocity =
        movement * speed
        + flat * flyForward * speed
        + Vector3.new(0, flyUp * speed, 0)

    flight.orientation.CFrame =
        CFrame.lookAt(Vector3.zero, flat)
end)

-- =========================================
-- ESP
-- =========================================

local function removeMark(mark)
    if not mark then return end

    if mark.highlight then
        mark.highlight:Destroy()
    end

    if mark.billboard then
        mark.billboard:Destroy()
    end
end

local function clearMarks(marks)
    for _, mark in pairs(marks) do
        removeMark(mark)
    end

    table.clear(marks)
end

local function makeMark(target, name, color)
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
                "BasePart", true
            )
    end

    if not part then return nil end

    local highlight = create("Highlight", workspace, {
        Adornee = target,
        FillColor = color,
        OutlineColor = C.white,
        FillTransparency = 0.75,
        OutlineTransparency = 0,
        DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop
    })

    local billboard = create("BillboardGui", gui, {
        Adornee = part,
        Size = UDim2.fromOffset(160, 42),
        StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = true,
        MaxDistance = 500
    })

    local nameLabel = textLabel(
        billboard,
        name,
        12,
        C.white
    )

    nameLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    nameLabel.TextStrokeTransparency = 0.1

    local distanceLabel = textLabel(
        billboard,
        "",
        10,
        color
    )

    distanceLabel.Position =
        UDim2.fromOffset(0, 23)

    distanceLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    distanceLabel.TextStrokeTransparency = 0.1

    return {
        target = target,
        part = part,
        highlight = highlight,
        billboard = billboard,
        distanceLabel = distanceLabel
    }
end

local function refreshPlayerESP()
    if not state.playerESP then
        clearMarks(playerMarks)
        return
    end

    for player, mark in pairs(playerMarks) do
        if not player.Parent
            or player.Character ~= mark.target
            or not mark.part.Parent then

            removeMark(mark)
            playerMarks[player] = nil
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
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

local itemWords = {
    "egg", "coin", "gem", "loot",
    "chest", "treasure", "collect",
    "pickup", "item", "ore", "rock",
    "mine", "dig", "reward", "drop"
}

local function containsItemWord(name)
    name = string.lower(name)

    for _, word in ipairs(itemWords) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return false
end

local function belongsToCharacter(object)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character
            and object:IsDescendantOf(
                player.Character
            ) then

            return true
        end
    end

    return false
end

local function scanItems()
    table.clear(scanResults)

    local seen = {}

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do
        if #scanResults >= 120 then break end

        if (
            object:IsA("BasePart")
            or object:IsA("Model")
            or object:IsA("Tool")
        )
            and containsItemWord(object.Name)
            and not belongsToCharacter(object) then

            local position = getPosition(object)

            if position
                and not seen[object]
                and distance(position) <= cfg.scanRadius then

                seen[object] = true

                table.insert(scanResults, {
                    object = object,
                    name = object.Name,
                    distance = math.floor(
                        distance(position)
                    )
                })
            end
        end
    end

    table.sort(scanResults, function(a, b)
        return a.distance < b.distance
    end)
end

local function refreshItemESP()
    clearMarks(itemMarks)

    if not state.itemESP then return end

    for _, result in ipairs(scanResults) do
        local object = result.object

        if object and object.Parent then
            local mark = makeMark(
                object,
                result.name,
                C.green
            )

            if mark then
                table.insert(itemMarks, mark)
            end
        end
    end
end

local function updateMarkDistances(marks)
    for _, mark in pairs(marks) do
        if mark.part
            and mark.part.Parent
            and mark.distanceLabel then

            mark.distanceLabel.Text =
                math.floor(
                    distance(mark.part.Position)
                ) .. " studs"
        end
    end
end

-- =========================================
-- NPC TARGET LOCK
-- =========================================

local function isNPC(model)
    if not model
        or not model:IsA("Model")
        or Players:GetPlayerFromCharacter(model) then

        return false
    end

    local h = model:FindFirstChildOfClass("Humanoid")

    return h ~= nil and h.Health > 0
end

local function npcPart(model)
    if not isNPC(model) then return nil end

    return model:FindFirstChild("Head")
        or model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

local function findNPC()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local best = nil
    local bestDistance = cfg.aimFov

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do
        if object:IsA("Model")
            and isNPC(object) then

            local part = npcPart(object)

            if part then
                local point, visible =
                    camera:WorldToViewportPoint(
                        part.Position
                    )

                if visible then
                    local d = (
                        Vector2.new(point.X, point.Y)
                        - center
                    ).Magnitude

                    if d < bestDistance then
                        bestDistance = d
                        best = object
                    end
                end
            end
        end
    end

    return best
end

connect(Run.RenderStepped, function(dt)
    if not state.aim then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    if not npcPart(aimTarget) then
        aimTarget = findNPC()
    end

    local part = npcPart(aimTarget)
    if not part then return end

    local current = camera.CFrame

    local desired = CFrame.lookAt(
        current.Position,
        part.Position
    )

    local alpha = 1 - math.pow(
        1 - cfg.aimSmooth,
        dt * 60
    )

    camera.CFrame = current:Lerp(
        desired,
        alpha
    )
end)

-- =========================================
-- AURA / MULTI ACTION
-- =========================================

local function nearestNPC(radius)
    local best = nil
    local bestDistance = radius

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do
        if object:IsA("Model")
            and isNPC(object) then

            local part = npcPart(object)

            if part then
                local d = distance(part.Position)

                if d < bestDistance then
                    bestDistance = d
                    best = object
                end
            end
        end
    end

    return best
end

local function auraTick()
    if state.aura
        and nearestNPC(cfg.auraRadius) then

        toolClick()
    end
end

local function promptMatches(prompt)
    if cfg.actionMode == "Auto" then
        return true
    end

    local value = string.lower(
        prompt.Name .. " " ..
        prompt.ActionText .. " " ..
        prompt.ObjectText
    )

    local keywords = {
        Collect = {"collect", "take", "pickup", "grab"},
        Dig = {"dig", "shovel"},
        Mine = {"mine", "rock", "ore"},
        Interact = {"interact", "open", "use"}
    }

    for _, word in ipairs(
        keywords[cfg.actionMode] or {}
    ) do
        if string.find(value, word, 1, true) then
            return true
        end
    end

    return false
end

local promptBusy = {}

local function multiTick()
    if not state.multi then return end

    local count = 0

    for _, prompt in ipairs(
        workspace:GetDescendants()
    ) do
        if count >= 5 then break end

        if prompt:IsA("ProximityPrompt")
            and prompt.Enabled
            and not promptBusy[prompt]
            and promptMatches(prompt) then

            local parent = prompt.Parent
            local position = parent and getPosition(parent)

            if position
                and distance(position) <= math.min(
                    cfg.actionRadius,
                    prompt.MaxActivationDistance
                ) then

                count = count + 1
                promptBusy[prompt] = true

                pcall(function()
                    prompt:InputHoldBegin()
                end)

                task.delay(
                    math.max(prompt.HoldDuration, 0.05),
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

-- =========================================
-- UTILITY
-- =========================================

local function setFullbright(enabled)
    if enabled then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        for key, value in pairs(originalLighting) do
            Lighting[key] = value
        end
    end
end

local function setInstantPrompt(enabled)
    if enabled then
        for _, prompt in ipairs(
            workspace:GetDescendants()
        ) do
            if prompt:IsA("ProximityPrompt") then
                if savedPrompts[prompt] == nil then
                    savedPrompts[prompt] =
                        prompt.HoldDuration
                end

                prompt.HoldDuration = 0
            end
        end
    else
        for prompt, value in pairs(savedPrompts) do
            if prompt.Parent then
                pcall(function()
                    prompt.HoldDuration = value
                end)
            end
        end

        table.clear(savedPrompts)
    end
end

-- =========================================
-- AUTOMATIC UPDATE LOOP
-- =========================================

local playerTimer = 0
local itemTimer = 0
local auraTimer = 0
local actionTimer = 0
local swingTimer = 0

connect(Run.Heartbeat, function(dt)
    if not active then return end

    playerTimer = playerTimer + dt
    itemTimer = itemTimer + dt
    auraTimer = auraTimer + dt
    actionTimer = actionTimer + dt
    swingTimer = swingTimer + dt

    if playerTimer >= cfg.refreshTime then
        playerTimer = 0

        if state.playerESP
            and state.playerRefresh then

            refreshPlayerESP()
        end

        updateMarkDistances(playerMarks)
        updateMarkDistances(itemMarks)
    end

    if itemTimer >= math.max(cfg.refreshTime, 2) then
        itemTimer = 0

        if state.itemESP
            and state.itemRefresh then

            scanItems()
            refreshItemESP()
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

    if swingTimer >= 0.1 then
        swingTimer = 0

        if cfg.swingEnabled then
            applySwingSpeed()
        end
    end
end)

-- =========================================
-- PAGES
-- =========================================

local pages = {}
local switch

pages.Home = function()
    heading("Dashboard")

    info("FREAKHUB v2.3.1 | Universal Stable Edition")

    info("Player: " .. LP.Name)

    button("COMBAT CONTROL", function()
        switch("Automation")
    end)

    button("PLAYER SETTINGS", function()
        switch("Player")
    end)

    button("ESP CENTER", function()
        switch("ESP")
    end)
end

pages.Player = function()
    heading("Player Control")

    toggle("Infinite Jump", "infJump")

    toggle("Noclip", "noclip", function(on)
        if not on then
            restoreCollision()
        end
    end)

    toggle("Infinite Health", "health")

    numberRow(
        "Walk Speed",
        cfg.walkSpeed,
        function(value)
            cfg.walkSpeed = math.clamp(value, 16, 200)
            applyMovement()
        end
    )

    numberRow(
        "Jump Power",
        cfg.jumpPower,
        function(value)
            cfg.jumpPower = math.clamp(value, 50, 200)
            applyMovement()
        end
    )

    heading("Flight")

    toggle("Fly", "fly", function(on)
        if on then
            state.mountFly = false
            state.fly = beginFly(root(), "player")
        else
            stopFly()
        end

        flyControls.Visible =
            state.fly or state.mountFly

        switch("Player")
    end)

    numberRow(
        "Fly Speed",
        cfg.flySpeed,
        function(value)
            cfg.flySpeed = math.clamp(value, 10, 200)
        end
    )

    toggle("Mount Fly", "mountFly", function(on)
        if on then
            state.fly = false
            state.mountFly = beginFly(
                getMountPart(),
                "mount"
            )
        else
            stopFly()
        end

        flyControls.Visible =
            state.fly or state.mountFly

        switch("Player")
    end)

    numberRow(
        "Mount Speed",
        cfg.mountSpeed,
        function(value)
            cfg.mountSpeed = math.clamp(value, 10, 200)
        end
    )

    button("STOP FLIGHT", function()
        state.fly = false
        state.mountFly = false

        stopFly()
        flyControls.Visible = false

        switch("Player")
    end)
end

pages.ESP = function()
    heading("ESP Center")

    toggle(
        "Player ESP",
        "playerESP",
        refreshPlayerESP
    )

    toggle(
        "Player Auto Refresh",
        "playerRefresh"
    )

    toggle("Item ESP", "itemESP", function(on)
        if on then
            scanItems()
        end

        refreshItemESP()
    end)

    toggle(
        "Item Auto Refresh",
        "itemRefresh"
    )

    numberRow(
        "Refresh (sec)",
        cfg.refreshTime,
        function(value)
            cfg.refreshTime =
                math.clamp(value, 0.5, 10)
        end
    )

    button("REFRESH ALL ESP", function()
        refreshPlayerESP()
        scanItems()
        refreshItemESP()
    end)

    button("CLEAR ESP", function()
        state.playerESP = false
        state.itemESP = false

        clearMarks(playerMarks)
        clearMarks(itemMarks)

        switch("ESP")
    end)
end

pages.Scanner = function()
    heading("Universal Scanner")

    numberRow(
        "Scan Radius",
        cfg.scanRadius,
        function(value)
            cfg.scanRadius =
                math.clamp(value, 25, 500)
        end
    )

    button("SCAN ITEMS", function()
        scanItems()
        refreshItemESP()
        switch("Results")
    end)

    toggle(
        "Instant Prompt",
        "instantPrompt",
        setInstantPrompt
    )
end

pages.Results = function()
    heading("Scan Results")

    info("Found: " .. #scanResults .. " candidates")

    button("SCAN AGAIN", function()
        scanItems()
        switch("Results")
    end)

    for i, result in ipairs(scanResults) do
        if i > 40 then break end

        button(
            result.name ..
            " | " ..
            result.distance ..
            " studs",
            function()
                local object = result.object

                if object and object.Parent then
                    local mark = makeMark(
                        object,
                        result.name,
                        C.green
                    )

                    if mark then
                        table.insert(itemMarks, mark)
                    end
                end
            end
        )
    end
end

pages.Aim = function()
    heading("NPC Target Lock")

    toggle("Target Lock", "aim", function(on)
        aimTarget = on and findNPC() or nil
    end)

    numberRow(
        "Aim FOV",
        cfg.aimFov,
        function(value)
            cfg.aimFov = math.clamp(value, 40, 500)
        end
    )

    numberRow(
        "Smooth %",
        cfg.aimSmooth * 100,
        function(value)
            cfg.aimSmooth = math.clamp(
                value / 100,
                0.01,
                1
            )
        end
    )

    button("FIND NPC", function()
        aimTarget = findNPC()
    end)

    button("UNLOCK TARGET", function()
        state.aim = false
        aimTarget = nil
        switch("Aim")
    end)

    info("NPC/dummy targeting only.")
end

-- =========================================
-- AUTOMATION + COMBAT CONTROL
-- =========================================

pages.Automation = function()
    heading("Combat Control")

    info(
        "Swing speed changes animations. " ..
        "Actual hit speed depends on the game."
    )

    toggle(
        "Swing Speed",
        "swingToggle",
        function(on)
            cfg.swingEnabled = on
            applySwingSpeed()
        end
    )

    numberRow(
        "Swing Speed (x)",
        cfg.swingSpeed,
        function(value)
            cfg.swingSpeed =
                math.clamp(value, 0.5, 10)

            applySwingSpeed()
        end
    )

    heading("Auto Clicker")
    info("Status: " .. clickStatus .. " | Minimum delay: 100 ms")

    button(
        "CLICK METHOD: " .. cfg.clickMethod,
        function()
            local methods = {
                "Tool",
                "Hybrid",
                "Screen"
            }

            for i, method in ipairs(methods) do
                if method == cfg.clickMethod then
                    cfg.clickMethod =
                        methods[i % #methods + 1]
                    break
                end
            end

            switch("Automation")
        end
    )

    toggle(
        "Auto Click",
        "autoClick",
        function(on)
            if on then
                startAutoClick()
            else
                stopClicker()
            end

            switch("Automation")
        end
    )

    toggle(
        "Burst Click",
        "burstClick",
        function(on)
            if on then
                startBurstClick()
            else
                stopClicker()
            end

            switch("Automation")
        end
    )

    toggle(
        "Keep Click Button",
        "keepButton",
        function(on)
            holdButton.Visible = on

            if not on then
                heldInput = nil
                clickToken = clickToken + 1
            end
        end
    )

    numberRow(
        "Click Delay (ms)",
        cfg.clickDelay,
        function(value)
            cfg.clickDelay = math.clamp(
                math.floor(value),
                MIN_CLICK_MS,
                60000
            )
        end
    )

    numberRow(
        "Burst Count",
        cfg.burstCount,
        function(value)
            cfg.burstCount = math.clamp(
                math.floor(value),
                1,
                MAX_BURST
            )
        end
    )

    numberRow(
        "Burst Gap (ms)",
        cfg.burstGap,
        function(value)
            cfg.burstGap = math.clamp(
                math.floor(value),
                MIN_BURST_GAP_MS,
                60000
            )
        end
    )

    button(
        "CLICK ATTEMPTS: " .. clickAttempts .. " | TOOL CALLS: " .. clickSuccess,
        function()
            switch("Automation")
        end
    )

    button(
        "LAST METHOD: " .. lastClickMethod,
        function()
            switch("Automation")
        end
    )

    button("RESET CLICK COUNTER", function()
        clickAttempts = 0
        clickSuccess = 0
        switch("Automation")
    end)

    button("TEST ONE CLICK", function()
        performClick()
        switch("Automation")
    end)

    heading("Aura Hit")

    toggle("Aura Hit (NPC)", "aura")

    numberRow(
        "Aura Radius",
        cfg.auraRadius,
        function(value)
            cfg.auraRadius =
                math.clamp(value, 5, 40)
        end
    )

    numberRow(
        "Aura Delay (s)",
        cfg.auraDelay,
        function(value)
            cfg.auraDelay =
                math.clamp(value, 0.2, 5)
        end
    )

    heading("Multi Action")

    toggle("Multi Action", "multi")

    button(
        "MODE: " .. cfg.actionMode,
        function()
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
        end
    )

    numberRow(
        "Action Radius",
        cfg.actionRadius,
        function(value)
            cfg.actionRadius =
                math.clamp(value, 3, 50)
        end
    )

    numberRow(
        "Action Delay (s)",
        cfg.actionDelay,
        function(value)
            cfg.actionDelay =
                math.clamp(value, 0.5, 10)
        end
    )

    button("EMERGENCY STOP ALL", function()
        emergencyStop()
        applySwingSpeed()

        switch("Automation")
    end)

    info(
        "Stable mode: Tool clicks only. Screen input is disabled to avoid executor crashes. Calls do not equal confirmed hits."
    )
end

-- =========================================
-- TELEPORT
-- =========================================

pages.Teleport = function()
    heading("Teleport Slots")

    for i = 1, 5 do
        local index = i
        local frame = row("Slot " .. i)

        local save = create("TextButton", frame, {
            Position = UDim2.new(1, -104, 0, 7),
            Size = UDim2.fromOffset(47, 28),
            BackgroundColor3 = C.red,
            BorderSizePixel = 0,
            Text = "SAVE",
            TextSize = 11,
            TextColor3 = C.white
        })
        corner(save, 6)

        local go = create("TextButton", frame, {
            Position = UDim2.new(1, -52, 0, 7),
            Size = UDim2.fromOffset(45, 28),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            Text = "GO",
            TextSize = 11,
            TextColor3 = C.white
        })
        corner(go, 6)

        connect(save.Activated, function()
            local r = root()

            if r then
                teleportSlots[index] = r.CFrame
            end
        end)

        connect(go.Activated, function()
            if teleportSlots[index]
                and LP.Character then

                LP.Character:PivotTo(
                    teleportSlots[index]
                )
            end
        end)
    end

    button("CLEAR ALL SLOTS", function()
        table.clear(teleportSlots)
    end)
end

-- =========================================
-- UTILITY
-- =========================================

pages.Utility = function()
    heading("Utility")

    toggle(
        "Fullbright",
        "fullbright",
        setFullbright
    )

    button(
        "UI SIZE: " .. cfg.uiSize,
        function()
            cfg.uiSize = ({
                Small = "Normal",
                Normal = "Large",
                Large = "Small"
            })[cfg.uiSize]

            switch("Utility")
        end
    )

    button("RESET LOGO POSITION", function()
        logo.Position =
            UDim2.new(0, 14, 0.45, 0)
    end)

    button("HIDE MENU", function()
        window.Visible = false
    end)

    info("Tap or drag the floating F icon.")
end

-- =========================================
-- SIDEBAR
-- =========================================

local tabs = {}

local tabNames = {
    "Home",
    "Player",
    "ESP",
    "Scanner",
    "Results",
    "Aim",
    "Automation",
    "Teleport",
    "Utility"
}

for i, name in ipairs(tabNames) do
    local tab = create("TextButton", sidebar, {
        Size = UDim2.new(1, 0, 0, 39),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        Text = name,
        TextSize = 12,
        TextColor3 = C.white,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = i
    })
    corner(tab, 8)

    tabs[name] = tab

    connect(tab.Activated, function()
        switch(name)
    end)
end

switch = function(name)
    selectedTab = name

    clearBody()

    if pages[name] then
        pages[name]()
    end

    for tabName, object in pairs(tabs) do
        object.BackgroundColor3 =
            tabName == name and C.red or C.card
    end

    applyUISize()
end

-- =========================================
-- DRAGGABLE UI
-- =========================================

local function draggable(handle, target, tapCallback)
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    local moved = false

    connect(handle.InputBegan, function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragInput = input
            dragStart = input.Position
            startPosition = target.Position
            moved = false
        end
    end)

    connect(UIS.InputChanged, function(input)
        if not dragInput then return end

        local isMouse =
            dragInput.UserInputType ==
                Enum.UserInputType.MouseButton1
            and input.UserInputType ==
                Enum.UserInputType.MouseMovement

        if input ~= dragInput and not isMouse then
            return
        end

        local delta = input.Position - dragStart

        if delta.Magnitude > 8 then
            moved = true
        end

        if moved then
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    connect(UIS.InputEnded, function(input)
        if input ~= dragInput then return end

        dragInput = nil

        if not moved and tapCallback then
            tapCallback()
        end
    end)
end

draggable(logo, logo, function()
    window.Visible = not window.Visible
end)

draggable(header, window)

connect(close.Activated, function()
    window.Visible = false
end)

-- =========================================
-- CLEANUP
-- =========================================

local function cleanup()
    if cleaned then return end
    cleaned = true

    active = false

    stopClicker()
    stopFly()

    restoreCollision()

    clearMarks(playerMarks)
    clearMarks(itemMarks)

    setInstantPrompt(false)
    setFullbright(false)

    cfg.swingEnabled = false
    applySwingSpeed()

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    if gui.Parent then
        gui:Destroy()
    end
end

_G.FREAKHUB_CLEANUP = cleanup

connect(gui.Destroying, cleanup)

-- =========================================
-- START
-- =========================================

switch("Home")

print("FREAKHUB v2.3.1 UNIVERSAL STABLE LOADED")

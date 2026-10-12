
--[[
 FREAKHUB v1.9 UNIVERSAL
 Compact Mobile UI
 Player / Fly / Mount Fly
 Player ESP + Name Tags
 Item ESP + Name Tags
 Universal Scanner
 Training Target Lock
 Teleport / Utility

 Target Lock requires CollectionService tag:
 "FreakHubTarget"
 on training dummy models.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local PromptService = game:GetService("ProximityPromptService")

local LP = Players.LocalPlayer
if not LP then return end

local PG = LP:WaitForChild("PlayerGui")

-- Remove older FREAKHUB interfaces
for _, name in ipairs({
    "FREAKHUB_V17",
    "FREAKHUB_V18",
    "FREAKHUB_V19",
    "FREAKHUB_UNIVERSAL"
}) do
    local old = PG:FindFirstChild(name)
    if old then old:Destroy() end
end

local C = {
    bg = Color3.fromRGB(12,13,19),
    panel = Color3.fromRGB(22,24,33),
    card = Color3.fromRGB(30,33,43),
    red = Color3.fromRGB(233,52,73),
    white = Color3.fromRGB(242,243,248),
    muted = Color3.fromRGB(151,156,172),
    green = Color3.fromRGB(75,205,144)
}

local alive = true
local connections = {}
local playerMarks = {}
local itemMarks = {}
local results = {}
local slots = {}
local originalPrompts = {}
local noclipParts = {}

local states = {
    infinite = false,
    noclip = false,
    fly = false,
    mountFly = false,
    playerESP = false,
    itemESP = false,
    instant = false,
    fullbright = false,
    aim = false
}

local speed = 16
local jump = 50
local flySpeed = 55
local mountSpeed = 65
local radius = 150
local filter = ""

local aimRadius = 160
local aimSmooth = 0.16
local aimPart = "Head"
local lockedTarget = nil

local vertical = 0
local activeFly = nil

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function new(class, parent, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radiusValue)
    new("UICorner", obj, {
        CornerRadius = UDim.new(0, radiusValue or 9)
    })
end

local function label(parent, value, size, color)
    return new("TextLabel", parent, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,20),
        Text = value,
        TextColor3 = color or C.white,
        TextSize = size or 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
end

local function hum()
    local character = LP.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function root()
    local character = LP.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- GUI

local gui = new("ScreenGui", PG, {
    Name = "FREAKHUB_V19",
    ResetOnSpawn = false,
    DisplayOrder = 500
})

local logo = new("TextButton", gui, {
    Name = "FloatingF",
    Size = UDim2.fromOffset(54,54),
    Position = UDim2.new(0,14,0.45,0),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Text = "F",
    TextSize = 32,
    Font = Enum.Font.GothamBlack,
    TextColor3 = C.red,
    Active = true,
    AutoButtonColor = false
})
round(logo,17)
new("UIStroke",logo,{
    Color=C.red,
    Thickness=2
})

local window = new("Frame",gui,{
    Size=UDim2.fromOffset(390,400),
    Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    Visible=false,
    Active=true
})
round(window,16)
new("UIStroke",window,{Color=C.card})

local header = new("Frame",window,{
    Size=UDim2.new(1,0,0,55),
    BackgroundTransparency=1,
    Active=true
})

local title = label(header,"FREAKHUB",18)
title.Position=UDim2.fromOffset(15,5)
title.Size=UDim2.new(1,-60,0,26)
title.Font=Enum.Font.GothamBold

local subtitle=label(
    header,
    "UNIVERSAL  •  v1.9",
    10,
    C.red
)
subtitle.Position=UDim2.fromOffset(16,31)

local close=new("TextButton",header,{
    Size=UDim2.fromOffset(31,31),
    Position=UDim2.new(1,-41,0,12),
    BackgroundColor3=C.red,
    BorderSizePixel=0,
    Text="×",
    TextColor3=C.white,
    TextSize=23
})
round(close,9)

local sidebar=new("ScrollingFrame",window,{
    Position=UDim2.fromOffset(10,60),
    Size=UDim2.new(0,106,1,-70),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
    ScrollBarThickness=0,
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    CanvasSize=UDim2.new()
})
round(sidebar,12)

new("UIPadding",sidebar,{
    PaddingTop=UDim.new(0,7),
    PaddingLeft=UDim.new(0,5),
    PaddingRight=UDim.new(0,5)
})

new("UIListLayout",sidebar,{
    Padding=UDim.new(0,5),
    SortOrder=Enum.SortOrder.LayoutOrder
})

local body=new("ScrollingFrame",window,{
    Position=UDim2.fromOffset(124,60),
    Size=UDim2.new(1,-134,1,-70),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=2,
    ScrollBarImageColor3=C.red,
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    CanvasSize=UDim2.new()
})

new("UIListLayout",body,{
    Padding=UDim.new(0,5),
    SortOrder=Enum.SortOrder.LayoutOrder
})

local function wipe()
    for _,o in ipairs(body:GetChildren()) do
        if o:IsA("GuiObject") then
            o:Destroy()
        end
    end
end

local function heading(value)
    local frame=new("Frame",body,{
        Size=UDim2.new(1,-3,0,27),
        BackgroundTransparency=1
    })

    local t=label(frame,value,14)
    t.Font=Enum.Font.GothamBold
    t.Position=UDim2.fromOffset(3,2)
end

local function info(value)
    local frame=new("Frame",body,{
        Size=UDim2.new(1,-3,0,39),
        BackgroundColor3=C.panel,
        BorderSizePixel=0
    })
    round(frame,8)

    local t=label(frame,value,10,C.muted)
    t.Position=UDim2.fromOffset(8,4)
    t.Size=UDim2.new(1,-16,1,-8)
    t.TextWrapped=true
    t.TextTruncate=Enum.TextTruncate.None
end

local function button(value,callback)
    local b=new("TextButton",body,{
        Size=UDim2.new(1,-3,0,31),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
        Text=value,
        TextColor3=C.white,
        TextSize=11,
        Font=Enum.Font.GothamMedium
    })
    round(b,8)
    connect(b.Activated,callback)
    return b
end

local function row(value)
    local frame=new("Frame",body,{
        Size=UDim2.new(1,-3,0,35),
        BackgroundColor3=C.card,
        BorderSizePixel=0
    })
    round(frame,8)

    local t=label(frame,value,11)
    t.Position=UDim2.fromOffset(9,7)
    t.Size=UDim2.new(.55,-9,0,20)

    return frame
end

local function toggle(value,key,callback)
    local frame=row(value)

    local b=new("TextButton",frame,{
        Position=UDim2.new(1,-66,0,5),
        Size=UDim2.fromOffset(59,25),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        TextColor3=C.white,
        TextSize=10,
        Font=Enum.Font.GothamBold
    })
    round(b,7)

    local function refresh()
        b.Text=states[key] and "ON" or "OFF"
        b.BackgroundColor3=
            states[key] and C.red or C.panel
    end

    connect(b.Activated,function()
        states[key]=not states[key]
        if callback then
            callback(states[key])
        end
        refresh()
    end)

    refresh()
end

local function numberRow(value,current,callback)
    local frame=row(value)

    local input=new("TextBox",frame,{
        Position=UDim2.new(1,-105,0,5),
        Size=UDim2.fromOffset(52,25),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        Text=tostring(current),
        TextColor3=C.white,
        TextSize=11,
        ClearTextOnFocus=false
    })
    round(input,6)

    local set=new("TextButton",frame,{
        Position=UDim2.new(1,-49,0,5),
        Size=UDim2.fromOffset(42,25),
        BackgroundColor3=C.red,
        BorderSizePixel=0,
        Text="SET",
        TextColor3=C.white,
        TextSize=10
    })
    round(set,6)

    connect(set.Activated,function()
        callback(tonumber(input.Text))
    end)

    return input
end

-- PLAYER

local function applyPlayer()
    local h=hum()
    if h then
        h.WalkSpeed=speed
        h.UseJumpPower=true
        h.JumpPower=jump
    end
end

connect(LP.CharacterAdded,function(character)
    character:WaitForChild("Humanoid",10)
    task.defer(applyPlayer)
end)

connect(UIS.JumpRequest,function()
    if states.infinite then
        local h=hum()
        if h then
            h:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
end)

local function restoreNoclip()
    for p,value in pairs(noclipParts) do
        if p.Parent then
            p.CanCollide=value
        end
    end
    table.clear(noclipParts)
end

connect(RS.Stepped,function()
    if states.noclip and LP.Character then
        for _,p in ipairs(
            LP.Character:GetDescendants()
        ) do
            if p:IsA("BasePart") then
                if noclipParts[p]==nil then
                    noclipParts[p]=p.CanCollide
                end
                p.CanCollide=false
            end
        end
    end
end)

-- FLY

local function stopFly()
    if activeFly then
        for _,obj in ipairs(activeFly.objects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        activeFly=nil
    end
    vertical=0
end

local function startFly(part,mode)
    stopFly()

    if not part or not part:IsA("BasePart") then
        return false
    end

    local att=new("Attachment",part,{
        Name="FH_FlyAttachment"
    })

    local vel=new("LinearVelocity",part,{
        Name="FH_FlyVelocity",
        Attachment0=att,
        RelativeTo=Enum.ActuatorRelativeTo.World,
        VelocityConstraintMode=
            Enum.VelocityConstraintMode.Vector,
        VectorVelocity=Vector3.zero,
        MaxForce=1e9,
        ForceLimitsEnabled=false
    })

    local orient=new("AlignOrientation",part,{
        Name="FH_FlyOrientation",
        Attachment0=att,
        Mode=Enum.OrientationAlignmentMode.OneAttachment,
        MaxTorque=1e9,
        Responsiveness=15
    })

    activeFly={
        part=part,
        mode=mode,
        velocity=vel,
        orientation=orient,
        objects={att,vel,orient}
    }

    return true
end

local function mountPart()
    local h=hum()
    if not h or not h.SeatPart then
        return nil
    end

    local seat=h.SeatPart
    local model=seat:FindFirstAncestorOfClass("Model")

    if model and model.PrimaryPart then
        return model.PrimaryPart
    end

    return seat
end

local function setFly(on)
    if on then
        states.mountFly=false
        if not startFly(root(),"player") then
            states.fly=false
        end
    elseif activeFly and activeFly.mode=="player" then
        stopFly()
    end
end

local function setMountFly(on)
    if on then
        states.fly=false

        if not startFly(mountPart(),"mount") then
            states.mountFly=false
        end
    elseif activeFly and activeFly.mode=="mount" then
        stopFly()
    end
end

connect(RS.Heartbeat,function()
    if not activeFly then return end

    local a=activeFly
    if not a.part.Parent then
        stopFly()
        return
    end

    if a.mode=="player" and not states.fly then
        stopFly()
        return
    end

    if a.mode=="mount" then
        local h=hum()
        if not states.mountFly or not h or not h.SeatPart then
            states.mountFly=false
            stopFly()
            return
        end
    end

    local camera=workspace.CurrentCamera
    if not camera then return end

    local h=hum()
    local move=h and h.MoveDirection or Vector3.zero

    local currentSpeed=
        a.mode=="mount" and mountSpeed or flySpeed

    a.velocity.VectorVelocity=
        move*currentSpeed+
        Vector3.new(0,vertical*currentSpeed,0)

    local look=camera.CFrame.LookVector
    local flat=Vector3.new(look.X,0,look.Z)

    if flat.Magnitude>.01 then
        a.orientation.CFrame=
            CFrame.lookAt(Vector3.zero,flat.Unit)
    end
end)

-- ESP + NAME TAGS

local function clearMarks(tbl)
    for _,entry in pairs(tbl) do
        for _,obj in pairs(entry) do
            if typeof(obj)=="Instance" then
                obj:Destroy()
            end
        end
    end
    table.clear(tbl)
end

local function makeESP(target,name,color)
    if not target or not target.Parent then
        return nil
    end

    local adorneePart

    if target:IsA("BasePart") then
        adorneePart=target
    elseif target:IsA("Model") then
        adorneePart=
            target:FindFirstChild("Head")
            or target.PrimaryPart
            or target:FindFirstChildWhichIsA(
                "BasePart",true
            )
    end

    if not adorneePart then return nil end

    local highlight=new("Highlight",gui,{
        Adornee=target,
        FillColor=color,
        OutlineColor=C.white,
        FillTransparency=.75,
        OutlineTransparency=0,
        DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    })

    local tag=new("BillboardGui",gui,{
        Name="FH_NameTag",
        Adornee=adorneePart,
        Size=UDim2.fromOffset(135,36),
        StudsOffsetWorldSpace=Vector3.new(0,2.8,0),
        AlwaysOnTop=true,
        MaxDistance=500
    })

    local nameText=new("TextLabel",tag,{
        Size=UDim2.new(1,0,0,19),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=C.white,
        TextStrokeColor3=Color3.new(0,0,0),
        TextStrokeTransparency=.15,
        Font=Enum.Font.GothamBold,
        TextSize=11,
        TextScaled=false
    })

    local distanceText=new("TextLabel",tag,{
        Position=UDim2.fromOffset(0,19),
        Size=UDim2.new(1,0,0,15),
        BackgroundTransparency=1,
        Text="",
        TextColor3=color,
        TextStrokeColor3=Color3.new(0,0,0),
        TextStrokeTransparency=.15,
        Font=Enum.Font.GothamMedium,
        TextSize=9
    })

    return {
        highlight=highlight,
        tag=tag,
        part=adorneePart,
        distanceText=distanceText
    }
end

local function updateDistance(entry)
    local r=root()

    if r and entry.part and entry.part.Parent then
        local d=(r.Position-entry.part.Position).Magnitude
        entry.distanceText.Text=
            tostring(math.floor(d)).." studs"
    end
end

local function syncPlayers()
    if not states.playerESP then
        clearMarks(playerMarks)
        return
    end

    for p,entry in pairs(playerMarks) do
        if not p.Parent
            or not p.Character
            or not entry.highlight.Parent
            or entry.highlight.Adornee~=p.Character then

            entry.highlight:Destroy()
            entry.tag:Destroy()
            playerMarks[p]=nil
        end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character
            and p.Character.Parent then

            if not playerMarks[p] then
                playerMarks[p]=makeESP(
                    p.Character,
                    p.DisplayName,
                    C.red
                )
            end
        end
    end
end

local function syncItems()
    clearMarks(itemMarks)

    if not states.itemESP then return end

    for _,entry in ipairs(results) do
        local obj=entry.obj

        if obj and obj.Parent then
            local target=obj

            if obj:IsA("Tool") then
                target=obj:FindFirstChild("Handle")
            end

            if target then
                local esp=makeESP(
                    target,
                    entry.name,
                    C.green
                )

                if esp then
                    table.insert(itemMarks,esp)
                end
            end
        end
    end
end

local espElapsed=0

connect(RS.Heartbeat,function(dt)
    espElapsed=espElapsed+dt

    if espElapsed>=.5 then
        espElapsed=0
        syncPlayers()

        for _,entry in pairs(playerMarks) do
            updateDistance(entry)
        end

        for _,entry in pairs(itemMarks) do
            updateDistance(entry)
        end
    end
end)

-- UNIVERSAL SCANNER

local keywords={
    "coin","gem","diamond","loot","drop",
    "chest","treasure","egg","collect",
    "pickup","reward","item","crystal",
    "fruit","key","token","orb","gift","tool"
}

local function keyword(value)
    value=string.lower(value)

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
        obj:IsA("Model")
        or obj:IsA("BasePart")
    ) then
        return false
    end

    if keyword(obj.Name) then return true end

    if obj:FindFirstChildWhichIsA(
        "ProximityPrompt",true
    ) then
        return true
    end

    for _,tag in ipairs(
        CollectionService:GetTags(obj)
    ) do
        if keyword(tag) then return true end
    end

    return false
end

local function objectPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then
        return obj:GetPivot().Position
    end

    if obj:IsA("Tool") then
        local handle=obj:FindFirstChild("Handle")
        if handle then return handle.Position end
    end
end

local function scan()
    table.clear(results)

    local r=root()
    if not r then return end

    local seen={}

    for _,obj in ipairs(workspace:GetDescendants()) do
        if #results>=150 then break end

        if collectible(obj) then
            local target=obj

            if obj:IsA("BasePart") then
                local model=
                    obj:FindFirstAncestorOfClass("Model")

                if model and collectible(model) then
                    target=model
                end
            end

            local character=LP.Character

            if target.Parent
                and not seen[target]
                and not (
                    character
                    and target:IsDescendantOf(character)
                )
                and not Players:GetPlayerFromCharacter(target) then

                local p=objectPosition(target)

                if p then
                    local d=(p-r.Position).Magnitude

                    local matches=
                        filter==""
                        or string.find(
                            string.lower(target.Name),
                            string.lower(filter),
                            1,true
                        )

                    if d<=radius and matches then
                        seen[target]=true

                        table.insert(results,{
                            obj=target,
                            name=target.Name,
                            distance=math.floor(d)
                        })
                    end
                end
            end
        end
    end

    table.sort(results,function(a,b)
        return a.distance<b.distance
    end)
end

-- INSTANT PROMPT

local function setInstant(on)
    if on then
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                if originalPrompts[p]==nil then
                    originalPrompts[p]=p.HoldDuration
                end
                p.HoldDuration=0
            end
        end
    else
        for p,duration in pairs(originalPrompts) do
            if p.Parent then
                p.HoldDuration=duration
            end
        end
        table.clear(originalPrompts)
    end
end

connect(PromptService.PromptShown,function(p)
    if states.instant then
        if originalPrompts[p]==nil then
            originalPrompts[p]=p.HoldDuration
        end
        p.HoldDuration=0
    end
end)

connect(workspace.DescendantAdded,function(p)
    if states.instant and p:IsA("ProximityPrompt") then
        task.defer(function()
            if p.Parent then
                if originalPrompts[p]==nil then
                    originalPrompts[p]=p.HoldDuration
                end
                p.HoldDuration=0
            end
        end)
    end
end)

-- TRAINING TARGET LOCK

local function targetPart(model)
    if not model or not model:IsA("Model") then
        return nil
    end

    if Players:GetPlayerFromCharacter(model) then
        return nil
    end

    return model:FindFirstChild(aimPart)
        or model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

local function findTrainingTarget()
    local camera=workspace.CurrentCamera
    if not camera then return nil end

    local center=camera.ViewportSize/2
    local best=nil
    local bestDistance=aimRadius

    for _,model in ipairs(
        CollectionService:GetTagged("FreakHubTarget")
    ) do
        if model:IsDescendantOf(workspace) then
            local part=targetPart(model)

            if part then
                local screen,visible=
                    camera:WorldToViewportPoint(part.Position)

                if visible then
                    local d=(
                        Vector2.new(screen.X,screen.Y)
                        -center
                    ).Magnitude

                    if d<bestDistance then
                        bestDistance=d
                        best=model
                    end
                end
            end
        end
    end

    return best
end

connect(RS.RenderStepped,function(dt)
    if not states.aim then return end

    local camera=workspace.CurrentCamera
    if not camera then return end

    if not lockedTarget
        or not lockedTarget.Parent then
        lockedTarget=findTrainingTarget()
    end

    local part=targetPart(lockedTarget)

    if not part then
        lockedTarget=nil
        return
    end

    local current=camera.CFrame
    local desired=CFrame.lookAt(
        current.Position,
        part.Position
    )

    local alpha=1-math.pow(
        1-math.clamp(aimSmooth,.01,1),
        math.max(dt,0)*60
    )

    camera.CFrame=current:Lerp(
        desired,
        math.clamp(alpha,0,1)
    )
end)

-- FULLBRIGHT

local lightOld={
    Brightness=Lighting.Brightness,
    ClockTime=Lighting.ClockTime,
    FogEnd=Lighting.FogEnd,
    GlobalShadows=Lighting.GlobalShadows
}

local function fullbright(on)
    if on then
        Lighting.Brightness=3
        Lighting.ClockTime=14
        Lighting.FogEnd=100000
        Lighting.GlobalShadows=false
    else
        for k,v in pairs(lightOld) do
            Lighting[k]=v
        end
    end
end

-- MOBILE FLY CONTROLS

local controls=new("Frame",gui,{
    Size=UDim2.fromOffset(115,105),
    Position=UDim2.new(1,-125,1,-165),
    BackgroundColor3=C.bg,
    BackgroundTransparency=.15,
    BorderSizePixel=0,
    Visible=false
})
round(controls,12)

local function holdButton(value,y,direction)
    local b=new("TextButton",controls,{
        Position=UDim2.fromOffset(8,y),
        Size=UDim2.fromOffset(99,42),
        BackgroundColor3=C.red,
        BorderSizePixel=0,
        Text=value,
        TextColor3=C.white,
        TextSize=13,
        Font=Enum.Font.GothamBold
    })
    round(b,9)

    connect(b.InputBegan,function(input)
        if input.UserInputType==
            Enum.UserInputType.Touch
            or input.UserInputType==
            Enum.UserInputType.MouseButton1 then

            vertical=direction
        end
    end)

    connect(b.InputEnded,function(input)
        if input.UserInputType==
            Enum.UserInputType.Touch
            or input.UserInputType==
            Enum.UserInputType.MouseButton1 then

            if vertical==direction then
                vertical=0
            end
        end
    end)
end

holdButton("▲ UP",7,1)
holdButton("▼ DOWN",55,-1)

-- PAGES

local pages={}
local switch

pages.Home=function()
    heading("Dashboard")
    info("FREAKHUB UNIVERSAL v1.9")
    info("Player: "..LP.Name)
    info("Compact UI • ESP Names • Training Aim")

    button("PLAYER SETTINGS",function()
        switch("Player")
    end)

    button("ESP CENTER",function()
        switch("ESP")
    end)

    button("TARGET LOCK",function()
        switch("Aim")
    end)
end

pages.Player=function()
    heading("Player")

    toggle("Infinite Jump","infinite")

    toggle("Noclip","noclip",function(on)
        if not on then restoreNoclip() end
    end)

    numberRow("Walk Speed",speed,function(v)
        speed=math.clamp(v or 16,16,200)
        applyPlayer()
    end)

    numberRow("Jump Power",jump,function(v)
        jump=math.clamp(v or 50,50,200)
        applyPlayer()
    end)

    heading("Flight")

    toggle("Fly","fly",function(on)
        setFly(on)
        controls.Visible=states.fly or states.mountFly
    end)

    numberRow("Fly Speed",flySpeed,function(v)
        flySpeed=math.clamp(v or 55,10,200)
    end)

    toggle("Mount Fly","mountFly",function(on)
        setMountFly(on)
        controls.Visible=states.fly or states.mountFly
        switch("Player")
    end)

    numberRow("Mount Speed",mountSpeed,function(v)
        mountSpeed=math.clamp(v or 65,10,200)
    end)

    button("STOP ALL FLIGHT",function()
        states.fly=false
        states.mountFly=false
        stopFly()
        controls.Visible=false
        switch("Player")
    end)
end

pages.ESP=function()
    heading("ESP Center")

    toggle("Player ESP","playerESP",syncPlayers)
    toggle("Item ESP","itemESP",syncItems)

    button("REFRESH PLAYER ESP",syncPlayers)
    button("REFRESH ITEM ESP",syncItems)

    button("CLEAR ALL ESP",function()
        states.playerESP=false
        states.itemESP=false
        clearMarks(playerMarks)
        clearMarks(itemMarks)
        switch("ESP")
    end)

    info("Name Tag: 11px • Distance: 9px")
end

pages.Scanner=function()
    heading("Universal Scanner")

    numberRow("Scan Radius",radius,function(v)
        radius=math.clamp(v or 150,25,500)
    end)

    local f=row("Name Filter")

    local box=new("TextBox",f,{
        Position=UDim2.new(.44,0,0,5),
        Size=UDim2.new(.53,0,0,25),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        Text=filter,
        PlaceholderText="All items",
        PlaceholderColor3=C.muted,
        TextColor3=C.white,
        TextSize=10,
        ClearTextOnFocus=false
    })
    round(box,6)

    button("SCAN NOW",function()
        filter=box.Text
        scan()
        syncItems()
        switch("Results")
    end)

    toggle("Instant Prompt","instant",setInstant)

    info("Scanner mencari kandidat item pada client.")
end

pages.Results=function()
    heading("Scan Results")
    info("Found: "..#results.." candidates")

    button("SCAN AGAIN",function()
        scan()
        syncItems()
        switch("Results")
    end)

    for i,entry in ipairs(results) do
        if i>45 then break end

        button(
            entry.name.." • "..entry.distance.." studs",
            function()
                local obj=entry.obj

                if obj and obj.Parent then
                    local target=obj

                    if obj:IsA("Tool") then
                        target=obj:FindFirstChild("Handle")
                    end

                    if target then
                        local esp=makeESP(
                            target,
                            entry.name,
                            C.green
                        )

                        if esp then
                            table.insert(itemMarks,esp)
                        end
                    end
                end
            end
        )
    end
end

pages.Aim=function()
    heading("Training Target Lock")

    toggle("Target Lock","aim",function(on)
        if on then
            lockedTarget=findTrainingTarget()

            if not lockedTarget then
                states.aim=false
            end
        else
            lockedTarget=nil
        end

        switch("Aim")
    end)

    numberRow("FOV Radius",aimRadius,function(v)
        aimRadius=math.clamp(v or 160,40,500)
    end)

    numberRow("Smooth %",aimSmooth*100,function(v)
        aimSmooth=math.clamp(
            (v or 16)/100,
            .01,1
        )
    end)

    button("TARGET PART: "..aimPart,function()
        aimPart=aimPart=="Head"
            and "HumanoidRootPart"
            or "Head"

        lockedTarget=nil
        switch("Aim")
    end)

    button("FIND NEAREST TRAINING TARGET",function()
        lockedTarget=findTrainingTarget()
    end)

    button("UNLOCK TARGET",function()
        lockedTarget=nil
        states.aim=false
        switch("Aim")
    end)

    info("Requires dummy tagged FreakHubTarget.")
end

pages.Teleport=function()
    heading("Teleport Slots")

    for i=1,5 do
        local index=i
        local f=row("Slot "..index)

        local save=new("TextButton",f,{
            Position=UDim2.new(1,-102,0,5),
            Size=UDim2.fromOffset(46,25),
            BackgroundColor3=C.red,
            BorderSizePixel=0,
            Text="SAVE",
            TextColor3=C.white,
            TextSize=10
        })
        round(save,6)

        local go=new("TextButton",f,{
            Position=UDim2.new(1,-52,0,5),
            Size=UDim2.fromOffset(45,25),
            BackgroundColor3=C.panel,
            BorderSizePixel=0,
            Text="GO",
            TextColor3=C.white,
            TextSize=10
        })
        round(go,6)

        connect(save.Activated,function()
            local r=root()
            if r then
                slots[index]=r.CFrame
            end
        end)

        connect(go.Activated,function()
            if slots[index] and LP.Character then
                LP.Character:PivotTo(slots[index])
            end
        end)
    end

    button("CLEAR ALL SLOTS",function()
        table.clear(slots)
    end)
end

pages.Utility=function()
    heading("Utility")

    toggle("Fullbright","fullbright",fullbright)

    button("RESET LOGO POSITION",function()
        logo.Position=UDim2.new(0,14,.45,0)
    end)

    button("HIDE MENU",function()
        window.Visible=false
    end)

    info("Drag F to move. Tap F to open menu.")
end

-- SIDEBAR

local tabs={}

for i,name in ipairs({
    "Home",
    "Player",
    "ESP",
    "Scanner",
    "Results",
    "Aim",
    "Teleport",
    "Utility"
}) do
    local b=new("TextButton",sidebar,{
        Size=UDim2.new(1,0,0,36),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
        Text=name,
        TextColor3=C.white,
        TextSize=11,
        Font=Enum.Font.GothamMedium,
        LayoutOrder=i
    })

    round(b,8)
    tabs[name]=b

    connect(b.Activated,function()
        switch(name)
    end)
end

switch=function(name)
    wipe()
    pages[name]()

    for n,b in pairs(tabs) do
        b.BackgroundColor3=
            n==name and C.red or C.card
    end
end

-- DRAG LOGO AND WINDOW

local function draggable(handle,target,tap)
    local active,start,origin,moved=
        nil,nil,nil,false

    connect(handle.InputBegan,function(input)
        if input.UserInputType==
            Enum.UserInputType.Touch
            or input.UserInputType==
            Enum.UserInputType.MouseButton1 then

            active=input
            start=input.Position
            origin=target.Position
            moved=false
        end
    end)

    connect(UIS.InputChanged,function(input)
        if not active then return end

        local mouse=
            active.UserInputType==
                Enum.UserInputType.MouseButton1
            and input.UserInputType==
                Enum.UserInputType.MouseMovement

        if input~=active and not mouse then
            return
        end

        local delta=input.Position-start

        if delta.Magnitude>8 then
            moved=true
        end

        if moved then
            target.Position=UDim2.new(
                origin.X.Scale,
                origin.X.Offset+delta.X,
                origin.Y.Scale,
                origin.Y.Offset+delta.Y
            )
        end
    end)

    connect(UIS.InputEnded,function(input)
        if input~=active then return end

        active=nil

        if not moved and tap then
            tap()
        end
    end)
end

draggable(logo,logo,function()
    window.Visible=not window.Visible
end)

draggable(header,window)

connect(close.Activated,function()
    window.Visible=false
end)

local function fit()
    local camera=workspace.CurrentCamera
    if not camera then return end

    local v=camera.ViewportSize

    window.Size=UDim2.fromOffset(
        math.min(390,math.max(220,v.X-12)),
        math.min(400,math.max(240,v.Y-28))
    )
end

fit()

if workspace.CurrentCamera then
    connect(
        workspace.CurrentCamera:
            GetPropertyChangedSignal("ViewportSize"),
        fit
    )
end

-- CLEANUP

connect(gui.Destroying,function()
    alive=false
    states.aim=false
    lockedTarget=nil

    stopFly()
    restoreNoclip()

    clearMarks(playerMarks)
    clearMarks(itemMarks)

    setInstant(false)
    fullbright(false)

    for _,connection in ipairs(connections) do
        connection:Disconnect()
    end
end)

switch("Home")

print("FREAKHUB v1.9 UNIVERSAL LOADED")

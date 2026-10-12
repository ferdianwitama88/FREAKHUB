-- FREAKHUB v1.6 UNIVERSAL
-- Black / Red | Mobile Friendly

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("FREAKHUB_UNIVERSAL")
if old then old:Destroy() end

local RED = Color3.fromRGB(224,45,65)
local BG = Color3.fromRGB(14,14,19)
local PANEL = Color3.fromRGB(27,27,35)
local WHITE = Color3.fromRGB(245,245,248)
local GRAY = Color3.fromRGB(165,165,178)

local gui = Instance.new("ScreenGui")
gui.Name = "FREAKHUB_UNIVERSAL"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 100
gui.Parent = pg

local function create(class, parent, props)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do
        o[k] = v
    end
    o.Parent = parent
    return o
end

local function round(o, r)
    create("UICorner",o,{
        CornerRadius = UDim.new(0,r)
    })
end

local function text(parent,value,size)
    return create("TextLabel",parent,{
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,30),
        Text = value,
        TextColor3 = WHITE,
        TextSize = size or 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
end

local function btn(parent,value,height)
    local b = create("TextButton",parent,{
        Size = UDim2.new(1,0,0,height or 38),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = value,
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true
    })
    round(b,12)
    return b
end

-- FLOATING LOGO
local logo = create("TextButton",gui,{
    Name = "FloatingLogo",
    Size = UDim2.fromOffset(58,58),
    Position = UDim2.new(0,18,0.45,0),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Active = true
})
round(logo,19)

create("UIStroke",logo,{
    Color = RED,
    Thickness = 2
})

local logoText = create("TextLabel",logo,{
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1,1),
    Text = "F",
    TextColor3 = RED,
    TextSize = 34,
    Font = Enum.Font.GothamBlack
})

-- MAIN WINDOW
local main = create("Frame",gui,{
    Size = UDim2.fromOffset(365,370),
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.5),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Visible = false,
    Active = true
})
round(main,20)

create("UIStroke",main,{
    Color = Color3.fromRGB(70,30,40),
    Thickness = 1
})

local header = create("Frame",main,{
    Size = UDim2.new(1,0,0,54),
    BackgroundTransparency = 1,
    Active = true
})

local title = create("TextLabel",header,{
    Position = UDim2.fromOffset(17,5),
    Size = UDim2.new(1,-65,1,-10),
    BackgroundTransparency = 1,
    Text = "FREAKHUB  v1.6",
    TextColor3 = WHITE,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
})

local close = create("TextButton",header,{
    Size = UDim2.fromOffset(34,34),
    Position = UDim2.new(1,-43,0,10),
    BackgroundColor3 = RED,
    Text = "×",
    TextColor3 = WHITE,
    TextSize = 23,
    BorderSizePixel = 0
})
round(close,12)

local tabs = create("ScrollingFrame",main,{
    Position = UDim2.fromOffset(10,55),
    Size = UDim2.new(1,-20,0,42),
    BackgroundTransparency = 1,
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    AutomaticCanvasSize = Enum.AutomaticSize.X,
    CanvasSize = UDim2.new()
})

create("UIListLayout",tabs,{
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0,6)
})

local content = create("ScrollingFrame",main,{
    Position = UDim2.fromOffset(15,105),
    Size = UDim2.new(1,-30,1,-117),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})

create("UIListLayout",content,{
    Padding = UDim.new(0,9)
})

local function clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end
end

local function notice(message)
    text(content,message,12).TextColor3 = GRAY
end

local function action(name,callback)
    local b = btn(content,name)
    b.Activated:Connect(callback)
    return b
end

local toggleStates = {}

local function toggle(name,callback)
    local b = btn(content,"")
    local function refresh()
        local on = toggleStates[name] == true
        b.Text = name .. (on and "  ● ON" or "  ○ OFF")
        b.BackgroundColor3 = on and RED or PANEL
    end
    b.Activated:Connect(function()
        local on = not toggleStates[name]
        toggleStates[name] = on
        callback(on)
        refresh()
    end)
    refresh()
end

local function inputBox(placeholder,initial)
    local box = create("TextBox",content,{
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = initial or "",
        PlaceholderText = placeholder,
        TextColor3 = WHITE,
        PlaceholderColor3 = GRAY,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    })
    round(box,12)
    return box
end

local function humanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function root()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local speed = 16
local jump = 50

local function applyPlayer()
    local h = humanoid()
    if h then
        h.WalkSpeed = speed
        h.UseJumpPower = true
        h.JumpPower = jump
    end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid",10)
    applyPlayer()
end)

-- UNIVERSAL COLLECTIBLE SCANNER
local scanRadius = 150
local scanFilter = ""
local scanResults = {}
local highlights = {}

local keywords = {
    "coin","gem","diamond","gold",
    "loot","drop","chest","treasure",
    "egg","pet","collect","pickup",
    "reward","item","crystal",
    "fruit","key","token","orb",
    "weapon","tool","gift"
}

local function hasKeyword(s)
    s = string.lower(s)
    for _,word in ipairs(keywords) do
        if string.find(s,word,1,true) then
            return true
        end
    end
    return false
end

local function candidate(obj)
    if obj:IsA("Tool") then return true end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then
        return false
    end

    if hasKeyword(obj.Name) then return true end

    local tags = CollectionService:GetTags(obj)
    for _,tag in ipairs(tags) do
        if hasKeyword(tag) then return true end
    end

    local attrs = obj:GetAttributes()
    for key,value in pairs(attrs) do
        if hasKeyword(key) and value ~= false then
            return true
        end
    end

    if obj:FindFirstChildWhichIsA("ProximityPrompt",true) then
        return true
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
        local handle = obj:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            return handle.Position
        end
    end
    return nil
end

local function scan()
    table.clear(scanResults)

    local r = root()
    if not r then return end

    local seen = {}

    for _,obj in ipairs(workspace:GetDescendants()) do
        if #scanResults >= 150 then break end

        if candidate(obj) then
            local target = obj

            -- Prefer outer collectible model over its parts
            if obj:IsA("BasePart") then
                local model = obj:FindFirstAncestorOfClass("Model")
                if model and model ~= player.Character
                    and candidate(model) then
                    target = model
                end
            end

            if not target:IsDescendantOf(player.Character or workspace)
                and target.Parent
                and not seen[target] then

                local pos = objectPosition(target)

                if pos then
                    local dist = (pos-r.Position).Magnitude
                    local nameMatches =
                        scanFilter == ""
                        or string.find(
                            string.lower(target.Name),
                            string.lower(scanFilter),
                            1,true
                        )

                    if dist <= scanRadius and nameMatches then
                        seen[target] = true
                        table.insert(scanResults,{
                            object = target,
                            name = target.Name,
                            distance = math.floor(dist)
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

local function clearESP()
    for _,h in ipairs(highlights) do
        if h then h:Destroy() end
    end
    table.clear(highlights)
end

local function mark(obj)
    if not obj or not obj.Parent then return end

    local adornee = obj
    if obj:IsA("Tool") then
        adornee = obj:FindFirstChild("Handle")
    end

    if not adornee then return end

    local h = Instance.new("Highlight")
    h.Name = "FreakHubItemESP"
    h.Adornee = adornee
    h.FillColor = RED
    h.OutlineColor = WHITE
    h.FillTransparency = 0.55
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = gui

    table.insert(highlights,h)
end

-- INSTANT PROMPT
local instantEnabled = false
local promptOriginal = {}

local function processPrompt(p)
    if not p:IsA("ProximityPrompt") then return end

    if promptOriginal[p] == nil then
        promptOriginal[p] = p.HoldDuration
    end

    if instantEnabled then
        p.HoldDuration = 0
    end
end

local function setInstant(on)
    instantEnabled = on

    if on then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                processPrompt(obj)
            end
        end
    else
        for p,duration in pairs(promptOriginal) do
            if p and p.Parent then
                p.HoldDuration = duration
            end
        end
        table.clear(promptOriginal)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if instantEnabled and obj:IsA("ProximityPrompt") then
        task.defer(function()
            if obj.Parent then processPrompt(obj) end
        end)
    end
end)

ProximityPromptService.PromptShown:Connect(function(p)
    if instantEnabled then
        processPrompt(p)
    end
end)

-- FIVE TELEPORT SLOTS
local saved = {}

local pages = {}
local selectTab

pages.Home = function()
    text(content,"WELCOME TO FREAKHUB",17)
    notice("Universal Roblox GUI")
    notice("Player: "..player.Name)
    notice("Place ID: "..game.PlaceId)
    notice("Theme: Black & Red")
    notice("Version: 1.6")
end

pages.Player = function()
    text(content,"PLAYER SETTINGS",16)

    local s = inputBox("WalkSpeed",tostring(speed))
    action("Apply Speed",function()
        speed = math.clamp(tonumber(s.Text) or 16,16,200)
        applyPlayer()
    end)

    local j = inputBox("JumpPower",tostring(jump))
    action("Apply Jump",function()
        jump = math.clamp(tonumber(j.Text) or 50,50,200)
        applyPlayer()
    end)

    action("Reset Player",function()
        speed = 16
        jump = 50
        applyPlayer()
        s.Text = "16"
        j.Text = "50"
    end)
end

pages.Scanner = function()
    text(content,"UNIVERSAL ITEM SCANNER",16)
    notice("Mencari kandidat item yang tersedia di client.")

    local radiusBox = inputBox(
        "Scan radius",tostring(scanRadius)
    )
    local filterBox = inputBox(
        "Filter nama (kosong = semua)",scanFilter
    )

    action("SCAN / REFRESH",function()
        scanRadius = math.clamp(
            tonumber(radiusBox.Text) or 150,25,500
        )
        scanFilter = filterBox.Text
        scan()
        selectTab("Results")
    end)

    toggle("Instant Prompt",setInstant)

    action("Clear ESP",clearESP)

    notice("Instant Prompt hanya mengubah HoldDuration lokal.")
    notice("Server tetap menentukan apakah interaksi valid.")
end

pages.Results = function()
    text(content,"SCAN RESULTS",16)
    notice("Ditemukan: "..#scanResults.." kandidat")

    action("ESP ALL RESULTS",function()
        clearESP()
        for _,item in ipairs(scanResults) do
            mark(item.object)
        end
    end)

    action("CLEAR ESP",clearESP)

    for i,item in ipairs(scanResults) do
        if i > 60 then
            notice("Hanya 60 hasil pertama ditampilkan.")
            break
        end

        local obj = item.object
        local b = action(
            item.name.."  •  "..item.distance.." studs  [ESP]",
            function()
                mark(obj)
            end
        )
        b.TextSize = 11
    end
end

pages.Teleport = function()
    text(content,"SAVE TELEPORT",16)
    notice("Lima slot selama sesi permainan.")

    for i = 1,5 do
        local slot = i
        local info = saved[slot]
        local name = info and info.name or ("Slot "..slot)

        text(content,name,13)

        local nameBox = inputBox(
            "Nama lokasi",info and info.name or ("Lokasi "..slot)
        )

        action("SAVE SLOT "..slot,function()
            local r = root()
            if r then
                saved[slot] = {
                    name = nameBox.Text,
                    cf = r.CFrame
                }
                selectTab("Teleport")
            end
        end)

        if info then
            action("TELEPORT "..slot,function()
                local char = player.Character
                if char then
                    char:PivotTo(saved[slot].cf)
                end
            end)

            action("HAPUS SLOT "..slot,function()
                saved[slot] = nil
                selectTab("Teleport")
            end)
        end
    end
end

pages.Settings = function()
    text(content,"SETTINGS",16)

    action("Hide Menu",function()
        main.Visible = false
    end)

    action("Reset Floating Logo Position",function()
        logo.Position = UDim2.new(0,18,0.45,0)
    end)

    notice("Drag logo F untuk memindahkan posisinya.")
end

-- TAB NAVIGATION
local tabButtons = {}

selectTab = function(name)
    clear()
    if pages[name] then pages[name]() end

    for n,b in pairs(tabButtons) do
        b.BackgroundColor3 = n == name and RED or PANEL
    end
end

for _,name in ipairs({
    "Home","Player","Scanner",
    "Results","Teleport","Settings"
}) do
    local b = btn(tabs,name,34)
    b.Size = UDim2.fromOffset(85,34)
    b.TextSize = 12
    tabButtons[name] = b
    b.Activated:Connect(function()
        selectTab(name)
    end)
end

-- MOBILE / MOUSE DRAG
local function makeDraggable(handle,target,onTap)
    local startInput = nil
    local startPoint = nil
    local startPosition = nil
    local dragged = false

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startInput = input
            startPoint = input.Position
            startPosition = target.Position
            dragged = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not startInput then return end

        local mouseDrag =
            startInput.UserInputType
                == Enum.UserInputType.MouseButton1
            and input.UserInputType
                == Enum.UserInputType.MouseMovement

        if input ~= startInput and not mouseDrag then
            return
        end

        local delta = input.Position-startPoint

        if delta.Magnitude > 8 then
            dragged = true
        end

        if dragged then
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset+delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset+delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input ~= startInput then return end

        startInput = nil

        if not dragged and onTap then
            onTap()
        end
    end)
end

local function showMenu()
    main.Visible = not main.Visible

    if main.Visible then
        local finalSize = main.Size
        main.Size = UDim2.new(
            finalSize.X.Scale,
            finalSize.X.Offset-18,
            finalSize.Y.Scale,
            finalSize.Y.Offset-18
        )

        TweenService:Create(
            main,
            TweenInfo.new(0.18,Enum.EasingStyle.Quad),
            {Size=finalSize}
        ):Play()
    end
end

makeDraggable(logo,logo,showMenu)
makeDraggable(header,main,nil)

close.Activated:Connect(function()
    main.Visible = false
end)

local camera = workspace.CurrentCamera
if camera then
    local function resize()
        local v = camera.ViewportSize
        main.Size = UDim2.fromOffset(
            math.min(365,v.X-18),
            math.min(370,v.Y-35)
        )
    end

    resize()
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

gui.Destroying:Connect(function()
    clearESP()
    setInstant(false)
end)

selectTab("Home")

print("FREAKHUB v1.6 UNIVERSAL LOADED")

-- FREAKHUB v1.5.0 | Black & Red
-- LocalScript: StarterPlayer > StarterPlayerScripts
-- Test in your own Roblox Studio experience.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RED = Color3.fromRGB(220, 48, 58)
local DARK = Color3.fromRGB(18, 18, 22)
local PANEL = Color3.fromRGB(30, 30, 36)
local WHITE = Color3.fromRGB(245, 245, 248)
local MUTED = Color3.fromRGB(180, 180, 190)

local previous = playerGui:FindFirstChild("FreakHub")
if previous then previous:Destroy() end

local connections = {}
local function track(connection)
    table.insert(connections, connection)
    return connection
end
local gui = Instance.new("ScreenGui")
gui.Name = "FreakHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
gui.Destroying:Connect(function()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
end)

local function make(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props) do obj[key] = value end
    obj.Parent = parent
    return obj
end
local function rounded(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius)}, obj)
end
local function button(text, parent)
    local obj = make("TextButton", {
        BackgroundColor3 = PANEL, BorderSizePixel = 0,
        Text = text, TextColor3 = WHITE, TextSize = 13,
        Font = Enum.Font.GothamMedium, AutoButtonColor = true,
    }, parent)
    rounded(obj, 13)
    return obj
end

local floating = button("F", gui)
floating.Name = "FloatingButton"
floating.Size = UDim2.fromOffset(52, 52)
floating.Position = UDim2.new(0, 14, 0.5, -26)
floating.BackgroundColor3 = Color3.fromRGB(22, 19, 25)
floating.Text = ""
rounded(floating, 26)
make("UIStroke", {Color = RED, Thickness = 2}, floating)
local logoInner = make("Frame", {
    Name = "LogoCore", Size = UDim2.fromOffset(38, 38),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = RED, BorderSizePixel = 0,
}, floating)
rounded(logoInner, 12)
make("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(255, 92, 104), Color3.fromRGB(147, 13, 37)),
    Rotation = 45,
}, logoInner)
make("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Text = "F", TextSize = 29, TextColor3 = WHITE,
    Font = Enum.Font.GothamBlack,
}, logoInner)


local main = make("Frame", {
    Name = "MainWindow", BackgroundColor3 = DARK,
    BorderSizePixel = 0, Size = UDim2.fromOffset(420, 355),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Visible = false,
    Active = true,
}, gui)
rounded(main, 20)
make("UIStroke", {Color = Color3.fromRGB(72, 37, 43), Thickness = 1}, main)

local header = make("Frame", {
    BackgroundColor3 = PANEL, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 44), Active = true,
}, main)
rounded(header, 18)
make("TextLabel", {
    Size = UDim2.new(1, -88, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1, Text = "◆ FREAKHUB  |  v1.4",
    TextColor3 = WHITE, TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local hide = button("_", header)
hide.Size = UDim2.fromOffset(29, 28)
hide.Position = UDim2.new(1, -69, 0, 8)
local close = button("X", header)
close.Size = UDim2.fromOffset(29, 28)
close.Position = UDim2.new(1, -35, 0, 8)
close.BackgroundColor3 = RED

local sidebar = make("ScrollingFrame", {
    BackgroundColor3 = PANEL, BorderSizePixel = 0,
    Position = UDim2.fromOffset(6, 49),
    Size = UDim2.new(0, 112, 1, -55),
    ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
}, main)
rounded(sidebar, 14)
make("UIListLayout", {
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, sidebar)
make("UIPadding", {
    PaddingTop = UDim.new(0, 7),
    PaddingBottom = UDim.new(0, 7),
}, sidebar)

local content = make("ScrollingFrame", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.fromOffset(125, 49),
    Size = UDim2.new(1, -132, 1, -55),
    ScrollBarThickness = 3,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
}, main)
make("UIListLayout", {Padding = UDim.new(0, 9)}, content)
make("UIPadding", {
    PaddingTop = UDim.new(0, 5),
    PaddingBottom = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 7),
}, content)

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end
local function label(text, height, size)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 27),
        Text = text, TextColor3 = WHITE,
        TextSize = size or 13, TextWrapped = true,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, content)
end
local function action(text, callback)
    local obj = button(text, content)
    obj.Size = UDim2.new(1, 0, 0, 35)
    obj.Activated:Connect(callback)
    return obj
end
local toggleStates = {}
local function toggle(text, callback)
    local enabled = toggleStates[text] or false
    local obj = action(text .. ": OFF", function()
        enabled = not enabled
        toggleStates[text] = enabled
        callback(enabled)
    end)
    local function refresh()
        obj.Text = text .. (enabled and ": ON" or ": OFF")
        obj.BackgroundColor3 = enabled and RED or PANEL
    end
    obj.Activated:Connect(refresh)
    refresh()
    return obj
end

local speed = 16
local jump = 50
local function humanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end
local function applySettings()
    local hum = humanoid()
    if hum then
        hum.WalkSpeed = speed
        hum.UseJumpPower = true
        hum.JumpPower = jump
    end
end
track(player.CharacterAdded:Connect(function()
    task.defer(function()
        local character = player.Character
        if character then character:WaitForChild("Humanoid", 10) end
        applySettings()
    end)
end))

local function slider(text, minimum, maximum, initial, callback)
    local container = make("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
    }, content)
    local caption = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        TextColor3 = WHITE, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    local bar = make("Frame", {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 9),
        BackgroundColor3 = PANEL, BorderSizePixel = 0,
        Active = true,
    }, container)
    rounded(bar, 5)
    local fill = make("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = RED, BorderSizePixel = 0,
    }, bar)
    rounded(fill, 5)
    local value = initial
    local function setValue(number)
        value = math.clamp(math.floor(number + 0.5), minimum, maximum)
        caption.Text = text .. ": " .. tostring(value)
        fill.Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1)
        callback(value)
    end
    setValue(initial)
    local activeInput = nil
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
            local ratio = math.clamp(
                (input.Position.X - bar.AbsolutePosition.X)
                / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            setValue(minimum + ratio * (maximum - minimum))
        end
    end)
    local changed = UIS.InputChanged:Connect(function(input)
        if activeInput and (input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement)) then
            local ratio = math.clamp(
                (input.Position.X - bar.AbsolutePosition.X)
                / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            setValue(minimum + ratio * (maximum - minimum))
        end
    end)
    local ended = UIS.InputEnded:Connect(function(input)
        if input == activeInput then activeInput = nil end
    end)
    container.Destroying:Connect(function()
        changed:Disconnect()
        ended:Disconnect()
    end)
    return setValue
end

-- Functional local features for testing in your own experience.
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local fullbright = false
local savedLighting = nil
local espEnabled = false
local highlights = {}
local noclipEnabled = false
local collisionStates = {}
local infiniteJump = false
local flyEnabled = false
local flySpeed = 45
local flyAttachment, flyVelocity
local flyUp, flyDown = false, false

local function setFullbright(enabled)
    fullbright = enabled
    if enabled then
        if not savedLighting then
            savedLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
            }
        end
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
    elseif savedLighting then
        for property, value in pairs(savedLighting) do
            Lighting[property] = value
        end
        savedLighting = nil
    end
end

local function clearHighlights()
    for _, h in pairs(highlights) do h:Destroy() end
    table.clear(highlights)
end
local function refreshHighlights()
    clearHighlights()
    if not espEnabled then return end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local h = Instance.new("Highlight")
            h.Name = "FreakHubHighlight"
            h.FillColor = RED
            h.OutlineColor = WHITE
            h.FillTransparency = 0.6
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = other.Character
            h.Parent = gui
            highlights[other] = h
        end
    end
end
track(Players.PlayerAdded:Connect(function(other)
    track(other.CharacterAdded:Connect(function()
        task.wait(0.2)
        refreshHighlights()
    end))
end))
track(Players.PlayerRemoving:Connect(function() task.defer(refreshHighlights) end))
for _, other in ipairs(Players:GetPlayers()) do
    if other ~= player then
        track(other.CharacterAdded:Connect(function()
            task.wait(0.2)
            refreshHighlights()
        end))
    end
end

local function restoreCollision()
    for part, original in pairs(collisionStates) do
        if part and part.Parent then part.CanCollide = original end
    end
    table.clear(collisionStates)
end
track(RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local character = player.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if collisionStates[part] == nil then
                collisionStates[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end))
track(UIS.JumpRequest:Connect(function()
    if infiniteJump then
        local hum = humanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- Fly: keep humanoid movement controls active, use camera-relative joystick/WASD.
-- Do not wait for PlayerModule: some Studio setups do not expose it.
-- Humanoid.MoveDirection supports default keyboard and mobile joystick movement.
local flyButtons = make("Frame", {
    Name = "FlyControls", BackgroundTransparency = 1,
    Size = UDim2.fromOffset(66, 132),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0), Visible = false,
}, gui)
local function flyHold(text, y, setFlag)
    local control = button(text, flyButtons)
    control.Size = UDim2.fromOffset(60, 55)
    control.Position = UDim2.fromOffset(3, y)
    control.BackgroundColor3 = RED
    control.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setFlag(true)
        end
    end)
    control.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setFlag(false)
        end
    end)
end
flyHold("UP", 3, function(v) flyUp = v end)
flyHold("DOWN", 69, function(v) flyDown = v end)

local function stopFly()
    flyEnabled = false
    flyUp, flyDown = false, false
    flyButtons.Visible = false
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    local hum = humanoid()
    if hum then hum.AutoRotate = true end
end
local function startFly()
    stopFly()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local hum = humanoid()
    if not root or not hum then return false end
    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "FreakHubFlyAttachment"
    flyAttachment.Parent = root
    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "FreakHubFlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.MaxForce = math.max(root.AssemblyMass * 3000, 100000)
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.Parent = root
    flyEnabled = true
    flyButtons.Visible = true
    hum.AutoRotate = false
    return true
end
track(RunService.Heartbeat:Connect(function()
    if not flyEnabled or not flyVelocity then return end
    local cam = workspace.CurrentCamera
    local hum = humanoid()
    if not cam or not hum then return end
    local direction = hum.MoveDirection
    if direction.Magnitude > 1 then direction = direction.Unit end
    local vertical = (flyUp and 1 or 0) - (flyDown and 1 or 0)
    flyVelocity.VectorVelocity = direction * flySpeed + Vector3.new(0, vertical * flySpeed, 0)
end))
track(player.CharacterAdded:Connect(function()
    stopFly()
    toggleStates["Fly"] = false
    restoreCollision()
    task.wait(0.3)
    refreshHighlights()
end))
gui.Destroying:Connect(function()
    stopFly()
    restoreCollision()
    setFullbright(false)
    clearHighlights()
end)

-- Item ESP: highlights locally replicated BaseParts/Models by case-insensitive name.
local itemEspEnabled = false
local itemQuery = ""
local itemHighlights = {}
local savedLocations = {}
local refreshTeleportPage
local function itemMatches(obj)
    if obj == player.Character then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    if obj:IsDescendantOf(gui) then return false end
    local name = obj.Name:lower()
    return itemQuery ~= "" and name:find(itemQuery:lower(), 1, true) ~= nil
end
local function refreshItemESP()
    for _, h in pairs(itemHighlights) do h:Destroy() end
    table.clear(itemHighlights)
    if not itemEspEnabled or itemQuery == "" then return end
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if itemMatches(obj) and count < 80 then
            local h = Instance.new("Highlight")
            h.Name = "FreakHubItemHighlight"
            h.Adornee = obj
            h.FillColor = Color3.fromRGB(255, 195, 50)
            h.OutlineColor = WHITE
            h.FillTransparency = 0.65
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = gui
            itemHighlights[obj] = h
            count += 1
        end
    end
end
local refreshPending = false
local function scheduleItemRefresh()
    if not itemEspEnabled or refreshPending then return end
    refreshPending = true
    task.delay(0.5, function()
        refreshPending = false
        if gui.Parent then refreshItemESP() end
    end)
end
track(workspace.DescendantAdded:Connect(scheduleItemRefresh))
track(workspace.DescendantRemoving:Connect(scheduleItemRefresh))
gui.Destroying:Connect(function()
    for _, h in pairs(itemHighlights) do h:Destroy() end
end)
local function textInput(placeholder, initial)
    local box = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = PANEL, BorderSizePixel = 0,
        PlaceholderText = placeholder, Text = initial or "",
        ClearTextOnFocus = false, TextColor3 = WHITE,
        PlaceholderColor3 = MUTED, TextSize = 13,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
    }, content)
    rounded(box, 12)
    make("UIPadding", {PaddingLeft = UDim.new(0, 9)}, box)
    return box
end
-- Collectible scan: heuristic, not a guarantee of collectibility.
local scanRadius = 150
local scannedItems = {}
local chosenItems = {}
local itemEspAll = false
local collectibleKeywords = {"coin", "gem", "gold", "chest", "treasure", "loot", "drop", "collect", "pickup", "pick_up", "reward", "ore", "crystal", "key", "token"}
local collectibleTags = {"Collectible", "Pickup", "Loot", "Item", "Collectable"}
local function objectPosition(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        return part and part.Position or nil
    end
    if obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle")
        return handle and handle.Position or nil
    end
    return nil
end
local function collectibleCandidate(obj)
    if not (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")) then return false end
    if player.Character and obj:IsDescendantOf(player.Character) then return false end
    if obj:IsA("Tool") then return true end
    for _, tag in ipairs(collectibleTags) do
        if CollectionService:HasTag(obj, tag) then return true end
    end
    for _, attribute in ipairs({"Collectible", "CanCollect", "Pickup", "IsLoot"}) do
        if obj:GetAttribute(attribute) == true then return true end
    end
    local lower = obj.Name:lower()
    for _, keyword in ipairs(collectibleKeywords) do
        if lower:find(keyword, 1, true) then return true end
    end
    if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
        return lower:find("item", 1, true) ~= nil or lower:find("pickup", 1, true) ~= nil
    end
    return false
end
-- Rarity is inferred only from replicated names/attributes/values.
-- These are configurable guesses, not confirmed Ride A Pet rarity tiers.
local rarityTiers = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Celestial", "Godly"}
local rarityRanks = {}
for i, name in ipairs(rarityTiers) do rarityRanks[name:lower()] = i end
local rarityMode = "Highest Known" -- Highest Known / Minimum Tier / All
local minimumTier = 5
local includeUnknown = false
local function readRarity(obj)
    local values = {obj.Name}
    local current = obj
    for _ = 1, 3 do
        if not current or current == workspace then break end
        for _, key in ipairs({"Rarity", "Tier", "Grade", "EggRarity", "PetRarity"}) do
            local value = current:GetAttribute(key)
            if value ~= nil then table.insert(values, tostring(value)) end
            local child = current:FindFirstChild(key)
            if child and (child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue")) then
                table.insert(values, tostring(child.Value))
            end
        end
        current = current.Parent
    end
    for _, text in ipairs(values) do
        local lower = text:lower()
        for i = #rarityTiers, 1, -1 do
            local tier = rarityTiers[i]
            if lower:find(tier:lower(), 1, true) then return tier, i end
        end
    end
    return "Unknown", 0
end
local function eggCandidate(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) then return false end
    if player.Character and obj:IsDescendantOf(player.Character) then return false end
    if obj.Name:lower():find("egg", 1, true) then return true end
    for _, tag in ipairs({"Egg", "EggPickup", "CollectibleEgg"}) do
        if CollectionService:HasTag(obj, tag) then return true end
    end
    for _, key in ipairs({"EggRarity", "EggType"}) do
        if obj:GetAttribute(key) ~= nil then return true end
    end
    return false
end
local function scanCollectibles()
    table.clear(scannedItems)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local candidates = {}
    -- Scan only egg-like objects; avoid every part in the world.
    for _, obj in ipairs(workspace:GetDescendants()) do
        if eggCandidate(obj) then
            local pos = objectPosition(obj)
            if pos then
                local distance = (pos - root.Position).Magnitude
                if distance <= scanRadius then
                    local rarity, rank = readRarity(obj)
                    table.insert(candidates, {object = obj, distance = distance, rarity = rarity, rank = rank})
                end
            end
        end
    end
    -- Remove nested duplicates, preferring a parent model if both qualify.
    local seen = {}
    for _, item in ipairs(candidates) do seen[item.object] = true end
    local unique = {}
    for _, item in ipairs(candidates) do
        local ancestor = item.object.Parent
        local nested = false
        while ancestor and ancestor ~= workspace do
            if seen[ancestor] then nested = true break end
            ancestor = ancestor.Parent
        end
        if not nested then table.insert(unique, item) end
    end
    local highest = 0
    for _, item in ipairs(unique) do highest = math.max(highest, item.rank) end
    for _, item in ipairs(unique) do
        local show = rarityMode == "All"
            or (rarityMode == "Highest Known" and highest > 0 and item.rank == highest)
            or (rarityMode == "Minimum Tier" and item.rank >= minimumTier)
        if item.rank == 0 and includeUnknown and rarityMode ~= "Highest Known" then show = true end
        if show then table.insert(scannedItems, item) end
    end
    table.sort(scannedItems, function(a, b)
        if a.rank ~= b.rank then return a.rank > b.rank end
        return a.distance < b.distance
    end)
    while #scannedItems > 100 do table.remove(scannedItems) end
end

local function clearItemHighlights()
    for _, h in pairs(itemHighlights) do h:Destroy() end
    table.clear(itemHighlights)
end
local function updateScannedESP()
    clearItemHighlights()
    for _, item in ipairs(scannedItems) do
        local obj = item.object
        if obj.Parent and (itemEspAll or chosenItems[obj]) then
            local adornee = obj
            if obj:IsA("Tool") then adornee = obj:FindFirstChild("Handle") end
            if adornee then
                local h = Instance.new("Highlight")
                h.Name = "FreakHubCollectibleESP"
                h.Adornee = adornee
                h.FillColor = Color3.fromRGB(255, 192, 56)
                h.OutlineColor = WHITE
                h.FillTransparency = 0.6
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = gui
                itemHighlights[obj] = h
            end
        end
    end
end
-- Instant Prompt: changes local hold duration only; server rules still apply.
local instantPrompt = false
local originalPrompts = {}
local function setInstantPrompt(enabled)
    instantPrompt = enabled
    if enabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if originalPrompts[obj] == nil then originalPrompts[obj] = obj.HoldDuration end
                obj.HoldDuration = 0
            end
        end
    else
        for prompt, duration in pairs(originalPrompts) do
            if prompt.Parent then prompt.HoldDuration = duration end
        end
        table.clear(originalPrompts)
    end
end
track(workspace.DescendantAdded:Connect(function(obj)
    if instantPrompt and obj:IsA("ProximityPrompt") then
        originalPrompts[obj] = obj.HoldDuration
        obj.HoldDuration = 0
    end
end))
-- Mount detection: supported controls for local physics-owned assemblies.
local mountSpeed = 80
local mountFlySpeed = 60
local mountFly = false
local mountAttachment, mountVelocity
local function findMount()
    local hum = humanoid()
    if not hum then return nil, "No character" end
    local seat = hum.SeatPart
    if seat and (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
        return seat.AssemblyRootPart or seat, "Seat / VehicleSeat"
    end
    return nil, "Custom mount: adapter required"
end
local function stopMountFly()
    mountFly = false
    if not flyEnabled then flyButtons.Visible = false end
    if mountVelocity then mountVelocity:Destroy() mountVelocity = nil end
    if mountAttachment then mountAttachment:Destroy() mountAttachment = nil end
end
local function startMountFly()
    stopMountFly()
    local part, status = findMount()
    if not part then warn("FREAKHUB mount:", status) return false end
    mountAttachment = Instance.new("Attachment")
    mountAttachment.Parent = part
    mountVelocity = Instance.new("LinearVelocity")
    mountVelocity.Attachment0 = mountAttachment
    mountVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    mountVelocity.MaxForce = 1000000
    mountVelocity.Parent = part
    mountFly = true
    flyButtons.Visible = true
    return true
end
track(RunService.Heartbeat:Connect(function()
    if not mountFly or not mountVelocity then return end
    local part = mountAttachment and mountAttachment.Parent
    local hum = humanoid()
    if not part or not part.Parent or not hum or not hum.SeatPart then
        stopMountFly()
        toggleStates["Mount Fly"] = false
        return
    end
    local vertical = (flyUp and 1 or 0) - (flyDown and 1 or 0)
    mountVelocity.VectorVelocity = hum.MoveDirection * mountFlySpeed + Vector3.new(0, vertical * mountFlySpeed, 0)
end))
track(player.CharacterAdded:Connect(stopMountFly))
gui.Destroying:Connect(function()
    stopMountFly()
    setInstantPrompt(false)
end)

local selectTab
local pages = {}
pages.Home = function()
    label("Welcome to FREAKHUB!", 30, 17)
    label("Player: " .. player.Name)
    label("Place ID: " .. tostring(game.PlaceId))
    label("Version: 1.3 | Black & Red")
    label("Functional Studio test modules", 35)
end
pages.Player = function()
    label("PLAYER SETTINGS", 28, 16)
    local setSpeed = slider("WalkSpeed", 16, 200, speed, function(v)
        speed = v
        applySettings()
    end)
    local setJump = slider("JumpPower", 50, 200, jump, function(v)
        jump = v
        applySettings()
    end)
    action("Reset Settings", function()
        setSpeed(16)
        setJump(50)
    end)
end
pages.Movement = function()
    label("MOVEMENT", 30, 16)
    toggle("Noclip", function(enabled)
        noclipEnabled = enabled
        if not enabled then restoreCollision() end
    end)
    toggle("Infinite Jump", function(enabled) infiniteJump = enabled end)
    toggle("Fly", function(enabled)
        if enabled then
            stopMountFly()
            toggleStates["Mount Fly"] = false
            if not startFly() then toggleStates["Fly"] = false end
        else stopFly() end
    end)
    slider("Fly Speed", 15, 120, flySpeed, function(v) flySpeed = v end)
    label("MOUNT CONTROL", 30, 16)
    local statusPart, status = findMount()
    label("Detected: " .. status, 40)
    slider("Mount Speed", 10, 300, mountSpeed, function(v)
        mountSpeed = v
        local hum = humanoid()
        local seat = hum and hum.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            -- Client-side changes may be overwritten by the server.
            pcall(function() seat.MaxSpeed = v end)
        end
    end)
    toggle("Mount Fly", function(enabled)
        if enabled then
            stopFly()
            toggleStates["Fly"] = false
            if not startMountFly() then toggleStates["Mount Fly"] = false end
        else stopMountFly() end
        flyButtons.Visible = flyEnabled or mountFly
    end)
    slider("Mount Fly Speed", 10, 300, mountFlySpeed, function(v) mountFlySpeed = v end)
    action("Refresh Mount Detection", function() selectTab("Movement") end)
    label("UP / DOWN controls: right side when flying", 40)
end
pages.Visual = function()
    label("VISUAL", 30, 16)
    toggle("Fullbright", setFullbright)
    toggle("Player Highlight", function(enabled)
        espEnabled = enabled
        refreshHighlights()
    end)
    action("Open Egg Scanner", function() selectTab("Scanner") end)
end
pages.Scanner = function()
    label("EGG SCANNER | RIDE A PET", 32, 16)
    slider("Scan Radius", 50, 500, scanRadius, function(v) scanRadius = v end)
    action("Rarity Mode: " .. rarityMode, function()
        if rarityMode == "Highest Known" then rarityMode = "Minimum Tier"
        elseif rarityMode == "Minimum Tier" then rarityMode = "All"
        else rarityMode = "Highest Known" end
        selectTab("Scanner")
    end)
    if rarityMode == "Minimum Tier" then
        action("Minimum Rarity: " .. rarityTiers[minimumTier], function()
            minimumTier = minimumTier % #rarityTiers + 1
            selectTab("Scanner")
        end)
    end
    if rarityMode ~= "Highest Known" then
        action("Include Unknown: " .. (includeUnknown and "YES" or "NO"), function()
            includeUnknown = not includeUnknown
            selectTab("Scanner")
        end)
    end
    toggle("Instant Prompt", setInstantPrompt)
    action("Scan / Refresh Eggs", function()
        scanCollectibles()
        updateScannedESP()
        selectTab("Scanner")
    end)
    action("ESP All Results", function()
        itemEspAll = true
        updateScannedESP()
    end)
    action("Clear Item ESP", function()
        itemEspAll = false
        table.clear(chosenItems)
        clearItemHighlights()
    end)
    label("Egg results: " .. tostring(#scannedItems) .. " (max 100)", 30)
    for _, item in ipairs(scannedItems) do
        local obj = item.object
        if obj.Parent then
            local prefix = chosenItems[obj] and "[ON] " or "[ ] "
            action(prefix .. obj.Name .. " | " .. item.rarity .. " | " .. math.floor(item.distance) .. " studs", function()
                chosenItems[obj] = not chosenItems[obj]
                itemEspAll = false
                updateScannedESP()
                selectTab("Scanner")
            end)
        end
    end
    label("Rarity from client metadata/name only. Unknown is not assumed rare.", 56)
end

pages.Teleport = function()
    label("SAVE TELEPORT (5 SLOT)", 30, 16)
    label("Tersimpan hanya selama sesi game.", 30)
    action("Teleport to Spawn", function()
        local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        local character = player.Character
        if spawn and character then
            character:PivotTo(spawn.CFrame + Vector3.new(0, 5, 0))
        else
            warn("Spawn or character not found")
        end
    end)
    for i = 1, 5 do
        local entry = savedLocations[i]
        label("Slot " .. i .. ": " .. (entry and entry.name or "Kosong"), 25)
        if entry then
            action("Teleport ke Slot " .. i, function()
                local character = player.Character
                if character then character:PivotTo(entry.cframe) end
            end)
            action("Hapus Slot " .. i, function()
                savedLocations[i] = nil
                if refreshTeleportPage then refreshTeleportPage() end
            end)
        else
            local nameBox = textInput("Nama lokasi " .. i, "Lokasi " .. i)
            action("Simpan Slot " .. i, function()
                local character = player.Character
                if not character then return end
                savedLocations[i] = {
                    name = nameBox.Text ~= "" and nameBox.Text or ("Lokasi " .. i),
                    cframe = character:GetPivot(),
                }
                -- Rebuild only after the active page function is available.
                if refreshTeleportPage then refreshTeleportPage() end
            end)
        end
    end
end
pages.Settings = function()
    label("SETTINGS", 30, 16)
    label("Theme: Black & Red")
    action("Hide Hub", function() main.Visible = false end)
end

local tabs = {}
selectTab = function(name)
    clearContent()
    pages[name]()
    for tabName, tabButton in pairs(tabs) do
        tabButton.BackgroundColor3 = tabName == name and RED or PANEL
    end
end
refreshTeleportPage = function() selectTab("Teleport") end
for _, name in ipairs({"Home", "Player", "Movement", "Visual", "Scanner", "Teleport", "Settings"}) do
    local tab = button(name, sidebar)
    tab.Size = UDim2.new(1, -10, 0, 31)
    tab.TextSize = 12
    tabs[name] = tab
    tab.Activated:Connect(function() selectTab(name) end)
end

-- Drag support for mouse and touchscreen, with click suppression on floating button.
local function draggable(handle, target, onTap)
    local inputStart, startPos, targetStart
    local moved = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            inputStart = input
            startPos = input.Position
            targetStart = target.Position
            moved = false
        end
    end)
    track(UIS.InputChanged:Connect(function(input)
        if not inputStart then return end
        if input ~= inputStart and not (
            inputStart.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        ) then return end
        local delta = input.Position - startPos
        if delta.Magnitude > 7 then moved = true end
        if moved then
            target.Position = UDim2.new(
                targetStart.X.Scale, targetStart.X.Offset + delta.X,
                targetStart.Y.Scale, targetStart.Y.Offset + delta.Y)
        end
    end))
    track(UIS.InputEnded:Connect(function(input)
        if input ~= inputStart then return end
        inputStart = nil
        if onTap and not moved then onTap() end
    end))
end

draggable(header, main)
-- Use the native button activation event for reliable mouse/touch taps.
-- Floating drag is temporarily disabled to avoid swallowing taps.
floating.Activated:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        local target = main.Size
        main.Size = UDim2.new(target.X.Scale, math.floor(target.X.Offset * 0.93), target.Y.Scale, math.floor(target.Y.Offset * 0.93))
        TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = target}):Play()
    end
    print("FREAKHUB menu:", main.Visible and "OPEN" or "CLOSED")
end)
hide.Activated:Connect(function() main.Visible = false end)
close.Activated:Connect(function() main.Visible = false end)

-- Keep window within small screens.
local camera = workspace.CurrentCamera
local function resize()
    camera = workspace.CurrentCamera
    if not camera then return end
    local size = camera.ViewportSize
    main.Size = UDim2.fromOffset(
        math.min(420, math.max(260, size.X - 20)),
        math.min(355, math.max(230, size.Y - 30)))
end
resize()
if camera then track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)) end

selectTab("Home")
print("FREAKHUB v1.5.0 loaded successfully!")

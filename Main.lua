
-- FREAKHUB v1.8 UNIVERSAL
-- Compact UI / Fly / Mount Fly / ESP Fix

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local PromptService=game:GetService("ProximityPromptService")
local LP=Players.LocalPlayer
if not LP then return end

local PG=LP:WaitForChild("PlayerGui")
local old=PG:FindFirstChild("FREAKHUB_V18")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(12,13,19),
 panel=Color3.fromRGB(22,24,33),
 card=Color3.fromRGB(30,33,43),
 red=Color3.fromRGB(233,52,73),
 white=Color3.fromRGB(242,243,248),
 muted=Color3.fromRGB(151,156,172),
 green=Color3.fromRGB(75,205,144)
}

local alive=true
local connections={}
local marks={}
local itemMarks={}
local results={}
local slots={}
local originalPrompts={}
local noclipParts={}

local states={
 infinite=false,
 noclip=false,
 fly=false,
 mountFly=false,
 playerESP=false,
 itemESP=false,
 instant=false,
 fullbright=false
}

local speed=16
local jump=50
local flySpeed=55
local mountSpeed=65
local radius=150
local filter=""
local vertical=0
local activeFly=nil

local function connect(signal,fn)
 local c=signal:Connect(fn)
 table.insert(connections,c)
 return c
end

local function new(class,parent,props)
 local o=Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent
 return o
end

local function round(o,r)
 new("UICorner",o,{CornerRadius=UDim.new(0,r or 9)})
end

local function label(parent,t,size,color)
 return new("TextLabel",parent,{
  BackgroundTransparency=1,
  Size=UDim2.new(1,0,0,20),
  Text=t,
  TextColor3=color or C.white,
  TextSize=size or 12,
  Font=Enum.Font.GothamMedium,
  TextXAlignment=Enum.TextXAlignment.Left,
  TextTruncate=Enum.TextTruncate.AtEnd
 })
end

local gui=new("ScreenGui",PG,{
 Name="FREAKHUB_V18",
 ResetOnSpawn=false,
 DisplayOrder=500
})

local logo=new("TextButton",gui,{
 Size=UDim2.fromOffset(54,54),
 Position=UDim2.new(0,14,.45,0),
 BackgroundColor3=C.bg,
 Text="F",
 TextSize=32,
 Font=Enum.Font.GothamBlack,
 TextColor3=C.red,
 BorderSizePixel=0,
 Active=true,
 AutoButtonColor=false
})
round(logo,17)
new("UIStroke",logo,{Color=C.red,Thickness=2})

local window=new("Frame",gui,{
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

local head=new("Frame",window,{
 Size=UDim2.new(1,0,0,55),
 BackgroundTransparency=1,
 Active=true
})

local title=label(head,"FREAKHUB",18)
title.Position=UDim2.fromOffset(15,5)
title.Size=UDim2.new(1,-60,0,26)
title.Font=Enum.Font.GothamBold

local sub=label(head,"UNIVERSAL  •  v1.8",10,C.red)
sub.Position=UDim2.fromOffset(16,31)

local close=new("TextButton",head,{
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
  if o:IsA("GuiObject") then o:Destroy() end
 end
end

local function heading(t)
 local f=new("Frame",body,{
  Size=UDim2.new(1,-3,0,27),
  BackgroundTransparency=1
 })
 local l=label(f,t,14)
 l.Font=Enum.Font.GothamBold
 l.Position=UDim2.fromOffset(3,2)
end

local function info(t)
 local f=new("Frame",body,{
  Size=UDim2.new(1,-3,0,38),
  BackgroundColor3=C.panel,
  BorderSizePixel=0
 })
 round(f,8)
 local l=label(f,t,10,C.muted)
 l.Position=UDim2.fromOffset(8,4)
 l.Size=UDim2.new(1,-16,1,-8)
 l.TextWrapped=true
 l.TextTruncate=Enum.TextTruncate.None
end

local function button(t,fn)
 local b=new("TextButton",body,{
  Size=UDim2.new(1,-3,0,31),
  BackgroundColor3=C.card,
  BorderSizePixel=0,
  Text=t,
  TextColor3=C.white,
  TextSize=11,
  Font=Enum.Font.GothamMedium
 })
 round(b,8)
 connect(b.Activated,fn)
 return b
end

local function row(t)
 local f=new("Frame",body,{
  Size=UDim2.new(1,-3,0,35),
  BackgroundColor3=C.card,
  BorderSizePixel=0
 })
 round(f,8)
 local l=label(f,t,11)
 l.Position=UDim2.fromOffset(9,7)
 l.Size=UDim2.new(.60,-9,0,20)
 return f
end

local function toggle(t,key,fn)
 local f=row(t)
 local b=new("TextButton",f,{
  Position=UDim2.new(1,-66,0,5),
  Size=UDim2.fromOffset(59,25),
  BorderSizePixel=0,
  TextSize=10,
  Font=Enum.Font.GothamBold,
  TextColor3=C.white
 })
 round(b,7)
 local function paint()
  b.Text=states[key] and "ON" or "OFF"
  b.BackgroundColor3=states[key] and C.red or C.panel
 end
 connect(b.Activated,function()
  states[key]=not states[key]
  if fn then fn(states[key]) end
  paint()
 end)
 paint()
end

local function numberRow(t,value,callback)
 local f=row(t)
 local box=new("TextBox",f,{
  Position=UDim2.new(1,-105,0,5),
  Size=UDim2.fromOffset(52,25),
  BackgroundColor3=C.panel,
  BorderSizePixel=0,
  Text=tostring(value),
  TextColor3=C.white,
  TextSize=11,
  ClearTextOnFocus=false
 })
 round(box,6)
 local apply=new("TextButton",f,{
  Position=UDim2.new(1,-49,0,5),
  Size=UDim2.fromOffset(42,25),
  BackgroundColor3=C.red,
  BorderSizePixel=0,
  Text="SET",
  TextColor3=C.white,
  TextSize=10
 })
 round(apply,6)
 connect(apply.Activated,function()
  callback(tonumber(box.Text))
 end)
 return box
end

local function hum()
 local c=LP.Character
 return c and c:FindFirstChildOfClass("Humanoid")
end

local function root()
 local c=LP.Character
 return c and c:FindFirstChild("HumanoidRootPart")
end

local function applyPlayer()
 local h=hum()
 if h then
  h.WalkSpeed=speed
  h.UseJumpPower=true
  h.JumpPower=jump
 end
end

connect(LP.CharacterAdded,function(c)
 c:WaitForChild("Humanoid",10)
 task.defer(applyPlayer)
end)

connect(UIS.JumpRequest,function()
 if states.infinite then
  local h=hum()
  if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
end)

-- NOCLIP

local function restoreNoclip()
 for p,value in pairs(noclipParts) do
  if p.Parent then p.CanCollide=value end
 end
 table.clear(noclipParts)
end

connect(RS.Stepped,function()
 if states.noclip and LP.Character then
  for _,p in ipairs(LP.Character:GetDescendants()) do
   if p:IsA("BasePart") then
    if noclipParts[p]==nil then
     noclipParts[p]=p.CanCollide
    end
    p.CanCollide=false
   end
  end
 end
end)

-- FLY ENGINE
-- Uses client-side LinearVelocity and AlignOrientation

local function stopFly()
 if activeFly then
  for _,o in ipairs(activeFly.objects) do
   if o and o.Parent then o:Destroy() end
  end
  activeFly=nil
 end
 vertical=0
end

local function startFly(part,mode)
 stopFly()
 if not part or not part:IsA("BasePart") then return false end

 local attachment=new("Attachment",part,{Name="FH_FlyAttachment"})

 local velocity=new("LinearVelocity",part,{
  Name="FH_FlyVelocity",
  Attachment0=attachment,
  RelativeTo=Enum.ActuatorRelativeTo.World,
  VelocityConstraintMode=Enum.VelocityConstraintMode.Vector,
  VectorVelocity=Vector3.zero,
  MaxForce=1e9,
  ForceLimitsEnabled=false
 })

 local orientation=new("AlignOrientation",part,{
  Name="FH_FlyOrientation",
  Attachment0=attachment,
  Mode=Enum.OrientationAlignmentMode.OneAttachment,
  MaxTorque=1e9,
  Responsiveness=15,
  RigidityEnabled=false
 })

 activeFly={
  part=part,
  mode=mode,
  objects={attachment,velocity,orientation},
  velocity=velocity,
  orientation=orientation
 }
 return true
end

local function mountPart()
 local h=hum()
 if not h or not h.SeatPart then return nil end
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
  startFly(root(),"player")
 else
  if activeFly and activeFly.mode=="player" then
   stopFly()
  end
 end
end

local function setMountFly(on)
 if on then
  states.fly=false
  local p=mountPart()
  if not p then
   states.mountFly=false
   return
  end
  startFly(p,"mount")
 else
  if activeFly and activeFly.mode=="mount" then
   stopFly()
  end
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
  if not states.mountFly or not hum() or not hum().SeatPart then
   states.mountFly=false
   stopFly()
   return
  end
 end

 local camera=workspace.CurrentCamera
 if not camera then return end

 local h=hum()
 local move=h and h.MoveDirection or Vector3.zero
 local magnitude=move.Magnitude

 local direction=Vector3.zero
 if magnitude>0 then
  direction=move.Unit
 end

 local currentSpeed=a.mode=="mount" and mountSpeed or flySpeed

 a.velocity.VectorVelocity=
  direction*currentSpeed+
  Vector3.new(0,vertical*currentSpeed,0)

 local look=camera.CFrame.LookVector
 local flat=Vector3.new(look.X,0,look.Z)
 if flat.Magnitude>.01 then
  a.orientation.CFrame=CFrame.lookAt(Vector3.zero,flat.Unit)
 end
end)

-- ESP ENGINE

local function clearMarks(tbl)
 for _,h in pairs(tbl) do
  if h then h:Destroy() end
 end
 table.clear(tbl)
end

local function highlight(obj,color)
 if not obj or not obj.Parent then return nil end
 local h=new("Highlight",gui,{
  Adornee=obj,
  FillColor=color,
  OutlineColor=C.white,
  FillTransparency=.72,
  OutlineTransparency=0,
  DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
 })
 return h
end

local function syncPlayers()
 if not states.playerESP then
  clearMarks(marks)
  return
 end

 for p,h in pairs(marks) do
  if not p.Parent or not p.Character
   or not h.Parent or h.Adornee~=p.Character then
   h:Destroy()
   marks[p]=nil
  end
 end

 for _,p in ipairs(Players:GetPlayers()) do
  if p~=LP and p.Character and p.Character.Parent then
   if not marks[p] then
    marks[p]=highlight(p.Character,C.red)
   end
  end
 end
end

-- Periodic sync handles respawns and streaming
local espElapsed=0
connect(RS.Heartbeat,function(dt)
 espElapsed=espElapsed+dt
 if espElapsed>=1.5 then
  espElapsed=0
  syncPlayers()
 end
end)

-- UNIVERSAL ITEM SCANNER

local keywords={
 "coin","gem","diamond","loot","drop",
 "chest","treasure","egg","collect",
 "pickup","reward","item","crystal",
 "fruit","key","token","orb","gift","tool"
}

local function keyword(s)
 s=string.lower(s)
 for _,k in ipairs(keywords) do
  if string.find(s,k,1,true) then return true end
 end
 return false
end

local function collectible(o)
 if o:IsA("Tool") then return true end
 if not (o:IsA("Model") or o:IsA("BasePart")) then
  return false
 end
 if keyword(o.Name) then return true end
 if o:FindFirstChildWhichIsA("ProximityPrompt",true) then
  return true
 end
 return false
end

local function pos(o)
 if o:IsA("BasePart") then return o.Position end
 if o:IsA("Model") then return o:GetPivot().Position end
 if o:IsA("Tool") then
  local handle=o:FindFirstChild("Handle")
  if handle then return handle.Position end
 end
end

local function scan()
 table.clear(results)
 local r=root()
 if not r then return end
 local seen={}

 for _,o in ipairs(workspace:GetDescendants()) do
  if #results>=150 then break end
  if collectible(o) then
   local target=o
   if o:IsA("BasePart") then
    local model=o:FindFirstAncestorOfClass("Model")
    if model and collectible(model) then
     target=model
    end
   end

   local ch=LP.Character
   if target.Parent and not seen[target]
    and not (ch and target:IsDescendantOf(ch))
    and not Players:GetPlayerFromCharacter(target) then
    local p=pos(target)
    if p then
     local d=(p-r.Position).Magnitude
     if d<=radius and (
      filter=="" or
      string.find(string.lower(target.Name),string.lower(filter),1,true)
     ) then
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
    local h=highlight(target,C.green)
    if h then table.insert(itemMarks,h) end
   end
  end
 end
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
  for p,d in pairs(originalPrompts) do
   if p.Parent then p.HoldDuration=d end
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

local function holdButton(t,y,dir)
 local b=new("TextButton",controls,{
  Position=UDim2.fromOffset(8,y),
  Size=UDim2.fromOffset(99,42),
  BackgroundColor3=C.red,
  BorderSizePixel=0,
  Text=t,
  TextColor3=C.white,
  TextSize=13,
  Font=Enum.Font.GothamBold
 })
 round(b,9)

 connect(b.InputBegan,function(input)
  if input.UserInputType==Enum.UserInputType.Touch
   or input.UserInputType==Enum.UserInputType.MouseButton1 then
   vertical=dir
  end
 end)

 connect(b.InputEnded,function(input)
  if input.UserInputType==Enum.UserInputType.Touch
   or input.UserInputType==Enum.UserInputType.MouseButton1 then
   if vertical==dir then vertical=0 end
  end
 end)
end

holdButton("▲ UP",7,1)
holdButton("▼ DOWN",55,-1)

-- PAGE CONTENT

local pages={}
local switch

pages.Home=function()
 heading("Dashboard")
 info("FREAKHUB UNIVERSAL v1.8")
 info("Player: "..LP.Name)
 info("Compact UI • Fly • ESP • Scanner")
 button("PLAYER SETTINGS",function() switch("Player") end)
 button("ESP CENTER",function() switch("ESP") end)
 button("ITEM SCANNER",function() switch("Scanner") end)
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

 info("Mount Fly memerlukan Seat/VehicleSeat aktif.")
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
  clearMarks(marks)
  clearMarks(itemMarks)
  switch("ESP")
 end)

 info("Player ESP otomatis refresh setiap 1,5 detik.")
end

pages.Scanner=function()
 heading("Item Scanner")

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
 info("Mencari kandidat item yang terlihat di client.")
end

pages.Results=function()
 heading("Scan Results")
 info("Found: "..#results.." candidates")

 button("SCAN AGAIN",function()
  scan()
  syncItems()
  switch("Results")
 end)

 for i,e in ipairs(results) do
  if i>45 then break end
  button(e.name.." • "..e.distance.." studs",function()
   local target=e.obj
   if target and target.Parent then
    if target:IsA("Tool") then
     target=target:FindFirstChild("Handle")
    end
    if target then
     local h=highlight(target,C.green)
     if h then table.insert(itemMarks,h) end
    end
   end
  end)
 end
end

pages.Teleport=function()
 heading("Teleport Slots")

 for i=1,5 do
  local index=i
  local saved=slots[index]
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
   if r then slots[index]=r.CFrame end
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

 info("Drag tombol F untuk mengubah posisi.")
end

-- SIDEBAR

local tabs={}

for i,name in ipairs({
 "Home","Player","ESP","Scanner",
 "Results","Teleport","Utility"
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
 connect(b.Activated,function() switch(name) end)
end

switch=function(name)
 wipe()
 pages[name]()
 for n,b in pairs(tabs) do
  b.BackgroundColor3=n==name and C.red or C.card
 end
end

-- DRAG SUPPORT

local function draggable(handle,target,tap)
 local active,start,origin,moved=nil,nil,nil,false

 connect(handle.InputBegan,function(input)
  if input.UserInputType==Enum.UserInputType.Touch
   or input.UserInputType==Enum.UserInputType.MouseButton1 then
   active=input
   start=input.Position
   origin=target.Position
   moved=false
  end
 end)

 connect(UIS.InputChanged,function(input)
  if not active then return end
  local mouse=
   active.UserInputType==Enum.UserInputType.MouseButton1
   and input.UserInputType==Enum.UserInputType.MouseMovement

  if input~=active and not mouse then return end
  local delta=input.Position-start
  if delta.Magnitude>8 then moved=true end

  if moved then
   target.Position=UDim2.new(
    origin.X.Scale,origin.X.Offset+delta.X,
    origin.Y.Scale,origin.Y.Offset+delta.Y
   )
  end
 end)

 connect(UIS.InputEnded,function(input)
  if input~=active then return end
  active=nil
  if not moved and tap then tap() end
 end)
end

draggable(logo,logo,function()
 window.Visible=not window.Visible
end)
draggable(head,window)

connect(close.Activated,function()
 window.Visible=false
end)

local function fit()
 local cam=workspace.CurrentCamera
 if not cam then return end
 local v=cam.ViewportSize
 window.Size=UDim2.fromOffset(
  math.min(390,math.max(220,v.X-12)),
  math.min(400,math.max(240,v.Y-28))
 )
end

fit()
if workspace.CurrentCamera then
 connect(
  workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),
  fit
 )
end

-- CLEANUP

connect(gui.Destroying,function()
 alive=false
 stopFly()
 restoreNoclip()
 clearMarks(marks)
 clearMarks(itemMarks)
 states.instant=false
 setInstant(false)
 fullbright(false)

 for _,c in ipairs(connections) do
  c:Disconnect()
 end
end)

switch("Home")
print("FREAKHUB v1.8 UNIVERSAL LOADED")

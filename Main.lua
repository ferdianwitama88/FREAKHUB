
-- FREAKHUB v1.7 UNIVERSAL
-- Mobile-first structured interface

local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local Tween=game:GetService('TweenService')
local PromptService=game:GetService('ProximityPromptService')
local CollectionService=game:GetService('CollectionService')
local LP=Players.LocalPlayer
if not LP then return end

local PG=LP:WaitForChild('PlayerGui')
local previous=PG:FindFirstChild('FREAKHUB_V17')
if previous then previous:Destroy() end

local C={
 bg=Color3.fromRGB(12,13,19),
 panel=Color3.fromRGB(22,24,33),
 card=Color3.fromRGB(30,33,43),
 red=Color3.fromRGB(233,52,73),
 white=Color3.fromRGB(242,243,248),
 muted=Color3.fromRGB(151,156,172),
 green=Color3.fromRGB(75,205,144)
}

local connections={}

local function connect(signal,fn)
 local c=signal:Connect(fn)
 table.insert(connections,c)
 return c
end

local function new(class,parent,p)
 local o=Instance.new(class)
 for k,v in pairs(p or {}) do
  o[k]=v
 end
 o.Parent=parent
 return o
end

local function corner(o,r)
 new('UICorner',o,{
  CornerRadius=UDim.new(0,r or 10)
 })
end

local function stroke(o,color)
 new('UIStroke',o,{
  Color=color or Color3.fromRGB(48,51,65),
  Thickness=1
 })
end

local function label(parent,t,size,color,height)
 return new('TextLabel',parent,{
  BackgroundTransparency=1,
  Size=UDim2.new(1,0,0,height or 22),
  Text=t,
  TextColor3=color or C.white,
  Font=Enum.Font.GothamMedium,
  TextSize=size or 13,
  TextXAlignment=Enum.TextXAlignment.Left,
  TextWrapped=true
 })
end

local gui=new('ScreenGui',PG,{
 Name='FREAKHUB_V17',
 ResetOnSpawn=false,
 DisplayOrder=500,
 IgnoreGuiInset=false
})

-- FLOATING LOGO

local logo=new('TextButton',gui,{
 Name='FloatingF',
 Size=UDim2.fromOffset(54,54),
 Position=UDim2.new(0,14,0.45,0),
 BackgroundColor3=C.bg,
 BorderSizePixel=0,
 Text='F',
 TextSize=32,
 Font=Enum.Font.GothamBlack,
 TextColor3=C.red,
 Active=true,
 AutoButtonColor=false
})

corner(logo,17)
stroke(logo,C.red)

-- MAIN WINDOW

local window=new('Frame',gui,{
 Size=UDim2.fromOffset(390,400),
 Position=UDim2.fromScale(.5,.5),
 AnchorPoint=Vector2.new(.5,.5),
 BackgroundColor3=C.bg,
 BorderSizePixel=0,
 Visible=false,
 Active=true
})

corner(window,16)
stroke(window)

local head=new('Frame',window,{
 Size=UDim2.new(1,0,0,55),
 BackgroundTransparency=1,
 Active=true
})

new('TextLabel',head,{
 Position=UDim2.fromOffset(15,6),
 Size=UDim2.new(1,-60,0,24),
 BackgroundTransparency=1,
 Text='FREAKHUB',
 TextColor3=C.white,
 Font=Enum.Font.GothamBold,
 TextSize=18,
 TextXAlignment=Enum.TextXAlignment.Left
})

new('TextLabel',head,{
 Position=UDim2.fromOffset(16,29),
 Size=UDim2.new(1,-60,0,15),
 BackgroundTransparency=1,
 Text='UNIVERSAL  •  v1.7',
 TextColor3=C.red,
 Font=Enum.Font.GothamMedium,
 TextSize=10,
 TextXAlignment=Enum.TextXAlignment.Left
})

local close=new('TextButton',head,{
 Size=UDim2.fromOffset(31,31),
 Position=UDim2.new(1,-41,0,12),
 BackgroundColor3=C.red,
 Text='×',
 TextSize=23,
 TextColor3=C.white,
 BorderSizePixel=0
})
corner(close,9)

-- SIDEBAR

local sidebar=new('ScrollingFrame',window,{
 Position=UDim2.fromOffset(10,60),
 Size=UDim2.new(0,106,1,-70),
 BackgroundColor3=C.panel,
 BorderSizePixel=0,
 ScrollBarThickness=0,
 AutomaticCanvasSize=Enum.AutomaticSize.Y,
 CanvasSize=UDim2.new()
})
corner(sidebar,12)

new('UIPadding',sidebar,{
 PaddingTop=UDim.new(0,8),
 PaddingLeft=UDim.new(0,6),
 PaddingRight=UDim.new(0,6),
 PaddingBottom=UDim.new(0,8)
})

new('UIListLayout',sidebar,{
 Padding=UDim.new(0,6),
 SortOrder=Enum.SortOrder.LayoutOrder
})

local body=new('ScrollingFrame',window,{
 Position=UDim2.fromOffset(124,60),
 Size=UDim2.new(1,-134,1,-70),
 BackgroundTransparency=1,
 BorderSizePixel=0,
 ScrollBarThickness=3,
 ScrollBarImageColor3=C.red,
 AutomaticCanvasSize=Enum.AutomaticSize.Y,
 CanvasSize=UDim2.new()
})

new('UIListLayout',body,{
 Padding=UDim.new(0,9),
 SortOrder=Enum.SortOrder.LayoutOrder
})

local function wipe()
 for _,o in ipairs(body:GetChildren()) do
  if o:IsA('GuiObject') then
   o:Destroy()
  end
 end
end

local function section(name,description)
 local f=new('Frame',body,{
  Size=UDim2.new(1,-4,0,description and 52 or 31),
  BackgroundTransparency=1
 })

 local l=label(f,name,15,C.white,24)
 l.Font=Enum.Font.GothamBold

 if description then
  local d=label(f,description,11,C.muted,26)
  d.Position=UDim2.fromOffset(0,24)
 end
end

local function card(title,description)
 local f=new('Frame',body,{
  Size=UDim2.new(1,-4,0,description and 78 or 54),
  BackgroundColor3=C.card,
  BorderSizePixel=0
 })
 corner(f,11)

 local t=label(f,title,12,C.white,23)
 t.Position=UDim2.fromOffset(11,7)
 t.Size=UDim2.new(1,-22,0,23)

 if description then
  local d=label(f,description,10,C.muted,37)
  d.Position=UDim2.fromOffset(11,29)
  d.Size=UDim2.new(1,-22,0,37)
 end
 return f
end

local function button(title,callback)
 local b=new('TextButton',body,{
  Size=UDim2.new(1,-4,0,38),
  BackgroundColor3=C.card,
  BorderSizePixel=0,
  Text=title,
  TextColor3=C.white,
  TextSize=12,
  Font=Enum.Font.GothamMedium
 })
 corner(b,10)
 connect(b.Activated,callback)
 return b
end

local function field(hint,value)
 local b=new('TextBox',body,{
  Size=UDim2.new(1,-4,0,36),
  BackgroundColor3=C.card,
  BorderSizePixel=0,
  Text=value or '',
  PlaceholderText=hint,
  PlaceholderColor3=C.muted,
  TextColor3=C.white,
  TextSize=12,
  Font=Enum.Font.Gotham,
  ClearTextOnFocus=false
 })
 corner(b,10)
 return b
end

local states={
 infinite=false,
 playerESP=false,
 itemESP=false,
 instant=false,
 noclip=false,
 fullbright=false
}

local function toggle(title,key,callback)
 local b=button('',function() end)

 local function paint()
  b.Text=title..(states[key] and '   ● ON' or '   ○ OFF')
  b.BackgroundColor3=states[key] and C.red or C.card
 end

 connect(b.Activated,function()
  states[key]=not states[key]
  if callback then
   callback(states[key])
  end
  paint()
 end)

 paint()
 return b
end

-- PLAYER SYSTEM

local function hum()
 local ch=LP.Character
 return ch and ch:FindFirstChildOfClass('Humanoid')
end

local function root()
 local ch=LP.Character
 return ch and ch:FindFirstChild('HumanoidRootPart')
end

local speed,jump=16,50

local function apply()
 local h=hum()
 if h then
  h.WalkSpeed=speed
  h.UseJumpPower=true
  h.JumpPower=jump
 end
end

connect(LP.CharacterAdded,function(ch)
 ch:WaitForChild('Humanoid',10)
 task.defer(apply)
end)

-- INFINITE JUMP

connect(UIS.JumpRequest,function()
 if states.infinite then
  local h=hum()
  if h then
   h:ChangeState(Enum.HumanoidStateType.Jumping)
  end
 end
end)

-- NOCLIP

connect(game:GetService('RunService').Stepped,function()
 if states.noclip and LP.Character then
  for _,p in ipairs(LP.Character:GetDescendants()) do
   if p:IsA('BasePart') then
    p.CanCollide=false
   end
  end
 end
end)

-- FULLBRIGHT

local lighting=game:GetService('Lighting')

local lightOld={
 Brightness=lighting.Brightness,
 ClockTime=lighting.ClockTime,
 FogEnd=lighting.FogEnd,
 GlobalShadows=lighting.GlobalShadows
}

local function fullbright(on)
 if on then
  lighting.Brightness=3
  lighting.ClockTime=14
  lighting.FogEnd=100000
  lighting.GlobalShadows=false
 else
  for k,v in pairs(lightOld) do
   lighting[k]=v
  end
 end
end

-- INSTANT PROMPT

local promptOld={}

local function updatePrompt(p)
 if not p:IsA('ProximityPrompt') then return end

 if promptOld[p]==nil then
  promptOld[p]=p.HoldDuration
 end

 if states.instant then
  p.HoldDuration=0
 end
end

local function instant(on)
 if on then
  for _,p in ipairs(workspace:GetDescendants()) do
   if p:IsA('ProximityPrompt') then
    updatePrompt(p)
   end
  end
 else
  for p,d in pairs(promptOld) do
   if p.Parent then
    p.HoldDuration=d
   end
  end
  table.clear(promptOld)
 end
end

connect(workspace.DescendantAdded,function(p)
 if states.instant and p:IsA('ProximityPrompt') then
  task.defer(function()
   if p.Parent then
    updatePrompt(p)
   end
  end)
 end
end)

connect(PromptService.PromptShown,function(p)
 if states.instant then
  updatePrompt(p)
 end
end)

-- ESP SYSTEM

local playerMarks,itemMarks={},{}

local function mark(adornee,parent,color)
 if not adornee or not adornee.Parent then return end

 local h=new('Highlight',gui,{
  Adornee=adornee,
  FillColor=color or C.red,
  OutlineColor=C.white,
  FillTransparency=.68,
  OutlineTransparency=0,
  DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
 })
 return h
end

local function clearMarks(t)
 for _,h in pairs(t) do
  if h then
   h:Destroy()
  end
 end
 table.clear(t)
end

local function updatePlayerESP()
 clearMarks(playerMarks)

 if not states.playerESP then return end

 for _,p in ipairs(Players:GetPlayers()) do
  if p~=LP and p.Character then
   playerMarks[p]=mark(p.Character,gui,C.red)
  end
 end
end

connect(Players.PlayerAdded,function(p)
 connect(p.CharacterAdded,function()
  task.wait(.4)
  if states.playerESP then
   updatePlayerESP()
  end
 end)
end)

connect(Players.PlayerRemoving,function(p)
 if playerMarks[p] then
  playerMarks[p]:Destroy()
  playerMarks[p]=nil
 end
end)

for _,p in ipairs(Players:GetPlayers()) do
 if p~=LP then
  connect(p.CharacterAdded,function()
   task.wait(.4)
   if states.playerESP then
    updatePlayerESP()
   end
  end)
 end
end

-- UNIVERSAL ITEM SCANNER

local keywords={
 'coin','gem','diamond','loot','drop',
 'chest','treasure','egg','collect',
 'pickup','reward','item','crystal',
 'fruit','key','token','orb','gift',
 'tool','pet'
}

local function keyword(s)
 s=string.lower(s)

 for _,k in ipairs(keywords) do
  if string.find(s,k,1,true) then
   return true
  end
 end
 return false
end

local function collectible(o)
 if o:IsA('Tool') then return true end

 if not (o:IsA('BasePart') or o:IsA('Model')) then
  return false
 end

 if keyword(o.Name) then return true end

 for _,t in ipairs(CollectionService:GetTags(o)) do
  if keyword(t) then return true end
 end

 for k,v in pairs(o:GetAttributes()) do
  if v~=false and keyword(k) then
   return true
  end
 end

 if o:FindFirstChildWhichIsA('ProximityPrompt',true) then
  return true
 end

 return false
end

local function position(o)
 if o:IsA('BasePart') then
  return o.Position
 end

 if o:IsA('Model') then
  return o:GetPivot().Position
 end

 if o:IsA('Tool') then
  local h=o:FindFirstChild('Handle')
  if h and h:IsA('BasePart') then
   return h.Position
  end
 end
end

local radius,filter=150,''
local results={}

local function scan()
 table.clear(results)

 local r=root()
 if not r then return end

 local seen={}

 for _,o in ipairs(workspace:GetDescendants()) do
  if #results>=150 then break end

  if collectible(o) then
   local target=o

   if o:IsA('BasePart') then
    local m=o:FindFirstAncestorOfClass('Model')
    if m and collectible(m) then
     target=m
    end
   end

   local char=LP.Character

   if target.Parent and not seen[target]
    and not (char and target:IsDescendantOf(char)) then

    local p=position(target)

    if p then
     local d=(p-r.Position).Magnitude

     if d<=radius and (
      filter=='' or
      string.find(
       string.lower(target.Name),
       string.lower(filter),
       1,true
      )
     ) then
      seen[target]=true

      table.insert(results,{
       obj=target,
       dist=math.floor(d),
       name=target.Name
      })
     end
    end
   end
  end
 end

 table.sort(results,function(a,b)
  return a.dist<b.dist
 end)
end

local function updateItemESP()
 clearMarks(itemMarks)

 if not states.itemESP then return end

 for _,entry in ipairs(results) do
  local obj=entry.obj

  local target=obj:IsA('Tool')
   and obj:FindFirstChild('Handle') or obj

  if target then
   table.insert(
    itemMarks,
    mark(target,gui,C.green)
   )
  end
 end
end

-- TELEPORT SLOTS

local saved={}
local pages={}
local switch

-- DASHBOARD

pages.Dashboard=function()
 section('Dashboard','Fitur utama dan status FREAKHUB.')

 card(
  'FREAKHUB UNIVERSAL',
  'v1.7 • Mobile UI • '..LP.Name
 )

 card(
  'Status fitur',
  'Infinite Jump: '..
  (states.infinite and 'ON' or 'OFF')..
  '  |  Player ESP: '..
  (states.playerESP and 'ON' or 'OFF')
 )

 button('Buka Player',function()
  switch('Player')
 end)

 button('Buka ESP',function()
  switch('ESP')
 end)

 button('Buka Scanner',function()
  switch('Scanner')
 end)
end

-- PLAYER TAB

pages.Player=function()
 section('Player','Gerakan dan kemampuan karakter.')

 toggle('Infinite Jump','infinite')
 toggle('Noclip','noclip')

 local s=field('WalkSpeed',tostring(speed))

 button('Terapkan WalkSpeed',function()
  speed=math.clamp(tonumber(s.Text) or 16,16,200)
  apply()
 end)

 local j=field('JumpPower',tostring(jump))

 button('Terapkan JumpPower',function()
  jump=math.clamp(tonumber(j.Text) or 50,50,200)
  apply()
 end)

 button('Reset Speed & Jump',function()
  speed=16
  jump=50
  apply()
  s.Text='16'
  j.Text='50'
 end)
end

-- ESP TAB

pages.ESP=function()
 section('ESP Center','Pengaturan visual dipisahkan dari scanner.')

 toggle('Player ESP','playerESP',function()
  updatePlayerESP()
 end)

 card(
  'Player ESP',
  'Menandai karakter pemain lain yang terlihat di client.'
 )

 toggle('Item ESP','itemESP',function()
  updateItemESP()
 end)

 card(
  'Item ESP',
  'Menandai hasil Scanner terakhir. Scan dahulu untuk mendapatkan hasil.'
 )

 button('Refresh Player ESP',updatePlayerESP)
 button('Refresh Item ESP',updateItemESP)

 button('Clear All ESP',function()
  states.playerESP=false
  states.itemESP=false
  clearMarks(playerMarks)
  clearMarks(itemMarks)
  switch('ESP')
 end)
end

-- SCANNER TAB

pages.Scanner=function()
 section('Item Scanner','Cari kandidat item pada berbagai game.')

 local rad=field('Radius (25–500)',tostring(radius))
 local fil=field('Filter nama, kosong = semua',filter)

 button('Scan Sekarang',function()
  radius=math.clamp(
   tonumber(rad.Text) or 150,
   25,500
  )

  filter=fil.Text
  scan()

  if states.itemESP then
   updateItemESP()
  end

  switch('Results')
 end)

 toggle('Instant Prompt','instant',instant)

 card(
  'Catatan',
  'Instant Prompt hanya mengubah HoldDuration lokal; validasi server tetap berlaku.'
 )
end

-- RESULTS TAB

pages.Results=function()
 section(
  'Hasil Scan',
  tostring(#results)..' kandidat terdeteksi.'
 )

 button('Scan Ulang',function()
  scan()

  if states.itemESP then
   updateItemESP()
  end

  switch('Results')
 end)

 button('Aktifkan Item ESP',function()
  states.itemESP=true
  updateItemESP()
  switch('ESP')
 end)

 for i,entry in ipairs(results) do
  if i>45 then break end

  local obj=entry.obj

  button(
   entry.name..' • '..entry.dist..' studs',
   function()
    if obj and obj.Parent then
     local t=obj:IsA('Tool')
      and obj:FindFirstChild('Handle') or obj

     if t then
      table.insert(
       itemMarks,
       mark(t,gui,C.green)
      )
     end
    end
   end
  )
 end

 if #results==0 then
  card(
   'Belum ada hasil',
   'Buka Scanner lalu tekan Scan Sekarang.'
  )
 end
end

-- TELEPORT TAB

pages.Teleport=function()
 section(
  'Teleport Slots',
  'Simpan sampai 5 lokasi selama sesi.'
 )

 for i=1,5 do
  local slot=i
  local data=saved[slot]

  local n=field(
   'Nama Slot '..slot,
   data and data.name or ''
  )

  button('Simpan Slot '..slot,function()
   local r=root()

   if r then
    saved[slot]={
     name=n.Text~='' and n.Text or 'Slot '..slot,
     cf=r.CFrame
    }

    switch('Teleport')
   end
  end)

  if data then
   button('Teleport → '..data.name,function()
    if LP.Character then
     LP.Character:PivotTo(data.cf)
    end
   end)

   button('Hapus Slot '..slot,function()
    saved[slot]=nil
    switch('Teleport')
   end)
  end
 end
end

-- UTILITY TAB

pages.Utility=function()
 section('Utility','Pengaturan dunia dan antarmuka.')

 toggle('Fullbright','fullbright',fullbright)

 button('Reset Posisi Logo',function()
  logo.Position=UDim2.new(0,14,.45,0)
 end)

 button('Tutup Menu',function()
  window.Visible=false
 end)

 card(
  'Drag & Tap',
  'Geser tombol F untuk pindah. Ketuk tombol F untuk membuka menu.'
 )
end

-- TAB NAVIGATION

local tabButtons={}

for i,name in ipairs({
 'Dashboard',
 'Player',
 'ESP',
 'Scanner',
 'Results',
 'Teleport',
 'Utility'
}) do

 local b=new('TextButton',sidebar,{
  Size=UDim2.new(1,0,0,38),
  BackgroundColor3=C.card,
  BorderSizePixel=0,
  Text=name,
  TextSize=11,
  Font=Enum.Font.GothamMedium,
  TextColor3=C.white,
  LayoutOrder=i
 })

 corner(b,9)
 tabButtons[name]=b

 connect(b.Activated,function()
  switch(name)
 end)
end

switch=function(name)
 wipe()
 pages[name]()

 for n,b in pairs(tabButtons) do
  b.BackgroundColor3=n==name and C.red or C.card
 end
end

-- MOBILE DRAG SYSTEM

local function drag(handle,target,tap)
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

  if input~=active and not (
   active.UserInputType==Enum.UserInputType.MouseButton1
   and input.UserInputType==Enum.UserInputType.MouseMovement
  ) then
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

drag(logo,logo,function()
 window.Visible=not window.Visible

 if window.Visible then
  local size=window.Size

  window.Size=UDim2.new(
   size.X.Scale,
   size.X.Offset-12,
   size.Y.Scale,
   size.Y.Offset-12
  )

  Tween:Create(
   window,
   TweenInfo.new(.15),
   {Size=size}
  ):Play()
 end
end)

drag(head,window)

connect(close.Activated,function()
 window.Visible=false
end)

-- RESPONSIVE WINDOW

local function fit()
 local cam=workspace.CurrentCamera

 if cam then
  local v=cam.ViewportSize

  window.Size=UDim2.fromOffset(
   math.max(230,math.min(390,v.X-12)),
   math.max(245,math.min(400,v.Y-28))
  )
 end
end

fit()

connect(
 workspace:GetPropertyChangedSignal('CurrentCamera'),
 fit
)

if workspace.CurrentCamera then
 connect(
  workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),
  fit
 )
end

-- CLEANUP

connect(gui.Destroying,function()
 states.infinite=false
 states.noclip=false
 states.playerESP=false
 states.itemESP=false

 clearMarks(playerMarks)
 clearMarks(itemMarks)

 instant(false)
 fullbright(false)

 for _,c in ipairs(connections) do
  c:Disconnect()
 end
end)

switch('Dashboard')

print('FREAKHUB v1.7 UNIVERSAL LOADED')

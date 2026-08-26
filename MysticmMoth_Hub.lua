-- MysticmMoth Hub
-- Originated by Credits To LeoDicap On The Old V3rmillion For Helping Me A Lot With The Script.
-- Version: 2.1.0 - Fluent UI execution fix
-- UI: Fluent-modded by StyearX

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer

local SUPPORTED = 13864667823
local LOBBY = {[14775231477]=true,[13864661000]=true}

local function fallback(t,m)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=6}) end)
end
if game.PlaceId ~= SUPPORTED and not LOBBY[game.PlaceId] then fallback("MysticmMoth Hub","Warning: Game Not Supported!"); return end

-- Fluent-modded official release loader.
local Fluent
local ok,err=pcall(function()
    local src=game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro")
    local fn=assert(loadstring(src),"Fluent source did not compile")
    Fluent=fn()
end)
if not ok or not Fluent then fallback("MysticmMoth Hub","Fluent UI failed to load. Make sure your executor supports HttpGet/loadstring."); return end

local Window=Fluent:CreateWindow({
    Title="MysticmMoth Hub",SubTitle="v2.1.0 • Fluent UI",TabWidth=160,
    Size=UDim2.fromOffset(650,520),Acrylic=true,Theme="Deep Violet",
    MinimizeKey=Enum.KeyCode.LeftControl,Search=true,
})
local function notify(t,m,d) pcall(function() Fluent:Notify({Title=t,Content=m,Duration=d or 5}) end) end

local State={Item="Med Kit",Damage=5,Position=1,WalkSpeed=50,JumpPower=100,
    Slip=false,God=false,Heal=false,HealAll=false,NoWind=false,NoWindSS=false,Noclip=false,Float=false,
    KillLoop=false,BreakLoop=false,BringLoop=false,CashLoop=false,PeteLoop=false,ESP=false}
local Events=RS:FindFirstChild("Events")
local function char() return LP.Character or LP.CharacterAdded:Wait() end
local function root() return char():FindFirstChild("HumanoidRootPart") end
local function hum() return char():FindFirstChildOfClass("Humanoid") end
local function remote(n) return Events and Events:FindFirstChild(n) end
local function fire(n,...)
    local r=remote(n); if not r then notify("Warning","Remote not found: "..n,4); return false end
    local a={...}; local good,e=pcall(function() r:FireServer(unpack(a)) end)
    if not good then notify("Warning",tostring(e),5) end
    return good
end
local function tp(cf) local r=root(); if r then r.CFrame=cf else notify("Warning","Character is not ready.",3) end end
local function safe(f) local a,e=pcall(f); if not a then notify("Warning",tostring(e),5) end return a end
local function delete(x) if x then fire("OnDoorHit",x) else notify("Warning","Target not found.",3) end end
local function unequip() for _,v in ipairs(char():GetChildren()) do if v:IsA("Tool") then v.Parent=LP.Backpack end end end
local function equip() for _,v in ipairs(LP.Backpack:GetChildren()) do if v:IsA("Tool") then v.Parent=char() end end end

local Items={"Crowbar 1","Crowbar 2","Bat","Pitchfork","Hammer","Wrench","Broom","Armor","Med Kit","Key","Gold Key","Louise","Lollipop","Chips","Golden Apple","Pizza","Gold Pizza","Rainbow Pizza","Rainbow Pizza Box","Book","Phone","Cookie","Apple","Bloxy Cola","Expired Bloxy Cola","Bottle","Ladder","Battery"}
local function give(item)
    local r=remote("Vending")
    if item=="Armor" then if r then safe(function() r:FireServer(3,"Armor2","Armor",tostring(LP),1) end) end
    elseif item=="Crowbar 1" or item=="Crowbar 2" or item=="Bat" or item=="Pitchfork" or item=="Hammer" or item=="Wrench" or item=="Broom" then
        if r then safe(function() r:FireServer(3,item:gsub(" ",""),"Weapons",LP.Name,1) end) end
    else fire("GiveTool",item:gsub(" ","")) end
end
local function train(a) fire("RainbowWhatStat",a) end
local function damage(a) fire("Energy",-a,false,false) end
local function heal() give("Pizza"); fire("Energy",25,"Pizza") end
local function healall() unequip(); give("Golden Apple"); task.wait(.5); local t=LP.Backpack:FindFirstChild("GoldenApple"); if t then t.Parent=char() end; task.wait(.5); fire("HealTheNoobs") end
local function best()
    local g=LP.PlayerGui:FindFirstChild("Assets"); local n=g and g:FindFirstChild("Note",true); if not n then return end
    for _,v in ipairs(n:GetChildren()) do if v.Name:match("Circle") and v.Visible then give(v.Name:gsub("Circle","")) end end
end
local function allgear() best(); task.wait(.1); give("Armor"); for i=1,5 do train("Speed");train("Strength") end; unequip(); for i=1,15 do give("Gold Pizza");task.wait(.05) end end
local function kill()
    local r=remote("HitBadguy"); if not r then return end
    for _,fn in ipairs({"BadGuys","BadGuysBoss","BadGuysFront"}) do local f=WS:FindFirstChild(fn); if f then for _,e in ipairs(f:GetChildren()) do pcall(function() r:FireServer(e,64.8,4) end) end end end
    for _,n in ipairs({"BadGuyPizza","BadGuyBrute"}) do local e=WS:FindFirstChild(n,true); if e then pcall(function() r:FireServer(e,64.8,4) end) end end
end
local function breakEnemies()
    for _,fn in ipairs({"BadGuys","BadGuysBoss","BadGuysFront"}) do local f=WS:FindFirstChild(fn); if f then for _,e in ipairs(f:GetChildren()) do local h=e:FindFirstChild("Humanoid",true); if h then h.Health=0 end end end end
end
local function bring()
    local r=root(); if not r then return end
    for _,fn in ipairs({"BadGuys","BadGuysBoss","BadGuysFront"}) do local f=WS:FindFirstChild(fn); if f then for _,e in ipairs(f:GetChildren()) do local er=e:FindFirstChild("HumanoidRootPart"); if er then er.Anchored=true;er.CFrame=r.CFrame*CFrame.new(0,0,-4) end end end end
end
local function trees()
    local f=WS:FindFirstChild("FallenTrees"); if not f then return notify("Warning","FallenTrees not found.",4) end
    for _,v in ipairs(f:GetChildren()) do local h=v:FindFirstChild("TreeHitPart"); if h then for i=1,20 do fire("RoadMissionEvent",1,h,5) end end end
end
local function cash()
    local r=root();if not r then return end
    for _,v in ipairs(WS:GetChildren()) do if v.Name=="Part" and v:FindFirstChild("TouchInterest") and v:FindFirstChild("Weld") and v.Transparency==1 then pcall(function() firetouchinterest(v,r,0) end) end end
end
local function secret() for _,n in ipairs({"HatCollected","MaskCollected","CrowbarCollected"}) do fire("LarryEndingEvent",n,true) end end
local function outside()
    tp(CFrame.new(-199.240555,30.0009422,-790.182739)); local f=WS:FindFirstChild("OutsideParts"); if f then for _,v in ipairs(f:GetChildren()) do local c=v:FindFirstChildOfClass("ClickDetector"); if c then pcall(function() fireclickdetector(c) end) end end end
end
local function dog()
    local g=LP.PlayerGui:FindFirstChild("Assets");local n=g and g:FindFirstChild("Note",true);if not n then return end
    for _,v in ipairs(n:GetChildren()) do if v.Name:match("Circle") and v.Visible then local i=v.Name:gsub("Circle","");give(i);task.wait(.1);local t=LP.Backpack:FindFirstChild(i);if t then t.Parent=char() end;tp(CFrame.new(-257.56839,29.4499969,-910.452637));task.wait(.5);fire("CatFed",i) end end
end
local function agent() give("Louise");task.wait(.1);local t=LP.Backpack:FindFirstChild("Louise");if t then t.Parent=char() end;fire("LouiseGive",2) end
local function uncle() give("Key");task.wait(.1);local t=LP.Backpack:FindFirstChild("Key");if t then t.Parent=char() end;fire("KeyEvent") end
local function pete() local p=WS:FindFirstChild("UnclePete");local c=p and p:FindFirstChildOfClass("ClickDetector");if c then pcall(function() fireclickdetector(c) end) end end
local function mud(s) local b=WS:FindFirstChild("BogArea");b=b and b:FindFirstChild("Bog");if b then for _,v in ipairs(b:GetDescendants()) do if v.Name=="Mud" and v:IsA("BasePart") then v.CanTouch=s end end end end
local function wind() local w=WS:FindFirstChild("WavePart");if w then w.CanTouch=false end end
local function noclip(s) for _,v in ipairs(char():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=s end end end

local function tab(title,icon) return Window:AddTab({Title=title,Icon=icon}) end
local function button(t,n,f,icon) t:AddButton({Title=n,Icon=icon,Callback=function() safe(f) end}) end
local function toggle(t,n,k,f) t:AddToggle(k,{Title=n,Default=State[k] or false,Callback=function(v) State[k]=v;safe(function() f(v) end) end}) end
local function slider(t,n,k,min,max,def,f) t:AddSlider(k,{Title=n,Default=def,Min=min,Max=max,Rounding=0,Callback=function(v) State[k]=v;safe(function() f(v) end) end}) end
local function para(t,a,b) t:AddParagraph({Title=a,Content=b}) end

-- GAME BREAKING
do local t=tab("Game Breaking","solar/bolt-bold");para(t,"MysticmMoth Hub","Game-breaking controls with warnings and nil-safe checks.")
button(t,"Delete The Game",function() for _,v in ipairs(WS:GetChildren()) do delete(v) end end)
button(t,"Delete The House",function() local h=WS:FindFirstChild("TheHouse");if h then for _,v in ipairs(h:GetChildren()) do if v.Name~="FloorLayer" then delete(v) end end end end)
button(t,"Delete Other's Humanoid",function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then local c=WS:FindFirstChild(p.Name,true);if c then delete(c) end end end end)
button(t,"Delete Everyone's Humanoid",function() for _,p in ipairs(Players:GetPlayers()) do local c=WS:FindFirstChild(p.Name,true);if c then delete(c) end end end)
button(t,"Delete Bad Guys",function() for _,n in ipairs({"BadGuys","BadGuysBoss","BadGuysFront"}) do local f=WS:FindFirstChild(n);if f then for _,v in ipairs(f:GetChildren()) do delete(v) end end end end)
button(t,"Delete Pizza Miniboss",function() delete(WS:FindFirstChild("BadGuyPizza",true)) end)
button(t,"Delete Brute",function() delete(WS:FindFirstChild("BadGuyBrute")) end)
button(t,"Delete Scary Mary",function() local v=WS:FindFirstChild("Villainess");if v then delete(v) else notify("Warning","Scary Mary is not active.",5) end end)
button(t,"Delete Scary Larry",function() local v=WS:FindFirstChild("BigBoss");if v then delete(v) else notify("Warning","Scary Larry is not active.",5) end end)
button(t,"Remove Ice For Everyone",function() delete(WS:FindFirstChildOfClass("Terrain")) end)
button(t,"Remove Hailing For Everyone",function() delete(WS:FindFirstChild("Hails")) end)
button(t,"Remove Mud For Everyone",function() local b=WS:FindFirstChild("BogArea");b=b and b:FindFirstChild("Bog");if b then for _,v in ipairs(b:GetDescendants()) do if v.Name=="Mud" and v:IsA("BasePart") then delete(v) end end end end)
-- This is intentionally non-destructive: no server-crash spam.
button(t,"Lag/Crash The Server",function() notify("Warning","Server-crash spam is disabled in this fixed build.",7) end)
end

-- OVERPOWERED
do local t=tab("Overpowered","solar/stars-bold");para(t,"Item Giver","Items are checked before remotes are fired.")
t:AddDropdown("Item",{Title="Item",Values=Items,Multi=false,Default=State.Item,Callback=function(v) State.Item=v end})
button(t,"Get Item",function() give(State.Item) end)
button(t,"Train Strength",function() train("Strength") end);button(t,"Train Speed",function() train("Speed") end)
button(t,"Heal Yourself",function() for i=1,10 do heal() end end)
toggle(t,"Loop Heal Yourself","Heal",function(v) if v then task.spawn(function() while State.Heal do heal();task.wait(.2) end end) end end)
button(t,"Heal All",healall);toggle(t,"Loop Heal All","HealAll",function(v) if v then task.spawn(function() while State.HealAll do healall();task.wait(3) end end) end end)
toggle(t,"Semi-Godmode","God",function(v) notify("Info",v and "Semi-Godmode enabled." or "Semi-Godmode disabled.",4) end)
toggle(t,"Remove Slipping","Slip",function(v) notify("Info",v and "Remove Slipping enabled." or "Remove Slipping disabled.",4) end)
toggle(t,"Remove Wind","NoWind",function(v) if v then task.spawn(function() while State.NoWind do wind();task.wait(.5) end end) end end)
toggle(t,"Remove Mud","NoMud",function(v) mud(not v) end)
button(t,"Spawn Pizza Box",function() fire("OutsideFood",6,{item2="Pizza",placement=State.Position}) end)
button(t,"Spawn Bloxy Cola",function() fire("OutsideFood",6,{item2="BloxyPack",placement=State.Position}) end)
slider(t,"Table Food Slot","Position",0,4,1,function() end)
button(t,"Unlock Secret Ending",secret);button(t,"Get Best Weapon",best);button(t,"Get All Equipment",allgear)
end

-- TELEPORTS
do local t=tab("Teleports","solar/map-point-bold");para(t,"Smooth Teleport Menu","Safe CFrame teleport locations.")
local loc={
{"Boss Fight",CFrame.new(-1565.78772,-368.711945,-1040.66626)},{"Shop",CFrame.new(-246.653229,30.4500484,-847.319275)},
{"Kitchen",CFrame.new(-249.753555,30.4500484,-732.703125)},{"Fighting Arena",CFrame.new(-255.521988,62.7139359,-723.436035)},
{"The Gym",CFrame.new(-256.477448,63.4500465,-840.825562)},{"Golden Apple",CFrame.new(61.8781624,29.4499969,-534.381165)},
{"Feeding Instructions",CFrame.new(-207.885056,60.4500465,-830.583557)},{"Middle Room",CFrame.new(-209.951859,30.4590473,-789.723877)},
{"Scary Mary Pillar",CFrame.new(-1501.49597,-325.156891,-1060.63367)},{"Secret Agent Bradley",CFrame.new(-281.792053,95.4500275,-790.556946)},
{"Twando The Dog",CFrame.new(-257.56839,29.4499969,-910.452637)},{"Uncle Pete",CFrame.new(-294.208923,63.4182587,-737.712036)},
{"Golden Crowbar",CFrame.new(-147.337204,29.4477,-929.365295)},{"Purple Mask",CFrame.new(102.560722,29.2477,-976.389954)},{"Homeless Kid",CFrame.new(-79.48718,29.4477,-932.7827)} }
for _,v in ipairs(loc) do button(t,v[1],function() tp(v[2]) end) end
button(t,"Outside Loot",outside)
button(t,"Teleport To Private Lobby",function() TeleportService:Teleport(14775231477,LP) end)
end

-- HUMANOID
do local t=tab("Humanoid","solar/user-bold");slider(t,"Walk Speed","WalkSpeed",0,500,50,function(v) local h=hum();if h and State.SpeedEnabled then h.WalkSpeed=v end end);slider(t,"Jump Power","JumpPower",0,500,100,function(v) local h=hum();if h and State.JumpEnabled then h.JumpPower=v end end)
toggle(t,"Enable Walk Speed","SpeedEnabled",function(v) local h=hum();if h then h.WalkSpeed=v and State.WalkSpeed or 16 end end)
toggle(t,"Enable Jump Power","JumpEnabled",function(v) local h=hum();if h then h.UseJumpPower=true;h.JumpPower=v and State.JumpPower or 50 end end)
toggle(t,"Enable Noclip","Noclip",function(v) if v then task.spawn(function() while State.Noclip do noclip(false);task.wait(.05) end end) else noclip(true) end end)
toggle(t,"Enable Floating","Float",function(v) if v then task.spawn(function() while State.Float do local r=root();if r then r.CFrame=r.CFrame+Vector3.new(0,-4,0) end;task.wait(.05) end end) end end)
end

-- COMBAT
do local t=tab("Combat","solar/sword-bold");button(t,"Kill All Enemies",function() for i=1,10 do kill() end end);toggle(t,"Loop Kill All","KillLoop",function(v) if v then task.spawn(function() while State.KillLoop do kill();task.wait(.15) end end) end end)
button(t,"Break All Enemies",breakEnemies);toggle(t,"Loop Break All","BreakLoop",function(v) if v then task.spawn(function() while State.BreakLoop do breakEnemies();task.wait(1) end end) end end)
button(t,"Bring All Enemies",bring);toggle(t,"Loop Bring All","BringLoop",function(v) if v then task.spawn(function() while State.BringLoop do bring();task.wait(.2) end end) end end)
end

-- BADGES
do local t=tab("Badges","solar/cup-star-bold");button(t,"Dream Team",function() dog();task.wait(5);agent();task.wait(1);uncle() end);button(t,"Operation: Dog Rescue",dog);button(t,"Wake Up, Bradley!",agent);button(t,"Uncle Pete's Return",uncle);button(t,"Reformed",secret);button(t,"Delivery's Here",outside);button(t,"So Speedy",function() for i=1,5 do train("Speed") end end);button(t,"So Strong",function() for i=1,5 do train("Strength") end end);button(t,"Get The Golden Apple",function() local a=WS:FindFirstChild("GoldenApple");if a then tp(a.CFrame) else notify("Warning","Golden Apple has not spawned.",5) end end) end

-- MISC
do local t=tab("Misc","solar/settings-bold");slider(t,"Damage Amount","Damage",0,200,5,function() end);button(t,"Damage Yourself",function() if State.God then notify("Warning","Disable Semi-Godmode first.",5) else damage(State.Damage) end end);button(t,"Slip",function() if State.Slip then notify("Warning","Remove Slipping is enabled.",5) else fire("IceSlip",Vector3.new()) end end)
button(t,"Equip All",equip);button(t,"Unequip All",unequip);button(t,"Collect Cash",cash);toggle(t,"Auto Collect Cash","CashLoop",function(v) if v then task.spawn(function() while State.CashLoop do cash();task.wait(1) end end) end end)
toggle(t,"Auto Claim Uncle Pete Quests","PeteLoop",function(v) if v then task.spawn(function() while State.PeteLoop do pete();task.wait(10) end end) end end)
button(t,"Get All Items From Outside",outside);button(t,"Break Fallen Trees",trees)
toggle(t,"Hidden Items ESP","ESP",function(v) local h=WS:FindFirstChild("Hidden");if not h then return end;if v then for _,x in ipairs(h:GetChildren()) do if not x:FindFirstChild("MysticmMothESP") then local z=Instance.new("Highlight");z.Name="MysticmMothESP";z.FillTransparency=.2;z.OutlineTransparency=0;z.Parent=x end end else for _,x in ipairs(h:GetChildren()) do local z=x:FindFirstChild("MysticmMothESP");if z then z:Destroy() end end end end)
local ob={Brightness=Lighting.Brightness,FogEnd=Lighting.FogEnd,Shadows=Lighting.GlobalShadows};toggle(t,"Full Bright","Bright",function(v) if v then Lighting.Brightness=1;Lighting.FogEnd=999999;Lighting.GlobalShadows=false else Lighting.Brightness=ob.Brightness;Lighting.FogEnd=ob.FogEnd;Lighting.GlobalShadows=ob.Shadows end end)
end

-- UPDATES
do local t=tab("Updates","solar/clipboard-text-bold");para(t,"MysticmMoth Hub Updates","Version 2.1.0\n• Fluent-modded UI refresh\n• Fixed broken task.task.wait calls\n• Fixed safer nil/remote checks\n• Fixed loop toggles to run in separate tasks\n• Fixed Damage variable handling\n• Added clear Warning notifications\n• Added Updates tab\n• Server-crash spam is disabled in this fixed build\n\nOriginated by Credits To LeoDicap On The Old V3rmillion.")
button(t,"Copy Version Info",function() if setclipboard then setclipboard("MysticmMoth Hub v2.1.0 • Fluent UI") end;notify("Updates","Version info copied.",3) end)
end

notify("MysticmMoth Hub","Loaded successfully! v2.1.0 • Fluent UI",7)

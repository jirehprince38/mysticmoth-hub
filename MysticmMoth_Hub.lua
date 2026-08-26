-- MysticmMoth Hub
-- Originated by Credits To LeoDicap On The Old V3rmillion For Helping Me A Lot With The Script, He Wants To Keep His Discord Private.
-- Version: 2.0.1 Fluent UI Refresh
-- UI: Fluent-modded by StyearX

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local SUPPORTED_PLACE = 13864667823
local LOBBY_PLACES = {
    [14775231477] = true,
    [13864661000] = true,
}

local function notifyFallback(title, content)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = 5,
        })
    end)
end

-- Place check first. Unsupported games are never allowed to continue.
if game.PlaceId ~= SUPPORTED_PLACE and not LOBBY_PLACES[game.PlaceId] then
    notifyFallback("MysticmMoth Hub", "Warning: Game Not Supported!")
    return
end

-- Fluent-modded loader from StyearX.
-- Wrapped so a failed library download does not hard-error the whole script.
local Fluent
do
    local ok, result = pcall(function()
        local source = game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro")
        local loader = loadstring(source)
        assert(loader, "Fluent library returned invalid Lua source")
        return loader()
    end)
    if not ok or not result then
        notifyFallback("MysticmMoth Hub", "Warning: Fluent UI failed to load. Check executor HttpGet/loadstring support.")
        return
    end
    Fluent = result
end

-- Lobby gets its own small Fluent interface, then stops here.
if LOBBY_PLACES[game.PlaceId] then
    local Window = Fluent:CreateWindow({
        Title = "MysticmMoth Hub",
        SubTitle = "Lobby • v2.0.1",
        TabWidth = 160,
        Size = UDim2.fromOffset(560, 440),
        Acrylic = true,
        Theme = "Deep Violet",
        MinimizeKey = Enum.KeyCode.LeftControl,
        Search = true,
    })
    local Tab = Window:AddTab({Title = "Free Gamepasses", Icon = "solar/gamepad-bold"})
    Tab:AddParagraph({Title = "MysticmMoth Hub", Content = "Lobby utilities"})
    Tab:AddButton({Title = "Free Hacker Role", Icon = "solar/phone-bold", Callback = function()
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
        local role = remotes and remotes:FindFirstChild("OutsideRole")
        if role then role:FireServer("Phone", true, false) else notifyFallback("Warning", "OutsideRole remote not found.") end
    end})
    Tab:AddButton({Title = "Free Nerd Kid Role", Icon = "solar/book-bold", Callback = function()
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
        local role = remotes and remotes:FindFirstChild("OutsideRole")
        if role then role:FireServer("Book", true, false) else notifyFallback("Warning", "OutsideRole remote not found.") end
    end})
    Tab:AddParagraph({Title = "Updates", Content = "v2.0.1 • Fluent-modded UI • safer checks • fixed execution errors"})
    return
end

local Window = Fluent:CreateWindow({
    Title = "MysticmMoth Hub",
    SubTitle = "v2.0.1 • Fluent UI Refresh",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Deep Violet",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = true,
})

local Options = Fluent.Options
local Events = ReplicatedStorage:FindFirstChild("Events")

local State = {
    RemoveSlipping = false,
    SemiGodmode = false,
    HealLoop = false,
    HealAllLoop = false,
    NoWind = false,
    NoWindSS = false,
    Noclipping = false,
    Float = false,
    KillAllLoop = false,
    BreakAllLoop = false,
    BringAllLoop = false,
    CollectAllCash = false,
    AutoPete = false,
    Damage = 5,
    SelectedItem = "Med Kit",
    Position = 1,
    ModifiedWalkspeed = 50,
    ModifiedJumpPower = 100,
}

local ItemsTable = {
    "Crowbar 1", "Crowbar 2", "Bat", "Pitchfork", "Hammer", "Wrench", "Broom",
    "Armor", "Med Kit", "Key", "Gold Key", "Louise", "Lollipop", "Chips",
    "Golden Apple", "Pizza", "Gold Pizza", "Rainbow Pizza", "Rainbow Pizza Box",
    "Book", "Phone", "Cookie", "Apple", "Bloxy Cola", "Expired Bloxy Cola",
    "Bottle", "Ladder", "Battery"
}

local function Notify(title, content, duration)
    pcall(function()
        Fluent:Notify({Title = title, Content = content, Duration = duration or 5})
    end)
end

local function Character()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function Root()
    local c = Character()
    return c:FindFirstChild("HumanoidRootPart")
end

local function Humanoid()
    return Character():FindFirstChildOfClass("Humanoid")
end

local function safeCall(fn)
    local ok, err = pcall(fn)
    if not ok then
        Notify("Warning", "Action failed: " .. tostring(err), 5)
    end
    return ok
end

local function Remote(name)
    if not Events then return nil end
    return Events:FindFirstChild(name)
end

local function Fire(name, ...)
    local remote = Remote(name)
    if not remote then
        Notify("Warning", "Remote not found: " .. name, 4)
        return false
    end
    return safeCall(function() remote:FireServer(...) end)
end

local function TeleportTo(cf)
    local root = Root()
    if root then root.CFrame = cf end
end

local function Delete(instance)
    if not instance then
        Notify("Warning", "Target was not found.", 3)
        return
    end
    Fire("OnDoorHit", instance)
end

local function UnequipAllTools()
    local c = Character()
    for _, v in ipairs(c:GetChildren()) do
        if v:IsA("Tool") then v.Parent = LocalPlayer.Backpack end
    end
end

local function EquipAllTools()
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then v.Parent = Character() end
    end
end

local function GiveItem(item)
    if not Events then return end
    safeCall(function()
        if item == "Armor" then
            Remote("Vending"):FireServer(3, "Armor2", "Armor", tostring(LocalPlayer), 1)
        elseif item == "Crowbar 1" or item == "Crowbar 2" or item == "Bat" or item == "Pitchfork" or item == "Hammer" or item == "Wrench" or item == "Broom" then
            Remote("Vending"):FireServer(3, item:gsub(" ", ""), "Weapons", LocalPlayer.Name, 1)
        else
            Remote("GiveTool"):FireServer(item:gsub(" ", ""))
        end
    end)
end

local function Train(ability)
    Fire("RainbowWhatStat", ability)
end

local function HealYourself()
    GiveItem("Pizza")
    Fire("Energy", 25, "Pizza")
end

local function HealAllPlayers()
    UnequipAllTools()
    GiveItem("Golden Apple")
    task.wait(.5)
    local tool = LocalPlayer.Backpack:FindFirstChild("GoldenApple")
    if tool then tool.Parent = Character() end
    task.wait(.5)
    Fire("HealTheNoobs")
end

local function TakeDamage(amount)
    Fire("Energy", -amount, false, false)
end

local function KillEnemies()
    local remote = Remote("HitBadguy")
    if not remote then return end
    local folders = {Workspace:FindFirstChild("BadGuys"), Workspace:FindFirstChild("BadGuysBoss"), Workspace:FindFirstChild("BadGuysFront")}
    for _, folder in ipairs(folders) do
        if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                pcall(function() remote:FireServer(enemy, 64.8, 4) end)
            end
        end
    end
    for _, name in ipairs({"BadGuyPizza", "BadGuyBrute"}) do
        local enemy = Workspace:FindFirstChild(name, true)
        if enemy then pcall(function() remote:FireServer(enemy, 64.8, 4) end) end
    end
end

local function BreakEnemies()
    for _, folderName in ipairs({"BadGuys", "BadGuysBoss", "BadGuysFront"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                local hum = enemy:FindFirstChild("Humanoid", true)
                if hum then hum.Health = 0 end
            end
        end
    end
end

local function BringAllEnemies()
    local root = Root()
    if not root then return end
    for _, folderName in ipairs({"BadGuys", "BadGuysBoss", "BadGuysFront"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                local eroot = enemy:FindFirstChild("HumanoidRootPart")
                if eroot then
                    eroot.Anchored = true
                    eroot.CFrame = root.CFrame * CFrame.new(0, 0, -4)
                end
            end
        end
    end
end

local function BreakBarricades()
    local folder = Workspace:FindFirstChild("FallenTrees")
    if not folder then return Notify("Warning", "FallenTrees is not available.", 4) end
    for _, tree in ipairs(folder:GetChildren()) do
        local hit = tree:FindFirstChild("TreeHitPart")
        if hit then
            for _ = 1, 20 do Fire("RoadMissionEvent", 1, hit, 5) end
        end
    end
end

local function CollectCash()
    local root = Root()
    if not root then return end
    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name == "Part" and v:FindFirstChild("TouchInterest") and v:FindFirstChild("Weld") and v.Transparency == 1 then
            pcall(function() firetouchinterest(v, root, 0) end)
        end
    end
end

local function GetSecretEnding()
    for _, name in ipairs({"HatCollected", "MaskCollected", "CrowbarCollected"}) do
        Fire("LarryEndingEvent", name, true)
    end
end

local function GetBestTool()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Assets")
    local note = gui and gui:FindFirstChild("Note", true)
    if not note then return end
    for _, v in ipairs(note:GetChildren()) do
        if v.Name:match("Circle") and v.Visible == true then
            GiveItem(v.Name:gsub("Circle", ""))
        end
    end
end

local function GiveAll()
    GetBestTool()
    task.wait(.1)
    GiveItem("Armor")
    for _ = 1, 5 do Train("Speed"); Train("Strength") end
    UnequipAllTools()
    for _ = 1, 15 do GiveItem("Gold Pizza"); task.wait(.05) end
end

local function GetDog()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Assets")
    local note = gui and gui:FindFirstChild("Note", true)
    if not note then return end
    for _, v in ipairs(note:GetChildren()) do
        if v.Name:match("Circle") and v.Visible == true then
            local item = v.Name:gsub("Circle", "")
            GiveItem(item)
            task.wait(.1)
            local tool = LocalPlayer.Backpack:FindFirstChild(item)
            if tool then tool.Parent = Character() end
            TeleportTo(CFrame.new(-257.56839, 29.4499969, -910.452637))
            task.wait(.5)
            Fire("CatFed", item)
        end
    end
end

local function GetAgent()
    GiveItem("Louise")
    task.wait(.1)
    local tool = LocalPlayer.Backpack:FindFirstChild("Louise")
    if tool then tool.Parent = Character() end
    Fire("LouiseGive", 2)
end

local function GetUncle()
    GiveItem("Key")
    task.wait(.1)
    local tool = LocalPlayer.Backpack:FindFirstChild("Key")
    if tool then tool.Parent = Character() end
    Fire("KeyEvent")
end

local function ClickPete()
    local pete = Workspace:FindFirstChild("UnclePete")
    local cd = pete and pete:FindFirstChildOfClass("ClickDetector")
    if cd then pcall(function() fireclickdetector(cd) end) end
end

local function GetAllOutsideItems()
    TeleportTo(CFrame.new(-199.240555, 30.0009422, -790.182739))
    local folder = Workspace:FindFirstChild("OutsideParts")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            local cd = v:FindFirstChildOfClass("ClickDetector")
            if cd then pcall(function() fireclickdetector(cd) end) end
        end
    end
end

local function GetGAppleBadge()
    local trees = Workspace:FindFirstChild("FallenTrees")
    local apple = Workspace:FindFirstChild("GoldenApple")
    if not trees or not apple then
        return Notify("Warning", "Golden Apple has not spawned yet. Wait until the first wave.", 5)
    end
    for _, tree in ipairs(trees:GetChildren()) do
        local hit = tree:FindFirstChild("TreeHitPart")
        if hit then for _ = 1, 20 do Fire("RoadMissionEvent", 1, hit, 5) end end
    end
    task.wait(1)
    TeleportTo(CFrame.new(61.8781624, 29.4499969, -534.381165))
    local cd = apple:FindFirstChildOfClass("ClickDetector")
    if cd then pcall(function() fireclickdetector(cd) end) else Notify("Warning", "Golden Apple ClickDetector not found.", 4) end
end

local function AntiMud(state)
    local bog = Workspace:FindFirstChild("BogArea")
    bog = bog and bog:FindFirstChild("Bog")
    if bog then
        for _, v in ipairs(bog:GetDescendants()) do
            if v.Name == "Mud" and v:IsA("BasePart") then v.CanTouch = state end
        end
    end
end

local function AntiWind()
    local wave = Workspace:FindFirstChild("WavePart")
    if wave then wave.CanTouch = false end
end

local function Noclip(state)
    local c = Character()
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = state end
    end
end

-- Tabs
local GameTab = Window:AddTab({Title = "Game Breaking", Icon = "solar/bolt-bold"})
local PowerTab = Window:AddTab({Title = "Overpowered", Icon = "solar/stars-bold"})
local TeleTab = Window:AddTab({Title = "Teleports", Icon = "solar/map-point-bold"})
local HumTab = Window:AddTab({Title = "Humanoid", Icon = "solar/user-bold"})
local CombatTab = Window:AddTab({Title = "Combat", Icon = "solar/sword-bold"})
local BadgeTab = Window:AddTab({Title = "Badges", Icon = "solar/cup-star-bold"})
local MiscTab = Window:AddTab({Title = "Misc", Icon = "solar/settings-bold"})
local UpdatesTab = Window:AddTab({Title = "Updates", Icon = "solar/clipboard-list-bold"})

GameTab:AddParagraph({Title = "MysticmMoth Hub", Content = "Game-breaking utilities with safer checks and warnings."})
GameTab:AddParagraph({Title = "Safety", Content = "Actions validate missing objects before calling remotes. The old server-crash loop has been replaced with a warning."})

GameTab:AddButton({Title = "Delete The Game", Icon = "solar/trash-bin-trash-bold", Callback = function()
    local count = 0
    for _, v in ipairs(Workspace:GetChildren()) do Delete(v); count += 1 end
    Notify("Done", "Requested deletion for " .. count .. " objects.", 4)
end})
GameTab:AddButton({Title = "Delete The House", Callback = function()
    local house = Workspace:FindFirstChild("TheHouse")
    if not house then return Notify("Warning", "TheHouse was not found.", 4) end
    for _, v in ipairs(house:GetChildren()) do if v.Name ~= "FloorLayer" then Delete(v) end end
end})

GameTab:AddInput({Title = "Delete Player's Humanoid", Default = "PlayerName", Placeholder = "PlayerName", Callback = function(value)
    local char = Workspace:FindFirstChild(value)
    if char then Delete(char) else Notify("Warning", "Player character not found.", 4) end
end})
GameTab:AddButton({Title = "Delete Other's Humanoid", Callback = function()
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Delete(Workspace:FindFirstChild(p.Name)) end end
end})
GameTab:AddButton({Title = "Delete Everyone's Humanoid", Callback = function()
    for _, p in ipairs(Players:GetPlayers()) do Delete(Workspace:FindFirstChild(p.Name)) end
end})

GameTab:AddButton({Title = "Delete Bad Guys", Callback = function()
    for _, folderName in ipairs({"BadGuys", "BadGuysBoss", "BadGuysFront"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then for _, v in ipairs(folder:GetChildren()) do Delete(v) end end
    end
end})
GameTab:AddButton({Title = "Delete Pizza Miniboss", Callback = function() Delete(Workspace:FindFirstChild("BadGuyPizza", true)) end})
GameTab:AddButton({Title = "Delete Brute", Callback = function() Delete(Workspace:FindFirstChild("BadGuyBrute")) end})
GameTab:AddButton({Title = "Delete Scary Mary", Callback = function()
    local x = Workspace:FindFirstChild("Villainess")
    if x then Delete(x) else Notify("Warning", "Scary Mary is already deleted or the boss fight has not started.", 6) end
end})
GameTab:AddButton({Title = "Delete Scary Larry", Callback = function()
    local x = Workspace:FindFirstChild("BigBoss")
    if x then Delete(x) else Notify("Warning", "Scary Larry is already deleted or the boss fight has not started.", 6) end
end})

GameTab:AddToggle({Title = "Remove Wind For Everyone", Default = false, Callback = function(value)
    State.NoWindSS = value
    if value then task.spawn(function() while State.NoWindSS do local wave=Workspace:FindFirstChild("WavePart"); if wave then Delete(wave) end task.wait(.2) end end) end
end})
GameTab:AddButton({Title = "Remove Ice For Everyone", Callback = function() Delete(Workspace:FindFirstChild("Terrain")) end})
GameTab:AddButton({Title = "Remove Hailing For Everyone", Callback = function() Delete(Workspace:FindFirstChild("Hails")) end})
GameTab:AddButton({Title = "Remove Mud For Everyone", Callback = function()
    local bog=Workspace:FindFirstChild("BogArea"); bog=bog and bog:FindFirstChild("Bog")
    if bog then for _,v in ipairs(bog:GetDescendants()) do if v.Name=="Mud" and v:IsA("BasePart") then Delete(v) end end end
end})

PowerTab:AddParagraph({Title="Item Giver", Content="Select an item and press Get Item."})
PowerTab:AddDropdown({Title="Item", Values=ItemsTable, Default=1, Multi=false, Callback=function(value)
    State.SelectedItem=value
    if value=="Book" or value=="Phone" then Notify("Warning", value.." may require its corresponding gamepass.", 6) end
end})
PowerTab:AddButton({Title="Get Item", Callback=function() GiveItem(State.SelectedItem) end})
PowerTab:AddButton({Title="Get Best Weapon", Callback=GetBestTool})
PowerTab:AddButton({Title="Get All Equipment", Callback=GiveAll})
PowerTab:AddButton({Title="Train Strength", Callback=function() Train("Strength") end})
PowerTab:AddButton({Title="Train Speed", Callback=function() Train("Speed") end})
PowerTab:AddButton({Title="Heal Yourself", Callback=function() for _=1,10 do HealYourself() end end})
PowerTab:AddToggle({Title="Loop Heal Yourself", Default=false, Callback=function(v) State.HealLoop=v; if v then task.spawn(function() while State.HealLoop do HealYourself(); task.wait(.25) end end) end end})
PowerTab:AddButton({Title="Heal All", Callback=HealAllPlayers})
PowerTab:AddToggle({Title="Loop Heal All", Default=false, Callback=function(v) State.HealAllLoop=v; if v then task.spawn(function() while State.HealAllLoop do HealAllPlayers(); task.wait(3) end end) end end})
PowerTab:AddToggle({Title="Semi-Godmode", Default=false, Callback=function(v) State.SemiGodmode=v; Notify("Info", v and "Semi-Godmode enabled." or "Semi-Godmode disabled.", 4) end})
PowerTab:AddToggle({Title="Remove Slipping", Default=false, Callback=function(v) State.RemoveSlipping=v; Notify("Info", v and "Remove Slipping enabled." or "Remove Slipping disabled.", 4) end})
PowerTab:AddToggle({Title="Remove Hailing", Default=false, Callback=function(v)
    local hails=Workspace:FindFirstChild("Hails")
    if v then
        if hails then hails.Parent=nil end
    elseif not hails then
        Notify("Info","Hailing was removed locally; rejoin/respawn to restore it.",5)
    end
end})
PowerTab:AddToggle({Title="Remove Wind", Default=false, Callback=function(v) State.NoWind=v; if v then task.spawn(function() while State.NoWind do AntiWind(); task.wait(.5) end end) end end})
PowerTab:AddToggle({Title="Remove Mud", Default=false, Callback=function(v) AntiMud(v) end})
PowerTab:AddButton({Title="Equip All", Callback=EquipAllTools})
PowerTab:AddButton({Title="Unequip All", Callback=UnequipAllTools})

-- Intentionally safe replacement for the old crash loop.
PowerTab:AddButton({Title="Lag/Crash The Server", Icon="solar/shield-warning-bold", Callback=function()
    Notify("Warning", "Server crash/lag functionality is disabled in this refresh. No spam loop will be started.", 8)
end})
PowerTab:AddButton({Title="Break The Game", Callback=function()
    local pete=Workspace:FindFirstChild("UnclePete")
    if pete and pete.PrimaryPart then
        local root=Root(); if root then root.CFrame=pete.PrimaryPart.CFrame end
        task.wait(.5)
        Notify("Warning", "The old extreme-position Break The Game action was disabled to avoid client instability.", 6)
    else Notify("Warning", "Uncle Pete is not available.", 4) end
end})
PowerTab:AddButton({Title="Teleport To Private Lobby", Callback=function() safeCall(function() TeleportService:Teleport(14775231477, LocalPlayer) end) end})
PowerTab:AddButton({Title="Unlock Secret Ending", Callback=GetSecretEnding})

local locations = {
    ["Boss Fight"] = CFrame.new(-1565.78772, -368.711945, -1040.66626),
    ["Shop"] = CFrame.new(-246.653229, 30.4500484, -847.319275),
    ["Kitchen"] = CFrame.new(-249.753555, 30.4500484, -732.703125),
    ["Fighting Arena"] = CFrame.new(-255.521988, 62.7139359, -723.436035),
    ["The Gym"] = CFrame.new(-256.477448, 63.4500465, -840.825562),
    ["Golden Apple"] = CFrame.new(61.8781624, 29.4499969, -534.381165),
    ["Feeding Instructions"] = CFrame.new(-207.885056, 60.4500465, -830.583557),
    ["Middle Room"] = CFrame.new(-209.951859, 30.4590473, -789.723877),
    ["Scary Mary Pillar"] = CFrame.new(-1501.49597, -325.156891, -1060.63367),
    ["Secret Agent Bradley"] = CFrame.new(-281.792053, 95.4500275, -790.556946),
    ["Twando The Dog"] = CFrame.new(-257.56839, 29.4499969, -910.452637),
    ["Uncle Pete"] = CFrame.new(-294.208923, 63.4182587, -737.712036),
    ["Golden Crowbar"] = CFrame.new(-147.337204, 29.4477005, -929.365295),
    ["Purple Mask"] = CFrame.new(102.560722, 29.2477055, -976.389954),
    ["Homeless Kid"] = CFrame.new(-79.4871826, 29.4477024, -932.782715),
}
for name, cf in pairs(locations) do
    TeleTab:AddButton({Title=name, Icon="solar/map-arrow-right-bold", Callback=function() TeleportTo(cf) end})
end
TeleTab:AddButton({Title="Outside Loot", Callback=function()
    local f=Workspace:FindFirstChild("OutsideParts"); local part=f and f:FindFirstChildWhichIsA("BasePart",true)
    if part then TeleportTo(part.CFrame+Vector3.new(10,0,0)) else Notify("Warning","Outside loot is unavailable.",4) end
end})
TeleTab:AddButton({Title="Experiment Room", Callback=function()
    local final=Workspace:FindFirstChild("Final"); local factory=final and final:FindFirstChild("Factory"); local red=factory and factory:FindFirstChild("RedDesk"); local drawer=red and red:FindFirstChild("Drawer")
    local children=drawer and drawer:GetChildren(); local target=children and children[2]
    if target and target:IsA("BasePart") then TeleportTo(target.CFrame+Vector3.new(20,0,0)) else Notify("Warning","Experiment Room is unavailable.",4) end
end})
TeleTab:AddButton({Title="Cafeteria", Callback=function()
    local final=Workspace:FindFirstChild("Final"); local factory=final and final:FindFirstChild("Factory"); local legs=factory and factory:FindFirstChild("Legs",true)
    if legs and legs:IsA("BasePart") then TeleportTo(legs.CFrame) else Notify("Warning","Cafeteria is unavailable.",4) end
end})
TeleTab:AddButton({Title="Rainbow Pizza Box", Callback=function() local x=Workspace:FindFirstChild("RainbowPizzaBox"); if x and x:IsA("BasePart") then TeleportTo(x.CFrame) elseif x and x:IsA("Model") and x.PrimaryPart then TeleportTo(x.PrimaryPart.CFrame) else Notify("Warning","Rainbow Pizza Box not found.",4) end end})

HumTab:AddSlider({Title="Walk Speed", Min=0, Max=500, Default=50, Rounding=0, Callback=function(v) State.ModifiedWalkspeed=v end})
HumTab:AddSlider({Title="Jump Power", Min=0, Max=500, Default=100, Rounding=0, Callback=function(v) State.ModifiedJumpPower=v end})
HumTab:AddToggle({Title="Enable Walk Speed", Default=false, Callback=function(v) local h=Humanoid(); if h then if v then h.WalkSpeed=State.ModifiedWalkspeed else h.WalkSpeed=16 end end end})
HumTab:AddToggle({Title="Enable Jump Power", Default=false, Callback=function(v) local h=Humanoid(); if h then h.UseJumpPower=true; h.JumpPower=v and State.ModifiedJumpPower or 50 end end})
HumTab:AddToggle({Title="Enable Noclip", Default=false, Callback=function(v) State.Noclipping=v; if v then task.spawn(function() while State.Noclipping do Noclip(false); task.wait(.05) end end) else Noclip(true) end end})
HumTab:AddToggle({Title="Enable Floating", Default=false, Callback=function(v) State.Float=v; if v then
    local part=Workspace:FindFirstChild("MysticmMothFloat")
    if not part then part=Instance.new("Part"); part.Name="MysticmMothFloat"; part.Size=Vector3.new(5,1,5); part.Anchored=true; part.Transparency=1; part.Parent=Workspace end
    task.spawn(function() while State.Float do local r=Root(); if r then part.CFrame=r.CFrame+Vector3.new(0,-4,0) end task.wait(.05) end end)
end end})

CombatTab:AddButton({Title="Kill All Enemies", Callback=function() for _=1,10 do KillEnemies() end end})
CombatTab:AddToggle({Title="Loop Kill All", Default=false, Callback=function(v) State.KillAllLoop=v; if v then task.spawn(function() while State.KillAllLoop do KillEnemies(); task.wait(.25) end end) end end})
CombatTab:AddButton({Title="Break All Enemies", Callback=BreakEnemies})
CombatTab:AddToggle({Title="Loop Break All", Default=false, Callback=function(v) State.BreakAllLoop=v; if v then task.spawn(function() while State.BreakAllLoop do BreakEnemies(); task.wait(1) end end) end end})
CombatTab:AddButton({Title="Bring All Enemies", Callback=BringAllEnemies})
CombatTab:AddToggle({Title="Loop Bring All", Default=false, Callback=function(v) State.BringAllLoop=v; if v then task.spawn(function() while State.BringAllLoop do BringAllEnemies(); task.wait(.25) end end) end end})

BadgeTab:AddButton({Title="Dream Team", Callback=function() GetDog(); task.wait(5); GetAgent(); task.wait(1); GetUncle() end})
BadgeTab:AddButton({Title="Operation: Dog Rescue", Callback=GetDog})
BadgeTab:AddButton({Title="Wake Up, Bradley!", Callback=GetAgent})
BadgeTab:AddButton({Title="Uncle Pete's Return", Callback=GetUncle})
BadgeTab:AddButton({Title="Reformed", Callback=GetSecretEnding})
BadgeTab:AddButton({Title="The Golden Apple", Callback=GetGAppleBadge})
BadgeTab:AddButton({Title="Delivery's Here", Callback=GetAllOutsideItems})
BadgeTab:AddButton({Title="So Speedy", Callback=function() for _=1,5 do Train("Speed") end end})
BadgeTab:AddButton({Title="So Strong", Callback=function() for _=1,5 do Train("Strength") end end})
BadgeTab:AddButton({Title="Avoid Humiliation", Callback=function() GiveAll(); task.wait(4); GetDog(); task.wait(5); GetAgent(); task.wait(1); GetUncle() end})

MiscTab:AddSlider({Title="Damage Amount", Min=0, Max=200, Default=5, Rounding=0, Callback=function(v) State.Damage=v end})
MiscTab:AddButton({Title="Damage Yourself", Callback=function() if State.SemiGodmode then Notify("Warning","Damage is blocked while Semi-Godmode is enabled.",5) else TakeDamage(State.Damage) end end})
MiscTab:AddButton({Title="Slip", Callback=function() if State.RemoveSlipping then Notify("Warning","Slipping is disabled.",5) else Fire("IceSlip",Vector3.new(0,0,0)) end end})
MiscTab:AddButton({Title="Collect Cash", Callback=CollectCash})
MiscTab:AddToggle({Title="Auto Collect Cash", Default=false, Callback=function(v) State.CollectAllCash=v; if v then task.spawn(function() while State.CollectAllCash do CollectCash(); task.wait(1) end end) end end})
MiscTab:AddToggle({Title="Auto Claim Uncle Pete Quests", Default=false, Callback=function(v) State.AutoPete=v; if v then task.spawn(function() while State.AutoPete do ClickPete(); task.wait(10) end end) end end})
MiscTab:AddButton({Title="Get All Items From Outside", Callback=GetAllOutsideItems})
MiscTab:AddButton({Title="Break Fallen Trees", Callback=BreakBarricades})
MiscTab:AddToggle({Title="Hidden Items ESP", Default=false, Callback=function(v)
    local hidden=Workspace:FindFirstChild("Hidden"); if not hidden then return Notify("Warning","Hidden folder not found.",4) end
    if v then for _,x in ipairs(hidden:GetChildren()) do local h=x:FindFirstChild("MysticmMothESP") or Instance.new("Highlight"); h.Name="MysticmMothESP"; h.Parent=x end
    else for _,x in ipairs(hidden:GetChildren()) do local h=x:FindFirstChild("MysticmMothESP"); if h then h:Destroy() end end end
end})

local originalBrightness=Lighting.Brightness
local originalFog=Lighting.FogEnd
local originalShadows=Lighting.GlobalShadows
MiscTab:AddToggle({Title="Full Bright", Default=false, Callback=function(v) if v then Lighting.Brightness=1; Lighting.FogEnd=999999; Lighting.GlobalShadows=false else Lighting.Brightness=originalBrightness; Lighting.FogEnd=originalFog; Lighting.GlobalShadows=originalShadows end end})

UpdatesTab:AddParagraph({Title="Updates", Content=[[MysticmMoth Hub • v2.0.1

• Rebuilt the interface using Fluent-modded.
• Added search-friendly tabs and modern icons.
• Added safer nil checks around game objects/remotes.
• Fixed broken task.task.wait calls.
• Fixed Damage/Damange variable mismatch.
• Fixed loop toggles so they run in separate tasks and stop correctly.
• Added clearer Warning notifications.
• Removed the old server-crash spam loop; its button now only shows a warning.
• Added this Updates message as requested.

Originated by Credits To LeoDicap On The Old V3rmillion.]]})
UpdatesTab:AddParagraph({Title="UI Library", Content="Fluent-modded by StyearX • modern themes, search, icon packs and refreshed elements."})

Notify("MysticmMoth Hub", "Loaded successfully! UI refreshed • v2.0.1", 7)

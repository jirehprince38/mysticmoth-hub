--[[
MysticmMoth Hub
Originated by Credits To LeoDicap On The Old V3rmillion For Helping Me A Lot With The Script.
Version: 3.1.0 - Fluent UI / Lobby-to-Story Flow
UI: Fluent-modded by StyearX

Notes:
- Restores the original feature groups and controls.
- Adds nil checks, protected callbacks and safer loops.
- The old "Lag/Crash The Server" spam is intentionally disabled.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local SUPPORTED_PLACE = 13864667823
local LOBBY_PLACES = {
    [14775231477] = true,
    [13864661000] = true
}

local function systemNotify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6
        })
    end)
end

if game.PlaceId ~= SUPPORTED_PLACE and not LOBBY_PLACES[game.PlaceId] then
    systemNotify("MysticmMoth Hub", "Warning: Game Not Supported!")
    return
end

-- When executed in the lobby, queue this same script to run again after teleport.
-- This makes the lobby UI appear first and the full hub appear after entering the story.
local SCRIPT_URL = "https://raw.githubusercontent.com/jirehprince38/mysticmoth-hub/refs/heads/main/MysticmMoth_Hub.lua"
if LOBBY_PLACES[game.PlaceId] and queue_on_teleport then
    pcall(function()
        queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/jirehprince38/mysticmoth-hub/refs/heads/main/MysticmMoth_Hub.lua"))()]])
    end)
end

-- Fluent-modded by StyearX
local Fluent
local loaded, loadError = pcall(function()
    local source = game:HttpGet(
        "https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"
    )
    Fluent = assert(loadstring(source), "Fluent source did not compile")()
end)

if not loaded or not Fluent then
    systemNotify("MysticmMoth Hub", "Fluent failed to load. Your executor may not support HttpGet/loadstring.")
    return
end

-- LOBBY UI: only the Free Gamepasses panel is shown before the story starts.
if LOBBY_PLACES[game.PlaceId] then
    local LobbyWindow = Fluent:CreateWindow({
        Title = "MysticmMoth Hub",
        SubTitle = "Lobby • Free Gamepasses",
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 460),
        Acrylic = true,
        Theme = "Deep Violet",
        MinimizeKey = Enum.KeyCode.LeftControl,
        Search = true
    })

    local LobbyTab = LobbyWindow:AddTab({Title = "Free Gamepasses", Icon = "solar/gamepad-bold"})
    LobbyTab:AddParagraph({
        Title = "MysticmMoth Hub",
        Content = [[Free Gamepasses • Lobby

Use these options before entering the story. The full hub will load automatically after teleporting into the supported story game.]]
    })

    local function LobbyRole(roleName, icon, label)
        LobbyTab:AddButton({
            Title = label,
            Icon = icon,
            Callback = function()
                local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
                local role = remotes and remotes:FindFirstChild("OutsideRole")
                if role and role:IsA("RemoteEvent") then
                    local ok, err = pcall(function()
                        role:FireServer(roleName, true, false)
                    end)
                    if ok then
                        pcall(function() Fluent:Notify({Title = "MysticmMoth Hub", Content = label .. " requested.", Duration = 4}) end)
                    else
                        systemNotify("Warning", tostring(err))
                    end
                else
                    systemNotify("Warning", "OutsideRole remote not found in this lobby.")
                end
            end
        })
    end

    LobbyRole("Phone", "solar/phone-bold", "Free Hacker Role")
    LobbyRole("Book", "solar/book-bold", "Free Nerd Kid Role")

    LobbyTab:AddParagraph({
        Title = "Updates",
        Content = [[Version 3.1.0
• Lobby shows Free Gamepasses first
• Full hub loads after teleport to the story
• Fluent-modded UI
• Restored original feature groups
• Safer object/remote checks
• Fixed loop handling and broken waits
• Added warning notifications

Originated by Credits To LeoDicap On The Old V3rmillion.]]
    })

    pcall(function() Fluent:Notify({Title = "MysticmMoth Hub", Content = "Lobby loaded • Full hub will appear after teleport.", Duration = 7}) end)
    return
end

-- STORY UI: the full original feature system starts here.
local Window = Fluent:CreateWindow({
    Title = "MysticmMoth Hub",
    SubTitle = "v3.1.0 • Restored",
    TabWidth = 160,
    Size = UDim2.fromOffset(650, 520),
    Acrylic = true,
    Theme = "Deep Violet",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = true
})

local function Notify(title, content, duration)
    pcall(function()
        Fluent:Notify({
            Title = title,
            Content = content,
            Duration = duration or 5
        })
    end)
end

local Events = ReplicatedStorage:FindFirstChild("Events")

local State = {
    SelectedItem = "Med Kit",
    Damage = 5,
    Position = 1,
    WalkSpeed = 50,
    JumpPower = 100,

    SemiGodmode = false,
    RemoveSlipping = false,
    RemoveHailing = false,
    RemoveWind = false,
    RemoveMud = false,
    Noclip = false,
    Floating = false,

    HealLoop = false,
    HealAllLoop = false,
    KillLoop = false,
    BreakLoop = false,
    BringLoop = false,
    CashLoop = false,
    PeteLoop = false,
    WindAll = false,

    HiddenESP = false,
    FullBright = false
}

local function Character()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function Root()
    return Character():FindFirstChild("HumanoidRootPart")
end

local function Humanoid()
    return Character():FindFirstChildOfClass("Humanoid")
end

local function FindRemote(name)
    return Events and Events:FindFirstChild(name)
end

local function FireRemote(name, ...)
    local remote = FindRemote(name)

    if not remote then
        Notify("Warning", "Remote not found: " .. tostring(name), 4)
        return false
    end

    local args = {...}
    local ok, err = pcall(function()
        remote:FireServer(unpack(args))
    end)

    if not ok then
        Notify("Warning", tostring(err), 5)
    end

    return ok
end

local function Safe(callback)
    local ok, err = pcall(callback)
    if not ok then
        Notify("Warning", tostring(err), 5)
    end
    return ok
end

local function Delete(instance)
    if not instance then
        Notify("Warning", "Target was not found.", 3)
        return
    end

    FireRemote("OnDoorHit", instance)
end

local function TeleportTo(cframe)
    local root = Root()

    if not root then
        Notify("Warning", "Character is not ready.", 3)
        return
    end

    root.CFrame = cframe
end

local function UnequipAllTools()
    local character = Character()

    for _, object in ipairs(character:GetChildren()) do
        if object:IsA("Tool") then
            object.Parent = LocalPlayer.Backpack
        end
    end
end

local function EquipAllTools()
    local character = Character()

    for _, object in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if object:IsA("Tool") then
            object.Parent = character
        end
    end
end

local ItemsTable = {
    "Crowbar 1",
    "Crowbar 2",
    "Bat",
    "Pitchfork",
    "Hammer",
    "Wrench",
    "Broom",
    "Armor",
    "Med Kit",
    "Key",
    "Gold Key",
    "Louise",
    "Lollipop",
    "Chips",
    "Golden Apple",
    "Pizza",
    "Gold Pizza",
    "Rainbow Pizza",
    "Rainbow Pizza Box",
    "Book",
    "Phone",
    "Cookie",
    "Apple",
    "Bloxy Cola",
    "Expired Bloxy Cola",
    "Bottle",
    "Ladder",
    "Battery"
}

local SecretEndingTable = {
    "HatCollected",
    "MaskCollected",
    "CrowbarCollected"
}

local function GiveItem(item)
    if not item or item == "" then
        Notify("Warning", "Select an item first.", 4)
        return
    end

    local vending = FindRemote("Vending")

    if item == "Armor" then
        if vending then
            Safe(function()
                vending:FireServer(3, "Armor2", "Armor", tostring(LocalPlayer), 1)
            end)
        end
        return
    end

    local weapons = {
        ["Crowbar 1"] = true,
        ["Crowbar 2"] = true,
        ["Bat"] = true,
        ["Pitchfork"] = true,
        ["Hammer"] = true,
        ["Wrench"] = true,
        ["Broom"] = true
    }

    if weapons[item] then
        if vending then
            Safe(function()
                vending:FireServer(
                    3,
                    item:gsub(" ", ""),
                    "Weapons",
                    LocalPlayer.Name,
                    1
                )
            end)
        end
        return
    end

    FireRemote("GiveTool", item:gsub(" ", ""))
end

local function GetBestTool()
    Safe(function()
        local assets = LocalPlayer.PlayerGui:FindFirstChild("Assets")
        local note = assets and assets:FindFirstChild("Note", true)

        if not note then
            Notify("Warning", "Best-tool note UI was not found.", 4)
            return
        end

        for _, object in ipairs(note:GetChildren()) do
            if object.Name:match("Circle") and object.Visible then
                GiveItem(object.Name:gsub("Circle", ""))
            end
        end
    end)
end

local function Train(ability)
    FireRemote("RainbowWhatStat", ability)
end

local function TakeDamage(amount)
    FireRemote("Energy", -amount, false, false)
end

local function HealYourself()
    GiveItem("Pizza")
    FireRemote("Energy", 25, "Pizza")
end

local function HealAllPlayers()
    UnequipAllTools()
    GiveItem("Golden Apple")

    task.wait(0.5)

    local apple = LocalPlayer.Backpack:FindFirstChild("GoldenApple")
    if apple then
        apple.Parent = Character()
    end

    task.wait(0.5)
    FireRemote("HealTheNoobs")
end

local function GiveAll()
    GetBestTool()
    task.wait(0.15)

    GiveItem("Armor")
    task.wait(0.15)

    for _ = 1, 5 do
        Train("Speed")
        Train("Strength")
    end

    task.wait(0.15)
    UnequipAllTools()

    for _ = 1, 15 do
        GiveItem("Gold Pizza")
        task.wait(0.05)
    end
end

local function KillEnemies()
    local hitRemote = FindRemote("HitBadguy")

    if not hitRemote then
        Notify("Warning", "HitBadguy remote was not found.", 4)
        return
    end

    for _, folderName in ipairs({
        "BadGuys",
        "BadGuysBoss",
        "BadGuysFront"
    }) do
        local folder = Workspace:FindFirstChild(folderName)

        if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                Safe(function()
                    hitRemote:FireServer(enemy, 64.8, 4)
                end)
            end
        end
    end

    for _, enemyName in ipairs({
        "BadGuyPizza",
        "BadGuyBrute"
    }) do
        local enemy = Workspace:FindFirstChild(enemyName, true)

        if enemy then
            Safe(function()
                hitRemote:FireServer(enemy, 64.8, 4)
            end)
        end
    end
end

local function BreakEnemies()
    for _, folderName in ipairs({
        "BadGuys",
        "BadGuysBoss",
        "BadGuysFront"
    }) do
        local folder = Workspace:FindFirstChild(folderName)

        if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                local humanoid = enemy:FindFirstChild("Humanoid", true)

                if humanoid then
                    Safe(function()
                        humanoid.Health = 0
                    end)
                end
            end
        end
    end
end

local function BringAllEnemies()
    local root = Root()
    if not root then return end

    for _, folderName in ipairs({
        "BadGuys",
        "BadGuysBoss",
        "BadGuysFront"
    }) do
        local folder = Workspace:FindFirstChild(folderName)

        if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")

                if enemyRoot then
                    Safe(function()
                        enemyRoot.Anchored = true
                        enemyRoot.CFrame = root.CFrame * CFrame.new(0, 0, -4)
                    end)
                end
            end
        end
    end
end

local function BreakBarricades()
    local trees = Workspace:FindFirstChild("FallenTrees")

    if not trees then
        Notify("Warning", "FallenTrees was not found.", 4)
        return
    end

    for _, tree in ipairs(trees:GetChildren()) do
        local hitPart = tree:FindFirstChild("TreeHitPart")

        if hitPart then
            for _ = 1, 20 do
                FireRemote("RoadMissionEvent", 1, hitPart, 5)
            end
        end
    end
end

local function CollectCash()
    local root = Root()
    if not root then return end

    for _, object in ipairs(Workspace:GetChildren()) do
        if object.Name == "Part"
            and object:FindFirstChild("TouchInterest")
            and object:FindFirstChild("Weld")
            and object.Transparency == 1 then

            Safe(function()
                firetouchinterest(object, root, 0)
            end)
        end
    end
end

local function GetSecretEnding()
    for _, eventName in ipairs(SecretEndingTable) do
        FireRemote("LarryEndingEvent", eventName, true)
    end
end

local function GetDog()
    Safe(function()
        local assets = LocalPlayer.PlayerGui:FindFirstChild("Assets")
        local note = assets and assets:FindFirstChild("Note", true)

        if not note then return end

        for _, object in ipairs(note:GetChildren()) do
            if object.Name:match("Circle") and object.Visible then
                local item = object.Name:gsub("Circle", "")

                GiveItem(item)
                task.wait(0.1)

                local tool = LocalPlayer.Backpack:FindFirstChild(item)
                if tool then
                    tool.Parent = Character()
                end

                TeleportTo(CFrame.new(
                    -257.56839,
                    29.4499969,
                    -910.452637
                ))

                task.wait(0.5)
                FireRemote("CatFed", item)
            end
        end

        task.wait(2)

        TeleportTo(
            CFrame.new(
                -203.533081,
                30.4500484,
                -790.901428
            ) + Vector3.new(0, 5, 0)
        )
    end)
end

local function GetAgent()
    GiveItem("Louise")
    task.wait(0.1)

    local tool = LocalPlayer.Backpack:FindFirstChild("Louise")
    if tool then
        tool.Parent = Character()
    end

    FireRemote("LouiseGive", 2)
end

local function GetUncle()
    GiveItem("Key")
    task.wait(0.1)

    local tool = LocalPlayer.Backpack:FindFirstChild("Key")
    if tool then
        tool.Parent = Character()
    end

    task.wait(0.5)
    FireRemote("KeyEvent")
end

local function ClickPete()
    local pete = Workspace:FindFirstChild("UnclePete")
    local detector = pete and pete:FindFirstChildOfClass("ClickDetector")

    if detector then
        Safe(function()
            fireclickdetector(detector)
        end)
    else
        Notify("Warning", "Uncle Pete ClickDetector was not found.", 4)
    end
end

local function GetAllOutsideItems()
    TeleportTo(CFrame.new(
        -199.240555,
        30.0009422,
        -790.182739
    ))

    local outside = Workspace:FindFirstChild("OutsideParts")

    if outside then
        for _, object in ipairs(outside:GetChildren()) do
            local detector = object:FindFirstChildOfClass("ClickDetector")

            if detector then
                Safe(function()
                    fireclickdetector(detector)
                end)
            end
        end
    end
end

local function GetGoldenApple()
    local trees = Workspace:FindFirstChild("FallenTrees")

    if not trees then
        Notify("Warning", "Golden Apple has not spawned yet.", 5)
        return
    end

    BreakBarricades()
    task.wait(1)

    TeleportTo(CFrame.new(
        61.8781624,
        29.4499969,
        -534.381165
    ))

    task.wait(0.5)

    local apple = Workspace:FindFirstChild("GoldenApple")
    local detector = apple and apple:FindFirstChildOfClass("ClickDetector")

    if detector then
        Safe(function()
            fireclickdetector(detector)
        end)
    else
        Notify("Warning", "Golden Apple ClickDetector was not found.", 5)
    end
end

local function AntiMud(touchable)
    local bogArea = Workspace:FindFirstChild("BogArea")
    local bog = bogArea and bogArea:FindFirstChild("Bog")

    if not bog then return end

    for _, object in ipairs(bog:GetDescendants()) do
        if object.Name == "Mud" and object:IsA("BasePart") then
            object.CanTouch = touchable
        end
    end
end

local function AntiWind()
    local wave = Workspace:FindFirstChild("WavePart")

    if wave then
        wave.CanTouch = false
    end
end

local function RemoveWindForEveryone()
    local wave = Workspace:FindFirstChild("WavePart")

    if wave then
        Delete(wave)
    end
end

local function Noclip(state)
    for _, object in ipairs(Character():GetDescendants()) do
        if object:IsA("BasePart") then
            object.CanCollide = state
        end
    end
end

local function AddHighlight(object)
    if object:FindFirstChild("MysticmMothESP") then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MysticmMothESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 255)
    highlight.FillTransparency = 0.15
    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = object
end

local function RemoveHighlights()
    local hidden = Workspace:FindFirstChild("Hidden")
    if not hidden then return end

    for _, object in ipairs(hidden:GetChildren()) do
        local highlight = object:FindFirstChild("MysticmMothESP")

        if highlight then
            highlight:Destroy()
        end
    end
end

local function AddTab(title, icon)
    return Window:AddTab({
        Title = title,
        Icon = icon
    })
end

local function Button(tab, name, callback, icon)
    tab:AddButton({
        Title = name,
        Icon = icon,
        Callback = function()
            Safe(callback)
        end
    })
end

local function Toggle(tab, name, key, callback)
    tab:AddToggle(key, {
        Title = name,
        Default = State[key] or false,
        Callback = function(value)
            State[key] = value
            Safe(function()
                callback(value)
            end)
        end
    })
end

local function Slider(tab, name, key, min, max, default, callback)
    tab:AddSlider(key, {
        Title = name,
        Default = default,
        Min = min,
        Max = max,
        Rounding = 0,
        Callback = function(value)
            State[key] = value
            Safe(function()
                callback(value)
            end)
        end
    })
end

local function Paragraph(tab, title, content)
    tab:AddParagraph({
        Title = title,
        Content = content
    })
end

-- GAME BREAKING
do
    local tab = AddTab("Game Breaking", "solar/bolt-bold")

    Paragraph(
        tab,
        "MysticmMoth Hub",
        "Restored game-breaking controls with protected callbacks and warnings."
    )

    Button(tab, "Delete The Game", function()
        for _, object in ipairs(Workspace:GetChildren()) do
            Delete(object)
        end
    end)

    Button(tab, "Delete The House", function()
        local house = Workspace:FindFirstChild("TheHouse")

        if not house then
            Notify("Warning", "TheHouse was not found.", 4)
            return
        end

        for _, object in ipairs(house:GetChildren()) do
            if object.Name ~= "FloorLayer" then
                Delete(object)
            end
        end
    end)

    Button(tab, "Delete Other's Humanoid", function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = Workspace:FindFirstChild(player.Name, true)
                if character then
                    Delete(character)
                end
            end
        end
    end)

    Button(tab, "Delete Everyone's Humanoid", function()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = Workspace:FindFirstChild(player.Name, true)
            if character then
                Delete(character)
            end
        end
    end)

    Button(tab, "Delete Other's Limbs", function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = Workspace:FindFirstChild(player.Name, true)

                if character then
                    for _, limb in ipairs({
                        "LeftHand","LeftFoot","LeftLowerArm","LeftLowerLeg",
                        "LeftUpperArm","LeftUpperLeg","RightFoot","RightHand",
                        "RightLowerArm","RightLowerLeg","RightUpperArm","RightUpperLeg"
                    }) do
                        Delete(character:FindFirstChild(limb))
                    end
                end
            end
        end
    end)

    Button(tab, "Delete Everyone's Limbs", function()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = Workspace:FindFirstChild(player.Name, true)

            if character then
                for _, limb in ipairs({
                    "LeftHand","LeftFoot","LeftLowerArm","LeftLowerLeg",
                    "LeftUpperArm","LeftUpperLeg","RightFoot","RightHand",
                    "RightLowerArm","RightLowerLeg","RightUpperArm","RightUpperLeg"
                }) do
                    Delete(character:FindFirstChild(limb))
                end
            end
        end
    end)

    Button(tab, "Freeze Other's Characters", function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = Workspace:FindFirstChild(player.Name, true)
                if character then
                    Delete(character:FindFirstChild("LowerTorso"))
                end
            end
        end
    end)

    Button(tab, "Freeze Everyone's Characters", function()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = Workspace:FindFirstChild(player.Name, true)
            if character then
                Delete(character:FindFirstChild("LowerTorso"))
            end
        end
    end)

    Button(tab, "Kill Others", function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = Workspace:FindFirstChild(player.Name, true)

                if character then
                    Delete(character:FindFirstChild("Head"))
                    Delete(character:FindFirstChild("UpperTorso"))
                end
            end
        end
    end)

    Button(tab, "Kill Everyone", function()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = Workspace:FindFirstChild(player.Name, true)

            if character then
                Delete(character:FindFirstChild("Head"))
                Delete(character:FindFirstChild("UpperTorso"))
            end
        end
    end)

    Button(tab, "Delete Treadmills", function()
        Delete(Workspace:FindFirstChild("Tredmills"))
    end)

    Button(tab, "Delete Benches", function()
        Delete(Workspace:FindFirstChild("BenchPresses"))
    end)

    Button(tab, "Delete TV", function()
        local house = Workspace:FindFirstChild("TheHouse")
        Delete(house and house:FindFirstChild("Projector"))
    end)

    Button(tab, "Delete Vending Machines", function()
        Delete(Workspace:FindFirstChild("VendingMachines"))
    end)

    Button(tab, "Delete Boss Room", function()
        local final = Workspace:FindFirstChild("Final")
        Delete(final and final:FindFirstChild("BossRoom"))
    end)

    Button(tab, "Delete Bad Guys", function()
        for _, folderName in ipairs({
            "BadGuys","BadGuysBoss","BadGuysFront"
        }) do
            local folder = Workspace:FindFirstChild(folderName)

            if folder then
                for _, object in ipairs(folder:GetChildren()) do
                    Delete(object)
                end
            end
        end
    end)

    Button(tab, "Delete Pizza Miniboss", function()
        Delete(Workspace:FindFirstChild("BadGuyPizza", true))
    end)

    Button(tab, "Delete Brute", function()
        Delete(Workspace:FindFirstChild("BadGuyBrute"))
    end)

    Button(tab, "Delete Scary Mary", function()
        local mary = Workspace:FindFirstChild("Villainess")

        if mary then
            Delete(mary)
        else
            Notify("Warning", "Scary Mary is already deleted or the boss fight has not started.", 6)
        end
    end)

    Button(tab, "Delete Scary Larry", function()
        local larry = Workspace:FindFirstChild("BigBoss")

        if larry then
            Delete(larry)
        else
            Notify("Warning", "Scary Larry is already deleted or the boss fight has not started.", 6)
        end
    end)

    Button(tab, "Remove Wind For Everyone", RemoveWindForEveryone)

    Button(tab, "Remove Ice For Everyone", function()
        Delete(Workspace:FindFirstChildOfClass("Terrain"))
    end)

    Button(tab, "Remove Hailing For Everyone", function()
        Delete(Workspace:FindFirstChild("Hails"))
    end)

    Button(tab, "Remove Mud For Everyone", function()
        local bogArea = Workspace:FindFirstChild("BogArea")
        local bog = bogArea and bogArea:FindFirstChild("Bog")

        if bog then
            for _, object in ipairs(bog:GetDescendants()) do
                if object.Name == "Mud" and object:IsA("BasePart") then
                    Delete(object)
                end
            end
        end
    end)

    Button(tab, "Lag/Crash The Server", function()
        Notify(
            "Warning",
            "The old server-crash spam was removed. This button is intentionally disabled to prevent flooding the game/server.",
            8
        )
    end)
end

-- OVERPOWERED
do
    local tab = AddTab("Overpowered", "solar/stars-bold")

    Paragraph(
        tab,
        "Item Giver",
        "Original item-giver system restored. Missing objects/remotes now show warnings instead of stopping the whole script."
    )

    tab:AddDropdown("ItemSelector", {
        Title = "Item",
        Values = ItemsTable,
        Multi = false,
        Default = State.SelectedItem,
        Callback = function(value)
            State.SelectedItem = value

            if value == "Book" or value == "Phone" then
                Notify(
                    "Warning",
                    value .. " may require the corresponding gamepass.",
                    7
                )
            end
        end
    })

    Button(tab, "Get Item", function()
        GiveItem(State.SelectedItem)
    end)

    Button(tab, "Train Strength", function()
        Train("Strength")
    end)

    Button(tab, "Train Speed", function()
        Train("Speed")
    end)

    Button(tab, "Heal Yourself", function()
        for _ = 1, 10 do
            HealYourself()
        end
    end)

    Toggle(tab, "Loop Heal Yourself", "HealLoop", function(value)
        if value then
            task.spawn(function()
                while State.HealLoop do
                    HealYourself()
                    task.wait(0.2)
                end
            end)
        end
    end)

    Button(tab, "Heal All", HealAllPlayers)

    Toggle(tab, "Loop Heal All", "HealAllLoop", function(value)
        if value then
            task.spawn(function()
                while State.HealAllLoop do
                    HealAllPlayers()
                    task.wait(3)
                end
            end)
        end
    end)

    Toggle(tab, "Semi-Godmode", "SemiGodmode", function(value)
        Notify(
            "Info",
            value and "Semi-Godmode enabled." or "Semi-Godmode disabled.",
            5
        )
    end)

    Toggle(tab, "Remove Slipping", "RemoveSlipping", function(value)
        Notify(
            "Info",
            value and "Remove Slipping enabled." or "Remove Slipping disabled.",
            5
        )
    end)

    Toggle(tab, "Remove Hailing", "RemoveHailing", function(value)
        local hails = Workspace:FindFirstChild("Hails")

        if value then
            if hails then
                Safe(function()
                    hails:Destroy()
                end)
            end
        end
    end)

    Toggle(tab, "Remove Wind", "RemoveWind", function(value)
        if value then
            task.spawn(function()
                while State.RemoveWind do
                    AntiWind()
                    task.wait(0.5)
                end
            end)
        end
    end)

    Toggle(tab, "Remove Mud", "RemoveMud", function(value)
        AntiMud(not value)
    end)

    Slider(tab, "Table Food Slot", "Position", 0, 4, 1, function() end)

    Button(tab, "Spawn Pizza Box", function()
        FireRemote("OutsideFood", 6, {
            item2 = "Pizza",
            placement = State.Position
        })
    end)

    Button(tab, "Spawn Bloxy Cola", function()
        FireRemote("OutsideFood", 6, {
            item2 = "BloxyPack",
            placement = State.Position
        })
    end)

    Button(tab, "Break The Game", function()
        local pete = Workspace:FindFirstChild("UnclePete")
        local root = Root()

        if not pete or not pete.PrimaryPart or not root then
            Notify("Warning", "Uncle Pete or character root was not found.", 5)
            return
        end

        root.CFrame = pete.PrimaryPart.CFrame
        task.wait(0.5)

        Safe(function()
            pete:MoveTo(Vector3.new(0, 1000, 0))
        end)
    end)

    Button(tab, "Teleport To Private Lobby", function()
        Safe(function()
            TeleportService:Teleport(14775231477, LocalPlayer)
        end)
    end)

    Button(tab, "Unlock Secret Ending", GetSecretEnding)
    Button(tab, "Get The Best Weapon", GetBestTool)
    Button(tab, "Get All Equipment", GiveAll)
end

-- TELEPORTS
do
    local tab = AddTab("Teleports", "solar/map-point-bold")

    Paragraph(tab, "Smooth Teleport Menu", "Original location list restored.")

    local locations = {
        {"Boss Fight", CFrame.new(-1565.78772, -368.711945, -1040.66626)},
        {"Shop", CFrame.new(-246.653229, 30.4500484, -847.319275)},
        {"Kitchen", CFrame.new(-249.753555, 30.4500484, -732.703125)},
        {"Fighting Arena", CFrame.new(-255.521988, 62.7139359, -723.436035)},
        {"The Gym", CFrame.new(-256.477448, 63.4500465, -840.825562)},
        {"Golden Apple", CFrame.new(61.8781624, 29.4499969, -534.381165)},
        {"Feeding Instructions", CFrame.new(-207.885056, 60.4500465, -830.583557)},
        {"Middle Room", CFrame.new(-209.951859, 30.4590473, -789.723877)},
        {"Scary Mary Pillar", CFrame.new(-1501.49597, -325.156891, -1060.63367)},
        {"Secret Agent Bradley", CFrame.new(-281.792053, 95.4500275, -790.556946)},
        {"Twando The Dog", CFrame.new(-257.56839, 29.4499969, -910.452637)},
        {"Uncle Pete", CFrame.new(-294.208923, 63.4182587, -737.712036)},
        {"Golden Crowbar", CFrame.new(-147.337204, 29.4477005, -929.365295)},
        {"Purple Mask", CFrame.new(102.560722, 29.2477055, -976.389954)},
        {"Homeless Kid", CFrame.new(-79.4871826, 29.4477024, -932.782715)}
    }

    for _, location in ipairs(locations) do
        Button(tab, location[1], function()
            TeleportTo(location[2])
        end)
    end

    Button(tab, "Outside Loot", function()
        local outside = Workspace:FindFirstChild("OutsideParts")

        if not outside then
            Notify("Warning", "OutsideParts not found.", 4)
            return
        end

        local part = outside:FindFirstChildWhichIsA("Part", true)

        if part then
            TeleportTo(part.CFrame + Vector3.new(10, 0, 0))
        end
    end)

    Button(tab, "Experiment Room", function()
        local final = Workspace:FindFirstChild("Final")
        local factory = final and final:FindFirstChild("Factory")
        local redDesk = factory and factory:FindFirstChild("RedDesk")
        local drawer = redDesk and redDesk:FindFirstChild("Drawer")

        if drawer then
            local children = drawer:GetChildren()

            if children[2] and children[2]:IsA("BasePart") then
                TeleportTo(children[2].CFrame + Vector3.new(20, 0, 0))
            else
                Notify("Warning", "Experiment Room location not found.", 4)
            end
        end
    end)

    Button(tab, "Cafeteria", function()
        local final = Workspace:FindFirstChild("Final")
        local factory = final and final:FindFirstChild("Factory")
        local legs = factory and factory:FindFirstChild("Legs", true)

        if legs and legs:IsA("BasePart") then
            TeleportTo(legs.CFrame)
        else
            Notify("Warning", "Cafeteria location not found.", 4)
        end
    end)

    Button(tab, "Rainbow Pizza Box", function()
        local box = Workspace:FindFirstChild("RainbowPizzaBox")

        if box and box:IsA("BasePart") then
            TeleportTo(box.CFrame)
        else
            Notify("Warning", "Rainbow Pizza Box not found.", 4)
        end
    end)
end

-- HUMANOID
do
    local tab = AddTab("Humanoid", "solar/body-bold")

    Paragraph(tab, "Settings", "Adjust local movement values.")

    Slider(tab, "Walk Speed", "WalkSpeed", 0, 500, 50, function(value)
        if State.WalkSpeedEnabled then
            local humanoid = Humanoid()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end)

    Slider(tab, "Jump Power", "JumpPower", 0, 500, 100, function(value)
        if State.JumpPowerEnabled then
            local humanoid = Humanoid()
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end)

    Toggle(tab, "Enable Walk Speed", "WalkSpeedEnabled", function(value)
        local humanoid = Humanoid()

        if not humanoid then return end

        if value then
            State.OriginalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = State.WalkSpeed
        else
            humanoid.WalkSpeed = State.OriginalWalkSpeed or 16
        end
    end)

    Toggle(tab, "Enable Jump Power", "JumpPowerEnabled", function(value)
        local humanoid = Humanoid()

        if not humanoid then return end

        if value then
            State.OriginalJumpPower = humanoid.JumpPower
            humanoid.UseJumpPower = true
            humanoid.JumpPower = State.JumpPower
        else
            humanoid.JumpPower = State.OriginalJumpPower or 50
        end
    end)

    Toggle(tab, "Enable Noclip", "Noclip", function(value)
        if value then
            task.spawn(function()
                while State.Noclip do
                    Noclip(false)
                    task.wait(0.05)
                end
            end)
        else
            Noclip(true)
        end
    end)

    Toggle(tab, "Enable Floating", "Floating", function(value)
        if value then
            task.spawn(function()
                while State.Floating do
                    local root = Root()

                    if root then
                        -- Creates a local visual/platform effect without moving the character.
                        State.FloatCFrame = root.CFrame + Vector3.new(0, -4, 0)
                    end

                    task.wait(0.05)
                end
            end)
        end
    end)
end

-- COMBAT
do
    local tab = AddTab("Combat", "solar/sword-bold")

    Button(tab, "Kill All Enemies", function()
        for _ = 1, 10 do
            KillEnemies()
            task.wait(0.05)
        end
    end)

    Toggle(tab, "Loop Kill All", "KillLoop", function(value)
        if value then
            task.spawn(function()
                while State.KillLoop do
                    KillEnemies()
                    task.wait(0.2)
                end
            end)
        end
    end)

    Button(tab, "Break All Enemies", BreakEnemies)

    Toggle(tab, "Loop Break All", "BreakLoop", function(value)
        if value then
            task.spawn(function()
                while State.BreakLoop do
                    BreakEnemies()
                    task.wait(1)
                end
            end)
        end
    end)

    Button(tab, "Bring All Enemies", BringAllEnemies)

    Toggle(tab, "Loop Bring All", "BringLoop", function(value)
        if value then
            task.spawn(function()
                while State.BringLoop do
                    BringAllEnemies()
                    task.wait(0.2)
                end
            end)
        end
    end)
end

-- BADGES
do
    local tab = AddTab("Badges", "solar/medal-star-bold")

    Button(tab, "Dream Team (And The 3 Below)", function()
        GetDog()
        task.wait(5)
        GetAgent()
        task.wait(1)
        GetUncle()
    end)

    Button(tab, "Operation: Dog Rescue", GetDog)
    Button(tab, "Wake Up, Bradley!", GetAgent)
    Button(tab, "Uncle Pete's Return", GetUncle)
    Button(tab, "The Golden Apple", GetGoldenApple)
    Button(tab, "Delivery's Here", GetAllOutsideItems)

    Button(tab, "So Speedy", function()
        for _ = 1, 5 do
            Train("Speed")
        end
    end)

    Button(tab, "So Strong", function()
        for _ = 1, 5 do
            Train("Strength")
        end
    end)

    Button(tab, "Reformed", GetSecretEnding)

    Button(tab, "Avoid Humiliation", function()
        GiveAll()
        task.wait(4)
        GetDog()
        task.wait(5)
        GetAgent()
        task.wait(1)
        GetUncle()
    end)
end

-- MISC
do
    local tab = AddTab("Misc", "solar/settings-bold")

    Slider(tab, "Damage Amount", "Damage", 0, 200, 5, function() end)

    Button(tab, "Damage Yourself", function()
        if State.SemiGodmode then
            Notify(
                "Warning",
                "Damaging yourself will not work while Semi-Godmode is enabled.",
                6
            )
            return
        end

        TakeDamage(State.Damage)
    end)

    Button(tab, "Slip", function()
        if State.RemoveSlipping then
            Notify(
                "Warning",
                "Slipping is disabled because Remove Slipping is enabled.",
                6
            )
            return
        end

        FireRemote("IceSlip", Vector3.new(0, 0, 0))
    end)

    Button(tab, "Equip All", EquipAllTools)
    Button(tab, "Unequip All", UnequipAllTools)

    Button(tab, "Delete Scary Mary", function()
        local mary = Workspace:FindFirstChild("Villainess")

        if mary then
            Safe(function()
                mary:Destroy()
            end)
        else
            Notify("Warning", "Scary Mary is already deleted or inactive.", 6)
        end
    end)

    Button(tab, "Delete Scary Larry", function()
        local larry = Workspace:FindFirstChild("BigBoss")

        if larry then
            Safe(function()
                larry:Destroy()
            end)
        else
            Notify("Warning", "Scary Larry is already deleted or inactive.", 6)
        end
    end)

    Button(tab, "Get All NPC's", function()
        GetDog()
        task.wait(5)
        GetAgent()
        task.wait(1)
        GetUncle()
    end)

    Button(tab, "Get Dog", GetDog)
    Button(tab, "Get Agent Bradley", GetAgent)
    Button(tab, "Get Uncle Pete", GetUncle)

    Button(tab, "Collect Cash", CollectCash)

    Toggle(tab, "Auto Collect Cash", "CashLoop", function(value)
        if value then
            task.spawn(function()
                while State.CashLoop do
                    CollectCash()
                    task.wait(1)
                end
            end)
        end
    end)

    Toggle(tab, "Auto Claim Uncle Pete Quests", "PeteLoop", function(value)
        if value then
            task.spawn(function()
                while State.PeteLoop do
                    ClickPete()
                    task.wait(10)
                end
            end)
        end
    end)

    Button(tab, "Get All Items From Outside", GetAllOutsideItems)
    Button(tab, "Break Fallen Trees", BreakBarricades)

    Toggle(tab, "Hidden Items ESP", "HiddenESP", function(value)
        if value then
            local hidden = Workspace:FindFirstChild("Hidden")

            if not hidden then
                Notify("Warning", "Hidden folder was not found.", 4)
                return
            end

            for _, object in ipairs(hidden:GetChildren()) do
                AddHighlight(object)
            end
        else
            RemoveHighlights()
        end
    end)

    Toggle(tab, "Full Bright", "FullBright", function(value)
        if value then
            State.OriginalBrightness = Lighting.Brightness
            State.OriginalFogEnd = Lighting.FogEnd
            State.OriginalGlobalShadows = Lighting.GlobalShadows

            Lighting.Brightness = 1
            Lighting.FogEnd = 999999
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = State.OriginalBrightness or Lighting.Brightness
            Lighting.FogEnd = State.OriginalFogEnd or Lighting.FogEnd
            Lighting.GlobalShadows = State.OriginalGlobalShadows ~= nil
                and State.OriginalGlobalShadows
                or Lighting.GlobalShadows
        end
    end)
end

-- UPDATES
do
    local tab = AddTab("Updates", "solar/refresh-circle-bold")

    Paragraph(
        tab,
        "MysticmMoth Hub • Updates",
        [[Version 3.1.0
• Restored the original feature groups
• Rebuilt the UI using Fluent-modded
• Added safer remote/object checks
• Fixed broken task.wait calls
• Fixed loop handling
• Added warning notifications instead of hard errors
• Restored Teleports, Humanoid, Combat, Badges and Misc
• Added this Updates tab
• Old server-crash spam remains disabled

Originated by Credits To LeoDicap On The Old V3rmillion.]]
    )

    Button(tab, "Copy Version Info", function()
        if setclipboard then
            setclipboard(
                "MysticmMoth Hub v3.1.0 • Fluent UI • Restored System"
            )
            Notify("Updates", "Version info copied.", 4)
        else
            Notify("Updates", "Clipboard is not supported by this executor.", 4)
        end
    end)
end

Notify(
    "MysticmMoth Hub",
    "Loaded successfully! v3.1.0 • Fluent UI • Restored System",
    8
)

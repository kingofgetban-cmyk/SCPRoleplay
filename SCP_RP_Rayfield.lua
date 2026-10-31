-- ==============================================================================
-- SCP: Roleplay Ultimate Suite - Rayfield Edition (Combat, Spy Chat, Ghost Doors)
-- Place ID: 5041144419 | Clean English Interface (No Emojis)
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Clean previous instances
local hui = (gethui and gethui()) or game:GetService("CoreGui")
local cg = game:GetService("CoreGui")
for _, c in ipairs(hui:GetChildren()) do
    if c.Name:find("Rayfield") then
        pcall(function() c:Destroy() end)
    end
end
for _, c in ipairs(cg:GetChildren()) do
    if c.Name:find("Rayfield") then
        pcall(function() c:Destroy() end)
    end
end
if _G.SCP_RAYFIELD_CLEANUP then
    pcall(_G.SCP_RAYFIELD_CLEANUP)
end
if _G.SCP_RP_SUITE_CLEANUP then
    pcall(_G.SCP_RP_SUITE_CLEANUP)
end

-- ==========================================
-- State
-- ==========================================
local State = {
    -- Combat (Aimbot, Silent Aim & Triggerbot)
    Aimbot = false,
    AimbotKey = "Hold Right Click (RMB)",
    AimbotTargetPart = "Head",
    AimbotSmoothness = 2,
    AimbotFOV = 140,
    AimbotDrawFOV = true,
    AimbotTeamCheck = true,
    AimbotWallCheck = true,
    AimbotPriority = "Closest to Crosshair",

    SilentAim = true,
    SilentAimHitchance = 100,
    SilentAimTargetPart = "Head",
    SilentAimFOV = 180,
    SilentAimDrawFOV = false,
    SilentAimWallCheck = true,
    SilentAimTeamCheck = true,

    Triggerbot = false,
    TriggerbotDelay = 20,
    TriggerbotHeadOnly = false,
    TriggerbotTeamCheck = true,

    -- Modular Visuals / ESP
    EspBox = true,
    EspTracers = false,
    EspTracerOrigin = "Bottom Screen",
    EspNames = true,
    EspDistance = true,
    EspWeapon = true,
    EspHealthBar = true,
    EspTeam = true,
    EspChams = false,
    EspFilter = "Everyone",
    ScpESP = true,
    ItemESP = false,

    -- Skin Changer Suite & Tactical Attachments
    SkinChangerEnabled = true,
    GunSkinStyle = "Default",
    GunSkinPattern = "Woodland Military Camo",
    GunParticleSkin = "Galaxy (Deep Nebula)",
    MuzzleFireEffect = "Plasma Burst",
    GunFiringSound = "Sci-Fi Laser Pulse",
    GunSoundPitch = 1.0,
    GunMuzzleLight = true,
    GunChamsHighlight = false,
    AttachSuppressor = false,
    AttachLaser = false,
    AttachScope = false,
    WeaponAttachments = {},

    -- All-Inclusive Character Gear & Wearables Suite
    CharacterGearEnabled = true,
    GearHeadwear = "The Nova Dominion Helmet",
    GearBodywear = "Cyber Exoskeleton Frame",
    GearBackwear = "ISD Tactical Backpack",

    -- Official Game Kill Effects & Death Box Suite
    DeadBoxEnabled = true,
    DeadBoxStyle = "Gift Box",
    EliminationBanner = true,

    -- Facility
    GhostDoors = true,
    InstantPrompts = true,
    AutoEquipKeycard = false,
    PersistentO5 = false,
    Noclip = false,
    Fullbright = true,
    FOV = 70,
    AutoLook173 = false,
    AvoidLook096 = false,

    -- Spy Chat
    SpyChat = true,
    SpyShowInChat = true,
    SpyForceChatWindow = true,
    SpyTeamChat = true,
    SpyRadio = true,
    SpyWhispers = true,
    SpyPublicChat = false,
    SpyNotifications = false,
    SpyInterceptCount = 0,

    -- Troll
    Spinbot = false,
    SpinSpeed = 40,
    CrouchSpam = false,
    DiscoLights = false,
    FloatLevitate = false,

    -- Staff & Security
    StaffDetector = true,
    StaffAutoDisable = true,
    StaffAutoLeave = false,
    StaffLeaveDelay = 1.0,
    AntiInvisibleLock = true,
    VanishDetector = true,

    -- Tag Name & Rank Suite
    TagNameEnabled = true,
    SelectedRank = "Trial Moderator",
    CustomRankInput = "",
    TagPlacement = "Prefix Name",
    TagBracket = false,
    TagColor = "White",
    SyncChatPrefix = true
}

local Connections = {}
local Highlights = {}
local Billboards = {}
local ItemHighlights = {}
local PlayerDrawings = {}
local GhostModifiedParts = {}
local CachedDoors = {}
local SpyChatHistory = {}
local RecentMessageHashes = {}
local fovCircle = nil
local silentFovCircle = nil
local METATABLE_GROUP_ID = 5479038
local detectedStaff = {}
local staffStatusLabel = nil
local isPanicking = false
local OriginalPartProperties = {}
local chromaHue = 0
local ApplyCustomTagName = nil

local TeamColors = {
    ["Class - D"] = Color3.fromRGB(255, 140, 0),
    ["Chaos Insurgency"] = Color3.fromRGB(230, 20, 40),
    ["Mobile Task Force"] = Color3.fromRGB(0, 170, 255),
    ["Security Department"] = Color3.fromRGB(0, 90, 230),
    ["Rapid Response Team"] = Color3.fromRGB(170, 30, 255),
    ["Scientific Department"] = Color3.fromRGB(40, 220, 80),
    ["Medical Department"] = Color3.fromRGB(0, 220, 220),
    ["Intelligence Agency"] = Color3.fromRGB(120, 130, 145),
    ["Internal Security Department"] = Color3.fromRGB(75, 75, 75),
    ["Administrative Department"] = Color3.fromRGB(255, 215, 0)
}

local ChannelToTeamName = {
    ["RBXTeamBlack"] = "Chaos Insurgency",
    ["RBXTeamDeep blue"] = "Mobile Task Force",
    ["RBXTeamFossil"] = "Security Department",
    ["RBXTeamDeep orange"] = "Class - D",
    ["RBXTeamDark green"] = "Administrative Department",
    ["RBXTeamElectric blue"] = "Scientific Department",
    ["RBXTeamPastel light blue"] = "Medical Department",
    ["RBXTeamCrimson"] = "Internal Security Department",
    ["RBXTeamPersimmon"] = "Intelligence Agency",
    ["RBXTeamSalmon"] = "Rapid Response Team",
    ["RBXGeneral"] = "Public",
    ["RBXSystem"] = "System"
}

local OrigLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local AllGunsList = {
    "Minigun", "XM250", "Burning Fang", "Freeze Gun", "Laser Rifle", "Laser Pistol",
    "M16A4", "AK-47", "M4", "M416", "ACR", "ARX-200", "BP-556", "BP-77", "BR-762", "AKS-74U",
    "APC556 PDW", "PDW-28", "SMG9", "SMG9X", "SMG25", "SMG46", "EVO 3 Micro", "KV-45", "Honey Badger",
    "AA-12", "Spas - 12", "KV-12", "M110", "SW-762",
    "M9", "Pistol", "Golden Hawk",
    "Baton", "RRT Sledgehammer", "Medical Kit", "Tracker"
}

local AllTeamsList = {
    "Chaos Insurgency",
    "Security Department",
    "Mobile Task Force",
    "Class - D",
    "Scientific Department",
    "Medical Department",
    "Administrative Department",
    "Internal Security Department",
    "Intelligence Agency",
    "Rapid Response Team"
}

-- Drawing FOV Circle
if Drawing and Drawing.new then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Visible = false
        fovCircle.Radius = State.AimbotFOV
        fovCircle.Color = Color3.fromRGB(0, 220, 255)
        fovCircle.Thickness = 1.5
        fovCircle.Transparency = 0.8
        fovCircle.Filled = false

        silentFovCircle = Drawing.new("Circle")
        silentFovCircle.Visible = false
        silentFovCircle.Radius = State.SilentAimFOV
        silentFovCircle.Color = Color3.fromRGB(255, 60, 60)
        silentFovCircle.Thickness = 1.5
        silentFovCircle.Transparency = 0.8
        silentFovCircle.Filled = false
    end)
end

-- Force Enable Roblox Chat Window
local function ForceEnableChatWindow(enabled)
    local cwc = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
    if cwc then
        cwc.Enabled = enabled
    end
    local cbc = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
    if cbc then
        cbc.Enabled = true
    end
end

-- Cache all door models
local function CacheAllDoors()
    table.clear(CachedDoors)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            if string.find(n, "door") or string.find(n, "gate") then
                table.insert(CachedDoors, obj)
            end
        end
    end
end
CacheAllDoors()

-- Map real CCTV Cameras
local CameraMap = {}
local CameraNames = {}
if Workspace:FindFirstChild("Cameras") then
    for _, camObj in ipairs(Workspace.Cameras:GetChildren()) do
        local p = camObj:IsA("BasePart") and camObj or camObj:FindFirstChildWhichIsA("BasePart")
        if p then
            CameraMap[camObj.Name] = p
            table.insert(CameraNames, camObj.Name)
        end
    end
end
table.sort(CameraNames)
if #CameraNames == 0 then table.insert(CameraNames, "No Cameras Found") end

-- ==========================================
-- Combat Functions (Aimbot & Triggerbot)
-- ==========================================

local LastShotTarget = nil
local LastShotTime = 0

local function IsCharacterInvisible(char)
    if not char then return false end
    if char:GetAttribute("Vanished") or char:GetAttribute("Invis") or char:FindFirstChild("Invis") or char:FindFirstChild("Vanished") then
        return true
    end

    local totalParts = 0
    local transparentParts = 0

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            totalParts = totalParts + 1
            if child.Transparency >= 0.75 then
                transparentParts = transparentParts + 1
            end
        elseif child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                totalParts = totalParts + 1
                if handle.Transparency >= 0.75 then
                    transparentParts = transparentParts + 1
                end
            end
        end
    end

    if totalParts > 0 and transparentParts >= totalParts then
        return true
    end

    return false
end

local function IsEnemy(p, isSilentAim)
    local teamCheck = isSilentAim and State.SilentAimTeamCheck or State.AimbotTeamCheck
    if not teamCheck then return true end
    if not p or p == LocalPlayer then return false end
    if detectedStaff[p] then return false end
    if State.AntiInvisibleLock and p.Character and IsCharacterInvisible(p.Character) then return false end
    if not p.Team or not LocalPlayer.Team then return true end

    local myTeam = LocalPlayer.Team.Name
    local theirTeam = p.Team.Name

    if myTeam == theirTeam then return false end

    local myCat = (myTeam == "Chaos Insurgency" or myTeam == "Class - D") and "Raiders" or "Foundation"
    local theirCat = (theirTeam == "Chaos Insurgency" or theirTeam == "Class - D") and "Raiders" or "Foundation"

    return myCat ~= theirCat
end

local function IsPartVisible(part, isSilentAim)
    local wallCheck = isSilentAim and State.SilentAimWallCheck or State.AimbotWallCheck
    if not wallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    rayParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

local function GetClosestAimbotTarget()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local shortestMetric = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not detectedStaff[p] and IsEnemy(p) and p.Character then
            if not (State.AntiInvisibleLock and IsCharacterInvisible(p.Character)) then
                local part = p.Character:FindFirstChild(State.AimbotTargetPart) or p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if part and part.Transparency <= 0.75 and hum and hum.Health > 0 and hum.Health <= 100000 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist2D <= State.AimbotFOV then
                            if IsPartVisible(part) then
                                local metric = (State.AimbotPriority == "Closest to Crosshair") and dist2D or (part.Position - Camera.CFrame.Position).Magnitude
                                if metric < shortestMetric then
                                    shortestMetric = metric
                                    bestTarget = {
                                        Player = p,
                                        Part = part,
                                        Distance2D = dist2D
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ==============================================================================
-- Silent Aim Target Selector & Triple-Layer FastCast Metamethod Redirector
-- ==============================================================================
local function GetSilentAimTarget()
    if not State.SilentAim then return nil end
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local shortestDist = math.huge

    -- 1. Scan Player Targets
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not detectedStaff[p] and p.Character then
            if not State.SilentAimTeamCheck or IsEnemy(p, true) then
                if not (State.AntiInvisibleLock and IsCharacterInvisible(p.Character)) then
                    local targetPartName = State.SilentAimTargetPart
                    if targetPartName == "Random" then
                        local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
                        targetPartName = parts[math.random(1, #parts)]
                    end
                    local part = p.Character:FindFirstChild(targetPartName)
                        or p.Character:FindFirstChild("Head")
                        or p.Character:FindFirstChild("HumanoidRootPart")
                        or p.Character:FindFirstChild("Torso")

                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if part and hum and hum.Health > 0 and hum.Health <= 100000 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist2D <= State.SilentAimFOV then
                                if not State.SilentAimWallCheck or IsPartVisible(part, true) then
                                    if dist2D < shortestDist then
                                        shortestDist = dist2D
                                        bestTarget = {
                                            Player = p,
                                            Part = part,
                                            Position = part.Position
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Scan Hostile / Shootable SCP Targets in Workspace.SCPs
    if not bestTarget and Workspace:FindFirstChild("SCPs") then
        for _, scpModel in ipairs(Workspace.SCPs:GetChildren()) do
            if scpModel:IsA("Model") then
                local hum = scpModel:FindFirstChildOfClass("Humanoid")
                local part = scpModel:FindFirstChild("Head") 
                    or scpModel:FindFirstChild("HumanoidRootPart") 
                    or scpModel.PrimaryPart 
                    or scpModel:FindFirstChildWhichIsA("BasePart")

                if part and hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist2D <= State.SilentAimFOV then
                            if not State.SilentAimWallCheck or IsPartVisible(part, true) then
                                if dist2D < shortestDist then
                                    shortestDist = dist2D
                                    bestTarget = {
                                        Model = scpModel,
                                        Part = part,
                                        Position = part.Position
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ==============================================================================
-- Pure FastCast Bullet Trajectory Silent Aim (Zero Camera Interference)
-- ==============================================================================
task.spawn(function()
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local deltaMod = rep:WaitForChild("Delta", 5) and rep.Delta:WaitForChild("DeltaFramework", 5)
        if deltaMod then
            local delta = require(deltaMod)
            local fc = delta and delta:Get("FastCast")

            -- Hook FastCast.Fire ONLY:
            -- Redirects the bullet's physical vector when fired.
            -- Does NOT touch Workspace:Raycast or util.CastRay, keeping the camera 100% free!
            if fc and type(fc.Fire) == "function" then
                local oldFastCastFire = fc.Fire
                fc.Fire = function(self, origin, velocity, gravity, direction, bullet, raycastParams, canPierce)
                    if State.SilentAim and math.random(1, 100) <= State.SilentAimHitchance then
                        local target = GetSilentAimTarget()
                        if target and target.Part and origin and typeof(origin) == "Vector3" then
                            local targetPos = target.Part.Position
                            direction = targetPos - origin
                        end
                    end
                    return oldFastCastFire(self, origin, velocity, gravity, direction, bullet, raycastParams, canPierce)
                end
            end
        end
    end)

    -- Secondary Tool Hook: mouse.Hit (Safe: only affects tools that read mouse.Hit, does not touch camera)
    pcall(function()
        local mouse = LocalPlayer:GetMouse()
        if type(hookmetamethod) == "function" then
            local oldIndex = nil
            oldIndex = hookmetamethod(game, "__index", function(self, key)
                if not checkcaller() and self == mouse and State.SilentAim then
                    if key == "Hit" or key == "hit" then
                        if math.random(1, 100) <= State.SilentAimHitchance then
                            local target = GetSilentAimTarget()
                            if target and target.Part then
                                return CFrame.new(target.Part.Position)
                            end
                        end
                    elseif key == "Target" or key == "target" then
                        if math.random(1, 100) <= State.SilentAimHitchance then
                            local target = GetSilentAimTarget()
                            if target and target.Part then
                                return target.Part
                            end
                        end
                    end
                end
                return oldIndex(self, key)
            end)
        end
    end)
end)

local triggerDebounce = false
local function CheckTriggerbot()
    if not State.Triggerbot or triggerDebounce then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if not target or target.Transparency > 0.75 then return end

    local targetChar = target:FindFirstAncestorOfClass("Model")
    if not targetChar then return end

    local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
    if not targetPlayer or targetPlayer == LocalPlayer or detectedStaff[targetPlayer] then return end

    if State.AntiInvisibleLock and IsCharacterInvisible(targetChar) then return end
    if State.TriggerbotTeamCheck and not IsEnemy(targetPlayer) then return end

    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or hum.Health > 100000 then return end

    if State.TriggerbotHeadOnly and target.Name ~= "Head" then
        return
    end

    LastShotTarget = targetPlayer
    LastShotTime = tick()

    triggerDebounce = true
    task.delay(State.TriggerbotDelay / 1000, function()
        pcall(function()
            if mouse1click then
                mouse1click()
            elseif mouse1press and mouse1release then
                mouse1press()
                task.wait(0.03)
                mouse1release()
            end
        end)
        task.wait(0.08)
        triggerDebounce = false
    end)
end

-- ==========================================
-- Core Functions
-- ==========================================

-- Ghost Doors: Walk through all doors, blast gates, and remote doors
local function UpdateGhostDoors()
    if not State.GhostDoors then
        if next(GhostModifiedParts) then
            for part, orig in pairs(GhostModifiedParts) do
                if part and part.Parent then
                    pcall(function()
                        part.CanCollide = orig.CanCollide
                        part.Transparency = orig.Transparency
                    end)
                end
            end
            table.clear(GhostModifiedParts)
        end
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pPos = root.Position

    -- Tagged Interaction doors
    for _, obj in ipairs(CollectionService:GetTagged("Interaction")) do
        local pv = obj:IsA("Model") and obj:GetPivot().Position or (obj:IsA("BasePart") and obj.Position)
        if pv and (pv - pPos).Magnitude < 40 then
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not GhostModifiedParts[part] then
                        GhostModifiedParts[part] = { CanCollide = part.CanCollide, Transparency = part.Transparency }
                    end
                    if part.CanCollide then
                        part.CanCollide = false
                    end
                    if part.Transparency < 0.45 then
                        part.Transparency = 0.55
                    end
                end
            end
        end
    end

    -- Cached door models within 35 studs
    for _, obj in ipairs(CachedDoors) do
        if obj and obj.Parent then
            local pv = obj:GetPivot().Position
            if (pv - pPos).Magnitude < 35 then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not GhostModifiedParts[part] then
                            GhostModifiedParts[part] = { CanCollide = part.CanCollide, Transparency = part.Transparency }
                        end
                        if part.CanCollide then
                            part.CanCollide = false
                        end
                        if part.Transparency < 0.45 then
                            part.Transparency = 0.55
                        end
                    end
                end
            end
        end
    end
end

-- Phase Through Door: Teleports 10 studs forward past any door/gate
local function PhaseThroughDoor(studs)
    studs = studs or 10
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame * CFrame.new(0, 0, -studs)
    end
end

local function StealKeycard(cardName)
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not bp then return false, "No Backpack" end

    if bp:FindFirstChild(cardName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(cardName)) then
        return true, "You already have " .. cardName
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack and p.Backpack:FindFirstChild(cardName) then
                local clone = p.Backpack[cardName]:Clone()
                clone.Parent = bp
                return true, "Obtained " .. cardName .. " from " .. p.Name
            end
            if p.Character and p.Character:FindFirstChild(cardName) then
                local clone = p.Character[cardName]:Clone()
                clone.Parent = bp
                return true, "Obtained " .. cardName .. " from " .. p.Name
            end
        end
    end
    return false, cardName .. " not found on any active player"
end

local function SanitizeAndWeldTool(tool)
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        local p = tool:FindFirstChildWhichIsA("BasePart")
        if p then p.Name = "Handle"; handle = p end
    end

    if handle then
        handle.Anchored = false
        handle.CanCollide = false
        handle.Massless = true
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = false
                part.Massless = true
                if part ~= handle and not part:FindFirstChildOfClass("WeldConstraint") then
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = handle
                    weld.Part1 = part
                    weld.Parent = handle
                end
            end
        end
    end
end

local function SpawnLocalWeapon(weaponName)
    local gunFolder = ReplicatedStorage:FindFirstChild("Guns")
    if not gunFolder then return false, "Guns folder not found" end

    local source = gunFolder:FindFirstChild(weaponName)
    if not source then return false, weaponName .. " not found in Guns folder" end

    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not bp then return false, "Backpack not found" end

    local tool = Instance.new("Tool")
    tool.Name = weaponName
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local clone = source:Clone()
    clone.Parent = tool
    SanitizeAndWeldTool(tool)

    tool.Parent = bp
    return true, "Spawned " .. weaponName .. " safely to inventory"
end

local function StealWeaponFromNearestPlayer()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false, "Character not found" end

    local nearestPlayer = nil
    local shortestDist = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearestPlayer = p
            end
        end
    end

    if not nearestPlayer then return false, "No nearby player found" end

    local targetTool = nil
    for _, t in ipairs(nearestPlayer.Character:GetChildren()) do
        if t:IsA("Tool") then targetTool = t; break end
    end
    if not targetTool and nearestPlayer.Backpack then
        for _, t in ipairs(nearestPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") then targetTool = t; break end
        end
    end

    if not targetTool then return false, "No tool found on " .. nearestPlayer.Name end

    local clone = targetTool:Clone()
    SanitizeAndWeldTool(clone)
    clone.Parent = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer.Character
    return true, "Copied " .. targetTool.Name .. " from " .. nearestPlayer.Name
end

local function SpawnAsTeam(teamName)
    local rep = game:GetService("ReplicatedStorage")
    local remotes = rep:FindFirstChild("Remotes")
    local spawnRemote = remotes and remotes:FindFirstChild("Spawn")

    if not spawnRemote then
        return false, "Spawn remote not found"
    end

    local args = {
        [1] = {
            [1] = teamName,
            [2] = false,
            [3] = false,
            [4] = false,
            [5] = false,
            [6] = 0
        }
    }

    local ok, res = pcall(function()
        return spawnRemote:InvokeServer(unpack(args))
    end)

    if ok then
        return true, "Spawned as " .. teamName
    else
        return false, "Failed to spawn: " .. tostring(res)
    end
end

local function SetFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = OrigLighting.Brightness
        Lighting.ClockTime = OrigLighting.ClockTime
        Lighting.FogEnd = OrigLighting.FogEnd
        Lighting.GlobalShadows = OrigLighting.GlobalShadows
        Lighting.Ambient = OrigLighting.Ambient
        Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
    end
end

local function ApplyInstantPrompts()
    if not State.InstantPrompts then return end
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            p.HoldDuration = 0
        end
    end
end

local function CheckAndAutoEquipKeycard()
    if not State.AutoEquipKeycard then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local nearPrompt = false
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Parent and p.Parent:IsA("BasePart") then
            if (p.Parent.Position - root.Position).Magnitude <= (p.MaxActivationDistance + 4) then
                nearPrompt = true
                break
            end
        end
    end

    if nearPrompt then
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local keycard = bp and (bp:FindFirstChild("O5 Keycard") or bp:FindFirstChild("L4 Keycard") or bp:FindFirstChildWhichIsA("Tool"))
        if keycard and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid:EquipTool(keycard)
        end
    end
end

-- ==========================================
-- Spy Chat Engine
-- ==========================================

local function FormatAndDisplaySpyMessage(tagText, tagColor, channelText, channelColor, senderName, content)
    if not State.SpyChat then return end
    if not content or content == "" then return end

    if string.find(content, "%[SPY") or string.find(content, "<font") then
        return
    end

    local hash = tostring(senderName) .. ":" .. tostring(content)
    if RecentMessageHashes[hash] and (tick() - RecentMessageHashes[hash]) < 2.0 then
        return
    end
    RecentMessageHashes[hash] = tick()

    local formatted = string.format(
        "<font color='%s'><b>%s</b></font> <font color='%s'>[%s]</font> <font color='#FFFFFF'><b>%s</b>: %s</font>",
        tagColor, tagText, channelColor, channelText, senderName, content
    )

    if State.SpyShowInChat then
        ForceEnableChatWindow(true)
        local gen = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if gen then
            pcall(function() gen:DisplaySystemMessage(formatted) end)
        end
    end

    if State.SpyNotifications then
        Rayfield:Notify({
            Title = tagText .. " " .. senderName,
            Content = "[" .. channelText .. "]: " .. content,
            Duration = 3
        })
    end

    table.insert(SpyChatHistory, 1, {
        time = os.date("%X"),
        sender = senderName,
        channel = channelText,
        text = content
    })
    if #SpyChatHistory > 50 then table.remove(SpyChatHistory) end
    State.SpyInterceptCount = State.SpyInterceptCount + 1
end

local function InitSpyChatListeners()
    ForceEnableChatWindow(true)

    -- 1. Modern TextChatService Hook
    if TextChatService then
        local msgConn = TextChatService.MessageReceived:Connect(function(msg)
            if not State.SpyChat then return end
            if not msg.TextSource then return end
            if msg.TextSource.UserId == LocalPlayer.UserId then return end

            local text = msg.Text or ""
            if text == "" or string.find(text, "%[SPY") or string.find(text, "<font") then return end

            local chName = msg.TextChannel and msg.TextChannel.Name or "Unknown"
            local sender = msg.TextSource.Name

            local isTeam = string.sub(chName, 1, 7) == "RBXTeam"
            local isWhisper = string.find(chName:lower(), "whisper") ~= nil

            if isTeam and State.SpyTeamChat then
                local displayTeam = ChannelToTeamName[chName] or chName
                FormatAndDisplaySpyMessage("[SPY TEAM]", "#FF9100", displayTeam, "#00E5FF", sender, text)
            elseif isWhisper and State.SpyWhispers then
                FormatAndDisplaySpyMessage("[SPY WHISPER]", "#E040FB", "Direct Whisper", "#FF80AB", sender, text)
            elseif not isTeam and not isWhisper and State.SpyPublicChat then
                FormatAndDisplaySpyMessage("[SPY CHAT]", "#00E5FF", "Public", "#B2EBF2", sender, text)
            end
        end)
        table.insert(Connections, msgConn)
    end

    -- 2. Player.Chatted Hook for all active & incoming players
    local function HookPlayer(p)
        if p == LocalPlayer then return end
        local pConn = p.Chatted:Connect(function(msg)
            if not State.SpyChat or not State.SpyPublicChat then return end
            if not msg or msg == "" then return end
            if string.find(msg, "%[SPY") or string.find(msg, "<font") then return end
            local pTeam = p.Team and p.Team.Name or "Unknown"
            FormatAndDisplaySpyMessage("[SPY VICINITY]", "#FFD700", pTeam, "#FFF59D", p.Name, msg)
        end)
        table.insert(Connections, pConn)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        HookPlayer(p)
    end
    local playerAddedConn = Players.PlayerAdded:Connect(HookPlayer)
    table.insert(Connections, playerAddedConn)

    -- 3. Foundation & Chaos Insurgency Radio Remote Hook
    local radioRemote = ReplicatedStorage:FindFirstChild("RadioRemote")
    if radioRemote then
        local radioConn = radioRemote.OnClientEvent:Connect(function(data)
            if not State.SpyChat or not State.SpyRadio then return end
            if type(data) ~= "table" then return end

            local rType = tostring(data.Type or "Radio")
            local sender = tostring(data.Username or data.Sender or "Unknown")
            local msg = tostring(data.Msg or data.Message or data.Text or "")
            if msg == "" or string.find(msg, "%[SPY") or string.find(msg, "<font") then return end

            local typeDisplay = (rType == "Raiders") and "Chaos Raiders" or ((rType == "AD") and "O5 Council" or "Foundation Radio")
            local typeColor = (rType == "Raiders") and "#FF3333" or ((rType == "AD") and "#FFD700" or "#33CCFF")

            FormatAndDisplaySpyMessage("[RADIO SPY]", "#FF1744", typeDisplay, typeColor, sender, msg)
        end)
        table.insert(Connections, radioConn)
    end
end

local function GetPlayerDrawings(p)
    if PlayerDrawings[p] then return PlayerDrawings[p] end
    if not (Drawing and Drawing.new) then return nil end

    local drawings = {}
    local ok = pcall(function()
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1.5
        box.Filled = false
        drawings.Box = box

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1.2
        drawings.Tracer = tracer

        local nameTag = Drawing.new("Text")
        nameTag.Visible = false
        nameTag.Size = 13
        nameTag.Center = true
        nameTag.Outline = true
        drawings.NameTag = nameTag

        local bottomTag = Drawing.new("Text")
        bottomTag.Visible = false
        bottomTag.Size = 12
        bottomTag.Center = true
        bottomTag.Outline = true
        drawings.BottomTag = bottomTag

        local hbOutline = Drawing.new("Line")
        hbOutline.Visible = false
        hbOutline.Thickness = 4.5
        hbOutline.Color = Color3.fromRGB(15, 15, 15)
        drawings.HealthBarOutline = hbOutline

        local hb = Drawing.new("Line")
        hb.Visible = false
        hb.Thickness = 2.5
        drawings.HealthBar = hb
    end)

    if ok and drawings.Box then
        PlayerDrawings[p] = drawings
        return drawings
    end
    return nil
end

local function HidePlayerDrawings(d)
    if not d then return end
    if d.Box then d.Box.Visible = false end
    if d.Tracer then d.Tracer.Visible = false end
    if d.NameTag then d.NameTag.Visible = false end
    if d.BottomTag then d.BottomTag.Visible = false end
    if d.HealthBarOutline then d.HealthBarOutline.Visible = false end
    if d.HealthBar then d.HealthBar.Visible = false end
end

local function RemovePlayerDrawings(p)
    local d = PlayerDrawings[p]
    if d then
        for _, obj in pairs(d) do
            pcall(function() obj:Remove() end)
        end
        PlayerDrawings[p] = nil
    end
end

local function UpdateDrawingESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local d = GetPlayerDrawings(p)
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            local isEnemy = true
            if State.EspFilter == "Enemies Only" and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then
                isEnemy = false
            end

            if d and char and root and hum and hum.Health > 0 and isEnemy then
                local head = char:FindFirstChild("Head") or root
                local topPos = head.Position + Vector3.new(0, 1.2, 0)
                local bottomPos = root.Position - Vector3.new(0, 3.0, 0)

                local topScreen, topOn = Camera:WorldToViewportPoint(topPos)
                local bottomScreen, bottomOn = Camera:WorldToViewportPoint(bottomPos)

                if bottomOn and bottomScreen.Z > 0 then
                    local height = math.abs(bottomScreen.Y - topScreen.Y)
                    local width = height * 0.65
                    local boxPos = Vector2.new(bottomScreen.X - width / 2, topScreen.Y)
                    local boxSize = Vector2.new(width, height)

                    local tName = p.Team and p.Team.Name or "Neutral"
                    local color = State.EspTeam and (TeamColors[tName] or Color3.fromRGB(220, 220, 220)) or Color3.fromRGB(255, 255, 255)

                    -- 1. Box ESP
                    if State.EspBox then
                        d.Box.Visible = true
                        d.Box.Position = boxPos
                        d.Box.Size = boxSize
                        d.Box.Color = color
                    else
                        d.Box.Visible = false
                    end

                    -- 2. Tracer Lines
                    if State.EspTracers then
                        local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        if State.EspTracerOrigin == "Center Screen" then
                            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        elseif State.EspTracerOrigin == "Top Screen" then
                            origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        end
                        d.Tracer.Visible = true
                        d.Tracer.From = origin
                        d.Tracer.To = Vector2.new(bottomScreen.X, bottomScreen.Y)
                        d.Tracer.Color = color
                    else
                        d.Tracer.Visible = false
                    end

                    -- 3. Name & Team Tag
                    if State.EspNames or State.EspTeam then
                        local nameStr = ""
                        if State.EspNames then nameStr = p.Name end
                        if State.EspTeam then
                            nameStr = (nameStr ~= "" and (nameStr .. " | ") or "") .. tName
                        end
                        d.NameTag.Visible = true
                        d.NameTag.Text = nameStr
                        d.NameTag.Position = Vector2.new(bottomScreen.X, topScreen.Y - 16)
                        d.NameTag.Color = color
                    else
                        d.NameTag.Visible = false
                    end

                    -- 4. Distance & Weapon Tag
                    local lpPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
                    local dist = math.floor((root.Position - lpPos).Magnitude)
                    local toolName = nil
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") then toolName = item.Name; break end
                    end

                    local bottomStr = ""
                    if State.EspDistance then
                        bottomStr = "[" .. dist .. "m]"
                    end
                    if State.EspWeapon and toolName then
                        bottomStr = (bottomStr ~= "" and (bottomStr .. " ") or "") .. "<" .. toolName .. ">"
                    end

                    if bottomStr ~= "" then
                        d.BottomTag.Visible = true
                        d.BottomTag.Text = bottomStr
                        d.BottomTag.Position = Vector2.new(bottomScreen.X, bottomScreen.Y + 2)
                        d.BottomTag.Color = Color3.fromRGB(240, 240, 240)
                    else
                        d.BottomTag.Visible = false
                    end

                    -- 5. Health Bar
                    if State.EspHealthBar then
                        local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
                        local curH = math.clamp(hum.Health, 0, maxH)
                        local healthPct = curH / maxH
                        local barHeight = height * healthPct
                        local barX = boxPos.X - 5

                        d.HealthBarOutline.Visible = true
                        d.HealthBarOutline.From = Vector2.new(barX, topScreen.Y)
                        d.HealthBarOutline.To = Vector2.new(barX, topScreen.Y + height)

                        local hColor = Color3.fromHSV(healthPct * 0.33, 1, 1)
                        d.HealthBar.Visible = true
                        d.HealthBar.Color = hColor
                        d.HealthBar.From = Vector2.new(barX, topScreen.Y + height)
                        d.HealthBar.To = Vector2.new(barX, topScreen.Y + height - barHeight)
                    else
                        d.HealthBar.Visible = false
                        d.HealthBarOutline.Visible = false
                    end

                    -- 6. Chams (Highlight)
                    if State.EspChams then
                        local hl = Highlights[char]
                        if not hl or hl.Parent ~= char then
                            if hl then pcall(function() hl:Destroy() end) end
                            hl = Instance.new("Highlight")
                            hl.Name = "Rayfield_ESP_HL"
                            hl.Adornee = char
                            hl.FillColor = color
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.55
                            hl.OutlineTransparency = 0.1
                            hl.Parent = char
                            Highlights[char] = hl
                        end
                        hl.FillColor = color
                        hl.Enabled = true
                    else
                        if Highlights[char] then Highlights[char].Enabled = false end
                    end
                else
                    HidePlayerDrawings(d)
                    if Highlights[char] then Highlights[char].Enabled = false end
                end
            else
                HidePlayerDrawings(d)
                if char and Highlights[char] then Highlights[char].Enabled = false end
            end
        end
    end
end

local function UpdatePlayerESP()
    -- Native Drawing ESP is rendered dynamically each frame in RenderStepped
end

local function PanicDisableAll()
    State.Aimbot = false
    State.AimbotDrawFOV = false
    State.Triggerbot = false
    State.EspBox = false
    State.EspTracers = false
    State.EspNames = false
    State.EspDistance = false
    State.EspWeapon = false
    State.EspHealthBar = false
    State.EspChams = false
    State.ScpESP = false
    State.ItemESP = false
    State.GhostDoors = false
    State.Noclip = false
    State.Fullbright = false
    State.AutoLook173 = false
    State.AvoidLook096 = false
    State.Spinbot = false
    State.CrouchSpam = false
    State.DiscoLights = false
    State.FloatLevitate = false

    if fovCircle then pcall(function() fovCircle.Visible = false end) end
    for _, d in pairs(PlayerDrawings) do
        HidePlayerDrawings(d)
    end

    for _, h in pairs(Highlights) do pcall(function() h.Enabled = false end) end
    for _, b in pairs(Billboards) do pcall(function() b.Enabled = false end) end
    for _, h in pairs(ItemHighlights) do pcall(function() h.Enabled = false end) end

    for part, orig in pairs(GhostModifiedParts) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = orig.CanCollide
                part.Transparency = orig.Transparency
            end)
        end
    end
    GhostModifiedParts = {}

    SetFullbright(false)
    print("[SECURITY] Panic Mode Activated: All features disabled!")
end

local StaffCache = {} -- [userId] = { isStaff = bool, role = string }
local StaffCheckQueue = {}
local isCheckingStaffQueue = false

local function ProcessStaffCheckQueue()
    if isCheckingStaffQueue then return end
    isCheckingStaffQueue = true
    task.spawn(function()
        while #StaffCheckQueue > 0 do
            local p = table.remove(StaffCheckQueue, 1)
            if p and p.Parent and p ~= LocalPlayer and StaffCache[p.UserId] == nil then
                local isStaff = false
                local role = nil

                -- 1. Creator check
                if p.UserId == game.CreatorId and game.CreatorType == Enum.CreatorType.User then
                    isStaff = true
                    role = "Game Creator"
                end

                -- 2. Metatable Games Group Check (5479038)
                if not isStaff then
                    local okR, rank = pcall(function() return p:GetRankInGroup(METATABLE_GROUP_ID) end)
                    if okR and rank and rank >= 240 then
                        local okRole, roleName = pcall(function() return p:GetRoleInGroup(METATABLE_GROUP_ID) end)
                        isStaff = true
                        role = (okRole and roleName) or ("Staff Rank " .. tostring(rank))
                    end
                end

                -- 3. Game Creator Group Check
                if not isStaff and game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 and game.CreatorId ~= METATABLE_GROUP_ID then
                    local okR2, rank2 = pcall(function() return p:GetRankInGroup(game.CreatorId) end)
                    if okR2 and rank2 and rank2 >= 100 then
                        local okRole2, roleName2 = pcall(function() return p:GetRoleInGroup(game.CreatorId) end)
                        local rName = (okRole2 and roleName2) or ("Rank " .. tostring(rank2))
                        local low = string.lower(rName)
                        if low:find("mod") or low:find("admin") or low:find("dev") or low:find("owner") or low:find("staff") or low:find("lead") or low:find("manager") or low:find("trial") or low:find("hydray") or rank2 >= 200 then
                            isStaff = true
                            role = rName
                        end
                    end
                end

                StaffCache[p.UserId] = { isStaff = isStaff, role = role }
                if isStaff then
                    detectedStaff[p] = role
                    handleStaffDetected(p, role)
                end

                -- Staggered delay to completely prevent Roblox HTTP 429 Rate Limits
                task.wait(0.35)
            end
        end
        isCheckingStaffQueue = false
    end)
end

local function isPlayerStaff(p)
    if not p or not p.Parent or p == LocalPlayer then return false, nil end

    -- 1. Fast Cache Lookup (0ms, no network)
    if StaffCache[p.UserId] ~= nil then
        if StaffCache[p.UserId].isStaff then
            return true, StaffCache[p.UserId].role
        end
    end

    -- 2. Instant Invisibility / Vanish Detection (Admin Spectator in real-time)
    if State.VanishDetector and p.Character and IsCharacterInvisible(p.Character) then
        return true, "Vanished Admin / Spectator"
    end

    -- 3. Instant Attributes / Tags check
    local hasAttr = p:GetAttribute("IsAdmin") or p:GetAttribute("Admin") or p:GetAttribute("Moderator") or p:GetAttribute("Staff")
    if hasAttr then return true, "Admin Attribute" end

    -- 4. Queue for background web check if not cached
    if StaffCache[p.UserId] == nil then
        table.insert(StaffCheckQueue, p)
        ProcessStaffCheckQueue()
    end

    return false, nil
end

local function handleStaffDetected(p, role)
    if isPanicking then return end
    local staffName = p.Name
    local staffRole = role or "Staff"

    if State.StaffDetector then
        Rayfield:Notify({
            Title = "SECURITY ALERT: STAFF DETECTED",
            Content = string.format("Staff '%s' (%s) is in server!", staffName, staffRole),
            Duration = 10
        })
        pcall(function()
            FormatAndDisplaySpyMessage("[STAFF DETECTED]", "#FF0000", staffRole, "#FFD700", staffName, "Joined the server! Panic protocol initiated.")
        end)
    end

    if State.StaffAutoDisable then
        PanicDisableAll()
    end

    if State.StaffAutoLeave then
        isPanicking = true
        task.spawn(function()
            if State.StaffLeaveDelay > 0 then
                task.wait(State.StaffLeaveDelay)
            end
            pcall(function()
                LocalPlayer:Kick(string.format("\n[SECURITY SHUTDOWN]\nStaff Member Detected: %s (%s)\nAutomatically disconnected for account safety.", staffName, staffRole))
            end)
        end)
    end
end

local function scanAllPlayersForStaff()
    local staffList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local isStaff, role = isPlayerStaff(p)
            if isStaff then
                table.insert(staffList, string.format("%s (%s)", p.Name, role))
                if not detectedStaff[p] then
                    detectedStaff[p] = role
                    handleStaffDetected(p, role)
                end
            end
        end
    end

    if staffStatusLabel then
        pcall(function()
            if #staffList > 0 then
                staffStatusLabel:Set(string.format("WARNING: %d Staff in Server! [%s]", #staffList, table.concat(staffList, ", ")))
            else
                staffStatusLabel:Set("Status: 0 Staff in Server (Safe)")
            end
        end)
    end
    return staffList
end

local function UpdateScpESP()
    if not Workspace:FindFirstChild("SCPs") then return end
    for _, scp in ipairs(Workspace.SCPs:GetChildren()) do
        if scp:IsA("Model") then
            local primary = scp.PrimaryPart or scp:FindFirstChildWhichIsA("BasePart")
            if State.ScpESP and primary then
                local hl = Highlights[scp]
                if not hl or hl.Parent ~= scp then
                    if hl then pcall(function() hl:Destroy() end) end
                    hl = Instance.new("Highlight")
                    hl.Name = "Rayfield_SCPHL"
                    hl.Adornee = scp
                    hl.FillColor = Color3.fromRGB(255, 30, 30)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0.1
                    hl.Parent = scp
                    Highlights[scp] = hl
                end
                hl.Enabled = true

                local bb = Billboards[scp]
                if not bb or bb.Parent ~= primary then
                    if bb then pcall(function() bb:Destroy() end) end
                    bb = Instance.new("BillboardGui")
                    bb.Name = "Rayfield_SCPTag"
                    bb.Adornee = primary
                    bb.Size = UDim2.new(0, 160, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true

                    local label = Instance.new("TextLabel")
                    label.Name = "InfoLabel"
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextStrokeTransparency = 0.2
                    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    label.Font = Enum.Font.GothamBlack
                    label.TextSize = 12
                    label.TextColor3 = Color3.fromRGB(255, 60, 60)
                    label.Parent = bb
                    bb.Parent = primary
                    Billboards[scp] = bb
                end

                local lpPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
                local dist = math.floor((primary.Position - lpPos).Magnitude)
                local infoLabel = bb:FindFirstChild("InfoLabel")
                if infoLabel then
                    infoLabel.Text = scp.Name .. " [" .. dist .. "m]\nThreat Level: High"
                end
                bb.Enabled = true
            else
                if Highlights[scp] then Highlights[scp].Enabled = false end
                if Billboards[scp] then Billboards[scp].Enabled = false end
            end
        end
    end
end

local function UpdateItemESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and not obj:IsDescendantOf(Players) then
            local primary = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
            if State.ItemESP and primary then
                local hl = ItemHighlights[obj]
                if not hl or hl.Parent ~= obj then
                    hl = Instance.new("Highlight")
                    hl.Name = "Item_HL"
                    hl.Adornee = obj
                    hl.FillColor = Color3.fromRGB(255, 230, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.Parent = obj
                    ItemHighlights[obj] = hl
                end
                hl.Enabled = true
            else
                if ItemHighlights[obj] then ItemHighlights[obj].Enabled = false end
            end
        end
    end
end

local function TeleportTo(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
    end
end

-- ==========================================
-- Skin Changer Core Engine (Materials, Textures, FX & Sounds)
-- ==========================================

local OriginalPartProperties = {}

local SkinStyles = {
    ["Default"] = { Material = nil, Color = nil, Reflectance = 0, Chroma = false },
    ["Gold Deluxe"] = { Material = Enum.Material.Metal, Color = Color3.fromRGB(255, 215, 0), Reflectance = 0.75, Chroma = false },
    ["Holographic Forcefield"] = { Material = Enum.Material.ForceField, Color = Color3.fromRGB(0, 240, 255), Reflectance = 0.2, Chroma = false },
    ["Cyber Neon Blue"] = { Material = Enum.Material.Neon, Color = Color3.fromRGB(0, 255, 255), Reflectance = 0.1, Chroma = false },
    ["Crimson Dragon"] = { Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 25, 45), Reflectance = 0.4, Chroma = false },
    ["Obsidian Shadow"] = { Material = Enum.Material.Glass, Color = Color3.fromRGB(20, 20, 25), Reflectance = 0.3, Chroma = false },
    ["Emerald Viper"] = { Material = Enum.Material.Neon, Color = Color3.fromRGB(0, 255, 120), Reflectance = 0.1, Chroma = false },
    ["Amethyst Galaxy"] = { Material = Enum.Material.Neon, Color = Color3.fromRGB(180, 20, 255), Reflectance = 0.2, Chroma = false },
    ["Arctic Glaze"] = { Material = Enum.Material.Glass, Color = Color3.fromRGB(240, 248, 255), Reflectance = 0.8, Chroma = false },
    ["Rainbow Chroma"] = { Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 0, 0), Reflectance = 0.2, Chroma = true }
}

local CamoDefinitions = {
    ["Woodland Military Camo"] = {
        Material = Enum.Material.Marble,
        Color = Color3.fromRGB(55, 78, 48),
        Reflectance = 0.05,
        TextureId = "rbxassetid://13264669888"
    },
    ["Desert Digital Camo"] = {
        Material = Enum.Material.Granite,
        Color = Color3.fromRGB(195, 168, 128),
        Reflectance = 0.05,
        TextureId = "rbxassetid://288768019"
    },
    ["Arctic Winter Camo"] = {
        Material = Enum.Material.Marble,
        Color = Color3.fromRGB(235, 240, 248),
        Reflectance = 0.35,
        TextureId = "rbxassetid://116893245"
    },
    ["Tigerstripe Tactical"] = {
        Material = Enum.Material.Pebble,
        Color = Color3.fromRGB(180, 118, 45),
        Reflectance = 0.05,
        TextureId = "rbxassetid://49779313"
    },
    ["Night Ops Dark Camo"] = {
        Material = Enum.Material.CorrodedMetal,
        Color = Color3.fromRGB(28, 28, 32),
        Reflectance = 0.05,
        TextureId = "rbxassetid://269748808"
    },
    ["Urban Flecktarn"] = {
        Material = Enum.Material.Granite,
        Color = Color3.fromRGB(115, 120, 125),
        Reflectance = 0.08,
        TextureId = "rbxassetid://144415444"
    },
    ["Dragon Magma Scale"] = {
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 60, 20),
        Reflectance = 0.4,
        TextureId = "rbxassetid://257697395"
    },
    ["Carbon Fiber Weave"] = {
        Material = Enum.Material.DiamondPlate,
        Color = Color3.fromRGB(22, 22, 25),
        Reflectance = 0.25,
        TextureId = "rbxassetid://258129522"
    },
    ["Damascus Steel Wave"] = {
        Material = Enum.Material.Foil,
        Color = Color3.fromRGB(160, 165, 175),
        Reflectance = 0.65,
        TextureId = "rbxassetid://6071535917"
    },
    ["Galaxy Nebula"] = {
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(160, 25, 240),
        Reflectance = 0.5,
        TextureId = "rbxassetid://149254212"
    },
    ["Clean Solid"] = {
        Material = nil,
        Color = nil,
        Reflectance = 0.6,
        TextureId = ""
    },
    ["Factory Default"] = {
        Material = nil,
        Color = nil,
        Reflectance = 0,
        TextureId = "KEEP_DEFAULT"
    }
}

local GunPatterns = {
    ["Woodland Military Camo"] = "rbxassetid://13264669888",
    ["Desert Digital Camo"] = "rbxassetid://288768019",
    ["Arctic Winter Camo"] = "rbxassetid://116893245",
    ["Tigerstripe Tactical"] = "rbxassetid://49779313",
    ["Night Ops Dark Camo"] = "rbxassetid://269748808",
    ["Urban Flecktarn"] = "rbxassetid://144415444",
    ["Dragon Magma Scale"] = "rbxassetid://257697395",
    ["Carbon Fiber Weave"] = "rbxassetid://258129522",
    ["Damascus Steel Wave"] = "rbxassetid://6071535917",
    ["Galaxy Nebula"] = "rbxassetid://149254212",
    ["Clean Solid"] = "",
    ["Factory Default"] = "KEEP_DEFAULT",
    
    -- Backward compatibility aliases
    ["Clean Solid (No Pattern)"] = "",
    ["Dragon Scales / Magma"] = "rbxassetid://257697395",
    ["Cyber Hex Grid"] = "rbxassetid://269748808",
    ["Damascus Wave"] = "rbxassetid://13264669888",
    ["Gold Foil Marble"] = "rbxassetid://144415444",
    ["Lava Fire Surface"] = "rbxassetid://258129522",
    ["Tiger Camo"] = "rbxassetid://49779313",
    ["Snow White Camo"] = "rbxassetid://116893245",
    ["Default Texture"] = "KEEP_DEFAULT"
}

local SoundPresets = {
    ["Default"] = nil,
    ["Sci-Fi Laser Pulse"] = "rbxassetid://180204650",
    ["Heavy 50 Cal Thunder"] = "rbxassetid://4513231858",
    ["Silenced Whisper Tactical"] = "rbxassetid://966248904",
    ["Plasma Railgun Burst"] = "rbxassetid://72986878402953",
    ["Dragon Fang Burst"] = "rbxassetid://3603400922",
    ["AK-47 Thunder"] = "rbxassetid://1174337926",
    ["Spas-12 Shotgun"] = "rbxassetid://7244956099",
    ["Tactical Pistol"] = "rbxassetid://165946426",
    ["M16A4 Military"] = "rbxassetid://2047319236",
    ["Energy Blaster Hit"] = "rbxassetid://180204650"
}

local function GetWeaponVisualModels(tool)
    local models = {}
    if tool and tool:IsA("Tool") then
        table.insert(models, tool)
    end
    -- Site-76 MorphAssets / ExternalGunVisuals (where the actual visible gun meshes are rendered)
    local morphAssets = Workspace:FindFirstChild("MorphAssets")
    local extFolder = morphAssets and morphAssets:FindFirstChild("ExternalGunVisuals")
    if extFolder and tool then
        local extModel = extFolder:FindFirstChild(tool.Name)
        if extModel then
            table.insert(models, extModel)
        end
    end
    -- Camera ViewModel
    local cam = Workspace.CurrentCamera
    if cam and tool then
        local vm = cam:FindFirstChild("ViewModel") or cam:FindFirstChild(tool.Name)
        if vm then
            table.insert(models, vm)
        end
    end
    return models
end

-- ==========================================
-- Official Game Kill Effects & Death Box Engine (ReplicatedStorage.ClientHandlers.KillEffects)
-- ==========================================

local OfficialKillEffectMap = {
    ["Gift Box"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles["Gift Box"] then
            ke.Bundles["Gift Box"](victimChar, killerChar)
        end
    end,
    ["Casket"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke["Hallowen 2023 Casket"] then
            ke["Hallowen 2023 Casket"](victimChar, killerChar)
        end
    end,
    ["Tombstone"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles["Rest In Peace"] then
            ke.Bundles["Rest In Peace"](victimChar, killerChar)
        end
    end,
    ["SCP Crate"] = function(victimChar, killerChar)
        pcall(function()
            local scpCrate = ReplicatedStorage:FindFirstChild("LoadAsset") and ReplicatedStorage.LoadAsset:FindFirstChild("SCPCrate")
            if scpCrate and victimChar and victimChar:FindFirstChild("HumanoidRootPart") then
                local clone = scpCrate:Clone()
                local pos = victimChar.HumanoidRootPart.Position
                clone:PivotTo(CFrame.new(pos))
                clone.Parent = Workspace
                game:GetService("Debris"):AddItem(clone, 30)
            end
        end)
    end,
    ["Ice Cube"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke["Ice Cube"] then
            ke["Ice Cube"](victimChar, killerChar)
        end
    end,
    ["Blackhole"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles.Blackhole then
            ke.Bundles.Blackhole(victimChar, killerChar)
        end
    end,
    ["Atomic Rebinding"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke["Atomic Rebinding"] then
            ke["Atomic Rebinding"](victimChar, killerChar)
        end
    end,
    ["Disintegration"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles.Disintegration then
            ke.Bundles.Disintegration(victimChar, killerChar)
        end
    end,
    ["Defragmentation"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles.Defragmentation then
            ke.Bundles.Defragmentation(victimChar, killerChar)
        end
    end,
    ["Black Flame"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles["Black Flame"] then
            ke.Bundles["Black Flame"](victimChar, killerChar)
        end
    end,
    ["Collect Soul"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke["Collect Soul"] then
            ke["Collect Soul"](victimChar, killerChar)
        end
    end,
    ["Northern Lights"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.Bundles and ke.Bundles["Northern Lights"] then
            ke.Bundles["Northern Lights"](victimChar, killerChar)
        end
    end,
    ["Foundation Seal"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke["Foundation Seal"] then
            ke["Foundation Seal"](victimChar, killerChar)
        end
    end,
    ["Gold Wrap"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.LegacyKillEffects and ke.LegacyKillEffects.GoldWrap then
            ke.LegacyKillEffects.GoldWrap(victimChar, killerChar)
        end
    end,
    ["Obsidian"] = function(victimChar, killerChar)
        local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
        if ke.LegacyKillEffects and ke.LegacyKillEffects.Obsidian then
            ke.LegacyKillEffects.Obsidian(victimChar, killerChar)
        end
    end
}

-- Backward compatibility aliases
OfficialKillEffectMap["Halloween Casket"] = OfficialKillEffectMap["Casket"]
OfficialKillEffectMap["Rest In Peace"] = OfficialKillEffectMap["Tombstone"]

local function TriggerOfficialKillEffect(victimChar, killerChar)
    if not State.DeadBoxEnabled or not victimChar then return end
    local effectName = type(State.DeadBoxStyle) == "table" and State.DeadBoxStyle[1] or State.DeadBoxStyle
    local fn = OfficialKillEffectMap[effectName]
    if fn then
        pcall(fn, victimChar, killerChar or LocalPlayer.Character)
    else
        pcall(function()
            local ke = require(ReplicatedStorage.ClientHandlers.KillEffects)
            if ke.Bundles and ke.Bundles["Gift Box"] then
                ke.Bundles["Gift Box"](victimChar, killerChar or LocalPlayer.Character)
            end
        end)
    end
end

local function OnPlayerDied(player, char, deathPos)
    if not State.DeadBoxEnabled then return end
    if not player or player == LocalPlayer or not char then return end

    local isMyKill = false
    if LastShotTarget == player and (tick() - LastShotTime) <= 3.5 then
        isMyKill = true
    end

    if isMyKill then
        TriggerOfficialKillEffect(char, LocalPlayer.Character)

        if State.EliminationBanner then
            Rayfield:Notify({
                Title = "TARGET ELIMINATED",
                Content = player.Name .. " (" .. (player.Team and player.Team.Name or "Unknown") .. ")",
                Duration = 3
            })
        end
    end
end

local function HookPlayerDeath(player)
    if player == LocalPlayer then return end

    local function onCharacter(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 4)
        local root = char:WaitForChild("HumanoidRootPart", 4)
        if not hum or not root then return end

        local hasDied = false
        local function triggerDeath()
            if hasDied then return end
            hasDied = true
            local pPos = root and root.Position or char:GetPivot().Position
            OnPlayerDied(player, char, pPos)
        end

        local dConn = hum.Died:Connect(triggerDeath)
        table.insert(Connections, dConn)

        local hConn = hum.HealthChanged:Connect(function(hp)
            if hp <= 0 then
                triggerDeath()
            end
        end)
        table.insert(Connections, hConn)
    end

    if player.Character then
        task.spawn(onCharacter, player.Character)
    end
    local cConn = player.CharacterAdded:Connect(onCharacter)
    table.insert(Connections, cConn)
end

local ParticleNameMap = {
    ["None"] = nil,
    ["Galaxy (Deep Nebula)"] = "Galaxy",
    ["Lightning 1 (Electric Blue)"] = "Lightning1",
    ["Lightning 2 (Arc Cyan)"] = "Lightning2",
    ["Lightning 3 (Plasma Violet)"] = "Lightning3",
    ["Fire Texture (Dragon Flame)"] = "FireTexParticle",
    ["Stars (Cosmic Glitter)"] = "Stars",
    ["Space (Interstellar)"] = "Space",
    ["Space Dust (Void Spores)"] = "SpaceDust",
    ["Black Smoke (Dark Matter)"] = "BlackSmoke",
    ["Red Dust (Crimson Ash)"] = "RedDust",
    ["Frost (Subzero Crystal)"] = "Frost",
    ["Flakes (Snow Flurry)"] = "Flakes",
    ["Heart Particles (Love Charm)"] = "HeartParticles",
    ["Halloween 2025 (Cursed Spirits)"] = "Halloween2025",
    ["Anniversary 2025 (Golden Confetti)"] = "Anniversary2025",
    ["Easter 2026 (Festive Glow)"] = "Easter2026",
    ["Red Raid Lightning"] = "RedRaidLightning",
    ["Blue Raid Lightning"] = "BlueRaidLightning"
}

local function ApplySkinsToTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    if not State.SkinChangerEnabled then return end

    local curStyle = type(State.GunSkinStyle) == "table" and State.GunSkinStyle[1] or State.GunSkinStyle
    local curPattern = type(State.GunSkinPattern) == "table" and State.GunSkinPattern[1] or State.GunSkinPattern
    local curParticle = type(State.GunParticleSkin) == "table" and State.GunParticleSkin[1] or State.GunParticleSkin
    local curFireFX = type(State.MuzzleFireEffect) == "table" and State.MuzzleFireEffect[1] or State.MuzzleFireEffect
    local curSound = type(State.GunFiringSound) == "table" and State.GunFiringSound[1] or State.GunFiringSound

    local styleData = SkinStyles[curStyle] or SkinStyles["Gold Deluxe"]

    -- Tag that tool is skinned
    local tag = tool:FindFirstChild("SkinChanger_Applied")
    if not tag then
        tag = Instance.new("BoolValue")
        tag.Name = "SkinChanger_Applied"
        tag.Parent = tool
    end

    -- Clean old dynamic effects
    for _, d in ipairs(tool:GetDescendants()) do
        if d.Name:find("SkinChanger_") and d.Name ~= "SkinChanger_Applied" and d.Name ~= "SkinChanger_Hooked" then
            pcall(function() d:Destroy() end)
        end
    end

    -- 1. Apply Materials, Colors, and Patterns (Textures across Tool and ExternalGunVisuals)
    local isDefaultPattern = (curPattern == "KEEP_DEFAULT" or curPattern == "Default Texture" or string.find(curPattern, "Factory Default") ~= nil)
    local camoDef = not isDefaultPattern and (CamoDefinitions[curPattern] or nil) or nil

    for _, rootObj in ipairs(GetWeaponVisualModels(tool)) do
        for _, part in ipairs(rootObj:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "LaserCast" and not part.Name:find("SkinChanger_Att_") then
                if not OriginalPartProperties[part] then
                    local origTex = ""
                    if part:IsA("MeshPart") then
                        pcall(function() origTex = part.TextureID end)
                    elseif part:FindFirstChildOfClass("SpecialMesh") then
                        pcall(function() origTex = part:FindFirstChildOfClass("SpecialMesh").TextureId end)
                    end
                    OriginalPartProperties[part] = {
                        Material = part.Material,
                        Color = part.Color,
                        Reflectance = part.Reflectance,
                        TextureID = origTex
                    }
                end

                local orig = OriginalPartProperties[part]

                if curStyle == "Default" and isDefaultPattern then
                    if orig then
                        part.Material = orig.Material
                        part.Color = orig.Color
                        part.Reflectance = orig.Reflectance
                        if part:IsA("MeshPart") then
                            pcall(function() part.TextureID = orig.TextureID end)
                        elseif part:FindFirstChildOfClass("SpecialMesh") then
                            pcall(function() part:FindFirstChildOfClass("SpecialMesh").TextureId = orig.TextureID end)
                        end
                    end
                else
                    -- Clean old dynamic textures
                    for _, oldT in ipairs(part:GetChildren()) do
                        if oldT.Name == "SkinChanger_CamoTex" or oldT.Name == "SkinChanger_SurfaceApp" then
                            pcall(function() oldT:Destroy() end)
                        end
                    end

                    -- Priority 1: Camo Pattern takes primary precedence for authentic military camouflage
                    if camoDef then
                        if camoDef.Material then part.Material = camoDef.Material end
                        if camoDef.Color then part.Color = camoDef.Color end
                        if camoDef.Reflectance then part.Reflectance = camoDef.Reflectance end

                        if camoDef.TextureId and camoDef.TextureId ~= "" and camoDef.TextureId ~= "KEEP_DEFAULT" then
                            if part:FindFirstChildOfClass("SpecialMesh") then
                                pcall(function() part:FindFirstChildOfClass("SpecialMesh").TextureId = camoDef.TextureId end)
                            end
                        end
                    else
                        -- Priority 2: Weapon Skin Style (Gold Deluxe, Cyber Neon, Crimson, etc.)
                        if styleData.Material then part.Material = styleData.Material end
                        if styleData.Color and not styleData.Chroma then part.Color = styleData.Color end
                        if styleData.Reflectance then part.Reflectance = styleData.Reflectance end
                    end
                end
            end
        end
    end

    -- 2. Weapon Chams Glow Highlight (Only when enabled and not obscuring camo)
    if State.GunChamsHighlight and curStyle ~= "Default" and isDefaultPattern then
        local hl = tool:FindFirstChild("SkinChanger_Highlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "SkinChanger_Highlight"
            hl.Adornee = tool
            hl.FillColor = styleData.Color or Color3.fromRGB(255, 215, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = (curStyle == "Holographic Forcefield") and 0.4 or 0.6
            hl.OutlineTransparency = 0.2
            hl.Parent = tool
        end
    else
        local oldHl = tool:FindFirstChild("SkinChanger_Highlight")
        if oldHl then pcall(function() oldHl:Destroy() end) end
    end

    local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")

    -- 3. Ambient Particle Aura
    local targetEmitterName = ParticleNameMap[curParticle]
    if targetEmitterName and muzzle then
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local ps = rs:FindFirstChild("ParticleSkins")
            local emitter = ps and ps:FindFirstChild(targetEmitterName)
            if emitter then
                local clone = emitter:Clone()
                clone.Name = "SkinChanger_Particle"
                clone.Rate = 12
                clone.Enabled = true
                clone.Parent = muzzle
            end
        end)
    end

    -- 4. Muzzle Fire & Flash Effect (Bursts on shoot)
    if muzzle and curFireFX ~= "Default" then
        local fireEmitter = Instance.new("ParticleEmitter")
        fireEmitter.Name = "SkinChanger_MuzzleFire"
        fireEmitter.Texture = "rbxassetid://258129522"
        fireEmitter.LightEmission = 1
        fireEmitter.Rate = 0
        fireEmitter.Speed = NumberRange.new(6, 16)
        fireEmitter.Lifetime = NumberRange.new(0.08, 0.18)
        fireEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 2.2),
            NumberSequenceKeypoint.new(1, 0.1)
        })

        if curFireFX == "Plasma Burst" then
            fireEmitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 255))
            })
        elseif curFireFX == "Dragon Flame" then
            fireEmitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 0))
            })
        elseif curFireFX == "Electric Arc" then
            fireEmitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 220, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
            })
        elseif curFireFX == "Void Dark" then
            fireEmitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 180)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 40))
            })
        elseif curFireFX == "Rainbow Sparkles" then
            fireEmitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 0))
            })
        end
        fireEmitter.Parent = muzzle

        if State.GunMuzzleLight then
            local light = Instance.new("PointLight")
            light.Name = "SkinChanger_Light"
            light.Range = 18
            light.Brightness = 4
            light.Enabled = false
            light.Color = (styleData.Color and not styleData.Chroma) and styleData.Color or Color3.fromRGB(255, 220, 100)
            light.Parent = muzzle
        end
    end

    -- 4.5 Tactical Attachments (Suppressor, Laser Sight, Scope)
    local attachments = State.WeaponAttachments or {}
    local hasSuppressor = State.AttachSuppressor
    local hasLaser = State.AttachLaser
    local hasScope = State.AttachScope

    if type(attachments) == "table" then
        for _, opt in ipairs(attachments) do
            if string.find(opt, "Suppressor") then hasSuppressor = true end
            if string.find(opt, "Laser") then hasLaser = true end
            if string.find(opt, "Scope") then hasScope = true end
        end
    end

    local handle = tool:FindFirstChild("Handle")
    local muzzle = tool:FindFirstChild("Muzzle")
    local laserCast = tool:FindFirstChild("LaserCast", true)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Clean old dynamic / cloned attachments
    for _, d in ipairs(tool:GetDescendants()) do
        if d.Name:find("SkinChanger_Att_") or d.Name:find("SkinChanger_Suppressor") or d.Name:find("SkinChanger_LaserBox") or d.Name:find("SkinChanger_Scope") then
            pcall(function() d:Destroy() end)
        end
    end

    -- Mathematical Straight Reference Frame (aligned with LaserCast and world Up)
    local fwd = (laserCast and laserCast.CFrame.LookVector) or (muzzle and handle and (muzzle.Position - handle.Position).Unit) or (root and root.CFrame.LookVector) or Vector3.new(0, 0, -1)
    local worldUp = (root and root.CFrame.UpVector) or Vector3.new(0, 1, 0)
    local right = fwd:Cross(worldUp).Unit
    local trueUp = right:Cross(fwd).Unit

    -- 1. SUPPRESSOR
    local foundBuiltinSupp = false
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and not part.Name:find("SkinChanger_") then
            local n = part.Name:lower()
            if n == "suppressor" or n == "silencer" or (n:find("suppressor") and not n:find("att_")) then
                foundBuiltinSupp = true
                part.Transparency = hasSuppressor and 0 or 1
                part.LocalTransparencyModifier = hasSuppressor and 0 or 1
            end
        end
    end

    -- If no built-in suppressor, create straight suppressor cylinder aligned with barrel
    if not foundBuiltinSupp and hasSuppressor and handle then
        pcall(function()
            local muzzlePos = (muzzle and muzzle.Position) or (laserCast and laserCast.Position) or (handle.Position + fwd * 1.5)
            local suppPos = muzzlePos + fwd * 0.65

            local supp = Instance.new("Part")
            supp.Name = "SkinChanger_Att_Suppressor"
            supp.Size = Vector3.new(1.3, 0.36, 0.36)
            supp.Material = Enum.Material.Metal
            supp.Color = Color3.fromRGB(22, 22, 25)
            supp.CanCollide = false
            supp.Massless = true
            supp.CastShadow = false

            local sm = Instance.new("SpecialMesh")
            sm.MeshType = Enum.MeshType.Cylinder
            sm.Parent = supp

            supp.CFrame = CFrame.fromMatrix(suppPos, fwd, trueUp, right)
            supp.Parent = tool

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = supp
            weld.Parent = supp
        end)
    end

    -- 2. LASER SIGHT
    local foundBuiltinLaser = false
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and not part.Name:find("SkinChanger_") then
            local n = part.Name:lower()
            if n == "laser" or (n:find("laser") and not n:find("lasercast") and not n:find("beam")) then
                foundBuiltinLaser = true
                part.Transparency = hasLaser and 0 or 1
                part.LocalTransparencyModifier = hasLaser and 0 or 1
            end
        end
    end

    -- Laser Beam projection from LaserCast or Muzzle pointing straight forward
    if hasLaser then
        local laserOriginPart = laserCast or muzzle or handle
        if laserOriginPart then
            pcall(function()
                local beamBox = Instance.new("Part")
                beamBox.Name = "SkinChanger_Att_LaserBeamBox"
                beamBox.Size = Vector3.new(0.05, 0.05, 0.05)
                beamBox.Transparency = 1
                beamBox.CanCollide = false
                beamBox.Massless = true
                beamBox.CFrame = laserOriginPart.CFrame
                beamBox.Parent = tool

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = laserOriginPart
                weld.Part1 = beamBox
                weld.Parent = beamBox

                local att0 = Instance.new("Attachment")
                att0.Name = "BeamAtt0"
                att0.Position = Vector3.new(0, 0, 0)
                att0.Parent = beamBox

                local att1 = Instance.new("Attachment")
                att1.Name = "BeamAtt1"
                att1.Position = Vector3.new(0, 0, -120)
                att1.Parent = beamBox

                local beam = Instance.new("Beam")
                beam.Name = "TacticalLaserBeam"
                beam.Attachment0 = att0
                beam.Attachment1 = att1
                beam.Width0 = 0.035
                beam.Width1 = 0.035
                beam.Color = ColorSequence.new(Color3.fromRGB(255, 10, 30))
                beam.LightEmission = 1
                beam.Transparency = NumberSequence.new(0.1)
                beam.FaceCamera = true
                beam.Parent = beamBox

                local dotLight = Instance.new("PointLight")
                dotLight.Name = "LaserDotLight"
                dotLight.Color = Color3.fromRGB(255, 30, 30)
                dotLight.Range = 8
                dotLight.Brightness = 2.5
                dotLight.Parent = beamBox
            end)
        end
    end

    -- 3. TACTICAL SCOPE (SIGHTS & OPTICS)
    local foundOptic = false

    -- Toggle existing optic models / Iron Sights inside tool
    for _, child in ipairs(tool:GetChildren()) do
        local n = child.Name:lower()
        if n:find("iron sight") or n:find("ironsight") then
            for _, p in ipairs(child:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = hasScope and 1 or 0
                    p.LocalTransparencyModifier = hasScope and 1 or 0
                end
            end
        elseif n:find("dot sight") or n:find("eotech") or n:find("trijicon") or n:find("hartman") or (n:find("scope") and not n:find("att_")) then
            foundOptic = true
            for _, p in ipairs(child:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = hasScope and 0 or 1
                    p.LocalTransparencyModifier = hasScope and 0 or 1
                    if hasScope and (p.Name:lower():find("reticle") or p.Name:lower():find("dot")) then
                        p.Material = Enum.Material.Neon
                        p.Color = Color3.fromRGB(0, 255, 120)
                    end
                end
            end
        end
    end

    -- If no optic found in tool, build straight, level tactical scope
    if not foundOptic and hasScope and handle then
        pcall(function()
            local basePos = handle.Position + fwd * 0.2 + trueUp * 0.42
            local scopeBase = Instance.new("Part")
            scopeBase.Name = "SkinChanger_Att_ScopeBase"
            scopeBase.Size = Vector3.new(0.28, 0.12, 0.7)
            scopeBase.Material = Enum.Material.Metal
            scopeBase.Color = Color3.fromRGB(22, 22, 25)
            scopeBase.CanCollide = false
            scopeBase.Massless = true
            scopeBase.CastShadow = false
            scopeBase.CFrame = CFrame.fromMatrix(basePos, right, trueUp, -fwd)
            scopeBase.Parent = tool

            local weldBase = Instance.new("WeldConstraint")
            weldBase.Part0 = handle
            weldBase.Part1 = scopeBase
            weldBase.Parent = scopeBase

            local tubePos = basePos + trueUp * 0.16
            local tube = Instance.new("Part")
            tube.Name = "SkinChanger_Att_ScopeTube"
            tube.Size = Vector3.new(0.9, 0.32, 0.32)
            tube.Material = Enum.Material.Metal
            tube.Color = Color3.fromRGB(25, 25, 30)
            tube.CanCollide = false
            tube.Massless = true
            tube.CastShadow = false

            local smTube = Instance.new("SpecialMesh")
            smTube.MeshType = Enum.MeshType.Cylinder
            smTube.Parent = tube

            tube.CFrame = CFrame.fromMatrix(tubePos, fwd, trueUp, right)
            tube.Parent = tool

            local weldTube = Instance.new("WeldConstraint")
            weldTube.Part0 = handle
            weldTube.Part1 = tube
            weldTube.Parent = tube

            local reticle = Instance.new("Part")
            reticle.Name = "SkinChanger_Att_Reticle"
            reticle.Size = Vector3.new(0.22, 0.22, 0.02)
            reticle.Material = Enum.Material.Neon
            reticle.Color = Color3.fromRGB(0, 255, 120)
            reticle.CanCollide = false
            reticle.Massless = true
            reticle.CastShadow = false
            reticle.CFrame = CFrame.fromMatrix(tubePos + fwd * 0.3, right, trueUp, -fwd)
            reticle.Parent = tool

            local weldR = Instance.new("WeldConstraint")
            weldR.Part0 = handle
            weldR.Part1 = reticle
            weldR.Parent = reticle
        end)
    end

    -- 5. Weapon Sound Replacement (Hook Site-76 Controller.Weapon AND Tool Sounds)
    local activeSoundName = type(State.GunFiringSound) == "table" and State.GunFiringSound[1] or State.GunFiringSound
    if hasSuppressor and (activeSoundName == "Default" or not activeSoundName) then
        activeSoundName = "Silenced Whisper Tactical"
    end
    local customSoundId = SoundPresets[activeSoundName]

    -- Update Site-76 native weapon controller
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local c = ps and ps:FindFirstChild("Controller")
        local wMod = c and c:FindFirstChild("Weapon")
        if wMod then
            local wData = require(wMod)
            if customSoundId and customSoundId ~= "" then
                wData.Sound = customSoundId
            end
        end
    end)

    for _, s in ipairs(tool:GetDescendants()) do
        if s:IsA("Sound") and not s.Name:find("SkinChanger_") then
            if not OriginalPartProperties[s] then
                OriginalPartProperties[s] = {
                    SoundId = s.SoundId,
                    Volume = s.Volume,
                    PlaybackSpeed = s.PlaybackSpeed
                }
            end

            if customSoundId and customSoundId ~= "" then
                s.SoundId = customSoundId
                s.Volume = 1.5
                s.PlaybackSpeed = State.GunSoundPitch or 1.0
            else
                local origS = OriginalPartProperties[s]
                if origS then
                    s.SoundId = origS.SoundId
                    s.Volume = origS.Volume
                    s.PlaybackSpeed = origS.PlaybackSpeed
                end
            end
        end
    end
end

local function ReapplySkinsToAll()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local appliedTag = tool:FindFirstChild("SkinChanger_Applied")
            if appliedTag then appliedTag:Destroy() end
            ApplySkinsToTool(tool)
        end
    end
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") then
            local appliedTag = t:FindFirstChild("SkinChanger_Applied")
            if appliedTag then appliedTag:Destroy() end
        end
    end
end

-- ==========================================
-- All-Inclusive Site-76 Character Wearables Engine
-- (Covers All In-Game UGC, Faction Morphs, Helmets, Vests, Backpacks & SCP Gear)
-- ==========================================

local function ClearAllCharacterGear()
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetChildren()) do
        if d.Name:find("Site76_Gear_") or d.Name:find("Site76_UGC_") then
            pcall(function() d:Destroy() end)
        end
    end
end

local function ResolveGameWearable(name)
    local rep = game:GetService("ReplicatedStorage")
    local ugc = rep:FindFirstChild("LoadAsset") and rep.LoadAsset:FindFirstChild("UGC")
    local la = rep:FindFirstChild("LoadAsset")
    local ws = game:GetService("Workspace")

    -- 1. UGC Folder (Permanent Pristine Models)
    if ugc then
        if name == "The Nova Dominion Helmet" then return ugc:FindFirstChild("The Nova Dominion Helmet") end
        if name == "FAST Helmet" then return ugc:FindFirstChild("FAST Helmet") end
        if name == "FAST Helmet Addons" then return ugc:FindFirstChild("FAST Helmet Addons") end
        if name == "Tactical Vest Var1" then return ugc:FindFirstChild("Tactical Vest Var1") end
        if name == "Tactical Vest Var1 Blue" then return ugc:FindFirstChild("Tactical Vest Var1 Blue") end
        if name == "Cyber Exoskeleton Frame" then return ugc:FindFirstChild("Exoskeleton") end
        if name == "3 Magazines Chest Rig" then return ugc:FindFirstChild("3 Magazines") end
        if name == "SCP-131 \"Eye Pods\" Earrings" then return ugc:FindFirstChild("SCP-131 \"Eye Pods\" Earrings") end
        if name == "Entity-007 \"Man of Bricks\" Plushie" then return ugc:FindFirstChild("Entity-007 \"Man of Bricks\" Plushie") end
    end

    -- 2. Special LoadAsset Artifacts
    if la then
        if name == "SCP-096 Shy Guy Bag" then return la:FindFirstChild("Bag096") end
        if name == "Flower Head Hat" then return la:FindFirstChild("FlowerHead") end
    end

    -- 3. SCP-049 Robe & Cloak
    if name == "SCP-049 Plague Doctor Cloak" then
        local scp049 = ws:FindFirstChild("SCPs") and ws.SCPs:FindFirstChild("SCP-049")
        local morph = scp049 and scp049:FindFirstChild("SCP049Morph")
        return morph and morph:FindFirstChild("CloakTorso")
    end

    -- 4. Faction Bundle Stands (GOC, TSH, GRU-P)
    for _, d in ipairs(ws:GetDescendants()) do
        if d.Name == "BundleStand" then
            local text = ""
            for _, c in ipairs(d:GetDescendants()) do
                if c:IsA("TextLabel") or c:IsA("TextButton") then text = text .. c.Text .. " " end
            end
            local morph = d:FindFirstChild("BundleStandMorph")
            if morph then
                if text:find("GOC") then
                    if name == "GOC Combat Helmet & Quad NVG" then return morph:FindFirstChild("HeadAccessory") end
                    if name == "GOC Heavy Combat Plate Carrier" then return morph:FindFirstChild("TorsoAccessory") end
                    if name == "GOC Tactical Field Pack" then return morph:FindFirstChild("TorsoAccessory") end
                elseif text:find("TSH") then
                    if name == "TSH Serpent's Hand Helmet" then return morph:FindFirstChild("HeadAccessory") end
                    if name == "TSH Serpent's Hand Combat Rig" then return morph:FindFirstChild("TorsoAccessory") end
                elseif text:find("GRU") then
                    if name == "GRU-P Tactical Helmet" then return morph:FindFirstChild("HeadAccessory") end
                    if name == "GRU-P Tactical Armor Rig" then return morph:FindFirstChild("TorsoAccessory") end
                end
            end
        end
    end

    -- 5. Sector 2 Meshes (MTF & Mad Scientist)
    local s2 = ws:FindFirstChild("Sector 2")
    local meshes = s2 and s2:FindFirstChild("SectionAMeshes")
    if meshes then
        for _, c in ipairs(meshes:GetChildren()) do
            if c.Name == "InteractableNPCMorph" then
                if name == "Mad Scientist Hair" and c:FindFirstChild("MadScientistHair") then
                    return c:FindFirstChild("MadScientistHair")
                end
                if name == "MTF Facility Security Helmet" and c:FindFirstChild("HeadAccessory") then
                    return c:FindFirstChild("HeadAccessory")
                end
                if name == "MTF Facility Body Armor" and c:FindFirstChild("TorsoAccessory") then
                    return c:FindFirstChild("TorsoAccessory")
                end
            end
        end
    end

    -- 6. MorphAssets Live Clones (Safe Isolated Welding)
    local ma = ws:FindFirstChild("MorphAssets")
    if ma then
        if name == "ISD Tactical Backpack" then return ma:FindFirstChild("ISD Backpack") end
        if name == "The Serpents Hand Cape" then return ma:FindFirstChild("The Serpents Hand|TSH Cape") end
        if name == "Epsilon-11 NTF Blue Scarf" then
            for _, c in ipairs(ma:GetChildren()) do if c.Name:find("11 Scarf") then return c end end
        end
        if name == "ISD Red Combat Shemagh" then return ma:FindFirstChild("ISD Scarf") end
        if name == "Christmas Holiday Scarf" then return ma:FindFirstChild(" (Christmas Scarf)") end
        if name == "Holiday Santa Hat" then return ma:FindFirstChild(" (Santa Hat)") end
        if name == "Epsilon-11 Foliage Camo" then
            for _, c in ipairs(ma:GetChildren()) do if c.Name:find("11 Foliage") then return c end end
        end
        if name == "Shadow Ninja Mask" then return ma:FindFirstChild("NinjaMaskOfShadows") end
        if name == "Chef Gourmet Hat" then return ma:FindFirstChild("Chef|Chef Hat") end
        if name == "Tactical Sunglasses" then return ma:FindFirstChild("Sunglasses") end
        if name == "ISD Tactical Watch" then return ma:FindFirstChild("ISD Watch") end
    end

    return nil
end

local function AttachWearableItem(sourceItem, slotPrefix, offsetCFrame)
    if not sourceItem then return end
    local char = LocalPlayer.Character
    if not char then return end

    local slotTag = "Site76_Gear_" .. slotPrefix .. "_"
    for _, d in ipairs(char:GetChildren()) do
        if d.Name:find(slotTag) then
            pcall(function() d:Destroy() end)
        end
    end

    local acc = sourceItem:IsA("Accessory") and sourceItem or sourceItem:FindFirstChildOfClass("Accessory")
    if acc then
        -- Native Roblox Accessory Path
        local clone = acc:Clone()
        clone.Name = slotTag .. sourceItem.Name:gsub("%s+", "_"):gsub("[^%w_]", "")
        local handle = clone:FindFirstChild("Handle") or clone:FindFirstChildWhichIsA("BasePart")
        if not handle then return end

        local att = handle:FindFirstChildWhichIsA("Attachment")
        local charAtt = nil
        if att then
            for _, a in ipairs(char:GetDescendants()) do
                if a:IsA("Attachment") and a.Name == att.Name and a.Parent ~= handle then
                    charAtt = a
                    break
                end
            end
        end

        local targetPart = charAtt and charAtt.Parent or (slotPrefix == "Head" and char:FindFirstChild("Head") or (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")))
        if not targetPart then return end

        handle.CanCollide = false
        handle.Massless = true
        handle.Transparency = 0
        handle.CastShadow = false

        if att and charAtt then
            handle.CFrame = targetPart.CFrame * charAtt.CFrame * att.CFrame:Inverse()
            local weld = Instance.new("Weld")
            weld.Name = "AccessoryWeld"
            weld.Part0 = handle
            weld.Part1 = targetPart
            weld.C0 = att.CFrame
            weld.C1 = charAtt.CFrame
            weld.Parent = handle
        else
            handle.CFrame = targetPart.CFrame * (offsetCFrame or CFrame.new(0, 0, 0))
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = targetPart
            weld.Part1 = handle
            weld.Parent = handle
        end

        clone.Parent = char
    else
        -- Model / Part Path with Complete Joint Severing (Safe from other players)
        local clone = sourceItem:Clone()
        clone.Name = slotTag .. sourceItem.Name:gsub("%s+", "_"):gsub("[^%w_]", "")

        for _, w in ipairs(clone:GetDescendants()) do
            if w:IsA("JointInstance") or w:IsA("WeldConstraint") then
                local p0 = w.Part0
                local p1 = w.Part1
                if not p0 or not p1 or not p0:IsDescendantOf(clone) or not p1:IsDescendantOf(clone) then
                    pcall(function() w:Destroy() end)
                end
            end
            if w:IsA("BasePart") then
                w.CanCollide = false
                w.Massless = true
                w.Transparency = 0
                w.CastShadow = false
            end
        end

        local targetPart = slotPrefix == "Head" and char:FindFirstChild("Head") or (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
        if not targetPart then return end

        local handle = clone:FindFirstChild("Handle") or clone:FindFirstChildWhichIsA("BasePart")
        if handle then
            handle.CFrame = targetPart.CFrame * (offsetCFrame or CFrame.new(0, 0, 0))
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = targetPart
            weld.Part1 = handle
            weld.Parent = handle
        end

        clone.Parent = char
    end
end

local function ApplyAllCharacterGear()
    if not State.CharacterGearEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Headwear
    if State.GearHeadwear and State.GearHeadwear ~= "None" then
        local item = ResolveGameWearable(State.GearHeadwear)
        if item then
            AttachWearableItem(item, "Head", CFrame.new(0, 0, 0))
        end
    else
        for _, d in ipairs(char:GetChildren()) do
            if d.Name:find("Site76_Gear_Head_") then pcall(function() d:Destroy() end) end
        end
    end

    -- 2. Bodywear / Vest
    if State.GearBodywear and State.GearBodywear ~= "None" then
        local item = ResolveGameWearable(State.GearBodywear)
        if item then
            AttachWearableItem(item, "Body", CFrame.new(0, 0, 0))
        end
    else
        for _, d in ipairs(char:GetChildren()) do
            if d.Name:find("Site76_Gear_Body_") then pcall(function() d:Destroy() end) end
        end
    end

    -- 3. Backwear / Pack / Cape
    if State.GearBackwear and State.GearBackwear ~= "None" then
        local item = ResolveGameWearable(State.GearBackwear)
        if item then
            local offset = CFrame.new(0, 0, 0.7)
            if State.GearBackwear:find("Cape") then
                offset = CFrame.new(0, 0.35, 0.45)
            elseif State.GearBackwear:find("Scarf") or State.GearBackwear:find("Shemagh") then
                offset = CFrame.new(0, 0.6, 0)
            end
            AttachWearableItem(item, "Back", offset)
        end
    else
        for _, d in ipairs(char:GetChildren()) do
            if d.Name:find("Site76_Gear_Back_") then pcall(function() d:Destroy() end) end
        end
    end
end

local function HookToolEquip()
    local function onCharacter(char)
        if not char then return end
        if State.UGCEnabled then
            pcall(ApplyAllCharacterGear)
        end
        if State.TagNameEnabled and type(ApplyCustomTagName) == "function" then
            task.wait(0.3)
            pcall(ApplyCustomTagName)
        end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(ApplySkinsToTool, tool)
        end
        local childConn = char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                pcall(ApplySkinsToTool, child)
            end
        end)
        table.insert(Connections, childConn)
    end

    if LocalPlayer.Character then
        onCharacter(LocalPlayer.Character)
    end

    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        onCharacter(char)
        if State.UGCEnabled then
            pcall(ApplyAllCharacterGear)
        end
        if State.TagNameEnabled and type(ApplyCustomTagName) == "function" then
            task.wait(0.3)
            pcall(ApplyCustomTagName)
        end
    end)
    table.insert(Connections, charAddedConn)

    -- Global shoot sound & muzzle burst on MouseButton1 / Touch
    local shootInputConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    local mouse = LocalPlayer:GetMouse()
                    local targetPart = mouse and mouse.Target
                    if targetPart then
                        local targetChar = targetPart:FindFirstAncestorOfClass("Model")
                        local targetPlayer = targetChar and Players:GetPlayerFromCharacter(targetChar)
                        if targetPlayer and targetPlayer ~= LocalPlayer then
                            LastShotTarget = targetPlayer
                            LastShotTime = tick()
                        end
                    end
                end)
            end
            if tool and State.SkinChangerEnabled then
                local activeSoundName = type(State.GunFiringSound) == "table" and State.GunFiringSound[1] or State.GunFiringSound
                if State.AttachSuppressor and (activeSoundName == "Default" or not activeSoundName) then
                    activeSoundName = "Silenced Whisper Tactical"
                end
                local soundId = SoundPresets[activeSoundName]
                if soundId and soundId ~= "" then
                    pcall(function()
                        local snd = Instance.new("Sound")
                        snd.Name = "SkinChanger_ShotSound"
                        snd.SoundId = soundId
                        snd.Volume = 1.2
                        snd.PlaybackSpeed = State.GunSoundPitch or 1.0
                        SoundService:PlayLocalSound(snd)
                        game:GetService("Debris"):AddItem(snd, 2)
                    end)
                end

                local muzzle = tool:FindFirstChild("Muzzle")
                if not muzzle and Workspace:FindFirstChild("MorphAssets") and Workspace.MorphAssets:FindFirstChild("ExternalGunVisuals") then
                    local ext = Workspace.MorphAssets.ExternalGunVisuals:FindFirstChild(tool.Name)
                    muzzle = ext and ext:FindFirstChild("Muzzle")
                end
                local mFire = muzzle and muzzle:FindFirstChild("SkinChanger_MuzzleFire")
                if mFire then mFire:Emit(25) end

                local mLight = muzzle and muzzle:FindFirstChild("SkinChanger_Light")
                if mLight and State.GunMuzzleLight then
                    mLight.Enabled = true
                    task.delay(0.06, function()
                        if mLight and mLight.Parent then mLight.Enabled = false end
                    end)
                end
            end
        end
    end)
    table.insert(Connections, shootInputConn)

    -- Auto-hook ExternalGunVisuals spawn events
    if Workspace:FindFirstChild("MorphAssets") and Workspace.MorphAssets:FindFirstChild("ExternalGunVisuals") then
        local extConn = Workspace.MorphAssets.ExternalGunVisuals.ChildAdded:Connect(function(child)
            task.wait(0.05)
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and child.Name == tool.Name then
                ApplySkinsToTool(tool)
            end
        end)
        table.insert(Connections, extConn)
    end

    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                if State.SkinChangerEnabled and LocalPlayer.Character then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and not tool:FindFirstChild("SkinChanger_Applied") then
                        ApplySkinsToTool(tool)
                    end
                end
            end)
        end
    end)

    -- Initialize Player Death Listeners for Dead Box
    for _, p in ipairs(Players:GetPlayers()) do
        HookPlayerDeath(p)
    end
    local pAddedConn = Players.PlayerAdded:Connect(HookPlayerDeath)
    table.insert(Connections, pAddedConn)
end

-- ==========================================
-- Rayfield UI Initialization (No Emojis, English Only)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "SCP: Roleplay Suite - Site 76",
    LoadingTitle = "SCP: Roleplay Assistant",
    LoadingSubtitle = "Combat & Intelligence Edition",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- ------------------------------------------
-- Tab 1: Combat (Aimbot & Triggerbot)
-- ------------------------------------------
local TabCombat = Window:CreateTab("Combat", 4483362458)

TabCombat:CreateSection("Aimbot & Camera Lock")

TabCombat:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = State.Aimbot,
    Flag = "Aimbot_Toggle",
    Callback = function(Value)
        State.Aimbot = Value
        if fovCircle then fovCircle.Visible = Value and State.AimbotDrawFOV end
        Rayfield:Notify({
            Title = "Aimbot",
            Content = Value and "Aimbot Active! Locks camera onto enemies." or "Aimbot Disabled.",
            Duration = 2
        })
    end,
})

TabCombat:CreateDropdown({
    Name = "Aimbot Activation Mode",
    Options = {"Hold Right Click (RMB)", "Hold Left Click (LMB)", "Always On", "While Shooting / Mobile Touch"},
    CurrentOption = {"Hold Right Click (RMB)"},
    Flag = "AimbotKey_Dropdown",
    Callback = function(Option)
        State.AimbotKey = type(Option) == "table" and Option[1] or Option
    end,
})

TabCombat:CreateDropdown({
    Name = "Target Hitbox",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Flag = "AimbotTargetPart_Dropdown",
    Callback = function(Option)
        State.AimbotTargetPart = type(Option) == "table" and Option[1] or Option
    end,
})

TabCombat:CreateSlider({
    Name = "Aim Smoothness",
    Range = {1, 10},
    Increment = 1,
    Suffix = "factor",
    CurrentValue = State.AimbotSmoothness,
    Flag = "AimbotSmoothness_Slider",
    Callback = function(Value)
        State.AimbotSmoothness = Value
    end,
})

TabCombat:CreateToggle({
    Name = "Team Check (Protect Allies)",
    CurrentValue = State.AimbotTeamCheck,
    Flag = "AimbotTeamCheck_Toggle",
    Callback = function(Value)
        State.AimbotTeamCheck = Value
    end,
})

TabCombat:CreateToggle({
    Name = "Wall Check (Visible Enemies Only)",
    CurrentValue = State.AimbotWallCheck,
    Flag = "AimbotWallCheck_Toggle",
    Callback = function(Value)
        State.AimbotWallCheck = Value
    end,
})

TabCombat:CreateDropdown({
    Name = "Target Priority",
    Options = {"Closest to Crosshair", "Closest Distance"},
    CurrentOption = {"Closest to Crosshair"},
    Flag = "AimbotPriority_Dropdown",
    Callback = function(Option)
        State.AimbotPriority = type(Option) == "table" and Option[1] or Option
    end,
})

TabCombat:CreateSection("FOV Targeting Circle")

TabCombat:CreateToggle({
    Name = "Draw FOV Circle",
    CurrentValue = State.AimbotDrawFOV,
    Flag = "AimbotDrawFOV_Toggle",
    Callback = function(Value)
        State.AimbotDrawFOV = Value
        if fovCircle then fovCircle.Visible = State.Aimbot and Value end
    end,
})

TabCombat:CreateSlider({
    Name = "FOV Radius",
    Range = {40, 350},
    Increment = 5,
    Suffix = "px",
    CurrentValue = State.AimbotFOV,
    Flag = "AimbotFOV_Slider",
    Callback = function(Value)
        State.AimbotFOV = Value
        if fovCircle then fovCircle.Radius = Value end
    end,
})

TabCombat:CreateSection("Silent Aim (Redirect Bullets)")

TabCombat:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = State.SilentAim,
    Flag = "SilentAim_Toggle",
    Callback = function(Value)
        State.SilentAim = Value
        if silentFovCircle then silentFovCircle.Visible = Value and State.SilentAimDrawFOV end
        Rayfield:Notify({
            Title = "Silent Aim",
            Content = Value and "Silent Aim Active! Redirects shots without moving camera." or "Silent Aim Disabled.",
            Duration = 2
        })
    end,
})

TabCombat:CreateSlider({
    Name = "Silent Aim Hitchance",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = State.SilentAimHitchance,
    Flag = "SilentAimHitchance_Slider",
    Callback = function(Value)
        State.SilentAimHitchance = Value
    end,
})

TabCombat:CreateDropdown({
    Name = "Target Hitbox",
    Options = {"Head", "HumanoidRootPart", "Random", "Torso"},
    CurrentOption = {State.SilentAimTargetPart},
    Flag = "SilentAimTargetPart_Dropdown",
    Callback = function(Option)
        State.SilentAimTargetPart = type(Option) == "table" and Option[1] or Option
    end,
})

TabCombat:CreateSlider({
    Name = "Silent Aim FOV Radius",
    Range = {40, 400},
    Increment = 5,
    Suffix = "px",
    CurrentValue = State.SilentAimFOV,
    Flag = "SilentAimFOV_Slider",
    Callback = function(Value)
        State.SilentAimFOV = Value
        if silentFovCircle then silentFovCircle.Radius = Value end
    end,
})

TabCombat:CreateToggle({
    Name = "Draw Silent Aim FOV",
    CurrentValue = State.SilentAimDrawFOV,
    Flag = "SilentAimDrawFOV_Toggle",
    Callback = function(Value)
        State.SilentAimDrawFOV = Value
        if silentFovCircle then silentFovCircle.Visible = State.SilentAim and Value end
    end,
})

TabCombat:CreateToggle({
    Name = "Silent Aim Wall Check",
    CurrentValue = State.SilentAimWallCheck,
    Flag = "SilentAimWallCheck_Toggle",
    Callback = function(Value)
        State.SilentAimWallCheck = Value
    end,
})

TabCombat:CreateToggle({
    Name = "Silent Aim Team Check",
    CurrentValue = State.SilentAimTeamCheck,
    Flag = "SilentAimTeamCheck_Toggle",
    Callback = function(Value)
        State.SilentAimTeamCheck = Value
    end,
})

TabCombat:CreateSection("Triggerbot (Automatic Fire)")

TabCombat:CreateToggle({
    Name = "Enable Triggerbot",
    CurrentValue = State.Triggerbot,
    Flag = "Triggerbot_Toggle",
    Callback = function(Value)
        State.Triggerbot = Value
        Rayfield:Notify({
            Title = "Triggerbot",
            Content = Value and "Triggerbot Active! Fires automatically when aiming at enemies." or "Triggerbot Disabled.",
            Duration = 2
        })
    end,
})

TabCombat:CreateSlider({
    Name = "Triggerbot Reaction Delay",
    Range = {0, 150},
    Increment = 5,
    Suffix = "ms",
    CurrentValue = State.TriggerbotDelay,
    Flag = "TriggerbotDelay_Slider",
    Callback = function(Value)
        State.TriggerbotDelay = Value
    end,
})

TabCombat:CreateToggle({
    Name = "Triggerbot Headshot Only",
    CurrentValue = State.TriggerbotHeadOnly,
    Flag = "TriggerbotHeadOnly_Toggle",
    Callback = function(Value)
        State.TriggerbotHeadOnly = Value
    end,
})

TabCombat:CreateToggle({
    Name = "Triggerbot Team Check",
    CurrentValue = State.TriggerbotTeamCheck,
    Flag = "TriggerbotTeamCheck_Toggle",
    Callback = function(Value)
        State.TriggerbotTeamCheck = Value
    end,
})

-- ------------------------------------------
-- Tab 2: Facility (Doors, Keycards, Phase)
-- ------------------------------------------
local TabFacility = Window:CreateTab("Facility", 4483362458)

TabFacility:CreateSection("Ghost Doors (Bypass All Doors & Remotes)")

TabFacility:CreateToggle({
    Name = "Walk Through All Doors (Ghost Doors / No Collision)",
    CurrentValue = State.GhostDoors,
    Flag = "GhostDoors_Toggle",
    Callback = function(Value)
        State.GhostDoors = Value
        if not Value then
            UpdateGhostDoors()
        end
        Rayfield:Notify({
            Title = "Ghost Doors",
            Content = Value and "Active! Walk straight through any door, gate, or remote blast door." or "Disabled. Door collision restored.",
            Duration = 3
        })
    end,
})

TabFacility:CreateButton({
    Name = "Phase Through Door (Blink 10 Studs Forward)",
    Callback = function()
        PhaseThroughDoor(10)
        Rayfield:Notify({
            Title = "Door Phased",
            Content = "Teleported 10 studs forward past the door!",
            Duration = 2
        })
    end,
})

TabFacility:CreateKeybind({
    Name = "Door Phase Hotkey",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Flag = "DoorPhase_Keybind",
    Callback = function()
        PhaseThroughDoor(10)
    end,
})

TabFacility:CreateSection("Prompts & Environment")

TabFacility:CreateToggle({
    Name = "Instant Prompts (0s Door Hold)",
    CurrentValue = State.InstantPrompts,
    Flag = "InstantPrompts_Toggle",
    Callback = function(Value)
        State.InstantPrompts = Value
        if Value then ApplyInstantPrompts() end
    end,
})

TabFacility:CreateToggle({
    Name = "Fullbright (Night Vision and No Shadows)",
    CurrentValue = State.Fullbright,
    Flag = "Fullbright_Toggle",
    Callback = function(Value)
        State.Fullbright = Value
        SetFullbright(Value)
    end,
})

TabFacility:CreateSection("Phasing & Wall Bypass")

TabFacility:CreateToggle({
    Name = "Noclip (Walk Through Walls)",
    CurrentValue = State.Noclip,
    Flag = "Noclip_Toggle",
    Callback = function(Value)
        State.Noclip = Value
        Rayfield:Notify({
            Title = "Noclip",
            Content = Value and "Noclip Enabled. Walk through walls freely." or "Noclip Disabled.",
            Duration = 2
        })
    end,
})

TabFacility:CreateKeybind({
    Name = "Noclip Hotkey",
    CurrentKeybind = "N",
    HoldToInteract = false,
    Flag = "Noclip_Keybind",
    Callback = function()
        State.Noclip = not State.Noclip
        Rayfield:Notify({
            Title = "Noclip Toggled",
            Content = "Noclip is now " .. (State.Noclip and "ON" or "OFF"),
            Duration = 1.5
        })
    end,
})

TabFacility:CreateButton({
    Name = "Infinite Jump",
    Callback = function()
        local conn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        table.insert(Connections, conn)
        Rayfield:Notify({
            Title = "Infinite Jump",
            Content = "Infinite Jump active for this session!",
            Duration = 2
        })
    end,
})

-- ------------------------------------------
-- Tab 3: Visuals
-- ------------------------------------------
local TabVisuals = Window:CreateTab("Visuals", 4483362458)
TabVisuals:CreateSection("Modular ESP Options")

TabVisuals:CreateToggle({
    Name = "Box ESP",
    CurrentValue = State.EspBox,
    Flag = "EspBox_Toggle",
    Callback = function(Value)
        State.EspBox = Value
    end,
})

TabVisuals:CreateToggle({
    Name = "Tracer Lines",
    CurrentValue = State.EspTracers,
    Flag = "EspTracers_Toggle",
    Callback = function(Value)
        State.EspTracers = Value
    end,
})

TabVisuals:CreateDropdown({
    Name = "Tracer Origin",
    Options = {"Bottom Screen", "Center Screen", "Top Screen"},
    CurrentOption = State.EspTracerOrigin,
    Flag = "EspTracerOrigin_Dropdown",
    Callback = function(Option)
        State.EspTracerOrigin = Option
    end,
})

TabVisuals:CreateToggle({
    Name = "Name ESP",
    CurrentValue = State.EspNames,
    Flag = "EspNames_Toggle",
    Callback = function(Value)
        State.EspNames = Value
    end,
})

TabVisuals:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = State.EspDistance,
    Flag = "EspDistance_Toggle",
    Callback = function(Value)
        State.EspDistance = Value
    end,
})

TabVisuals:CreateToggle({
    Name = "Weapon ESP",
    CurrentValue = State.EspWeapon,
    Flag = "EspWeapon_Toggle",
    Callback = function(Value)
        State.EspWeapon = Value
    end,
})

TabVisuals:CreateToggle({
    Name = "Health Bar ESP",
    CurrentValue = State.EspHealthBar,
    Flag = "EspHealthBar_Toggle",
    Callback = function(Value)
        State.EspHealthBar = Value
    end,
})

TabVisuals:CreateToggle({
    Name = "Team Colors",
    CurrentValue = State.EspTeam,
    Flag = "EspTeam_Toggle",
    Callback = function(Value)
        State.EspTeam = Value
    end,
})

TabVisuals:CreateToggle({
    Name = "Chams (3D Highlight)",
    CurrentValue = State.EspChams,
    Flag = "EspChams_Toggle",
    Callback = function(Value)
        State.EspChams = Value
        if not Value then
            for _, hl in pairs(Highlights) do hl.Enabled = false end
        end
    end,
})

TabVisuals:CreateDropdown({
    Name = "ESP Target Filter",
    Options = {"Everyone", "Enemies Only"},
    CurrentOption = State.EspFilter,
    Flag = "EspFilter_Dropdown",
    Callback = function(Option)
        State.EspFilter = Option
    end,
})

TabVisuals:CreateSection("Facility & Objects ESP")

TabVisuals:CreateToggle({
    Name = "SCP ESP (Threat and Distance)",
    CurrentValue = State.ScpESP,
    Flag = "ScpESP_Toggle",
    Callback = function(Value)
        State.ScpESP = Value
        if not Value and Workspace:FindFirstChild("SCPs") then
            for _, scp in ipairs(Workspace.SCPs:GetChildren()) do
                if Highlights[scp] then Highlights[scp].Enabled = false end
                if Billboards[scp] then Billboards[scp].Enabled = false end
            end
        end
    end,
})

TabVisuals:CreateToggle({
    Name = "Dropped Items and Weapons ESP",
    CurrentValue = State.ItemESP,
    Flag = "ItemESP_Toggle",
    Callback = function(Value)
        State.ItemESP = Value
        if not Value then
            for _, hl in pairs(ItemHighlights) do hl.Enabled = false end
        end
    end,
})

TabVisuals:CreateSection("Field of View")

TabVisuals:CreateSlider({
    Name = "Camera Field of View",
    Range = {70, 120},
    Increment = 1,
    Suffix = "deg",
    CurrentValue = State.FOV,
    Flag = "FOV_Slider",
    Callback = function(Value)
        State.FOV = Value
        Camera.FieldOfView = Value
    end,
})

-- ------------------------------------------
-- Tab 4: Skin Changer
-- ------------------------------------------
local TabSkins = Window:CreateTab("Skin Changer", 4483362458)
TabSkins:CreateSection("Weapon Skin & Visual Finish")

TabSkins:CreateToggle({
    Name = "Enable Weapon Skin Changer",
    CurrentValue = State.SkinChangerEnabled,
    Flag = "SkinChanger_Toggle",
    Callback = function(Value)
        State.SkinChangerEnabled = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateDropdown({
    Name = "Weapon Skin Style",
    Options = {
        "Gold Deluxe",
        "Holographic Forcefield",
        "Cyber Neon Blue",
        "Crimson Dragon",
        "Obsidian Shadow",
        "Emerald Viper",
        "Amethyst Galaxy",
        "Arctic Glaze",
        "Rainbow Chroma",
        "Default"
    },
    CurrentOption = State.GunSkinStyle,
    Flag = "GunSkinStyle_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GunSkinStyle = val
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateDropdown({
    Name = "Gun Camo Pattern",
    Options = {
        "Woodland Military Camo",
        "Desert Digital Camo",
        "Arctic Winter Camo",
        "Tigerstripe Tactical",
        "Night Ops Dark Camo",
        "Urban Flecktarn",
        "Dragon Magma Scale",
        "Carbon Fiber Weave",
        "Damascus Steel Wave",
        "Galaxy Nebula",
        "Clean Solid",
        "Factory Default"
    },
    CurrentOption = State.GunSkinPattern,
    Flag = "GunSkinPattern_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GunSkinPattern = val
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateSection("Tactical Attachments")

TabSkins:CreateDropdown({
    Name = "Weapon Attachments",
    Options = {
        "Suppressor",
        "Laser Sight",
        "Tactical Scope"
    },
    CurrentOption = State.WeaponAttachments,
    MultipleOptions = true,
    Flag = "WeaponAttachments_Dropdown",
    Callback = function(Options)
        State.WeaponAttachments = type(Options) == "table" and Options or {Options}
        State.AttachSuppressor = false
        State.AttachLaser = false
        State.AttachScope = false
        for _, opt in ipairs(State.WeaponAttachments) do
            if string.find(opt, "Suppressor") then State.AttachSuppressor = true end
            if string.find(opt, "Laser") then State.AttachLaser = true end
            if string.find(opt, "Scope") then State.AttachScope = true end
        end
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateToggle({
    Name = "Equip Suppressor",
    CurrentValue = State.AttachSuppressor,
    Flag = "AttachSuppressor_Toggle",
    Callback = function(Value)
        State.AttachSuppressor = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateToggle({
    Name = "Equip Laser Sight",
    CurrentValue = State.AttachLaser,
    Flag = "AttachLaser_Toggle",
    Callback = function(Value)
        State.AttachLaser = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateToggle({
    Name = "Equip Tactical Scope",
    CurrentValue = State.AttachScope,
    Flag = "AttachScope_Toggle",
    Callback = function(Value)
        State.AttachScope = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateToggle({
    Name = "Weapon Glow Aura (Highlight)",
    CurrentValue = State.GunChamsHighlight,
    Flag = "GunChamsHighlight_Toggle",
    Callback = function(Value)
        State.GunChamsHighlight = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateSection("Official Particle Skin Effects")

TabSkins:CreateDropdown({
    Name = "Particle Skin",
    Options = {
        "Galaxy (Deep Nebula)",
        "Lightning 1 (Electric Blue)",
        "Lightning 2 (Arc Cyan)",
        "Lightning 3 (Plasma Violet)",
        "Fire Texture (Dragon Flame)",
        "Stars (Cosmic Glitter)",
        "Space (Interstellar)",
        "Space Dust (Void Spores)",
        "Black Smoke (Dark Matter)",
        "Red Dust (Crimson Ash)",
        "Frost (Subzero Crystal)",
        "Flakes (Snow Flurry)",
        "Heart Particles (Love Charm)",
        "Halloween 2025 (Cursed Spirits)",
        "Anniversary 2025 (Golden Confetti)",
        "Easter 2026 (Festive Glow)",
        "Red Raid Lightning",
        "Blue Raid Lightning",
        "None"
    },
    CurrentOption = State.GunParticleSkin,
    Flag = "GunParticleSkin_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GunParticleSkin = val
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateSection("Muzzle Fire & Flash FX")

TabSkins:CreateDropdown({
    Name = "Muzzle Fire & Flash Effect",
    Options = {
        "Plasma Burst",
        "Dragon Flame",
        "Electric Arc",
        "Void Dark",
        "Rainbow Sparkles",
        "Default"
    },
    CurrentOption = State.MuzzleFireEffect,
    Flag = "MuzzleFireEffect_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.MuzzleFireEffect = val
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateToggle({
    Name = "Dynamic Muzzle Flash Lighting",
    CurrentValue = State.GunMuzzleLight,
    Flag = "GunMuzzleLight_Toggle",
    Callback = function(Value)
        State.GunMuzzleLight = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateSection("Custom Firing Sounds")

TabSkins:CreateDropdown({
    Name = "Firing Sound Preset",
    Options = {
        "Sci-Fi Laser Pulse",
        "Heavy 50 Cal Thunder",
        "Silenced Whisper Tactical",
        "Plasma Railgun Burst",
        "Dragon Fang Burst",
        "AK-47 Thunder",
        "Spas-12 Shotgun",
        "Tactical Pistol",
        "M16A4 Military",
        "Energy Blaster Hit",
        "Default"
    },
    CurrentOption = State.GunFiringSound,
    Flag = "GunFiringSound_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GunFiringSound = val
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateSlider({
    Name = "Firing Sound Pitch",
    Range = {0.5, 2.0},
    Increment = 0.05,
    Suffix = "x",
    CurrentValue = State.GunSoundPitch,
    Flag = "GunSoundPitch_Slider",
    Callback = function(Value)
        State.GunSoundPitch = Value
        ReapplySkinsToAll()
    end,
})

TabSkins:CreateSection("Official Game Kill Effects")

TabSkins:CreateToggle({
    Name = "Enable Game Kill Effect",
    CurrentValue = State.DeadBoxEnabled,
    Flag = "DeadBoxEnabled_Toggle",
    Callback = function(Value)
        State.DeadBoxEnabled = Value
    end,
})

TabSkins:CreateDropdown({
    Name = "Official Kill Effect & Death Box",
    Options = {
        "Gift Box",
        "Casket",
        "Tombstone",
        "SCP Crate",
        "Ice Cube",
        "Blackhole",
        "Atomic Rebinding",
        "Disintegration",
        "Defragmentation",
        "Black Flame",
        "Collect Soul",
        "Northern Lights",
        "Foundation Seal",
        "Gold Wrap",
        "Obsidian"
    },
    CurrentOption = State.DeadBoxStyle,
    Flag = "DeadBoxStyle_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.DeadBoxStyle = val
    end,
})

TabSkins:CreateToggle({
    Name = "Elimination Banner Notification",
    CurrentValue = State.EliminationBanner,
    Flag = "EliminationBanner_Toggle",
    Callback = function(Value)
        State.EliminationBanner = Value
    end,
})

TabSkins:CreateSection("All-Inclusive Character Wearables Suite")

TabSkins:CreateToggle({
    Name = "Enable All Character Wearables",
    CurrentValue = State.CharacterGearEnabled,
    Flag = "CharacterGearEnabled_Toggle",
    Callback = function(Value)
        State.CharacterGearEnabled = Value
        if not Value then
            ClearAllCharacterGear()
        else
            ApplyAllCharacterGear()
        end
    end,
})

TabSkins:CreateDropdown({
    Name = "Headwear, Helmets & Masks",
    Options = {
        "None",
        "The Nova Dominion Helmet",
        "FAST Helmet",
        "FAST Helmet Addons",
        "GOC Combat Helmet & Quad NVG",
        "TSH Serpent's Hand Helmet",
        "GRU-P Tactical Helmet",
        "MTF Facility Security Helmet",
        "SCP-096 Shy Guy Bag",
        "Flower Head Hat",
        "SCP-131 \"Eye Pods\" Earrings",
        "Mad Scientist Hair",
        "Shadow Ninja Mask",
        "Holiday Santa Hat",
        "Chef Gourmet Hat",
        "Tactical Sunglasses"
    },
    CurrentOption = State.GearHeadwear,
    Flag = "GearHeadwear_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GearHeadwear = val
        if State.CharacterGearEnabled then
            ApplyAllCharacterGear()
        end
    end,
})

TabSkins:CreateDropdown({
    Name = "Tactical Vests, Body Armor & Rigs",
    Options = {
        "None",
        "Tactical Vest Var1",
        "Tactical Vest Var1 Blue",
        "Cyber Exoskeleton Frame",
        "3 Magazines Chest Rig",
        "GOC Heavy Combat Plate Carrier",
        "TSH Serpent's Hand Combat Rig",
        "GRU-P Tactical Armor Rig",
        "MTF Facility Body Armor",
        "SCP-049 Plague Doctor Cloak",
        "Entity-007 \"Man of Bricks\" Plushie"
    },
    CurrentOption = State.GearBodywear,
    Flag = "GearBodywear_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GearBodywear = val
        if State.CharacterGearEnabled then
            ApplyAllCharacterGear()
        end
    end,
})

TabSkins:CreateDropdown({
    Name = "Backpack, Cape & Gear Accessories",
    Options = {
        "None",
        "ISD Tactical Backpack",
        "GOC Tactical Field Pack",
        "The Serpents Hand Cape",
        "Epsilon-11 NTF Blue Scarf",
        "ISD Red Combat Shemagh",
        "Christmas Holiday Scarf",
        "Epsilon-11 Foliage Camo",
        "ISD Tactical Watch"
    },
    CurrentOption = State.GearBackwear,
    Flag = "GearBackwear_Dropdown",
    Callback = function(Option)
        local val = type(Option) == "table" and Option[1] or Option
        State.GearBackwear = val
        if State.CharacterGearEnabled then
            ApplyAllCharacterGear()
        end
    end,
})

TabSkins:CreateButton({
    Name = "Apply All Character Gear Now",
    Callback = function()
        ApplyAllCharacterGear()
        Rayfield:Notify({
            Title = "Gear Equipped",
            Content = "All selected headwear, body armor, and backpacks applied!",
            Duration = 2.5
        })
    end,
})

TabSkins:CreateButton({
    Name = "Clear All Character Gear",
    Callback = function()
        ClearAllCharacterGear()
        Rayfield:Notify({
            Title = "Gear Cleared",
            Content = "Removed all worn character accessories.",
            Duration = 2.5
        })
    end,
})

TabSkins:CreateSection("Skin Management")

TabSkins:CreateButton({
    Name = "Apply Skins to Equipped Weapon Now",
    Callback = function()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local appliedTag = tool:FindFirstChild("SkinChanger_Applied")
            if appliedTag then appliedTag:Destroy() end
            ApplySkinsToTool(tool)
            Rayfield:Notify({
                Title = "Skins Applied",
                Content = "Custom skin, pattern, particles, and sounds applied to " .. tool.Name,
                Duration = 2.5
            })
        else
            Rayfield:Notify({
                Title = "Skin Changer",
                Content = "Please hold a weapon in your hand first!",
                Duration = 2.5
            })
        end
    end,
})

    TabSkins:CreateButton({
        Name = "Reset Weapon to Default Appearance",
        Callback = function()
            State.GunSkinStyle = "Default"
            State.GunSkinPattern = "Factory Default"
            State.GunParticleSkin = "None"
            State.MuzzleFireEffect = "Default"
            State.GunFiringSound = "Default"
            State.GunChamsHighlight = false
            State.AttachSuppressor = false
            State.AttachLaser = false
            State.AttachScope = false
            State.WeaponAttachments = {}
            ReapplySkinsToAll()
            Rayfield:Notify({
                Title = "Weapon Reset",
                Content = "Weapon reverted to factory original appearance.",
                Duration = 2.5
            })
        end,
    })

-- ------------------------------------------
-- Tab 5: Class Switcher (Server Official Weapons)
-- ------------------------------------------
local TabTeams = Window:CreateTab("Class Switcher", 4483362458)
TabTeams:CreateSection("Combat Classes (With Official Server Weapons)")

TabTeams:CreateButton({
    Name = "Spawn as Chaos Insurgency (BR-762 Rifle)",
    Callback = function()
        local ok, msg = SpawnAsTeam("Chaos Insurgency")
        Rayfield:Notify({
            Title = ok and "Spawn Successful" or "Spawn Error",
            Content = msg,
            Duration = 3
        })
    end,
})

TabTeams:CreateButton({
    Name = "Spawn as Security Department (M4 Rifle)",
    Callback = function()
        local ok, msg = SpawnAsTeam("Security Department")
        Rayfield:Notify({
            Title = ok and "Spawn Successful" or "Spawn Error",
            Content = msg,
            Duration = 3
        })
    end,
})

TabTeams:CreateButton({
    Name = "Spawn as Mobile Task Force (M16A4 Rifle)",
    Callback = function()
        local ok, msg = SpawnAsTeam("Mobile Task Force")
        Rayfield:Notify({
            Title = ok and "Spawn Successful" or "Spawn Error",
            Content = msg,
            Duration = 3
        })
    end,
})

TabTeams:CreateButton({
    Name = "Spawn as Class - D",
    Callback = function()
        local ok, msg = SpawnAsTeam("Class - D")
        Rayfield:Notify({
            Title = ok and "Spawn Successful" or "Spawn Error",
            Content = msg,
            Duration = 3
        })
    end,
})

TabTeams:CreateSection("Select Any Facility Department")

TabTeams:CreateDropdown({
    Name = "Choose Department",
    Options = AllTeamsList,
    CurrentOption = {"Chaos Insurgency"},
    Flag = "Department_Dropdown",
    Callback = function(Option)
        local target = type(Option) == "table" and Option[1] or Option
        local ok, msg = SpawnAsTeam(target)
        Rayfield:Notify({
            Title = ok and "Spawn Successful" or "Spawn Error",
            Content = msg,
            Duration = 3
        })
    end,
})

-- ------------------------------------------
-- Tab 6: Weapons (37 Weapons Arsenal)
-- ------------------------------------------
local TabWeapons = Window:CreateTab("Weapons", 4483362458)
TabWeapons:CreateSection("Arsenal Spawner")

local SelectedGun = AllGunsList[1]
TabWeapons:CreateDropdown({
    Name = "Select Weapon Model",
    Options = AllGunsList,
    CurrentOption = {AllGunsList[1]},
    Flag = "GunSelect_Dropdown",
    Callback = function(Option)
        SelectedGun = type(Option) == "table" and Option[1] or Option
    end,
})

TabWeapons:CreateButton({
    Name = "Spawn Selected Weapon to Inventory",
    Callback = function()
        local ok, msg = SpawnLocalWeapon(SelectedGun)
        Rayfield:Notify({
            Title = ok and "Weapon Ready" or "Spawner Error",
            Content = msg,
            Duration = 2.5
        })
    end,
})

TabWeapons:CreateButton({
    Name = "Give All 37 Weapons",
    Callback = function()
        local count = 0
        for _, g in ipairs(AllGunsList) do
            local ok = SpawnLocalWeapon(g)
            if ok then count = count + 1 end
        end
        Rayfield:Notify({
            Title = "Arsenal Loaded",
            Content = "Spawned " .. count .. " weapons safely to backpack!",
            Duration = 3.5
        })
    end,
})

TabWeapons:CreateSection("Steal Live Weapons")

TabWeapons:CreateButton({
    Name = "Steal Weapon from Nearest Player",
    Callback = function()
        local ok, msg = StealWeaponFromNearestPlayer()
        Rayfield:Notify({
            Title = ok and "Weapon Copied" or "Steal Result",
            Content = msg,
            Duration = 3
        })
    end,
})

-- ------------------------------------------
-- Tab 7: Spy Chat (Intercept Communications)
-- ------------------------------------------
local TabSpyChat = Window:CreateTab("Spy Chat", 4483362458)
TabSpyChat:CreateSection("Roblox Chat Box Integration")

TabSpyChat:CreateToggle({
    Name = "Force Show Roblox Chat Box",
    CurrentValue = State.SpyForceChatWindow,
    Flag = "SpyForceChatWindow_Toggle",
    Callback = function(Value)
        State.SpyForceChatWindow = Value
        ForceEnableChatWindow(Value)
        Rayfield:Notify({
            Title = "Roblox Chat Window",
            Content = Value and "Chat window forced VISIBLE in top-left." or "Chat window restored to game default.",
            Duration = 2.5
        })
    end,
})

TabSpyChat:CreateToggle({
    Name = "Display Messages in Roblox Chat",
    CurrentValue = State.SpyShowInChat,
    Flag = "SpyShowInChat_Toggle",
    Callback = function(Value)
        State.SpyShowInChat = Value
    end,
})

TabSpyChat:CreateButton({
    Name = "Send Test Message to Roblox Chat Box",
    Callback = function()
        ForceEnableChatWindow(true)
        FormatAndDisplaySpyMessage("[SPY TEST]", "#00FF66", "System", "#00E5FF", LocalPlayer.Name, "This is a live test message in your Roblox chat window!")
        Rayfield:Notify({
            Title = "Test Message Sent",
            Content = "Check the top-left Roblox chat window!",
            Duration = 2.5
        })
    end,
})

TabSpyChat:CreateSection("Spy Channels")

TabSpyChat:CreateToggle({
    Name = "Enable Spy Chat",
    CurrentValue = State.SpyChat,
    Flag = "SpyChat_Toggle",
    Callback = function(Value)
        State.SpyChat = Value
        Rayfield:Notify({
            Title = "Spy Chat",
            Content = Value and "Active! Intercepting facility communications." or "Spy Chat Disabled.",
            Duration = 2.5
        })
    end,
})

TabSpyChat:CreateToggle({
    Name = "Spy Team Chats (All 10 Departments)",
    CurrentValue = State.SpyTeamChat,
    Flag = "SpyTeamChat_Toggle",
    Callback = function(Value)
        State.SpyTeamChat = Value
    end,
})

TabSpyChat:CreateToggle({
    Name = "Spy Facility Radios (Foundation & Chaos)",
    CurrentValue = State.SpyRadio,
    Flag = "SpyRadio_Toggle",
    Callback = function(Value)
        State.SpyRadio = Value
    end,
})

TabSpyChat:CreateToggle({
    Name = "Spy Player Vicinity Speech",
    CurrentValue = State.SpyPublicChat,
    Flag = "SpyPublicChat_Toggle",
    Callback = function(Value)
        State.SpyPublicChat = Value
    end,
})

TabSpyChat:CreateToggle({
    Name = "Spy Private Whispers",
    CurrentValue = State.SpyWhispers,
    Flag = "SpyWhispers_Toggle",
    Callback = function(Value)
        State.SpyWhispers = Value
    end,
})

TabSpyChat:CreateToggle({
    Name = "Show Rayfield Notifications",
    CurrentValue = State.SpyNotifications,
    Flag = "SpyNotifications_Toggle",
    Callback = function(Value)
        State.SpyNotifications = Value
    end,
})

TabSpyChat:CreateSection("Spy Log Actions")

TabSpyChat:CreateButton({
    Name = "Print Last 10 Intercepted Messages to Console",
    Callback = function()
        print("========== SPY CHAT LOG ==========")
        for i = math.min(10, #SpyChatHistory), 1, -1 do
            local item = SpyChatHistory[i]
            print(string.format("[%s] [%s] %s: %s", item.time, item.channel, item.sender, item.text))
        end
        print("==================================")
        Rayfield:Notify({
            Title = "Spy Log",
            Content = "Printed last " .. math.min(10, #SpyChatHistory) .. " intercepted messages to F9 console.",
            Duration = 3
        })
    end,
})

TabSpyChat:CreateButton({
    Name = "Clear Intercepted History",
    Callback = function()
        table.clear(SpyChatHistory)
        State.SpyInterceptCount = 0
        Rayfield:Notify({
            Title = "Spy Log",
            Content = "Cleared spy chat history.",
            Duration = 2
        })
    end,
})

-- ------------------------------------------
-- Tab 8: Anti SCP
-- ------------------------------------------
local TabAntiScp = Window:CreateTab("Anti SCP", 4483362458)
TabAntiScp:CreateSection("Automated Survival Protections")

TabAntiScp:CreateToggle({
    Name = "Auto Look at SCP-173 (Lock Eyes to Freeze)",
    CurrentValue = State.AutoLook173,
    Flag = "AutoLook173_Toggle",
    Callback = function(Value)
        State.AutoLook173 = Value
    end,
})

TabAntiScp:CreateToggle({
    Name = "Avoid Looking at SCP-096 (Prevent Enrage)",
    CurrentValue = State.AvoidLook096,
    Flag = "AvoidLook096_Toggle",
    Callback = function(Value)
        State.AvoidLook096 = Value
    end,
})

-- ------------------------------------------
-- Tab 10: Troll (Pure English, No Emojis)
-- ------------------------------------------
local TabTroll = Window:CreateTab("Troll", 4483362458)
TabTroll:CreateSection("Character Troll Actions")

TabTroll:CreateToggle({
    Name = "Spinbot",
    CurrentValue = State.Spinbot,
    Flag = "Spinbot_Toggle",
    Callback = function(Value)
        State.Spinbot = Value
    end,
})

TabTroll:CreateSlider({
    Name = "Spin Speed",
    Range = {10, 100},
    Increment = 5,
    Suffix = "deg/frame",
    CurrentValue = State.SpinSpeed,
    Flag = "SpinSpeed_Slider",
    Callback = function(Value)
        State.SpinSpeed = Value
    end,
})

TabTroll:CreateToggle({
    Name = "Spam Crouch (Teabag Mode)",
    CurrentValue = State.CrouchSpam,
    Flag = "CrouchSpam_Toggle",
    Callback = function(Value)
        State.CrouchSpam = Value
        if not Value then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
        end
    end,
})

TabTroll:CreateToggle({
    Name = "Float and Levitate",
    CurrentValue = State.FloatLevitate,
    Flag = "Float_Toggle",
    Callback = function(Value)
        State.FloatLevitate = Value
    end,
})

TabTroll:CreateButton({
    Name = "Ragdoll Trip Character",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
        end
    end,
})

TabTroll:CreateSection("Facility Visual Trolls")

TabTroll:CreateToggle({
    Name = "Disco Facility Lights (Rainbow Rave)",
    CurrentValue = State.DiscoLights,
    Flag = "Disco_Toggle",
    Callback = function(Value)
        State.DiscoLights = Value
        if not Value then
            SetFullbright(State.Fullbright)
        end
    end,
})

-- ------------------------------------------
-- Tab 11: Teleports
-- ------------------------------------------
local TabTeleports = Window:CreateTab("Teleports", 4483362458)
TabTeleports:CreateSection("SCP Containment Cells")

local ScpWaypoints = {
    ["SCP-173 (The Sculpture)"] = Vector3.new(-82, 3, -712),
    ["SCP-096 (The Shy Guy)"] = Vector3.new(115, 3, -792),
    ["SCP-106 (The Old Man)"] = Vector3.new(275, 1, -775),
    ["SCP-049 (Plague Doctor)"] = Vector3.new(20, 3, -643),
    ["SCP-939 (With Many Voices)"] = Vector3.new(-196, -20, -754),
    ["SCP-087 (The Stairwell)"] = Vector3.new(-57, 3, -733),
    ["SCP-023 (Black Shuck)"] = Vector3.new(-249, 3, -749),
    ["SCP-076 (Able)"] = Vector3.new(-3, 3, -1011),
    ["SCP-079 (Old AI)"] = Vector3.new(106, 4, -718),
    ["SCP-966 (Sleep Killer)"] = Vector3.new(-12, 3, -929)
}

for name, pos in pairs(ScpWaypoints) do
    TabTeleports:CreateButton({
        Name = "Chamber: " .. name,
        Callback = function()
            TeleportTo(pos)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Arrived at " .. name,
                Duration = 2
            })
        end,
    })
end

TabTeleports:CreateSection("Facility Sectors & Bases")

local FacilityWaypoints = {
    ["Class - D Containment (CDC)"] = Vector3.new(-14, 3, -859),
    ["Sector 1 Corridor"] = Vector3.new(64, 1, -606),
    ["Sector 2 Checkpoint"] = Vector3.new(-35, 3, -844),
    ["Sector 3 Heavy Containment"] = Vector3.new(-115, 3, -848),
    ["Control Room & Warhead"] = Vector3.new(-475, 2, -900),
    ["Chaos Insurgency Base"] = Vector3.new(301, 26, -858),
    ["Mobile Task Force Spawn"] = Vector3.new(-163, 46, -715),
    ["Surface Zone Exit"] = Vector3.new(100, 50, -400)
}

for name, pos in pairs(FacilityWaypoints) do
    TabTeleports:CreateButton({
        Name = "Sector: " .. name,
        Callback = function()
            TeleportTo(pos)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Arrived at " .. name,
                Duration = 2
            })
        end,
    })
end

-- ------------------------------------------
-- Tab 12: Staff & Security
-- ------------------------------------------
local TabStaff = Window:CreateTab("Staff & Security", 4483362458)
TabStaff:CreateSection("Moderator & Staff Detector")

TabStaff:CreateToggle({
    Name = "Staff Detector Alerts",
    CurrentValue = State.StaffDetector,
    Flag = "StaffDetector_Toggle",
    Callback = function(Value)
        State.StaffDetector = Value
    end,
})

TabStaff:CreateToggle({
    Name = "Anti-Invisible Aim Lock (Never Aim At Ghost/Vanish)",
    CurrentValue = State.AntiInvisibleLock,
    Flag = "AntiInvisibleLock_Toggle",
    Callback = function(Value)
        State.AntiInvisibleLock = Value
    end,
})

TabStaff:CreateToggle({
    Name = "Vanish & Spectator Real-Time Alert",
    CurrentValue = State.VanishDetector,
    Flag = "VanishDetector_Toggle",
    Callback = function(Value)
        State.VanishDetector = Value
    end,
})

TabStaff:CreateToggle({
    Name = "Auto Disable All Features on Staff Detect",
    CurrentValue = State.StaffAutoDisable,
    Flag = "StaffAutoDisable_Toggle",
    Callback = function(Value)
        State.StaffAutoDisable = Value
    end,
})

TabStaff:CreateToggle({
    Name = "Auto Leave Server on Staff Detect",
    CurrentValue = State.StaffAutoLeave,
    Flag = "StaffAutoLeave_Toggle",
    Callback = function(Value)
        State.StaffAutoLeave = Value
    end,
})

TabStaff:CreateSlider({
    Name = "Auto Leave Delay",
    Range = {0, 5},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = State.StaffLeaveDelay,
    Flag = "StaffLeaveDelay_Slider",
    Callback = function(Value)
        State.StaffLeaveDelay = Value
    end,
})

staffStatusLabel = TabStaff:CreateLabel("Status: Checking Server...")

TabStaff:CreateButton({
    Name = "Scan Server for Staff Now",
    Callback = function()
        local list = scanAllPlayersForStaff()
        if #list > 0 then
            Rayfield:Notify({
                Title = "Staff Scan Result",
                Content = string.format("Found %d staff member(s)!", #list),
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Staff Scan Result",
                Content = "No staff members found. Server is safe.",
                Duration = 3
            })
        end
    end,
})

TabStaff:CreateSection("Emergency Panic Actions")

TabStaff:CreateButton({
    Name = "Disable All Features Now (Panic)",
    Callback = function()
        PanicDisableAll()
        Rayfield:Notify({
            Title = "Panic Activated",
            Content = "All ESP, Combat, and Movement features have been disabled.",
            Duration = 4
        })
    end,
})

TabStaff:CreateButton({
    Name = "Emergency Disconnect (Leave Game)",
    Callback = function()
        PanicDisableAll()
        LocalPlayer:Kick("\n[MANUAL DISCONNECT]\nEmergency panic leave executed by user.")
    end,
})

TabStaff:CreateButton({
    Name = "Rejoin Current Server",
    Callback = function()
        local TS = game:GetService("TeleportService")
        if game.JobId ~= "" then
            TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        else
            TS:Teleport(game.PlaceId, LocalPlayer)
        end
    end,
})

-- ------------------------------------------
-- Tab: Tag Name (Game Ranks & Custom Overhead)
-- ------------------------------------------
local activeTagConnection = nil

local function GetEffectiveRankText()
    local rank = (State.CustomRankInput and State.CustomRankInput ~= "") and State.CustomRankInput or State.SelectedRank
    if State.TagBracket then
        return "[" .. rank .. "]"
    else
        return rank
    end
end

local function GetTagColorValues()
    if State.TagColor == "White" then return Color3.fromRGB(255, 255, 255), "#FFFFFF"
    elseif State.TagColor == "Cyan Blue" then return Color3.fromRGB(0, 195, 255), "#00C3FF"
    elseif State.TagColor == "Gold" then return Color3.fromRGB(255, 215, 0), "#FFD700"
    elseif State.TagColor == "Crimson" then return Color3.fromRGB(255, 60, 60), "#FF3C3C"
    elseif State.TagColor == "Green" then return Color3.fromRGB(80, 255, 80), "#50FF50"
    elseif State.TagColor == "Purple" then return Color3.fromRGB(180, 80, 255), "#B450FF"
    end
    return Color3.fromRGB(255, 255, 255), "#FFFFFF"
end

ApplyCustomTagName = function(targetChar)
    if not State.TagNameEnabled then return end
    targetChar = targetChar or LocalPlayer.Character
    if not targetChar then return end

    local rankText = GetEffectiveRankText()
    local col3, hexCol = GetTagColorValues()

    local function applyToTag(tag)
        if not tag then return false end
        if State.TagPlacement == "Prefix Name" then
            local userLabel = tag:FindFirstChild("User")
            if userLabel and userLabel:IsA("TextLabel") then
                local isRich = (State.TagColor ~= "White")
                local target = isRich and string.format("<font color='%s'>%s</font> %s", hexCol, rankText, LocalPlayer.DisplayName) or (rankText .. " " .. LocalPlayer.DisplayName)

                userLabel.RichText = isRich
                userLabel.TextColor3 = col3
                userLabel.Text = target

                local back = userLabel:FindFirstChild("Back")
                if back and back:IsA("TextLabel") then
                    back.RichText = isRich
                    back.Text = target
                end

                if activeTagConnection then
                    pcall(function() activeTagConnection:Disconnect() end)
                    activeTagConnection = nil
                end
                activeTagConnection = userLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    if userLabel.Text ~= target then
                        userLabel.RichText = isRich
                        userLabel.TextColor3 = col3
                        userLabel.Text = target
                    end
                end)
                table.insert(Connections, activeTagConnection)
                return true
            end
        elseif State.TagPlacement == "Replace Role" then
            local teamLabel = tag:FindFirstChild("Team")
            if teamLabel and teamLabel:IsA("TextLabel") then
                local isRich = (State.TagColor ~= "White")
                teamLabel.RichText = isRich
                teamLabel.TextColor3 = col3
                teamLabel.Text = rankText

                local back = teamLabel:FindFirstChild("Back")
                if back and back:IsA("TextLabel") then
                    back.RichText = isRich
                    back.Text = rankText
                end

                if activeTagConnection then
                    pcall(function() activeTagConnection:Disconnect() end)
                    activeTagConnection = nil
                end
                activeTagConnection = teamLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    if teamLabel.Text ~= rankText then
                        teamLabel.RichText = isRich
                        teamLabel.TextColor3 = col3
                        teamLabel.Text = rankText
                    end
                end)
                table.insert(Connections, activeTagConnection)
                return true
            end
        end
        return false
    end

    -- Immediate attempt
    local head = targetChar:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("Tag")
    if tag then
        applyToTag(tag)
    end

    -- Asynchronous watcher for Character Respawn / Delayed Tag Creation
    task.spawn(function()
        local h = targetChar:WaitForChild("Head", 15)
        if not h then return end

        local tagAddedConn = h.ChildAdded:Connect(function(child)
            if child.Name == "Tag" then
                task.wait(0.2)
                applyToTag(child)
            end
        end)
        table.insert(Connections, tagAddedConn)

        -- Multi-phase retries (0.3s, 0.8s, 1.8s, 3.2s) to override game LocalTagHandler after respawn
        for _, delayTime in ipairs({0.3, 0.8, 1.8, 3.2}) do
            task.wait(delayTime)
            if not State.TagNameEnabled or LocalPlayer.Character ~= targetChar then break end
            local curTag = h:FindFirstChild("Tag")
            if curTag then
                applyToTag(curTag)
            end
        end
    end)

    -- Sync Chat Prefix
    if State.SyncChatPrefix then
        pcall(function()
            TextChatService.OnIncomingMessage = function(message)
                local props = Instance.new("TextChatMessageProperties")
                if message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
                    if State.TagColor ~= "White" then
                        props.PrefixText = string.format("<font color='%s'>%s</font> %s", hexCol, rankText, (message.PrefixText or ""))
                    else
                        props.PrefixText = rankText .. " " .. (message.PrefixText or "")
                    end
                end
                return props
            end
        end)
    end
end

-- Automatic Watcher on Respawn / Death
local tagCharAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    if State.TagNameEnabled and type(ApplyCustomTagName) == "function" then
        task.spawn(function()
            task.wait(0.5)
            ApplyCustomTagName(newChar)
        end)
    end
end)
table.insert(Connections, tagCharAddedConn)

local function ResetCustomTagName()
    if activeTagConnection then
        pcall(function() activeTagConnection:Disconnect() end)
        activeTagConnection = nil
    end

    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("Tag")
    if tag then
        local userLabel = tag:FindFirstChild("User")
        if userLabel and userLabel:IsA("TextLabel") then
            userLabel.RichText = false
            userLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            userLabel.Text = LocalPlayer.DisplayName
            local back = userLabel:FindFirstChild("Back")
            if back then back.Text = LocalPlayer.DisplayName end
        end

        local teamLabel = tag:FindFirstChild("Team")
        if teamLabel and teamLabel:IsA("TextLabel") then
            local origTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "Class - D"
            teamLabel.RichText = false
            teamLabel.TextColor3 = Color3.fromRGB(255, 176, 0)
            teamLabel.Text = origTeam
            local back = teamLabel:FindFirstChild("Back")
            if back then back.Text = origTeam end
        end
    end

    pcall(function()
        TextChatService.OnIncomingMessage = nil
    end)
end

local TabTagName = Window:CreateTab("Tag Name", 4483362458)
TabTagName:CreateSection("Custom Rank & Overhead Name Tag")

TabTagName:CreateToggle({
    Name = "Enable Custom Tag Name",
    CurrentValue = State.TagNameEnabled,
    Flag = "TagNameEnabled_Toggle",
    Callback = function(Value)
        State.TagNameEnabled = Value
        if Value then
            ApplyCustomTagName()
            Rayfield:Notify({
                Title = "Tag Name Enabled",
                Content = "Custom tag applied: " .. GetEffectiveRankText(),
                Duration = 3
            })
        else
            ResetCustomTagName()
            Rayfield:Notify({
                Title = "Tag Name Disabled",
                Content = "Restored original game name & rank.",
                Duration = 3
            })
        end
    end,
})

TabTagName:CreateDropdown({
    Name = "Preset Game Ranks",
    Options = {
        "Trial Moderator",
        "Game Moderator",
        "Senior Moderator",
        "Head Moderator",
        "Developer",
        "Project Manager",
        "Coordinator",
        "Administrator",
        "O5-1",
        "O5-5",
        "O5-13",
        "Delta Command",
        "Head Commander",
        "Commander",
        "Task Force Leader",
        "Internal Security Manager",
        "General",
        "Medical Director",
        "Lead Researcher",
        "VIP"
    },
    CurrentOption = {State.SelectedRank},
    Flag = "SelectedRank_Dropdown",
    Callback = function(Option)
        State.SelectedRank = type(Option) == "table" and Option[1] or Option
        if State.TagNameEnabled then
            ApplyCustomTagName()
        end
    end,
})

TabTagName:CreateInput({
    Name = "Custom Rank Input",
    PlaceholderText = "e.g. Owner, Director or leave blank for preset...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        State.CustomRankInput = Text
        if State.TagNameEnabled then
            ApplyCustomTagName()
        end
    end,
})

TabTagName:CreateDropdown({
    Name = "Tag Placement",
    Options = {"Prefix Name", "Replace Role"},
    CurrentOption = {State.TagPlacement},
    Flag = "TagPlacement_Dropdown",
    Callback = function(Option)
        State.TagPlacement = type(Option) == "table" and Option[1] or Option
        if State.TagNameEnabled then
            ResetCustomTagName()
            ApplyCustomTagName()
        end
    end,
})

TabTagName:CreateToggle({
    Name = "Include Brackets [ ]",
    CurrentValue = State.TagBracket,
    Flag = "TagBracket_Toggle",
    Callback = function(Value)
        State.TagBracket = Value
        if State.TagNameEnabled then
            ApplyCustomTagName()
        end
    end,
})

TabTagName:CreateDropdown({
    Name = "Tag Color",
    Options = {"White", "Cyan Blue", "Gold", "Crimson", "Green", "Purple"},
    CurrentOption = {State.TagColor},
    Flag = "TagColor_Dropdown",
    Callback = function(Option)
        State.TagColor = type(Option) == "table" and Option[1] or Option
        if State.TagNameEnabled then
            ApplyCustomTagName()
        end
    end,
})

TabTagName:CreateToggle({
    Name = "Sync with Chat Prefix",
    CurrentValue = State.SyncChatPrefix,
    Flag = "SyncChatPrefix_Toggle",
    Callback = function(Value)
        State.SyncChatPrefix = Value
        if State.TagNameEnabled then
            ApplyCustomTagName()
        end
    end,
})

TabTagName:CreateSection("Quick Actions")

TabTagName:CreateButton({
    Name = "Apply Tag Now",
    Callback = function()
        ApplyCustomTagName()
        Rayfield:Notify({
            Title = "Tag Applied",
            Content = "Applied: " .. GetEffectiveRankText() .. " " .. LocalPlayer.DisplayName,
            Duration = 3
        })
    end,
})

TabTagName:CreateButton({
    Name = "Reset to Default",
    Callback = function()
        ResetCustomTagName()
        Rayfield:Notify({
            Title = "Tag Reset",
            Content = "Reset to original name & team.",
            Duration = 3
        })
    end,
})


local crouchToggle = false
local discoHue = 0

local steppedConn = RunService.Stepped:Connect(function(t, dt)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Noclip
    if State.Noclip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end

    -- Spinbot
    if State.Spinbot and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed * 0.4), 0)
    end

    -- Float
    if State.FloatLevitate and root then
        root.Velocity = Vector3.new(root.Velocity.X, 1.2, root.Velocity.Z)
    end
end)
table.insert(Connections, steppedConn)

local crouchTimer = 0
local renderConn = RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Aimbot Loop
    if State.Aimbot then
        local isAiming = false
        if State.AimbotKey == "Hold Right Click (RMB)" then
            isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif State.AimbotKey == "Hold Left Click (LMB)" then
            isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif State.AimbotKey == "Always On" then
            isAiming = true
        elseif State.AimbotKey == "While Shooting / Mobile Touch" then
            isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) 
                or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                or (UserInputService.TouchEnabled and #UserInputService:GetTouches() > 0)
        end

        if isAiming then
            local target = GetClosestAimbotTarget()
            if target and target.Part then
                if target.Player and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
                    LastShotTarget = target.Player
                    LastShotTime = tick()
                end
                local camPos = Camera.CFrame.Position
                local targetCFrame = CFrame.new(camPos, target.Part.Position)
                if State.AimbotSmoothness <= 1 then
                    Camera.CFrame = targetCFrame
                else
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / State.AimbotSmoothness)
                end
            end
        end
    end

    -- Triggerbot Loop
    if State.Triggerbot then
        CheckTriggerbot()
    end

    -- FOV Circle Position
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if fovCircle then
        fovCircle.Position = center
        fovCircle.Radius = State.AimbotFOV
        fovCircle.Visible = State.Aimbot and State.AimbotDrawFOV
    end
    if silentFovCircle then
        silentFovCircle.Position = center
        silentFovCircle.Radius = State.SilentAimFOV
        silentFovCircle.Visible = State.SilentAim and State.SilentAimDrawFOV
    end

    -- Teabag Crouch
    if State.CrouchSpam and hum then
        crouchTimer = crouchTimer + dt
        if crouchTimer >= 0.12 then
            crouchTimer = 0
            crouchToggle = not crouchToggle
            hum.CameraOffset = crouchToggle and Vector3.new(0, -1.5, 0) or Vector3.new(0, 0, 0)
        end
    end

    -- Auto Look at 173
    if State.AutoLook173 and root and Workspace:FindFirstChild("SCPs") then
        local peanut = Workspace.SCPs:FindFirstChild("SCP-173")
        local pPart = peanut and (peanut.PrimaryPart or peanut:FindFirstChildWhichIsA("BasePart"))
        if pPart and (pPart.Position - root.Position).Magnitude < 65 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pPart.Position)
        end
    end

    -- Avoid Looking at 096
    if State.AvoidLook096 and root and Workspace:FindFirstChild("SCPs") then
        local shyGuy = Workspace.SCPs:FindFirstChild("SCP-096")
        local head = shyGuy and shyGuy:FindFirstChild("Head")
        if head and (head.Position - root.Position).Magnitude < 65 then
            local toHead = (head.Position - Camera.CFrame.Position).Unit
            local dot = Camera.CFrame.LookVector:Dot(toHead)
            if dot > 0.3 then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Vector3.new(Camera.CFrame.LookVector.X, -1.2, Camera.CFrame.LookVector.Z))
            end
        end
    end

    -- Disco Lights
    if State.DiscoLights then
        discoHue = (discoHue + dt * 0.6) % 1
        Lighting.Ambient = Color3.fromHSV(discoHue, 0.85, 1)
        Lighting.OutdoorAmbient = Color3.fromHSV(discoHue, 0.85, 1)
    end

    -- Rainbow Chroma Gun Skin
    local curStyle = type(State.GunSkinStyle) == "table" and State.GunSkinStyle[1] or State.GunSkinStyle
    if State.SkinChangerEnabled and curStyle == "Rainbow Chroma" then
        chromaHue = (chromaHue + dt * 0.5) % 1
        local chromaColor = Color3.fromHSV(chromaHue, 0.9, 1)
        local equippedTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if equippedTool then
            for _, p in ipairs(equippedTool:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "LaserCast" and p.Transparency < 0.9 then
                    p.Color = chromaColor
                end
            end
            local hl = equippedTool:FindFirstChild("SkinChanger_Highlight")
            if hl then
                hl.FillColor = chromaColor
                hl.OutlineColor = chromaColor
            end
        end
    end

    -- Dynamic Modular Drawing ESP
    pcall(UpdateDrawingESP)
end)
table.insert(Connections, renderConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(p)
    pcall(RemovePlayerDrawings, p)
    if detectedStaff[p] then
        detectedStaff[p] = nil
        pcall(scanAllPlayersForStaff)
    end
end)
table.insert(Connections, playerRemovingConn)

local playerStaffConn = Players.PlayerAdded:Connect(function(p)
    table.insert(StaffCheckQueue, p)
    ProcessStaffCheckQueue()
    pcall(scanAllPlayersForStaff)
end)
table.insert(Connections, playerStaffConn)

local promptConn = Workspace.DescendantAdded:Connect(function(obj)
    if State.InstantPrompts and obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)
table.insert(Connections, promptConn)

-- Periodic Heartbeat Loop (0.2s for GhostDoors, 0.8s for ESP, 2.5s for Staff)
local timer = 0
local ghostTimer = 0
local staffTimer = 0
local heartbeatConn = RunService.Heartbeat:Connect(function(dt)
    ghostTimer = ghostTimer + dt
    if ghostTimer >= 0.2 then
        ghostTimer = 0
        pcall(UpdateGhostDoors)
    end

    staffTimer = staffTimer + dt
    if staffTimer >= 2.5 then
        staffTimer = 0
        pcall(scanAllPlayersForStaff)
    end

    timer = timer + dt
    if timer >= 0.8 then
        timer = 0
        pcall(UpdatePlayerESP)
        pcall(UpdateScpESP)
        pcall(UpdateItemESP)
        pcall(ApplyInstantPrompts)
    end
end)
table.insert(Connections, heartbeatConn)

-- Cleanup Handler
_G.SCP_RAYFIELD_CLEANUP = function()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, h in pairs(Highlights) do pcall(function() h:Destroy() end) end
    for _, b in pairs(Billboards) do pcall(function() b:Destroy() end) end
    for _, h in pairs(ItemHighlights) do pcall(function() h:Destroy() end) end
    for p, d in pairs(PlayerDrawings) do
        if d then
            for _, obj in pairs(d) do
                pcall(function() obj:Remove() end)
            end
        end
    end
    PlayerDrawings = {}
    if fovCircle then
        pcall(function() fovCircle:Remove() end)
    end
    if silentFovCircle then
        pcall(function() silentFovCircle:Remove() end)
    end
    for part, orig in pairs(GhostModifiedParts) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = orig.CanCollide
                part.Transparency = orig.Transparency
            end)
        end
    end
    pcall(function()
        Lighting.Brightness = OrigLighting.Brightness
        Lighting.ClockTime = OrigLighting.ClockTime
        Lighting.FogEnd = OrigLighting.FogEnd
        Lighting.GlobalShadows = OrigLighting.GlobalShadows
        Lighting.Ambient = OrigLighting.Ambient
        Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
    end)
    local hui = (gethui and gethui()) or game:GetService("CoreGui")
    if hui and hui:FindFirstChild("Rayfield") then
        pcall(function() hui.Rayfield:Destroy() end)
    end
end

-- Initialize Spy Chat Listeners & Force Enable Chat Box
InitSpyChatListeners()

-- Apply initial states
SetFullbright(State.Fullbright)
ApplyInstantPrompts()
task.spawn(scanAllPlayersForStaff)
task.spawn(HookToolEquip)
if State.TagNameEnabled then
    task.spawn(function()
        task.wait(1)
        pcall(ApplyCustomTagName)
    end)
end

FormatAndDisplaySpyMessage("[SPY SYSTEM]", "#00FF66", "Status", "#80D8FF", "Site-76 Intelligence", "Roblox Chat Box is forced OPEN. Combat, Modular ESP, Skin Changer & Staff Detector active!")

Rayfield:Notify({
    Title = "Site-76 Suite Ready",
    Content = "Skin Changer, Modular ESP, Combat & Staff Detector active!",
    Duration = 5
})

return "Rayfield Suite (Skin Changer & Security Edition) initialized successfully!"

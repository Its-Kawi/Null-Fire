local cons = { }
local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 78, 117, 108, 108, 45, 67, 104, 101, 114, 114, 121, 47, 85, 116, 105, 108, 105, 116, 105, 101, 115, 47, 114, 101, 102, 115, 47, 104, 101, 97, 100, 115, 47, 109, 97, 105, 110, 47, 85, 116, 105, 108, 105, 116, 121, 47, 77, 97, 105, 110, 46, 108, 117, 97)))() end)()
local window = util:NullFireWindow()
local esp = util:ESP()
local fire = util:Fire()
local other = util:Other()
local event = util:Event()
local physics = util:Physics()
local pipes = util:PressureTubePuzzle()

local fpp, fti, touch = fire.fireproximityprompt, fire.firetouchinterest, fire.touchpart

esp:InitClass("Keycard", { Color = Color3.fromRGB(170, 170, 255) })
esp:InitClass("Item", { Color = Color3.fromRGB(255, 85, 255) })
esp:InitClass("Currency", { Color = Color3.fromRGB(85, 255, 255) })
esp:InitClass("Door", { Color = Color3.fromRGB(0, 170, 255) })
esp:InitClass("Node Monster", { Color = Color3.fromRGB(255, 60, 25) })
esp:InitClass("Monster", { Color = Color3.fromRGB(255, 100, 10) })
esp:InitClass("Weak Monster", { Color = Color3.fromRGB(255, 101, 62) })
esp:InitClass("Fake Object", { Color = Color3.fromRGB(116, 93, 193) })
esp:InitClass("Hazard", { Color = Color3.fromRGB(150, 10, 40) })
esp:InitClass("Generator", { Color = Color3.fromRGB(150, 150, 150) })
esp:InitClass("Interactable", { Color = Color3.fromRGB(255, 170, 127) })

local values = {
	Visual = {
		NoPopups = false,
		AntiCameraFlip = false,

		Debug = false,
		DebugObjects = false
	},
	
	Debug = {
		ShowPipePuzzle = false
	},

	Notify = {
		NodeMonsters = false,
		InChat = false,

		ChatRandomDelay = 0,
		ChatFormat = "<Monster> has spawned!",

		Monsters = false
	},

	Automation = {
		NeoStyk = false,
		Medkit = false,
		HealthBoost = false,

		FixGenerators = false,
		TeleportToGenerators = false,

		DisarmHazards = false,

		Hide = false,
		UseLockers = false,
		TeleportToLocker = false,
		InstantHide = false,

		PullSwitches = false,
		
		SolvePipePuzzle = false,
		PlaySolvedSolution = false
	},

	Other = {
		BetterDoors = false,
		InfiniteOxygen = false,
	},

	AutoPick = {
		Enabled = false,

		LightSources = false,
		Currency = false,
		Items = false,
		Keycards = false
	},

	Anti = {
		Eyefestation = false,
		Searchlights = false,
		Pandemonium = false,
		Harbinger = false,
		Friend = false,
		DamageParts = false,
		Turret = false,
		Parasites = false,
		Fog = false,
		Coagulate = false,
		GOM = false,
		EdenTree = false,
		Lopee = false,
		Skinless = false,
		WitchingHour = false,
		Squiddle = false,
		MonsterLocker = false,
		GoodPeople = false,
		DiVine = false,
		HotPotato = false,
		NoGood = false,
		WallDweller = false,
		KittyClock = false,
		Fish = false,
		Pipsqueak = false,
		Bottomfeeder = false,
		LockerClaustrophobia = false,
		
		Damage = false,
		ADs = false
	}
}

while not game:IsLoaded() do wait() end

local playerSpoofer = physics.Spoofer:SpoofPlayer()
playerSpoofer.Enabled = false
playerSpoofer.OffsetCFrame = nil

local insert, remove, find = table.insert, table.remove, table.find
local spawn = task.spawn
local max, min = math.max, math.min
local tick = tick
local wait = task.wait
local random, round = math.random, math.round
local v3 = vector.create
local typeof = typeof
local env = (getfenv().getgenv or getfenv)()

local hookfunc, hookmeta = env.hookfunction, env.hookmetamethod
local hookmetamethod, hookfunction

local hooksEnabled = false
local namecall = env.getnamecallmethod

local isObfuscated do local _p=newproxy(true)local _m=getmetatable(_p)_m.__namecall=function()return true;end;_m.__index=function()return pcall;end;isObfuscated=_p:_()~=true end
local isLuaVM = isObfuscated
local hooks = { }

if hookfunc and hookmeta and namecall and not isLuaVM then
	local test = function() return false end
	local old = hookfunc(test, function() return true end)
	
	hooksEnabled = test() == true and old() == false
end

if hooksEnabled then
	hookfunction = function(a, b)
		local old; old = hookfunc(a, function(...) return b(old, ...) end)
		hooks[a] = old
	end
	
	hookmetamethod = function(a, b)
		local old;
		local fc = function(self, ...) return b(self, old, ...) end
		old = hookmeta(game, a, fc)
		
		hooks[fc] = old
	end
else
	hookfunction = function() end
	hookmetamethod = hookfunction
end

local plr = game:GetService("Players").LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")
local general = game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local rs = game:GetService("RunService")
local mainGui = pgui:WaitForChild("Main")
local pfolder = plr:WaitForChild("PlayerFolder")

local rstorage = game:GetService("ReplicatedStorage")
local shakeOff = rstorage:FindFirstChild("ParasiteShakeOff", true)
local itemsRFolder = rstorage:WaitForChild("Items")
local eventsRFolder = rstorage:WaitForChild("Events")
local assetsRFolder = rstorage:WaitForChild("Assets")
local equipableItems = rstorage:WaitForChild("EquipableItems")
local gameSettingsRFolder = rstorage:WaitForChild("GameSettings")

local remoteHooks = {
	AdBreak = { "ADs",
		function(...) return true end
	},
	LocalDamage = { "Damage",
		function(...) return end
	}
}

local namecallMethods = {
	RemoteEvent = "FireServer",
	UnreliableRemoteEvent = "FireServer",
	RemoteFunction = "InvokeServer"
}

local ping = plr:GetNetworkPing()
hookmetamethod("__namecall", function(self, old, ...)
	if self.Parent ~= eventsRFolder then return old(self, ...) end

	local ncm = namecallMethods[self.ClassName]
	if not ncm then return old(self, ...) end
	
	local rh = remoteHooks[self.Name]
	if not rh or not values.Anti[rh[1]] then return old(self, ...) end
	
	local method = namecall()
	method = method:sub(1, 1):upper() .. method:sub(2)
	
	if method ~= ncm then return old(self, ...) end
	if method == "InvokeServer" then
		wait(ping / 4)
	end
	
	return rh[2](...)
end)

local gameSettings = { }
for i, v in gameSettingsRFolder:GetChildren() do
	if v.ClassName:match("Value") then
		gameSettings[v.Name] = v.Value
	end
end

local nodeMonsterSpawned = event.new()
local monsterSpawned = event.new()

local roomsFolder = workspace:WaitForChild("GameplayFolder"):WaitForChild("Rooms")
local allRooms = roomsFolder:GetChildren()
local traversalOrder = { }
local lastDoor = nil
local lastRoom = nil
local previousRoom = nil

local clone = function(tbl)
	local copy = { }

	for i, v in tbl do
		copy[i] = v
	end

	return copy
end

if #allRooms > 0 then
	local hasEntrances = { } -- true for ignoring invalid rooms
	for i, v in allRooms do
		if v:FindFirstChild("Entrances") then
			local door = v.Entrances:GetChildren()[1]
			if door then
				local me = hasEntrances[v]
				if me == nil then
					hasEntrances[v] = false
				end

				local exit = door:FindFirstChild("Exit")
				if exit and exit.Value then
					hasEntrances[exit.Value] = true
				else
					hasEntrances[v] = true
				end
			else
				hasEntrances[v] = true
			end
		else
			hasEntrances[v] = true
		end
	end

	for i, v in hasEntrances do
		if v == false then
			lastRoom = i
			break
		end
	end

	if lastRoom then
		lastDoor = lastRoom.Entrances:GetChildren()[1]
		previousRoom = lastDoor.Exit.Value

		local current = lastRoom
		local i = 0

		while current and current:IsDescendantOf(workspace) do
			local door = current:FindFirstChild("Entrances") and current.Entrances:GetChildren()[1]
			if not door or not door:FindFirstChild("Exit") or not door:FindFirstChild("Enter") then
				break
			end

			traversalOrder[door.Enter.Value] = i
			current = door.Exit.Value

			i += 1
		end
	end
end

local roomNum = -1

local endingRoomNames = {
	["ModifierEnding"] = true
}

local code = nil
cons[#cons + 1] = roomsFolder.ChildAdded:Connect(function(room)
	previousRoom = lastRoom
	lastRoom = (previousRoom and not endingRoomNames[previousRoom.Name] or not previousRoom) and room or previousRoom
	code = nil
end)

window = window(cons, ...)
spawn(function()
	window:Notification({ Title = "Beta", Text = "Warning: That script is in active development! More functions are coming soon!\n\nSome functions are not implemented:\nAuto Hide In Lockers\nTeleport to Lockers", Duration = 30, HasButtons = true })
end)
			
local anti = window:AddTab("B", { Text = "Bypasses", Icon = "l://shield" })
local antiL = anti:AddLeftGroupbox("R", { Text = "Regular Monsters" })
local gmFuncs = { }

gmFuncs[#gmFuncs + 1] = antiL:AddToggle("0", { Text = "Anti Eyefestation", Callback = function(val)
	values.Anti.Eyefestation = val
end })
antiL:AddToggle("1", { Text = "Anti Imaginary Friend", Callback = function(val)
	values.Anti.Friend = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("2", { Text = "Anti Searchlights", Callback = function(val)
	values.Anti.Searchlights = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("3", { Text = "Anti Lopee", Callback = function(val)
	values.Anti.Lopee = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("4", { Text = "Anti Squiddle", Callback = function(val)
	values.Anti.Squiddle = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("5", { Text = "Anti Monster Locker", Tooltip = "Aka. Anti Void Mass", Callback = function(val)
	values.Anti.MonsterLocker = val
end })
antiL:AddToggle("6", { Text = "Anti Fake Door", Tooltip = "Aka. Anti Good People", Callback = function(val)
	values.Anti.GoodPeople = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("7", { Text = "Anti DiVine", Tooltip = "Deletes the guy who always touches grass", Callback = function(val)
	values.Anti.DiVine = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("8", { Text = "Anti Coagulate", Tooltip = "Thats this one walking nerves guy", Callback = function(val)
	values.Anti.Coagulate = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("9", { Text = "Anti Wall Dweller", Tooltip = "Those guys ruined me really lot games", Callback = function(val)
	values.Anti.WallDweller = val
end })
gmFuncs[#gmFuncs + 1] = antiL:AddToggle("A", { Text = "Anti Bottomfeeder", Tooltip = "Aka. Anti Fish", Callback = function(val)
	values.Anti.Bottomfeeder = val
end })

local antiR = anti:AddRightGroupbox("N", { Text = "Node Monsters" })
gmFuncs[#gmFuncs + 1] = antiR:AddToggle("1", { Text = "Anti Pandemonium", Callback = function(val)
	values.Anti.Pandemonium = val
end })
gmFuncs[#gmFuncs + 1] = antiR:AddToggle("2", { Text = "Anti Harbinger", Tooltip = "Aka. Anti Death Angel", Callback = function(val)
	values.Anti.Harbinger = val
end })
gmFuncs[#gmFuncs + 1] = antiR:AddToggle("3", { Text = "Anti Witching Hour", Tooltip = "Yay, I can play at 3 AM", Callback = function(val)
	values.Anti.WitchingHour = val
end })

local anti2 = anti:AddLeftGroupbox("O", { Text = "Other" })
gmFuncs[#gmFuncs + 1] = anti2:AddToggle("1", { Text = "Anti Damaging Parts", Callback = function(val)
	values.Anti.DamageParts = val
end })
gmFuncs[#gmFuncs + 1] = anti2:AddToggle("3", { Text = "Anti Turret", Callback = function(val)
	values.Anti.Turret = val
end })
gmFuncs[#gmFuncs + 1] = anti2:AddToggle("4", { Text = "Anti Parasites", Callback = function(val)
	values.Anti.Parasites = val
end })
gmFuncs[#gmFuncs + 1] = anti2:AddToggle("5", { Text = "Infinite Oxygen", Callback = function(val)
	values.Other.InfiniteOxygen = val
end })

local events = anti:AddLeftGroupbox("E", { Text = "Events" })
events:AddLabel({ Text = "This one is just going to make your life bit easier" })
events:AddToggle("1", { Text = "Anti Invert Movement", Callback = function(val, self)
	while workspace.DistributedGameTime < 20 or not game:IsLoaded() do wait() end

	local pscr = plr:FindFirstChildOfClass("PlayerScripts") or plr:WaitForChild("PlayerScripts")
	if self.Value then	
		local pm = pscr:FindFirstChild("PlayerModule")
		if pm then
			pm.Name = "NotPlayerModule"
		end
	else
		local pm = pscr:FindFirstChild("NotPlayerModule")
		if pm then
			pm.Name = "PlayerModule"
		end
	end
end })
gmFuncs[#gmFuncs + 1] = events:AddToggle("2", { Text = "Anti Hot Potato", Callback = function(val)
	values.Anti.HotPotato = val
end })

local modifierOnly = anti:AddRightGroupbox("M", { Text = "Modifier Only" })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("1", { Text = "Anti GOM", Callback = function(val)
	values.Anti.GOM = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("2", { Text = "Anti Eden Tree", Callback = function(val)
	values.Anti.EdenTree = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("3", { Text = "Anti Skinless", Callback = function(val)
	values.Anti.Skinless = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("4", { Text = "Anti No Good", Tooltip = "I HATE THIS GUY SO MUCH</b>", Callback = function(val)
	values.Anti.NoGood = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("5", { Text = "Anti Kitty Clock", Callback = function(val)
	values.Anti.KittyClock = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("6", { Text = "Anti Fish", Tooltip = "No, thats not about bottomfeeder", Callback = function(val)
	values.Anti.Fish = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("7", { Text = "Anti Pipsqueak", Callback = function(val)
	values.Anti.Pipsqueak = val
end })
gmFuncs[#gmFuncs + 1] = modifierOnly:AddToggle("8", { Text = "Anti A200", Callback = function(val)
	values.Anti.A200 = val
end })

local experemental = anti:AddRightGroupbox("EX", { Text = "Experemental" })
experemental:AddLabel({ Text = "Most of functions require high level executors, so they won't work on Solara / Xeno / JJSploit\nAlso those functions are <b>experemental</b>, means that they MIGHT cause issues. <b><font color=\"#F00\">Use at your own risk!</font></b>" })
experemental:AddToggle({
	Text = "Bypass ADs",
	Tooltip = "ADs will no longer show up, but you will recieve rewards.\nThis can be used to turn into a ghost by clicking the AD button without having to watch it",
	DisabledTooltip = "Your executor does not support that function!",
	Disabled = not hooksEnabled,
	Callback = function(val)
		values.Anti.ADs = val
	end
})

gmFuncs[#gmFuncs + 1] = experemental:AddToggle({
	Text = "Anti Damage",
	DisabledTooltip = "Your executor does not support that function!",
	Disabled = not hooksEnabled,
	Callback = function(val)
		values.Anti.Damage = val
	end
})

anti:AddButton({
	Text = "<b>GOD MODE</b>",
	Tooltip = "This one is only enabling bunch of functions, nothing special",
	Callback = function()
		for i, v in gmFuncs do
			if not v.Disabled then
				v:Set(true)
			end
		end
		
		window:Notification({ Title = "God Mode", Text = "Needed functions for immortality have been enabled!\nEnjoy being untouchable!" })
	end
})

local automation = window:AddTab("A", { Text = "Automation", Icon = "flame" })
local ahealth = automation:AddLeftGroupbox("C", { Text = "Health" })
ahealth:AddToggle("1", { Text = "Auto use NeoStyk", Callback = function(val)
	values.Automation.NeoStyk = val
end })
ahealth:AddToggle("2", { Text = "Auto use Medkit", Callback = function(val)
	values.Automation.Medkit = val
end })
ahealth:AddToggle("3", { Text = "Auto use Health Boost", Callback = function(val)
	values.Automation.HealthBoost = val
end })

local safety = automation:AddRightGroupbox("S", { Text = "Safety" })
gmFuncs[#gmFuncs + 1] = safety:AddToggle("1", { Text = "Auto Disarm Hazards", Tooltip = "Disarms Landmines and Tripwires", Callback = function(val)
	values.Automation.DisarmHazards = val
end })

local generatorInteracts = automation:AddRightGroupbox("G", { Text = "Generators" })
generatorInteracts:AddToggle("1", { Text = "Auto Fix Generators", Value = false, Callback = function(val)
	values.Automation.FixGenerators = val
end })

local hiding = automation:AddLeftGroupbox("H", { Text = "Hiding" })
gmFuncs[#gmFuncs + 1] = hiding:AddToggle("1", { Text = "Auto Hide", Tooltip = "No, it does work. Enemies won't attack you, if you're not using the locker mode", Value = false, Callback = function(val)
	values.Automation.Hide = val
end })
gmFuncs[#gmFuncs + 1] = hiding:AddToggle("2", { Text = "Auto Hide Instant Teleport", Tooltip = "Teleports you to the sky right after an entity spawns, without waiting until the entity reaches you\n<b>This function SHOULD be enabled, if you have internet issues</b>", Value = false, Callback = function(val)
	values.Automation.InstantHide = val
end })

hiding:AddToggle("3", { Text = "Use Lockers for Auto Hide", Value = false, Callback = function(val)
	values.Other.UseLockers = val
end })
hiding:AddToggle("4", { Text = "Teleport to Lockers", Value = false, Callback = function(val)
	values.Other.TeleportToLocker = val
end })

local looting = automation:AddRightGroupbox("L", { Text = "Interactions" })
looting:AddToggle("1", { Text = "Auto Loot", Value = false, Callback = function(val)
	values.AutoPick.Enabled = val
end })

local valuesReformed = { }
for i in values.AutoPick do
	if i ~= "Enabled" then
		insert(valuesReformed, other:Smart(i))
	end
end

looting:AddDropdown("2", { Text = "Allowed Loot List", Values = valuesReformed, Multi = true, Callback = function(vals)
	for i, v in vals do
		values.AutoPick[i:gsub(" ", "")] = v
	end
end })

looting:AddSeparator()
looting:AddToggle("3", { Text = "Auto Pull Switches", Value = false, Callback = function(val)
	values.Automation.PullSwitches = val
end })

looting:AddHeader({ Text = "Pipe Puzzle" })
looting:AddToggle("4", { Text = "Auto Find Solution", Value = false, Callback = function(val)
	values.Automation.SolvePipePuzzle = val
	values.Debug.ShowPipePuzzle = val
end })
looting:AddToggle("5", { Text = "Auto Play Solution", Value = false, Callback = function(val)
	values.Automation.PlaySolvedSolution = val
end })

local notifs = window:AddTab("N", { Text = "Notifications", Icon = "UI" })
notifs:AddToggle("1", { Text = "Notify Monsters", Callback = function(val)
	values.Notify.Monsters = val
end })
notifs:AddToggle("2", { Text = "Notify Node Monsters", Callback = function(val)
	values.Notify.NodeMonsters = val
end })
notifs:AddHeader({ Text = "Chat Notification" })
notifs:AddToggle("3", { Text = "Notify Node Monsters in Chat", Callback = function(val)
	values.Notify.InChat = val
end })
notifs:AddSlider("4", { Text = "Chat Notification random delay", Min = 0, Max = 10, Step = 0.1, Value = values.Notify.ChatRandomDelay, Callback = function(val)
	values.Notify.ChatRandomDelay = val
end })
notifs:AddTextBox("5", { Text = "Chat Notification Format", PlaceholderText = values.Notify.ChatFormat, ValueUsesPlaceholder = true, Instant = true, MultiLine = true, Value = values.Notify.ChatFormat, Callback = function(val)
	values.Notify.ChatFormat = val
end, Tooltip = "<Monster> for Monster's name (Angler)\n<monster> for lowercase Monster's name (angler)\n<MONSTER> for uppercase (ANGLER)" })

local interact = window:AddTab("I", { Text = "Interactions", Icon = "list-plus" })
local prompts = interact:AddLeftGroupbox("P", { Text = "Proximity Prompts" })
local instant = prompts:AddToggle("I", { Text = "Instant Interact", Tooltip = "You would no longer to hold E", Value = false })
prompts:AddToggle("D", { Text = "Better Doors", Tooltip = "Makes it easier to open doors", Value = false, Callback = function(val)
	values.Other.BetterDoors = val
end })

local dummy = Instance.new("Model")
local char = plr.Character or dummy
local charPos = char:GetPivot()
local spoofedCharPos = char:GetPivot()
local camera = workspace.CurrentCamera or Instance.new("Camera")
local yxz = CFrame.fromEulerAnglesYXZ

cons[#cons + 1] = physics.Spoofer.BeforeSpoofing:Connect(function()
	if playerSpoofer.Enabled then
		local y, x, z = camera.CFrame:ToEulerAnglesXYZ()
		-- char:PivotTo(yxz(0, x, z) + char:GetPivot().Position)
	end

	charPos = char:GetPivot()
end)

cons[#cons + 1] = physics.Spoofer.AfterSpoofing:Connect(function()
	spoofedCharPos = char:GetPivot()
end)

local function crouch(state)
	if tonumber(state) or state == nil then
		for i = 1, state or 1 do
			plr.Crouching.Value = not plr.Crouching.Value
			wait()
		end
	else
		plr.Crouching.Value = not not state
		wait()
	end
end

local character = interact:AddRightGroupbox("C", { Text = "Character" })
character:AddToggle("1", { Text = "Noclip", Callback = function(val, self)
	if not val then return end

	while self.Value and not window.Closed do
		for i, v in char:GetDescendants() do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end

		wait()
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CanCollide = true
	end

	crouch(6)
end })

local speed = character:AddSlider("2", { Text = "Speed", AllowSetValue = true, Min = 0, Max = 100, Step = 1, Value = 0, Format = "%" })

cons[#cons + 1] = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(pp)
	if instant.Value then
		pp:InputHoldEnd()
		fpp(pp)
	end
end)

local lastPos

cons[#cons + 1] = rs.Stepped:Connect(function(_, delta)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	local pos = (hrp or char):GetPivot().Position

	if lastPos and hrp and hum and hum.MoveDirection.Magnitude > 0.01 then
		local vel = pos - lastPos
		if vel.X ~= vel.X or vel.Magnitude > 2 then vel = v3(0, 0, 0) end

		char:TranslateBy(v3(vel.X, vel.Y > 0 and vel.Y / 1.5 or 0, vel.Z) * (speed.Value * 5) * delta)
	end

	lastPos = (hrp or char):GetPivot().Position
end)

pcall(function()
	workspace.FallenPartsDestroyHeight = 0 / 0
end)

local visuals = window:AddTab("V", { Text = "Visuals", Icon = "rectangle-goggles" })
local funny = visuals:AddLeftGroupbox("F", { Text = "Funny Visuals" })
local rgbEyefest = funny:AddToggle("R", { Text = "RGB Eyefestation", Tooltip = "How I even came up with that?", Value = false })
local hsv, rgb = Color3.fromHSV, Color3.fromRGB
local lighting = game:GetService("Lighting")

local useful = visuals:AddRightGroupbox("U", { Text = "Useful Visuals" })
useful:AddToggle("I", { Text = "Fullbright", Tooltip = "Aka. See in dark", Value = false, Callback = function(val, self)
	if not val then return end

	local w = rgb(150, 150, 150)

	while self.Value and not window.Closed do
		lighting.Ambient = w
		lighting.Brightness = 1
		wait()
	end

	lighting.Ambient = Color3.new()
	lighting.Brightness = 0
end })

modifierOnly:AddToggle("N", { Text = "No Popups", Tooltip = "Modifier Only", Value = false, Callback = function(val)
	values.Visual.NoPopups = val
end })

modifierOnly:AddToggle("C", { Text = "Anti Camera Flip", Tooltip = "Modifier Only", Value = false, Callback = function(val)
	values.Visual.AntiCameraFlip = val
end })

local originalFogEnd = lighting.FogEnd
useful:AddToggle("F", { Text = "No Fog", Tooltip = "(Possibly) Modifier Only", Value = false, Callback = function(val)
	values.Anti.Fog = val
end })

local tables = {
	Defuseables = { },
	Doors = { },
	AllDoors = { },
	Generators = { },
	Switches = { },
	Bruteforceables = { },
	Turrets = { },
	EdenTrees = { },
	Landmines = { },
	Dwellers = { },
	Lockers = { },

	Currency = { },
	Cards = { },
	LightItems = { },
	Items = { }
}

local bannedInstances = { }
local originalParents = { }
local theirRooms = { }

local bfs = 400
local bruteforceStop = { }
local unlocked = setmetatable({ }, { __mode = "kv" })
local buzy = false

local teleportSlider = Instance.new("CFrameValue")
local tpSliderTween : Tween = nil
local ts = game:GetService("TweenService")

local inf = 1 / 0
local cfr = CFrame.new

local teleport; teleport = function(target, slidingSpeed)
	if not slidingSpeed or slidingSpeed == 0 or slidingSpeed == inf then
		if typeof(target) == "Vector3" then target = cfr(target) end

		char:PivotTo(target)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = v3(0, 0, 0)
		end
	else
		if tpSliderTween then
			tpSliderTween:Destroy()
		end

		tpSliderTween.Destroying:Once(function()
			tpSliderTween:Pause()
			tpSliderTween = nil
		end)

		teleportSlider.Value = char:GetPivot()
		tpSliderTween = ts:Create(teleportSlider, TweenInfo.new((target.Position - char:GetPivot().Position).Magnitude / slidingSpeed, Enum.EasingStyle.Linear), { Value = target })
		tpSliderTween:Play()

		tpSliderTween.Completed:Wait()
		tpSliderTween:Destroy()

		teleportSlider.Value = target

	end
end

cons[#cons + 1] = teleportSlider.Changed:Connect(teleport)

window.OnClose:Once(function()
	if tpSliderTween then
		tpSliderTween:Destroy()
	end

	for i, v in hooks do
		hookfunction(i, v)
	end
end)

local bruteforceLock do
	local bfd = 4.5
	bruteforceLock = function(lock, tp)
		if buzy then return "Already in process" end
		if unlocked[lock] then return "Already unlocked" end

		local rf = lock:WaitForChild("RemoteFunction", ping + 0.1)
		if not rf then return "Not bruteforceable" end

		local unlocking = lock:WaitForChild("KeycardUnlocking", ping + 0.1)
		if not unlocking then return "Lock got deleted?" end

		buzy = true
		if tp and char then
			teleport(lock:GetPivot())
			wait(ping + 0.05)
			teleport(lock:GetPivot())
		end

		if (lock:GetPivot().Position - spoofedCharPos.Position).Magnitude > bfd then
			buzy = false
			return "Too far"
		end

		if lock.Parent.Parent == lastDoor and code then
			spawn(rf.InvokeServer, rf, code)

			buzy = false
			return 2
		else
			for i = bruteforceStop[lock] or 0, 9999 do
				spawn(rf.InvokeServer, rf, ("%04d"):format(i))

				if i ~= 0 and i % bfs == 0 then
					wait(ping)

					if unlocking.Playing then
						break
					end

					if tp and char then
						teleport(lock:GetPivot())
					end

					if (lock:GetPivot().Position - spoofedCharPos.Position).Magnitude > bfd then
						bruteforceStop[lock] = i - bfs
						buzy = false

						return "Too far"
					end
				end
			end
		end

		buzy = false
		unlocked[lock] = true

		return 1
	end
end

local getDoor; getDoor = function(obj)
	local root = obj:FindFirstChild("Root", true) or obj:FindFirstChild("RootPart", true) or obj.PrimaryPart
	if not root then return end

	local base = obj:FindFirstChild("BaseAddition", true)
	if base then
		return base.Parent.Parent, root
	end

	local door = obj:FindFirstChild("Door", true)
	if door and door:IsA("Model") then
		return door, root
	end
	
	return root, root
end

local doorInteracts = interact:AddRightGroupbox("D", { Text = "Doors" })
doorInteracts:AddButton({ Text = "Bruteforce Closest Door Code", Callback = function()
	local closest, dist = nil, math.huge
	for i, v in tables.Bruteforceables do
		local mag = (v:GetPivot().Position - spoofedCharPos.Position).Magnitude
		if mag < dist then
			closest, dist = v, mag
		end
	end

	if closest then
		local reason = bruteforceLock(closest)
		if typeof(reason) == "string" then
			window:Notification({ Title = "Bruteforce Failed", Text = reason })
		elseif reason == 1 then
			window:Notification({ Title = "Bruteforce Succeed", Text = "The door should open now.\nIt might take a bit, because your ping goes down and you need to wait for it to finish" })
		end
	end
end })

doorInteracts:AddButton({ Text = "Teleport to Last Door", Callback = function()
	local pivot, root
	if lastDoor then
		pivot, root = getDoor(lastDoor)
	end

	if pivot then
		teleport(pivot:GetPivot() - (root:GetPivot().XVector * 3))
	else
		window:Notification({ Title = "Teleport Failed", Text = "The Door is unavailable!" })
	end
end })

local function cleanupTable(tbl)
	local i = 1
	local removed = { }

	while i <= #tbl do
		local origV = tbl[i]
		local v = origV

		if typeof(v) == "table" then
			local res
			for idx, val in v do
				if typeof(val) == "Instance" then
					res = val
					break
				end
			end

			v = res
		end

		if not v or not v:IsDescendantOf(game) then
			remove(tbl, i)
			insert(removed, v)
		else
			i += 1
		end
	end

	return removed
end

cons[#cons + 1] = monsterSpawned:Connect(function(monster, type)
	if values.Notify.Monsters then
		window:Notification({ Title = type .. " Spawned", Text = type .. " has spawned!" })
	end

	if type == "Eyefestation" then
		local defused = false
		spawn(function()
			local nonAnim = monster.NonAnimated
			local reye = nonAnim:WaitForChild("RightEye")
			local ocol = reye.Color
			local wasRGB = false
			local lastCol = false

			while monster and monster:IsDescendantOf(workspace) do
				reye.Name = values.Anti.Eyefestation and reye:WaitForChild("BeamMesh").Transparency ~= 1 and not defused and "REye" or "RightEye"
				if rgbEyefest.Value and not window.Closed then
					wasRGB = true

					if lastCol and reye.Color ~= lastCol then
						ocol = reye.Color
					end

					local col = hsv(tick() % 20 / 20, 0.67, 1)
					for i, v in nonAnim:GetDescendants() do
						if v:IsA("BasePart") or v:IsA("SpotLight") then
							v.Color = col
						end
					end

					lastCol = col
				else
					lastCol = false

					if wasRGB then
						wasRGB = false
						for i, v in nonAnim:GetDescendants() do
							if v:IsA("BasePart") or v:IsA("SpotLight") then
								v.Color = ocol
							end
						end
					else
						ocol = reye.Color
					end
				end

				if window.Closed then
					for i, v in nonAnim:GetDescendants() do
						if v:IsA("BasePart") or v:IsA("SpotLight") then
							v.Color = ocol
						end
					end
					
					return
				end

				wait()
			end
		end)

		while monster:IsDescendantOf(workspace) and not char:FindFirstChild("FlashBeacon") and not window.Closed do wait() end
		if monster:IsDescendantOf(workspace) and not window.Closed then
			local active = monster:WaitForChild("Active")
			while not active.Value do wait() end

			defused = true
			wait()
			active.Value = false
			wait()
			active.Value = true
		end
	end
end)

local nodeMonsters = { }
local predictedPositions = { }

local function getAverage(t)
	local avg = 0
	local l = #t

	for i = 1, l do
		avg += t[i]
	end

	avg /= l
	return avg ~= avg and 0 or avg
end

local append do
	local function getAverage(t)
		local avg = 0
		local l = #t

		for i = 1, l do
			avg += t[i]
		end

		avg /= l
		return avg ~= avg and 0 or avg
	end

	append = function(table, value, size)
		local size = round(max(tonumber(size) or 0, 1))

		while #table >= size do
			remove(table, #table)
		end

		insert(table, 1, value)
		return getAverage(table)
	end
end

local reportedBefore = setmetatable({ }, { __type = "kv" })
local localEntities = {
	pande = "Pandemonium",
	nium = "Pandemonium",
	harbinger = "Harbinger",
	death = "Harbinger",
	pipsq = "Pipsqueak",
	["200"] = "A200"
}

cons[#cons + 1] = nodeMonsterSpawned:Connect(function(monster)
	if reportedBefore[monster] or not lastRoom or lastRoom.Name == "1RidgeStart" then return end
	reportedBefore[monster] = true

	wait() -- so :Destroy can work on pande

	local name = other:Smart(monster.Name)
	local namel = name:lower():gsub(" ", "")

	local cat
	for i, v in localEntities do
		if namel:match(i) then
			cat = v
			break
		end
	end

	local reportTime = reportedBefore[monster.Name]
	local shouldNotify = true
	local ct = tick()

	if reportTime and ct - reportTime < 12.5 then
		shouldNotify = false
	else
		reportedBefore[monster.Name] = ct
	end

	if cat and values.Anti[cat] then
		monster:Destroy()

		if values.Notify.NodeMonsters and shouldNotify then
			window:Notification({ Title = name .. " Destroyed", Text = name .. " has spawned, but it got destroyed, because of Anti " .. cat .. " setting enabled" })
		end

		return
	end

	esp.new(monster, {
		Highlight = false,
		Text = name
	}, "Node Monster")

	insert(nodeMonsters, monster)

	local prevPos = monster:GetPivot()
	local last = tick()
	local lastMoveDelta
	local mdCache = { }

	local con = monster:GetPropertyChangedSignal("Position"):Connect(function()
		local current = tick()
		local delta = current - last
		last = current

		local currentPos = monster:GetPivot()
		local move = currentPos.Position - prevPos.Position
		prevPos = currentPos

		local moveDelta = move * delta * ping * 1000
		local mixedDeltas = ((lastMoveDelta or moveDelta).Magnitude + moveDelta.Magnitude) / 2
		lastMoveDelta = moveDelta

		local tbl = predictedPositions[monster] or { }
		predictedPositions[monster] = tbl

		tbl[1] = currentPos:Lerp(charPos, mixedDeltas / 7.75)
		tbl[2] = max(append(mdCache, mixedDeltas, 30) * 70, max(700 * ping, 80))
	end)

	cons[#cons + 1] = monster.Destroying:Once(function()
		remove(nodeMonsters, find(nodeMonsters, monster))
		predictedPositions[monster] = nil
		con:Disconnect()
	end)

	if values.Notify.NodeMonsters and shouldNotify then
		window:Notification({ Title = name ~= "Mirage" and "Monster Spawned" or "ITS MIRAGE", Text = name .. " has spawned!" .. (name == "Mirage" and "\nThat's Mirage, no worries about it." or cat == "Pandemonium" and "\nHappy minigames! :P" or "") })
	end

	if values.Notify.InChat and shouldNotify then
		wait((random() / 2 + 0.5) * values.Notify.ChatRandomDelay)
		general:SendAsync((values.Notify.ChatFormat:gsub("<monster>", name:lower()):gsub("<Monster>", name):gsub("<MONSTER>", name:upper()):gsub("\n", "\r")))
	end
end)

local generatorDistance = 10
local fixGenerator do
	local inGenerator = { }

	fixGenerator = function(gen)
		if inGenerator[gen] then return end

		local model = gen.Model
		if (spoofedCharPos.Position - model:GetPivot().Position).Magnitude > generatorDistance then return false end

		inGenerator[gen] = true
		spawn(gen.RemoteFunction.InvokeServer, gen.RemoteFunction)

		local re = gen.RemoteEvent
		local fixed = gen.Fixed
		while fixed.Value < 100 and values.Automation.FixGenerators do
			re:FireServer(true)
			spawn(gen.RemoteFunction.InvokeServer, gen.RemoteFunction)

			wait(0.1)

			if (spoofedCharPos.Position - model:GetPivot().Position).Magnitude > generatorDistance then
				inGenerator[gen] = false
				return false
			end
		end

		return values.Automation.FixGenerators
	end
end

local function reparent(a, b)
	a.Parent = b
end

local function isSafe(position)
	if values.Automation.InstantHide and #nodeMonsters > 0 then return false end
	position = typeof(position) == "CFrame" and position.Position or position

	for i, v in nodeMonsters do
		if ((predictedPositions[v] and predictedPositions[v][1] or v:GetPivot()).Position - position).Magnitude < (predictedPositions[v] and predictedPositions[v][2] or 150) then
			return false
		end
	end

	return true
end

cons[#cons + 1] = lighting.ChildAdded:Connect(function(ch)
	if ch:IsA("Atmosphere") then
		insert(bannedInstances, { ch, "Fog" })
	end
end)

for i, ch in lighting:GetChildren() do
	if ch:IsA("Atmosphere") then
		insert(bannedInstances, { ch, "Fog" })
	end
end

local currentTool = char:GetAttribute("ToolName")
if currentTool == "nil" then
	currentTool = nil
end

local function equip(toolName)
	local equip = eventsRFolder:FindFirstChild("Equip")
	if equip and toolName ~= currentTool then
		currentTool = toolName
		equip:FireServer(toolName)
	end
end

local function unequip(toolName)
	local unequip = eventsRFolder:FindFirstChild("Unequip")
	if unequip then
		currentTool = nil
		unequip:FireServer(toolName)
	end
end

local function activate(toolName, ...)
	local activate = eventsRFolder:FindFirstChild("Activate")
	if activate then
		equip(toolName)
		activate:FireServer(toolName, ...)
	end
end

local erasePrefixes = { "Big", "Large", "Normal", "Medium", "Small", "Shop", "Crate", "Box", "Chest", "Ridge" }
local alwaysCanCarry = { "card", "password" }

local function getName(model, type)
	local name = model.Name:gsub(" ", "")
	for i, v in erasePrefixes do
		name = name:gsub(v, "")
	end

	local n = name:lower()
	if type == "Keycard" then
		return (n == "innerkeycard" and "Inner " or "") .. "Keycard"
	elseif n:match("battery") then
		return "Battery"
	elseif n == "defib" then
		return "Defibrillator"
	elseif n == "petbunny" then
		return "Bunny"
	elseif n:match("sprint") then
		return "Adrenaline"
	elseif n:match("neostyk") then
		return "NeoStyk"
	elseif n == "model" then
		return "The Gun"
	elseif n == "winduplight" then
		return "Windup Light"
	end

	local semi = other:Smart(name)
	return semi:sub(1, 1):upper() .. semi:sub(2)
end

local function canCarry(item)
	if not pfolder:FindFirstChild("Inventory") then return true end

	local oItemName = item.Name
	local lo = oItemName:lower()
	local itemName = getName(item, (lo:match("card") or lo:match("password")) and "Keycard"):gsub(" ", "")

	local eq = equipableItems:FindFirstChild(itemName)
	local max = item:GetAttribute("Charge") or item:GetAttribute("Uses") or eq and eq:GetAttribute("MaxStack")
	local item = pfolder.Inventory:FindFirstChild(itemName) or pfolder:FindFirstChild(itemName) or pfolder.Inventory:FindFirstChild(oItemName) or pfolder:FindFirstChild(oItemName) or itemName:lower():match("battery") and pfolder:FindFirstChild("Batteries")
	max = max or item and item.Parent == pfolder and 5 or false

	if item then
		if max then
			return item.Value < max
		else
			return false
		end
	else
		local lo = itemName:lower()
		for i, v in alwaysCanCarry do
			if lo:match(v) then
				return true
			end
		end

		local buzySlots = 0
		for i, v in pfolder.Inventory:GetChildren() do
			local EQ = equipableItems:FindFirstChild(v.Name)
			if EQ then
				if not EQ:GetAttribute("Auxillary") then
					buzySlots += 1
				else
					local S = false
					local LO = itemName:lower()
					for i, v in alwaysCanCarry do
						if LO:match(v) then
							S = true
							break
						end
					end

					if not S then
						buzySlots += 1
					end
				end
			end
		end

		return eq and eq:GetAttribute("Auxillary") or #pfolder.Inventory:GetChildren() < gameSettings.MaxInventory
	end
end

local red = Color3.new(1)
local mainLoop do 
	local cycles = 0
	local fppCycles = 0

	local consCd = false
	local consumeNeostyk do
		consumeNeostyk = function()
			if consCd then return end

			local neo = eventsRFolder:FindFirstChild("NeoStyk")
			if neo and pfolder.NeoStyk.Value > 0 and pfolder.Health.Value < pfolder.MaxHealth.Value then
				consCd = true

				local neos = pfolder.NeoStyk.Value
				neo:FireServer("Heal")

				repeat wait() until pfolder.NeoStyk.Value ~= neos or pfolder.NeoStyk.Value <= 0

				consCd = false
			end
		end
	end

	local consumeTool do
		local toolCds = { }
		consumeTool = function(toolName, ...)
			local tool = pfolder.Inventory:FindFirstChild(toolName)
			if tool and tool.Value > 0 and not toolCds[toolName] then
				toolCds[toolName] = true

				local old = tool.Value
				activate(toolName, ...)

				repeat wait() until tool.Value ~= old or tool.Value <= 0

				toolCds[toolName] = false

				if tool.Value <= 0 then
					unequip(toolName)
				end
			end
		end
	end

	local function consumeWithRegenCD(toolName, ...)
		if consCd then return end

		consCd = true
		consumeTool(toolName, ...)
		consCd = false
	end

	mainLoop = function()
		char = plr.Character or char or dummy
		camera = workspace.CurrentCamera or camera
		cycles = (cycles + 1) % 60
		fppCycles = (fppCycles + 1) % 2

		if cycles == 0 then
			for i, v in tables do
				cleanupTable(v)
			end
		end

		if values.Anti.Eyefestation then
			local sound = mainGui:FindFirstChild("EyefestationGaze", true)
			if sound then
				for i, v in sound.Parent:GetChildren() do
					if v:IsA("Sound") then
						v.Playing = false
					end
				end
			end
			
			local effect = camera:FindFirstChild("EyefestationCameraEffect")
			if effect then
				effect:Destroy()
			end
		end

		if values.Automation.HealthBoost and pfolder.Health.Value + 40 <= pfolder.MaxHealth.Value then
			spawn(consumeWithRegenCD, "HealthBoost", "Activated")
		end

		if values.Automation.Medkit and pfolder.Health.Value + 40 <= pfolder.MaxHealth.Value then
			spawn(consumeWithRegenCD, "Medkit", true)
		end

		if values.Automation.NeoStyk and pfolder.Health.Value + 10 <= pfolder.MaxHealth.Value then
			spawn(consumeNeostyk)
		end

		if values.Anti.WallDweller then
			for i, v in tables.Dwellers do
				if v:IsDescendantOf(workspace) then
					v:FireServer(nil, true, false)
				end
			end
		end

		if values.Anti.Fish then
			local fish = assetsRFolder:FindFirstChild("Fish")
			if fish then
				local anim = fish:FindFirstChild("AnimationController")
				if anim then
					anim.Name = "NotAnimationController"
				end
			end

			if char:FindFirstChild("Fish") then
				char.Fish:Destroy()
			end
		else
			local fish = assetsRFolder:FindFirstChild("Fish")
			if fish then
				local anim = fish:FindFirstChild("NotAnimationController")
				if anim then
					anim.Name = "AnimationController"
				end
			end
		end

		if values.Anti.KittyClock and pfolder.Inventory:FindFirstChild("KittyClock") then
			activate("KittyClock", "StopScream")

			if char:FindFirstChild("KittyClock") then
				char.KittyClock:Destroy()
			end
		end

		if values.Visual.AntiCameraFlip then
			pcall(rs.UnbindFromRenderStep, rs, "CameraFlip")
		end

		for i, v in tables.Landmines do
			v.CanTouch = not values.Anti.DamageParts
		end

		if values.Anti.WitchingHour then
			local wh = assetsRFolder:FindFirstChild("WitchingHour", true)
			if wh then
				wh.Name = "NotWitchingHour"
			end
		else
			local wh = assetsRFolder:FindFirstChild("NotWitchingHour", true)
			if wh then
				wh.Name = "WitchingHour"
			end
		end

		local sc1 = mainGui:FindFirstChild("SkinlessClient", true)
		if sc1 then
			sc1:SetAttribute("DespawnAfterSeconds", values.Anti.Skinless and -9e6 or 60)
		end

		if values.Other.InfiniteOxygen then
			for i, v in lighting:GetChildren() do
				if v:IsA("Sound") then
					local attr = v:GetAttribute("OriginalVolume")
					if attr ~= true then
						v:SetAttribute("_OriginalVolume", attr)
						v:SetAttribute("OriginalVolume", red)
					end
				end
			end
		else
			for i, v in lighting:GetChildren() do
				if v:IsA("Sound") then
					local attr = v:GetAttribute("_OriginalVolume")
					if attr then
						v:SetAttribute("OriginalVolume", attr)
						v:SetAttribute("_OriginalVolume", nil)
					end
				end
			end
		end

		if values.Anti.Lopee then
			local lp = mainGui:FindFirstChild("LopeePart", true)
			if lp then
				lp.Name = "NotLopeePart"
			end
		else
			local lp = mainGui:FindFirstChild("NotLopeePart", true)
			if lp then
				lp.Name = "LopeePart"
			end
		end

		for i, v in tables.EdenTrees do
			v.PrimaryPart = not values.Anti.EdenTree and v:FindFirstChild("RootPart") or nil
		end

		if values.Anti.GOM then
			local app = mainGui:FindFirstChild("GOMAppear", true)
			if app then
				app.Name = "NotGOMAppear"
			end
		else
			local app = mainGui:FindFirstChild("NotGOMAppear", true)
			if app then
				app.Name = "GOMAppear"
			end
		end

		if values.Anti.Coagulate then
			plr:SetAttribute("CurrentRoomNumber", round(random() * 100000))
			plr:SetAttribute("Dead", true)
		else
			plr:SetAttribute("CurrentRoomNumber", nil)
			plr:SetAttribute("Dead", nil)
		end

		lighting.FogEnd = values.Anti.Fog and 9e6 or originalFogEnd

		if mainGui:FindFirstChild("Popups") then
			local appear = mainGui:FindFirstChild("PopUp_Appear", true)
			if appear then
				appear.Volume = values.Visual.NoPopups and 0 or 1
			end

			if values.Visual.NoPopups then
				mainGui.Popups:ClearAllChildren()
			end
		end

		if values.Automation.Hide and #nodeMonsters > 0 and camera then
			if not values.Automation.UseLockers then
				if not isSafe(charPos) then
					playerSpoofer.Enabled = true
					playerSpoofer.OffsetCFrame = cfr(0, 200, 0)
				else
					playerSpoofer.Enabled = false
					playerSpoofer.OffsetCFrame = nil
				end
			else
				playerSpoofer.Enabled = false
				playerSpoofer.OffsetCFrame = nil
				-- TODO: make it use a locker
			end
		else
			playerSpoofer.Enabled = false
			playerSpoofer.OffsetCFrame = nil
		end

		if values.Anti.Turret then
			for i, v in tables.Turrets do
				for idx, val in v:GetChildren() do
					if val.ClassName:match("Remote") then
						val:Destroy()
					end
				end
			end
		end

		if values.Other.BetterDoors then
			local toRemove = { }

			for i, v in tables.AllDoors do
				if v:FindFirstChild("OpenValue", true) and v:FindFirstChild("OpenValue", true).Value or v:GetAttribute("Locked") then
					insert(toRemove, v)
				else
					local pp = v:FindFirstChildWhichIsA("ProximityPrompt", true)
					if pp then
						fpp(pp, 1, v:FindFirstChild("Exit") or false, 0.05, 16)
					end
				end
			end

			for i, v in toRemove do
				remove(tables.AllDoors, find(tables.AllDoors, v))
			end
		end

		shakeOff = shakeOff or rstorage:FindFirstChild("ParasiteShakeOff", true)
		if values.Anti.Parasites and shakeOff then
			shakeOff:FireServer()
		end

		if values.AutoPick.Enabled and fppCycles == 0 then
			if values.AutoPick.Currency then
				for i, v in tables.Currency do
					fpp(v, 1, true, ping + 0.05)
				end
			end

			if values.AutoPick.Items then
				for i, v in tables.Items do
					local model = v:FindFirstAncestorOfClass("Model")
					if model and canCarry(model) then
						fpp(v, 1, true, ping + 0.1)
					end
				end

				if values.AutoPick.LightSources then
					for i, v in tables.LightItems do
						local model = v:FindFirstAncestorOfClass("Model")
						if model and canCarry(model) then
							fpp(v, 1, true, ping + 0.1)
						end
					end
				end
			end

			if values.AutoPick.Keycards then
				for i, v in tables.Cards do
					local model = v:FindFirstAncestorOfClass("Model")
					if model and canCarry(model) then
						fpp(v, 1, true, ping + 0.3)
					end
				end
			end
		end

		if values.Automation.DisarmHazards then
			for i, v in tables.Defuseables do
				fpp(v, 1, true, ping + 0.05, 24)
			end
		end

		if workspace.DistributedGameTime > 20 then
			local toRemove = { }
			for _, c in bannedInstances do
				local v, i = c[1], c[2]
				if not originalParents[v] then
					originalParents[v] = v.Parent

					local room = v
					while true do
						local next = room:FindFirstAncestorOfClass("Model")
						if next then
							room = next
						else
							break
						end
					end

					theirRooms[v] = room
				end

				if theirRooms[v] == nil or not theirRooms[v]:IsDescendantOf(game) then
					theirRooms[v] = nil
					originalParents[v] = nil
					insert(toRemove, v)
				else
					pcall(reparent, v, not values.Anti[i] and originalParents[v] or nil)
				end
			end

			for i, v in toRemove do
				remove(bannedInstances, find(bannedInstances, v))
			end
		end

		for i, v in tables.Generators do
			esp.new(v.Model, {
				Visible = v.Fixed.Value < 100,
				Text = "Generator"
			}, "Generator")

			if values.Automation.FixGenerators and (char:GetPivot().Position - v.Model:GetPivot().Position).Magnitude <= generatorDistance and v.Fixed.Value < 100 then
				spawn(fixGenerator, v)
			end
		end

		for i, v in tables.Switches do
			local prox = v:FindFirstChildWhichIsA("ProximityPrompt", true)
			esp.new(v, {
				RotationLevel = prox and prox.Enabled and 0.5 or -0.5,
				Text = "Switch"
			}, "Interactable")

			if prox and prox.Enabled and values.Automation.PullSwitches then
				fpp(prox, 1, true, ping / 3)
			end
		end

		local friend = workspace:FindFirstChild("FriendPart")
		if friend and values.Anti.Friend then
			friend:Destroy()
		end
	end
end

spawn(function()
	local currentPuzzle, r
	local active = pipes.ActivePuzzles
	
	while wait() and not window.Closed do
		pipes.ShowDebugUI = values.Debug.ShowPipePuzzle
		
		if #active > 0 and values.Automation.SolvePipePuzzle then
			if currentPuzzle ~= active[1] or not r then
				wait(1)
				
				currentPuzzle = active[1]
				r = pipes:Solve(currentPuzzle)
				
				if values.Automation.PlaySolvedSolution then
					pipes:Play(r)
				end
			elseif values.Automation.PlaySolvedSolution then
				pipes:Play(r)
			end
		else
			currentPuzzle = nil
			r = nil
		end
	end
end)

spawn(function()
	while wait() do
		local s, e = pcall(mainLoop)
		if s and e then
			break
		elseif not s then
			warn("MAIN LOOP ERROR:", e)
		end

		if window.Closed then
			break
		end
	end
end)

local function isLightSource(modelName)
	modelName = modelName:lower()
	return modelName:match("light") or modelName:match("lantern") or modelName:match("flash")
end

local rotations = {
	["Inney Keycard"] = 0.7,
	["Keycard"] = 0,
	["Battery"] = -0.6,
	["Defibrillater"] = 1.3,
	["Bunny"] = 2,
	["Adrenaline"] = -0.85,
	["Neostyk"] = 1,
	["Health Boost"] = 2,
	["The Gun"] = -2
}

local function getRotation(modelName, type)
	local isLight = isLightSource(modelName)
	return (isLight and (modelName ~= "Blacklight" and 0.8 or -1.6) or rotations[modelName] or modelName:match("Document") and -1 or type == "Interactable" and -1 or 0), isLight
end

local ff = Enum.Material.ForceField

spawn(function()
	local prevWarning, prevWarningCon
	while wait() do
		local warning = mainGui:FindFirstChild("HotPotatoWarning")
		if warning and warning ~= prevWarning then
			if prevWarningCon then
				prevWarningCon:Disconnect()
				prevWarningCon = nil
			end

			prevWarning = warning
			prevWarningCon = warning:GetPropertyChangedSignal("Visible"):Connect(function()
				if warning.Visible and values.Anti.HotPotato then
					warning.Visible = false
					crouch(2)
				end
			end)
		end

		local sounds = mainGui:FindFirstChild("HotPotatoSounds", true)
		if sounds then
			local beep = sounds:FindFirstChild("TempBeep")
			if beep then
				beep.Volume = values.Anti.HotPotato and 0 or 0.6

				local disarm = beep.Parent:FindFirstChild("MineDisarm")
				if disarm then
					disarm.Volume = values.Anti.HotPotato and 0 or 1
				end
			end
		end

		if window.Closed then
			return
		end
	end
end)

local function onInstance(v, alreadyExisted)
	local c, n = v.ClassName, v.Name
	local p = v.Parent
	local pc, pn = p and p.ClassName or "", p and p.Name or ""

	if c == "Model" then
		if pn == "Entrances" then -- door
			if previousRoom and not endingRoomNames[previousRoom.Name] and not alreadyExisted then
				lastDoor = v
			end

			if not alreadyExisted then
				roomNum += 1
			end

			insert(tables.Doors, { v, roomNum })

			esp.new(v, {
				HighlightAdornee = v:WaitForChild("Door", ping + 0.1) or v,
				RotationLevel = v:GetAttribute("Locked") and 1 or 0,
				TopText = (v:GetAttribute("Locked") and '<font size="10">[ Locked ]</font>\n' or "") .. '<font size="12">' .. other:Smart(v:WaitForChild("Enter", 9e9).Value.Name) .. "</font>",
				Text = "Room: <b>" .. (roomNum + 1 - (traversalOrder[p.Parent] or 0)) .. "</b>"
			}, "Door")
		elseif n == "Tripwire" then -- tripwire
			esp.new(v:WaitForChild("Main", 9e9), {
				HighlightAdornee = v,
				Text = n
			}, "Hazard")

			wait(ping + 0.25)
			insert(tables.Defuseables, v:WaitForChild("ProxyPart", 9e9):WaitForChild("ProximityPrompt", 9e9))
		elseif n == "MonsterLocker" then -- void mass, aka fake locker
			esp.new(v, {
				Text = "Void Mass",
				TopText = '<font size="10">(Fake Locker)</font>',
				RotationLevel = 1.5,
			}, "Fake Object")

			insert(bannedInstances, { v:WaitForChild("ProximityPrompt", 9e9), "MonsterLocker" })
		elseif n == "DiVine" then
			esp.new(v, {
				Text = "DiVine",
				RotationLevel = 1.5,
			}, "Weak Monster")

			insert(bannedInstances, { v, "DiVine" })
		elseif n == "DiVineRoot" then
			wait(ping + 0.1)
			if v:FindFirstChild("DwellerModel") then
				monsterSpawned:Fire(v, "Wall Dweller")
				esp.new(v, {
					Text = "Wall Dweller"
				}, "Monster")

				insert(tables.Dwellers, v:WaitForChild("Events", 9e9):WaitForChild("RemoteEvent", 9e9))
			else
				insert(bannedInstances, { v, "DiVine" })
			end
		elseif n == "NoGood" and p == workspace or n == "Coagulate" and p == camera then
			wait(wait())
			if values.Anti[n] then
				v:Destroy()
			end
		elseif pc == "Model" and p:WaitForChild("Fixed", ping + 0.1) then -- generator
			insert(tables.Generators, p)
		end
	elseif c == "Folder" then
		if n == "Eyes" then -- searchlight & it's main
			if pc == "Model" and p:FindFirstChild("HRP") then
				esp.new(p:FindFirstChild("HRP"), {
					Text = "Searchlight",
					HighlightAdornee = p,
					RotationLevel = 0.3,
				}, "Monster")
			elseif pc == "Part" and p:WaitForChild("Weld", ping + 0.1) then
				monsterSpawned:Fire(p, "Searchlight")
				insert(bannedInstances, { p:WaitForChild("RemoteEvent", 9e9), "Searchlights" })
			end
		elseif n == "NonAnimated" and pc == "Model" and p:WaitForChild("Active", ping + 0.1) then -- eyefestation
			local col = v:WaitForChild("RightEye", 9e9)
			local esp = esp.new(v, {
				HighlightAdornee = p,
				Text = "Eyefestation",
				Color = col.Color
			}, "Monster")

			monsterSpawned:Fire(p, "Eyefestation")

			while wait() and p:IsDescendantOf(workspace) and not window.Closed do
				esp.Color = col.Color
			end
		elseif v:WaitForChild("DetectLight", ping + 0.1) then -- statue monster
			local model = p:FindFirstChildOfClass("Model")
			while not model and wait() do
				model = p:FindFirstChildOfClass("Model")
			end

			esp.new(model:WaitForChild("HumanoidRootPart"), {
				HighlightAdornee = model,
				Text = other:Smart(model.Name)
			}, "Monster")

			monsterSpawned:Fire(p, "Statue")
		end
	elseif c == "Part" then
		if n == "LandmineSpawn" then -- landmine
			esp.new(v, {
				HighlightAdornee = v:WaitForChild("Value", 9e9).Value,
				Text = "Landmine"
			}, "Hazard")

			insert(tables.Defuseables, v:WaitForChild("ProximityPrompt", 9e9))
			insert(tables.Landmines, v)
		elseif n == "GrowlPart" and pc == "Model" then -- good people, aka fake door
			esp.new(p:WaitForChild("TricksterDoor"), {
				Text = "Good People",
				TopText = '<font size="10">(Fake Door)</font>',
				RotationLevel = 0.3,
			}, "Fake Object")

			insert(bannedInstances, { p:WaitForChild("RemoteEvent", 9e9), "GoodPeople" })
			insert(bannedInstances, { p:WaitForChild("RemoteEvent", 9e9), "DamageParts" })
		elseif n == "LockerCollision" then
			if p.Name ~= "MonsterLocker" then
				insert(tables.Lockers, p)
			end
		elseif (v.Color == red and v.Transparency == 1 and v.Material == ff or pn:lower():match("damag") or n:lower():match("damag")) and (p.Parent == roomsFolder or not p:IsA("Model")) then -- damagepart
			insert(bannedInstances, { v, "DamageParts" })
		elseif n == "MineSpawn" then
			insert(bannedInstances, { v:WaitForChild("RemoteEvent", 9e9), "DamageParts" })
		elseif n == "PlayerFog" then
			insert(bannedInstances, { p, "Fog" })
		elseif n == "Root" and pc == "Model" and p:WaitForChild("Barrel", ping + 0.1) then -- Turret
			if p.Parent:GetAttribute("Active") == nil then return end
			esp.new(v, {
				HighlightAdornee = p,
				Text = "Turret",
				RotationLevel = 0.5,
			}, "Hazard")

			insert(bannedInstances, { p.Parent:WaitForChild("DesiredLocation", 9e9), "Turret" })
		end
	elseif c == "ProximityPrompt" then
		if v.Enabled and pn == "ProxyPart" and p.Parent.ClassName == "Model" then
			local model = p.Parent
			local name = model.Name
			local nl = name:lower()
			local it = (model:GetAttribute("InteractionType") or ""):lower()

			if name == "Toilet" or name == "Dryer" or nl == "highlight" or nl == "tripwire" or nl:match("generator") or it:match("chest") or it:match("box") or it:match("crate") or nl:match("bed") then return end

			local isPassword = name:match("Password")

			local amount = model:GetAttribute("Amount")
			local type = amount and "Currency" or (name:match("Key") or isPassword) and "Keycard" or name ~= "Model" and itemsRFolder:FindFirstChild(name, true) and "Item" or "Interactable" 

			if type == "Currency" then
				esp.new(p, {
					Highlight = false,
					Text = "$" .. amount,
					RotationLevel = (amount - 5) / 70
				}, type)

				insert(tables.Currency, v)
			elseif isPassword then
				local c = model:WaitForChild("Code", 9e9):WaitForChild("SurfaceGui", 9e9):WaitForChild("TextLabel", 9e9).Text
				code = c

				esp.new(p, {
					Highlight = false,
					Text = code
				}, type)

				insert(tables.Cards, v)

				repeat wait() until not code or not v:IsDescendantOf(workspace)
				if v:IsDescendantOf(workspace) then
					code = c
				end
			else
				local name = getName(model, type)
				local rot, isLight = getRotation(name, type)

				esp.new(p, {
					Highlight = false,
					Text = name,
					RotationLevel = rot
				}, type)

				if type == "Keycard" then
					insert(tables.Cards, v)
				elseif type == "Item" then
					if model.Parent.Name == "DroppedItems" or model:GetAttribute("Price") then return end
					insert(tables[(isLight and "Light" or "") .. "Items"], v)
				end
			end
		end
	elseif c == "Beam" then
		if p.Parent == workspace and pc == "Part" and p:FindFirstChildOfClass("Sound") then -- some node monster
			nodeMonsterSpawned:Fire(p)
		end
	elseif c == "Humanoid" then
		if pc == "Part" and p.Parent == workspace then
			nodeMonsterSpawned:Fire(p)
		end
	elseif c == "Sound" then
		if n == "LeverPull" and p:IsA("BasePart") then
			insert(tables.Switches, p.Parent)
		elseif n == "KeycardUnlock" and pc == "Part" and pn == "Main" then
			insert(tables.Bruteforceables, p)
		end
	elseif c == "BoolValue" then
		if n == "OpenValue" then
			wait(ping + 0.1)
			if p:FindFirstChildOfClass("Model") then
				insert(tables.AllDoors, p)
			end
		end
	elseif c == "MeshPart" then
		if n == "Tentacle18" then -- squiddle
			esp.new(p, {
				Text = "Squiddle",
				RotationLevel = -0.4,
			}, "Weak Monster")
			insert(bannedInstances, { p, "Squiddle" })
		elseif n == "TreeBody" and p:WaitForChild("RootPart", ping + 0.1) then -- eden tree
			insert(tables.EdenTrees, p)
			esp.new(p, {
				Text = "Eden Tree",
				RotationLevel = 0.8,
			}, "Weak Monster")		
		end
	elseif n:sub(1, 4) == "Fish" and #n == 8 then
		insert(bannedInstances, { v, "Bottomfeeder" })
	end
end

spawn(function()
	local e = eventsRFolder.CurrentRoomNumber
	roomNum = e:InvokeServer()

	while not window.Closed do
		ping = plr:GetNetworkPing()
		wait()
	end
end)

spawn(function()
	repeat wait() until roomNum ~= -1 or window.Closed
	if window.Closed then return end

	for i, v in workspace:GetDescendants() do
		spawn(onInstance, v, true)
	end

	cons[#cons + 1] = workspace.DescendantAdded:Connect(onInstance)
end)

local cons = { }
local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 78, 117, 108, 108, 45, 67, 104, 101, 114, 114, 121, 47, 85, 116, 105, 108, 105, 116, 105, 101, 115, 47, 114, 101, 102, 115, 47, 104, 101, 97, 100, 115, 47, 109, 97, 105, 110, 47, 85, 116, 105, 108, 105, 116, 121, 47, 77, 97, 105, 110, 46, 108, 117, 97)))() end)()
local window = util:NullFireWindow()
local esp = util:ESP()
local lib = util:FunkyFridayAutoPlay()

esp:InitClass("Inactive Stages", { Color = Color3.fromRGB(85, 170, 127) })

window = window(cons, ...)

local function isBuzyStage(stage)
	if stage:GetAttribute("ActiveGame") then return true end

	for i, v in stage.Nodes:GetChildren() do
		if v:FindFirstChildOfClass("Attachment") then
			return true
		end
	end

	return false
end

local stages = workspace:WaitForChild("Map"):WaitForChild("Stages")
local plr = game:GetService("Players").LocalPlayer

local wait = task.wait
local spawn = task.spawn
local round = math.round
local min = math.min
local clamp = math.clamp

spawn(function()
	while wait() do
		local a = 0
		for i, v in stages:GetChildren() do
			a += 1
			esp.new(v, {
				Text = "Inactive Stage",
				Visible = not isBuzyStage(v)
			}, "Inactive Stages")
		end

		window.DisableBlurBackground = a == 1
	end
end)

local autoplayTab = window:AddTab("AP", { Text = "Auto Play", Icon = "l://play" })
autoplayTab:AddLabel({ Text = "Auto Player version: <b>" .. lib.Version .. "</b>" })
autoplayTab:AddLabel({ Text = "Quick fixes if autoplay does not work or works unstable:\n1. Change your note skin - sometimes autoplayer interprets your note skin as death/poison note\n2. Hit Offset in Funky Friday's settings missmatch the one in the script" })
autoplayTab:AddLabel({ Text = "If you found a bug, you can report it in NullFire tab. If you have an idea/suggestion, join our discord (also NullFire tab) and tell it there!" })

local autoplay = autoplayTab:AddLeftGroupbox("A", { Text = "Auto Play" })
autoplay:AddToggle("E", {
	Text = "Auto Play Enabled",
	Value = false,
	Callback = function(val)
		lib.AutoPlay = val
	end
})

autoplay:AddToggle("C", {
	Text = "Copy Enemy Notes",
	Tooltip = "When your lane has no arrows, it autoplays enemy's notes",
	Value = lib.CopyEnemyNotes,
	Callback = function(val)
		lib.CopyEnemyNotes = val
	end
})

autoplay:AddToggle("S", {
	Text = "Enable SV Detection",
	Value = -- lib.SVEnabled,
		false,
	Tooltip = "CURRENTLY THAT FEATURE IS BROKEN, ENABLE IT ONLY WHEN YOU PLAY SV SONGS",
	Callback = function(val)
		lib.SVEnabled = val
		window:Notification({ Title = "SV Detection", Text = "CURRENTLY THAT FEATURE IS BROKEN, ENABLE IT ONLY WHEN YOU PLAY SV SONGS" })
	end
})

autoplay:AddSlider("O", {
	Text = "Hitbox Offset",
	Min = -1000,
	Max = 1000,
	Value = 0,
	Step = 1,
	Compact = true,
	AllowSetValue = true,
	Tooltip = "MAKE IT THE SAME AS IN FUNKY FRIDAY SETTINGS",
	Callback = function(val)
		lib.HitOffset = val / 1000
	end, Format = function(self)
		return self.Value .. " ms"
	end
})

autoplay:AddSlider("P", {
	Text = "Perfect Sick",
	Tooltip = "If you have bad device, make perfect sick early",
	Value = (lib.PerfectSick * 100) - 100,
	Min = -100,
	Max = 100,
	Step = 1,
	AllowSetValue = true,
	Callback = function(value)
		lib.PerfectSick = value / 100 + 1
	end,
	Format = function(self)
		local val = self.Value
		return val < -10 and "Early (" .. (-val) .. "%)" or (val >= -10 and val <= 10) and "Perfect Sick" .. (val == 0 and "" or val < 0 and " (" .. (-val) .. "% early)" or " (" .. val .. "% late)") or "Late (" .. val .. "%)"
	end
})

autoplay:AddButton({
	Text = "Teleport to Inactive Stage",
	Callback = function()
		if not plr.Character then return end
		for i, v in stages:GetChildren() do
			if not isBuzyStage(v) then
				plr.Character:PivotTo(v:GetPivot() + Vector3.new(0, 5, 0))
			end
		end
	end,
})

local performance = autoplayTab:AddLeftGroupbox("Op", { Text = "Optimizations" })
performance:AddSlider("N", {
	Text = "Reduce Note Render",
	Tooltip = "Higher values will result in less notes being rendered concurrently and less lags",
	Min = 0,
	Max = 100,
	Step = 1,
	Format = "%",
	Compact = true,
	AllowSetValue = true,
	Value = lib.Performance.Notes * 10,
	Callback = function(val)
		lib.Performance.Notes = val / 10
	end
})

performance:AddSlider("H", {
	Text = "Hide HUD (UI)",
	Min = 0,
	Max = 3,
	Step = 1,
	Compact = true,
	Value = lib.Performance.UI,
	AllowSetValue = true,
	Callback = function(val)
		lib.Performance.UI = val
	end
})

performance:AddToggle("S", {
	Text = "Disable 3D Rendering",
	Value = lib.Performance.Disable3D,
	Callback = function(val)
		lib.Performance.Disable3D = val
	end
})

local re
local function refresh()
	if re then
		re()
	end
end

local autoplaySettings = autoplayTab:AddRightGroupbox("AP", { Text = "Autoplay Settings" })
local skill = autoplaySettings:AddSlider("S", {
	Text = "Skill",
	Min = 0,
	Max = 100,
	Step = 1,
	Value = 100,
	Format = "%",
	Compact = true,
	Callback = refresh,
	AllowSetValue = true
})

local hht = autoplaySettings:AddSlider("HT", {
	Text = "Hit Holding Time",
	Min = 0,
	Max = 100,
	Step = 1,
	Value = 40,
	Format = "%",
	Compact = true,
	Callback = refresh,
	AllowSetValue = true
})

autoplaySettings:AddSeparator()

local le = autoplaySettings:AddCheckBox("L", {
	Text = "Legit",
	Value = false,
	Callback = refresh
})

local function lerp(a, b, c)
	return a + (b - a) * c
end

local lkps = autoplaySettings:AddSlider("LK", {
	Text = "Legit KPS (per key)",
	Min = 2,
	Max = 19,
	Step = 0.1,
	Value = 9,
	Format = function(self)
		local val = self.Value
		return (val >= 3 and val <= 18 and clamp(val, 4, 17) or "inf") .. " KPS"
	end,
	Callback = refresh,
	AllowSetValue = true
})

local legacy = autoplayTab:AddRightGroupbox("LS", { Text = "Legacy Settings" })
local legacyChances = { }

for _, i in { "Sick", "Good", "Ok", "Bad", "Miss" } do
	legacyChances[i] = legacy:AddSlider({
		Text = i .. " Chance",
		Value = i == "Sick" and 100 or 0,
		Min = 0,
		Max = 100,
		Step = 0.1,
		Compact = true,
		AllowSetValue = true,
		Callback = refresh,
		Format = "%"
	})
end

legacy:AddSeparator()

kps = legacy:AddSlider({
	Text = "Max KPS",
	Tooltip = "0 = inf",
	Value = lib.KPS.Global,
	Min = 0,
	Max = 100,
	Step = 1,
	Compact = true,
	AllowSetValue = true,
	Callback = refresh
})

kpspk = legacy:AddSlider({
	Text = "Max KPS per key",
	Tooltip = "0 = inf",
	Value = lib.KPS.PerKey,
	Min = 0,
	Max = 35,
	Step = 1,
	Compact = true,
	AllowSetValue = true,
	Callback = refresh
})

legacy:AddSeparator()

hd = legacy:AddSlider({
	Text = "Hold Duration",
	Value = round(lib.HoldDuration.Value * 1000),
	Min = 0,
	Max = 1000,
	Step = 1,
	Compact = true,
	Callback = refresh,
	AllowSetValue = true,
	Format = function(self)
		return self.Value .. " ms"
	end
})

hdr = legacy:AddSlider({
	Text = "Hold Duration random",
	Value = round(lib.HoldDuration.Random * 1000),
	Min = 0,
	Max = 1000,
	Step = 1,
	Compact = true,
	Callback = refresh,
	AllowSetValue = true,
	Format = function(self)
		local val = self.Value
		return val ~= 0 and "-" .. round(val / 4) .. " to " .. val .. " ms" or "0 ms"
	end
})

legacy:AddSeparator()

local spray = legacy:AddToggle("S", {
	Text = "Spray",
	Tooltip = "Aka Legit | Makes ms random when you hit notes, e.g. static 40 ms will turn into from 40 to -20 ms",
	Value = lib.Spray,
	Callback = refresh
})

local extra = autoplayTab:AddRightGroupbox({ Text = "Extra" })
local showNull
local moreStats = extra:AddToggle({
	Text = "Extra Stats",
	Value = lib.MoreStats,
	Callback = function(val)
		lib.MoreStats = val and (showNull.Value and "<font color=\"#BB33FF\">NullFire</font>" or true) or false
	end
})

showNull = extra:AddCheckBox({
	Text = "NullFire in extra stats",
	Value = lib.MoreStats ~= false,
	Callback = function(val)
		if moreStats.Value then
			moreStats:Set(false)
			moreStats:Set(true)
		end
	end
})

local useLegacy = autoplay:AddCheckBox({
	Text = "Use Legacy Auto-Play settings",
	Value = false,
	Callback = refresh
})

re = function()
	legacy.Visible = useLegacy.Value
	autoplaySettings.Visible = not useLegacy.Value

	if useLegacy.Value then
		for i, v in legacyChances do
			lib.Chances[i] = v.Value
		end

		lib.KPS.Global = kps.Value
		lib.KPS.PerKey = kpspk.Value
		lib.HoldDuration.Value = hd.Value / 1000
		lib.HoldDuration.Random = hdr.Value / 1000
		lib.Spray = spray.Value
	else
		local val = skill.Value
		local legit = le.Value
		local kps = lib.Display.KPS

		local lkps = lkps.Value
		local maxLegitKPS = lkps >= 3 and lkps <= 18 and clamp(lkps, 4, 17) or 1 / 0

		local div = val <= 50 and val / 50 or kps > (maxLegitKPS - 2) and legit and lerp((val - 50) / 50, 0, round((kps - (maxLegitKPS - 2)) / 25)) or (val - 50) / 50

		for i, v in (val <= 50 and {
			Sick = lerp(50, 90, div),
			Good = lerp(50, 60, div),
			Ok = lerp(40, 25, div),
			Bad = lerp(30, 5, div),
			Miss = lerp(20, 1, div)
			} or {
				Sick = lerp(90, 100, div),
				Good = lerp(60, 0, div),
				Ok = lerp(25, 0, div),
				Bad = lerp(5, 0, div),
				Miss = lerp(1, 0, div)
			}) do
			lib.Chances[i] = v
		end

		lib.KPS.Global = (legit and maxLegitKPS - 2 or 0) * 10
		lib.KPS.PerKey = legit and maxLegitKPS + 1 or 0
		lib.Spray = legit

		local val = hht.Value
		if val > 75 then
			local div = (100 - val) / 25
			lib.HoldDuration.Value, lib.HoldDuration.Random = lerp(0.25, 0.125, div), lerp(0.15, 0.1, div)
		elseif val > 50 then
			local div = (75 - val) / 25
			lib.HoldDuration.Value, lib.HoldDuration.Random = lerp(0.125, 0.067, div), lerp(0.1, 0.05, div)
		elseif val > 25 then
			local div = (50 - val) / 25
			lib.HoldDuration.Value, lib.HoldDuration.Random = lerp(0.067, 0.03, div), lerp(0.05, 0.03, div)
		else
			local div = (25 - val) / 25
			lib.HoldDuration.Value, lib.HoldDuration.Random = lerp(0.03, 0, div), lerp(0.03, 0, div)
		end
	end
end

re()
cons[#cons + 1] = game:GetService("RunService").Stepped:Connect(re)

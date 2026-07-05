local cons = { }
local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet("https://raw.githubusercontent.com/Null-Cherry/Utilities/refs/heads/main/Utility/Main.lua"))() end)()
local window = util:NullFireWindow()
local lib = util:FunkyFridayAutoPlay()

window = window(cons, ...)

cons[#cons + 1] = lib.Message:Connect(function(text)
	window:Notification({ Title = "Auto Play message", Text = text, Duration = 10 })
end)

local autoplayTab = window:AddTab("AP", { Text = "Auto Play", Icon = "l://play" })
autoplayTab:AddLabel({ Text = "Auto Player version: <b>" .. lib.Version .. "</b>" })
autoplayTab:AddLabel({ Text = "Quick fixes if autoplay does not work or works unstable:\n1. Change your note skin - sometimes autoplayer interprets your note skin as death/poison note\n2. Change your note skin from pure black - autoplayer also interprets them as death notes\n3. Hit Offset in Funky Friday's settings missmatch the one in the script\n4. Your executor rejects virtual inputs for some reason, try changing it\n5. Keybinds in Funky Friday settings aren't set properly" })
autoplayTab:AddLabel({ Text = "If you found any bug or have a suggestion, join our discord server (NullFire tab)!" })

local left = autoplayTab:AddLeftGroupbox({ Text = "Auto Play" })
local skill, legacy
local skillValue, holdingValue, isLegit
local legacyChances = { }
local kps, kpspk, hd, hdr, ps

local function lerpNumber(num, target, value)
	return num + (target - num) * value
end

local val
local legit

local function refreshValues()
	if skill.Visible then
		val = skillValue.Value
		legit = isLegit.Value

		lib.MaxKPS = 0
		if val <= 25 then
			local div = val / 25
			lib.Chances.Sick, lib.Chances.Good, lib.Chances.Ok, lib.Chances.Bad, lib.Chances.Miss = lerpNumber(0, 50, div), 50, lerpNumber(10, 5, div), lerpNumber(10, 5, div), lerpNumber(10, 5, div)
			lib.MaxKPSPerKey = legit and math.floor(lerpNumber(2, 4, div) + 0.25) or 0
		elseif val <= 50 then
			local div = (val - 25) / 25
			lib.Chances.Sick, lib.Chances.Good, lib.Chances.Ok, lib.Chances.Bad, lib.Chances.Miss = lerpNumber(50, 75, div), lerpNumber(50, 35, div), lerpNumber(5, 3, div), lerpNumber(5, 3, div), lerpNumber(5, 2, div)
			lib.MaxKPSPerKey = legit and math.floor(lerpNumber(4, 6, div) + 0.25) or 0
		elseif val <= 75 then
			local div = (val - 50) / 25
			lib.Chances.Sick, lib.Chances.Good, lib.Chances.Ok, lib.Chances.Bad, lib.Chances.Miss = lerpNumber(75, 97.5, div), lerpNumber(35, 5, div), lerpNumber(3, 0.1, div), lerpNumber(3, 0.01, div), lerpNumber(2, 0.005, div)
			lib.MaxKPSPerKey = legit and math.floor(lerpNumber(6, 10, div) + 0.25) or 0
		else
			local div = (val - 75) / 25
			lib.Chances.Sick, lib.Chances.Good, lib.Chances.Ok, lib.Chances.Bad, lib.Chances.Miss = lerpNumber(97.5, 100, div), lerpNumber(5, 0, div), lerpNumber(0.1, 0, div), lerpNumber(0.01, 0, div), lerpNumber(0.005, 0, div)
			lib.MaxKPSPerKey = legit and math.floor(lerpNumber(10, 14, div) + 0.25) or 0
		end

		local val = holdingValue.Value
		if val > 75 then
			local div = (100 - val) / 25
			lib.HoldDuration, lib.HoldDurationRandom = lerpNumber(0.5, 0.25, div), lerpNumber(0.3, 0.2, div)
		elseif val > 50 then
			local div = (75 - val) / 25
			lib.HoldDuration, lib.HoldDurationRandom = lerpNumber(0.25, 0.125, div), lerpNumber(0.2, 0.1, div)
		elseif val > 25 then
			local div = (50 - val) / 25
			lib.HoldDuration, lib.HoldDurationRandom = lerpNumber(0.125, 0.067, div), lerpNumber(0.1, 0.067, div)
		else
			local div = (25 - val) / 25
			lib.HoldDuration, lib.HoldDurationRandom = lerpNumber(0.067, 0, div), lerpNumber(0.067, 0, div)
		end
	else
		val, legit = false, false

		for i, v in legacyChances do
			lib.Chances[i] = v.Value
		end

		lib.MaxKPS = kps.Value
		lib.MaxKPSPerKey = kpspk.Value
		lib.HoldDuration = hd.Value
		lib.HoldDurationRandom = hdr.Value
	end
end

cons[#cons + 1] = game:GetService("RunService").RenderStepped:Connect(function()
	window.DisableBlurBackground = lib.Playing

	if legit then
		lib.PerfectSick = math.random() * 2
	else
		lib.PerfectSick = legacy.Visible and (ps.Value / 100) + 1 or 0
	end
end)

left:AddToggle({
	Text = "Auto Play enabled",
	Value = lib.AutoPlay,
	Callback = function(val)
		lib.AutoPlay = val
	end
})

left:AddToggle({
	Text = "Copy Enemy notes",
	Value = lib.CopyEnemyNotes,
	Tooltip = "I find this stupid",
	Callback = function(val)
		lib.CopyEnemyNotes = val
	end
})

left:AddSlider({
	Text = "Hit Offset",
	Value = lib.HitOffset * 1000,
	Min = -1000,
	Max = 1000,
	Step = 5,
	AllowSetValue = true,
	BypassSetValue = true,
	Compact = true,
	Format = function(self)
		return self.Value .. " ms"
	end,
	Callback = function(val)
		lib.HitOffset = val / 1000
	end
})

left:AddSeparator()

left:AddCheckBox({
	Text = "Use Scroll Speed buffer",
	Value = lib.UseScrollSpeedBuffer,
	Tooltip = "Used for more precise scroll speed calculations",
	Callback = function(val)
		lib.UseScrollSpeedBuffer = val
	end
})

left:AddSlider({
	Text = "Scroll Speed buffer size",
	Value = lib.ScrollSpeedBufferSize,
	Min = 0,
	Max = 3,
	Step = 0.05,
	AllowSetValue = true,
	Format = function(self)
		return self.Value .. " seconds"
	end,
	Callback = function(val)
		lib.ScrollSpeedBufferSize = val
	end
})

left:AddSeparator()

local round = math.round
left:AddSlider({
	Text = "Performance",
	Tooltip = "More value = less lags during the game (removes some game's details to increase FPS)",
	Value = lib.Performance,
	Min = 0,
	Max = 7,
	Step = 1,
	AllowSetValue = true,
	BypassSetValue = true,
	Compact = true,
	Format = function(self)
		return round((self.Value / self.Max) * 100) .. "%"
	end,
	Callback = function(val)
		lib.Performance = val
	end
})

left:AddCheckBox({
	Text = "Use Legacy settings",
	Value = lib.AutoPlay,
	Callback = function(val)
		legacy.Visible = val
		skill.Visible = not val
		refreshValues()
	end
})

left:AddCheckBox({
	Text = "Detect SV",
	Value = lib.DetectSV,
	Tooltip = "Applies automatic settings when SV song is detected",
	Callback = function(val)
		lib.DetectSV = val
	end
})

skill = autoplayTab:AddRightGroupbox({ Text = "Autoplayer Skill", Visible = true })
skillValue = skill:AddSlider({
	Text = "Skill",
	Value = 100,
	Min = 0,
	Max = 100,
	Step = 1,
	Format = "%",
	Compact = true,
	AllowSetValue = true,
	Callback = refreshValues
})

holdingValue = skill:AddSlider({
	Text = "Holding Time",
	Value = 0,
	Min = 0,
	Max = 100,
	Step = 1,
	Compact = true,
	AllowSetValue = true,
	Callback = refreshValues
})

isLegit = skill:AddToggle({
	Text = "Legit Mode",
	Tooltip = "Limits your KPS and makes Sick hits more real",
	Value = false,
	Callback = refreshValues
})

val = skillValue.Value
legit = isLegit.Value
refreshValues()

legacy = autoplayTab:AddRightGroupbox({ Text = "Legacy settings", Visible = false })

for i, v in { "Sick", "Good", "Ok", "Bad", "Miss" } do
	legacyChances[v] = legacy:AddSlider({
		Text = v .. " Chance",
		Value = lib.Chances[v],
		Min = 0,
		Max = 100,
		Step = 0.1,
		Compact = true,
		AllowSetValue = true,
		Callback = refreshValues,
		Format = "%"
	})
end

legacy:AddSeparator()

ps = legacy:AddSlider({
	Text = "Perfect Sick",
	Tooltip = "If you have bad device, make perfect sick early",
	Value = (lib.PerfectSick * 100) - 100,
	Min = -100,
	Max = 100,
	Step = 1,
	AllowSetValue = true,
	Format = function(self)
		local val = self.Value
		return val < -10 and "Early (" .. (-val) .. "%)" or (val >= -10 and val <= 10) and "Perfect Sick" .. (val == 0 and "" or val < 0 and " (" .. (-val) .. "% early)" or " (" .. val .. "% late)") or "Late (" .. val .. "%)"
	end,
	Callback = refreshValues
})

kps = legacy:AddSlider({
	Text = "Max KPS",
	Tooltip = "0 = inf",
	Value = lib.MaxKPS,
	Min = 0,
	Max = 100,
	Step = 1,
	Compact = true,
	AllowSetValue = true,
	Callback = refreshValues
})

kpspk = legacy:AddSlider({
	Text = "Max KPS per key",
	Tooltip = "0 = inf",
	Value = lib.MaxKPSPerKey,
	Min = 0,
	Max = 35,
	Step = 1,
	Compact = true,
	AllowSetValue = true,
	Callback = refreshValues
})

legacy:AddSeparator()

hd = legacy:AddSlider({
	Text = "Hold Duration",
	Value = lib.HoldDuration,
	Min = 0,
	Max = 1,
	Step = 0.01,
	Compact = true,
	Callback = refreshValues,
	AllowSetValue = true,
	Format = function(self)
		return self.Value .. " ms"
	end
})

hdr = legacy:AddSlider({
	Text = "Hold Duration random",
	Value = lib.HoldDurationRandom,
	Min = 0,
	Max = 1,
	Step = 0.01,
	Compact = true,
	Callback = refreshValues,
	AllowSetValue = true,
	Format = function(self)
		local val = self.Value
		return val ~= 0 and "-" .. val .. " to " .. val .. " ms" or "0 ms"
	end
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

showNull = extra:AddToggle({
	Text = "NullFire in extra stats",
	Value = lib.MoreStats ~= false,
	Callback = function(val)
		if moreStats.Value then
			moreStats:Set(false)
			moreStats:Set(true)
		end
	end
})

local infoTab = window:AddTab("IT", { Text = "Info", Icon = "l://info" })
local meanings = {
	[0] = "<b><font color=\"#FF4444\">Not Supported</font></b>",
	[1] = "<b><font color=\"#FF8833\">Poorly Supported</font></b>",
	[2] = "<font color=\"#AADD33\">Mostly Supported</font>",
	[3] = "<font color=\"#33FF33\">Supported</font>",
}

infoTab:AddLabel({
	Text = "Here you can see what Auto Player currently supports or not"
})

infoTab:AddSeparator({ Invisible = true })

local text = ""
local supported = { }

for i, v in lib.Supported do
	supported[#supported + 1] = { i, v }
end

table.sort(supported, function(v1, v2)
	return v1[2] < v2[2]
end)

for _, v in supported do
	text ..= v[1] .. ": " .. meanings[v[2]] .. "\n"
end

infoTab:AddLabel({
	Text = text:sub(1, -2)
})

local c3n, clamp = Color3.new, math.clamp
local function paintText(text, color)
	return "<font color=\"#" .. c3n(clamp(color.R, 0, 1), clamp(color.G, 0, 1), clamp(color.B, 0, 1)):ToHex() .. "\">" .. text .. "</font>"
end

local text = ""
local offsetColors = {
	Sick = c3n(0.66, 0.33, 1),
	Good = c3n(0.33, 1, 0.5),
	Ok = c3n(1, 0.66, 0.5),
	Bad = c3n(1, 0.33, 0.5)
}

for idx, i in { "Sick", "Good", "Ok", "Bad" } do
	local v = tonumber(tostring(idx * 0.05):sub(1, 4))
	text ..= "<b>" .. paintText(i, offsetColors[i]) .. ": " .. paintText(tostring(v) .. " ms", c3n(0.33, 1, 0.5):Lerp(c3n(1, 0.66, 0.5), (idx - 1) / 3)) .. "</b>\n"
end

infoTab:AddLabel({
	Text = "<font size=\"20\">Hit offsets (positive and negative ms)</font>\n" .. text:sub(1, -2)
})

local ros = { }
for i, v in lib.ReadOnlyStats do
	ros[i] = v
end

local readOnlyStats = infoTab:AddLabel({ })
table.sort(ros)

local typeof, tostring, find, round, max, min = typeof, tostring, table.find, math.round, math.max, math.min
local add = { "Version", "AutoPlay" }
local ignoreValues = { "RenderDelta", "FPS", "SongNameColor" }
local always = { "Playing", "Side", "Version" }
local unknown = { "ScrollSpeed" }
local showIfNotZero = { "TotalNotes", "MyTotalNotes", "EnemyTotalNotes", "SongDuration", "SongRealDuration", "SongName", "Rate", "Lanes", "SongDifficulty", "SongName" }
local playing = lib.Playing
local prev = round(lib.ScrollSpeed * 10) / 10

for i, v in add do
	table.insert(ros, 1, v)
end

local function special(i)
	return i:lower() == i and i:upper() == i
end

local function isUpper(v)
	return not special(v) and v:upper() == v
end

local function isLower(v)
	return not special(v) and v:lower() == v
end

local function smart(str: string)
	local result = str:sub(1, 1):upper()
	for i = 2, #str do
		local v = str:sub(i, i)
		local prev = str:sub(max(i - 1, 1), max(i - 1, 1))
		local prevPrev = str:sub(max(i - 2, 1), max(i - 2, 1))
		local next = str:sub(min(i + 1, #str), min(i + 1, #str))

		result ..= ((isUpper(v) and not isUpper(prev) or isUpper(v) and isUpper(prev) and isUpper(prevPrev) and isLower(next)) and " " or "") .. v
	end

	return result
end

local q = "???"
local cq = paintText(q, c3n(0.4, 0.2, 1))

local function valueToString(val, add, mn, mx)
	if val == q then
		return cq
	end

	local t = typeof(val)
	local str = tostring(val)

	if t == "boolean" then
		return paintText(str, val and c3n(0.4, 0.2, 1) or c3n(1, 0.4, 0.2))
	elseif t == "number" then
		mn, mx = mn or 0, mx or 10

		return paintText(str .. (add or ""), c3n(0.3, 1, 0.3):Lerp(c3n(1, 0.3, 0.4), (val - mn) / (mx - mn)))
	end

	return str
end

local valueRanges = {
	NotesRendered = { 0, 100 },
	KPS = { 0, 20 },
	NotesVisible = { 0, 80 },
	ScrollSpeed = { 5, 20 },
	MyNotesRendered = { 0, 75 },
	EnemyNotesRendered = { 0, 60 },
	MyNotesVisible = { 0, 75 },
	EnemyNotesVisible = { 0, 60 },
	Rate = { -0.25, 2.75 },
	TimeLeft = { 5, 0 },
	TotalNotes = { 0, 5000 },
	MyTotalNotes = { 0, 3000 },
	EnemyTotalNotes = { 0, 3000 },
	Lanes = { -10, 9 },
}

local difficultyColors = {
	Easy = c3n(0.4, 0.2, 1),
	Normal = c3n(0.2, 1, 0.4),
	Hard = c3n(1, 0.4, 0.2),
	Alt = c3n(0.7, 0.3, 1),
	Mania = c3n(1, 0.2, 0.5),
	Lunatic = c3n(0.5, 0, 0),
	Insane = c3n(0.7, 0.7, 0.7),
	Expert = c3n(0.4, 0.2, 0.7),
	Corrupted = c3n(0.9, 0.5, 0.2)
}

local suffixes = {
	Rate = "x",
	SongDuration = " s",
	SongRealDuration = " s",
	TimeLeft = " s",
	ScrollSpeed = " p/f"
}

local function generateColorForUnknownDifficulty(diffStr: string)
	local c1, c2, c3 = diffStr:byte(1, 3)
	return c3n(1 - (((c1 and ((c1 ^ 3) * 2) % 255) or 255) / 765), 1 - (((c2 and ((c2 ^ 3) * 2) % 255) or 255) / 765), 1 - (((c3 and ((c3 ^ 3) * 2) % 255) or 255) / 765))
end

local function refreshReadOnlyStats()
	local text = ""
	for _, i in ros do
		local v = lib[i]
		if typeof(v) ~= "table" and not find(ignoreValues, i) and (playing or find(always, i) or find(showIfNotZero, i) and v ~= 0 and v ~= "") then
			local str = valueToString((find(unknown, i) and (v == 0 or v == "") and q or (i ~= "ScrollSpeed" and v ~= nil and v or i == "ScrollSpeed" and prev or v)), suffixes[i] or "", unpack(valueRanges[i] or { }))
			if i == "SongName" then
				str = paintText(str, lib.SongNameColor or c3n())
			elseif i == "SongDifficulty" then
				str = paintText(str, difficultyColors[v] or generateColorForUnknownDifficulty(v))
			end
			
			text ..= smart(i) .. ": <b>" .. str .. "</b>\n"
		end
	end

	readOnlyStats.Text = text:sub(1, -2)
end

refreshReadOnlyStats()
cons[#cons + 1] = lib.Changed:Connect(function(i, v, r)
	if i == "Playing" then
		playing = v
	end

	unknown[2] = lib[unknown[1]] == 0 and "TimeLeft" or nil

	if (not find(ignoreValues, i) or i == "ScrollSpeed") and r then
		if i == "ScrollSpeed" then
			local calc = round(v * 10) / 10
			if calc == prev then
				return
			end

			prev = calc
		end

		refreshReadOnlyStats()
	end
end)

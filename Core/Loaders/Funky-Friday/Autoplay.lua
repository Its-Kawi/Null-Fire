local global = getgenv and getgenv() or _G
local key = "FFAutoplayLib"

local settings = {
	Version = "1.01", -- autoplayer version

	AutoPlay = false,
	PerfectSick = 0, -- 0 to 1, 0 = off, values above 1 can cause issues
	CopyEnemyNotes = false, -- I find this stupid

	Performance = 0, -- 0 - 5

	MaxKPSPerKey = 0, -- 0 or less = inf
	MaxKPS = 0, -- same here; MaxKPS limits keys per second for ALL keys, while MaxKPSPerKey limits keys per second for each key

	HoldDuration = 0,
	HoldDurationRandom = 0, -- both positive and negative

	MoreStats = false, -- if true, stats will have autoplayer stats also, if string, it will act as its "true", but will contain that one string on top of the stats

	Side = "Left", -- read only
	Playing = false, -- read only
	FPS = 0, -- read only
	NotesRendered = 0, -- read only
	KPS = 0, -- read only
	NotesVisible = 0, -- read only
	ScrollSpeed = 1, -- read only

	Chances = {
		Sick = 100,
		Good = 0,
		Ok = 0,
		Bad = 0,
		Miss = 0
	}
}

--[[ Extra readonly values:
Keybinds = { string }, -- #keybinds will return how much keys right now a song has, e.g. 4 keys, 9 keys
Events = { [string] = Event }

NoteAdded = Event(instance, isMine: boolean)
NoteRemoved = Event(instance, isMine: boolean)

KeybindsChanged = Event({ string })

GameStarted = Event()
GameEnded = Event()

Message = Event(string)
SettingChanged = Event(string, any) -- settings from the settings table below

----

print(settings.Keybinds[1]) -- will print the first keybind
]]

local readonlyStats = { "Side", "Playing", "FPS", "NotesRendered", "KPS", "NotesVisible" }

local fps, estFps, lastDelta = 0, 0, 0
local psick = false
local ap = false
local maxkpspk, maxkps = 0, 0
local hd, hdr = 0, 0
local scrollSpeed = 1
local cn = false
local perf = 0
local chances = settings.Chances
local rendered, total = 0, 0
local renderedOnLanes = { }

local tick = tick
local game, workspace = game, workspace
local wait, spawn = task.wait, task.spawn
local max, min, clamp, abs, random, round = math.max, math.min, math.clamp, math.abs, math.random, math.round
local inf = 1 / 0
local insert, remove, find, pack, unpack, clone, sort, concat = table.insert, table.remove, table.find, table.pack, unpack or table.unpack, --[[table.clone]] function(t) local copy = { } for i, v in t do copy[i] = v end return copy end, table.sort, table.concat
local v2, c3 = vector and vector.create or Vector2.new, Color3.new
local ipairs = ipairs
local tonumber, tostring = tonumber, tostring
local error = error
local pcall = pcall
local typeof = typeof
local smt = setmetatable
local rawset = rawset

local oldSettings = clone(settings)

local connectionBase = {
	Disconnect = function(self)
		rawset(self, "Connected", false)
	end,
	Fire = function(self, ...)
		if not self.Connected then
			error("Event is not connected!", 0)
		end

		if not self.Enabled then return end

		spawn(self.Callback, ...)
	end,
}

connectionBase = { __index = connectionBase }

local eventBase = {
	Connect = function(self, func)
		local connection = smt({ Callback = func, Connected = true, Enabled = true }, connectionBase)
		insert(self._Connections, connection)

		return connection
	end,
	Once = function(self, func)
		local con; con = self:Connect(function(...)
			con:Disconnect()
			con = nil

			func(...)
		end)

		return con
	end,
	Wait = function(self)
		local result
		self:Once(function(...)
			result = pack(...)
		end)

		repeat wait() until result
		return unpack(result, 1, result.n)
	end,
	Fire = function(self, ...)
		local cons = self._Connections
		for i = 1, #cons do
			local v = cons[i]
			if v and v.Connected then
				v:Fire(...)
			else
				remove(cons, i)
			end
		end
	end
}

eventBase = { __index = eventBase }

local newEvent = function()
	return smt({ _Connections = { } }, eventBase)
end

local settingChanged = newEvent()
settingChanged:Connect(function(setting, value)
	if setting == "AutoPlay" then
		ap = value
	elseif setting == "MaxKPSPerKey" then
		maxkpspk = value
	elseif setting == "MaxKPS" then
		maxkps = value
	elseif setting == "Chances" then
		chances = value
	elseif setting == "CopyEnemyNotes" then
		cn = value
	elseif setting == "HoldDuration" then
		hd = value
	elseif setting == "HoldDurationRandom" then
		hdr = value
	elseif setting == "Performance" then
		perf = value
	end
end)

local note = newEvent()
local noteRemoved = newEvent()
local gameStarted = newEvent()
local gameEnded = newEvent()
local message = newEvent()
local keybindsChanged = newEvent()

local events = { -- not actually only events
	Message = message,

	NoteAdded = note,
	NoteRemoved = noteRemoved,

	KeybindsChanged = keybindsChanged,

	SettingChanged = settingChanged, --setting, value

	GameStarted = gameStarted,
	GameEnded = gameEnded,
}

local function getUnrepeated(data)
	local n = #data
	local assignment = { }
	local used = { }

	local sortedIndices = { }
	for i = 1, n do sortedIndices[i] = i end

	sort(sortedIndices, function(a, b) return #data[a] < #data[b] end)

	local backtrack; backtrack = function(idx)
		if idx > n then return true end

		local setIdx = sortedIndices[idx]
		local candidates = { }

		for _, val in ipairs(data[setIdx]) do
			if not used[val] then
				insert(candidates, val)
			end
		end

		sort(candidates)

		for _, val in ipairs(candidates) do
			assignment[setIdx] = val
			used[val] = true

			if backtrack(idx + 1) then
				return true
			end

			used[val] = nil
			assignment[setIdx] = nil
		end

		return false
	end

	if backtrack(1) then
		local result = { }
		for i = 1, n do result[i] = assignment[i] end

		return result
	end

	return false
end

local function rollChance()
	local total = 0

	for _, weight in chances do
		total += weight
	end

	if total == 0 then
		local keys = { }
		for k in chances do
			keys[#keys + 1] = k
		end

		return keys[random(#keys)]
	end

	local r = random() * total
	local sum = 0

	for k, weight in chances do
		sum += weight
		if r <= sum then
			return k
		end
	end

	return "Sick"
end

local plr = game:GetService("Players").LocalPlayer
local pgui = plr:WaitForChild("PlayerGui", 9e9)
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local kk = Enum.KeyCode
local vim = game:GetService("VirtualInputManager")
local rse = rs.RenderStepped

local function r(times)
	local dt = tick()

	for i = 1, tonumber(times) or 1 do
		rse:Wait()
	end

	return tick() - dt
end

local fpsBuffer = { }
spawn(function()
	while true do
		lastDelta = r()
		fps = 1 / lastDelta
		psick = fps > 20 and settings.PerfectSick or 0

		local ffps = max(round(fps), 1)
		while #fpsBuffer >= ffps do
			remove(fpsBuffer, 1)
		end

		insert(fpsBuffer, fps)

		estFps = 0
		for i, v in fpsBuffer do
			estFps += v
		end

		estFps = clamp(round((estFps / #fpsBuffer) * 10) / 10, 0, 2e9)

		settings.FPS = estFps
		local ros = { }

		for _, v in readonlyStats do
			ros[v] = settings[v]
			settings[v] = 0
		end

		local changed = false
		for i, v in settings do
			if oldSettings[i] ~= v then
				changed = true
				settingChanged:Fire(i, v)
			end
		end

		if changed then
			oldSettings = clone(settings)
		end

		for i, v in ros do
			settings[i] = v
		end
	end
end)

local function getClosest(toIterate)
	if not plr.Character then return end

	local c, d = nil, inf

	for _, v in toIterate:GetChildren() do
		local m = (v:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude
		if m < d then
			c, d = v, m
		end
	end

	return c, d
end

local function getMyStage()
	if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Stages") then
		return getClosest(workspace.Map.Stages)
	end
end

local function getMySide()
	local stage = getMyStage()
	if stage then
		local node = getClosest(stage.Nodes)
		if node then
			return node.Name:sub(1, node.Name:find("_") - 1)
		end
	end
end

local side = getMySide() or "Left"
spawn(function()
	while wait(0.1) do
		side = getMySide() or side
		settings.Side = side
	end
end)

local lanes = 0
local isDownscroll = false
local downscrollPropability = 0
local power = 0.89

local hit = { }
local receptors = { }

local useX = false
local function UDimToVector2(ud)
	return v2(useX and ud.X.Scale or 0, ud.Y.Scale, 0)
end

local function getDistance(a, b)
	return (a - b).Magnitude
end

local kbVals = { }
local kbs = { }
local lastKbs = concat(kbs, ",")

events.Keybinds = kbs

local function refreshKbs(t)
	wait(t or 0)
	kbs = getUnrepeated(kbVals)

	local newKbs = concat(kbs, ",")
	if newKbs ~= lastKbs then
		lastKbs = newKbs
		settingChanged:Fire("Keybinds", kbs)

		events.Keybinds = kbs
		events.KeybindsChanged:Fire(kbs)
	end
end

local labelAdded; labelAdded = function(laneNum, label, cons)
	local textL = label:WaitForChild("Text", 9e9)
	kbVals[laneNum] = kbVals[laneNum] or { }

	local myIdx = #kbVals[laneNum] + 1
	kbVals[laneNum][myIdx] = textL.Text

	cons[#cons + 1] = textL:GetPropertyChangedSignal("Text"):Connect(function()
		if textL.TextTransparency >= 0.95 then return end
		kbVals[laneNum][myIdx] = textL.Text
		refreshKbs(0)
	end)
end

local rolled = { }
local actuallyVisible = 0

local function noteAdded(v, notest, mine)
	note:Fire(v, mine)

	insert(notest, v)

	renderedOnLanes[notest] = (renderedOnLanes[notest] or 0) + 1
	local visible = perf <= 4 or actuallyVisible < lanes * (5 / (scrollSpeed * 1.25)) and (renderedOnLanes[notest] < (7 / (scrollSpeed * 1.25)) or total % (7 / (scrollSpeed * 1.25)) == 0)
	local val = visible and 1 or 0

	total += 1

	settings.NotesRendered += 1
	rendered += 1
	actuallyVisible += val
	settings.NotesVisible += val

	v.Visible = visible -- because of multiplie lanes it will show really low amount of notes

	v:GetPropertyChangedSignal("Parent"):Wait()

	noteRemoved:Fire(v, mine)

	renderedOnLanes[notest] -= 1
	settings.NotesRendered -= 1
	rendered -= 1	
	actuallyVisible -= val
	settings.NotesVisible += val

	rolled[v] = nil
	hit[v] = false

	local found = find(notest, v)
	if found then
		remove(notest, found)
	end
end

local function laneAdded(lane, isMine, notest, cons)
	local laneNum = tonumber(lane.Name:sub(5))
	if not laneNum then return end

	notest[laneNum] = { }
	notest = notest[laneNum]

	local receptor = lane:WaitForChild("Receptor", 9e9)
	receptors[laneNum] = receptor

	if isMine then
		lanes = max(lanes, laneNum)
		wait(); r()

		if lanes == laneNum then
			local allNotes = { }
			local side = isMine

			for i = 1, lanes do
				local lane = side:FindFirstChild("Lane" .. i)
				if lane then
					local notes = lane:FindFirstChild("Notes")
					if notes then
						for _, v in notes:GetChildren() do
							insert(allNotes, v)
						end
					end
				end
			end

			local n = #allNotes
			if n ~= 0 then
				local topOnes = 0

				for _, v in allNotes do
					if v.Position.Y.Scale < receptor.Position.Y.Scale + 0.5 then
						topOnes += 1
					end
				end

				isDownscroll = topOnes / n > 0.5
				downscrollPropability = isDownscroll and 1 or -1
			end
		end
	end

	local notes = lane:WaitForChild("Notes", 9e9)
	local children = notes:GetChildren()

	if #children ~= 0 then
		local unsorted = { }
		for _, v in children do
			insert(unsorted, v)
		end

		sort(unsorted, function(a, b)
			local bool = a.Position.Y.Scale > b.Position.Y.Scale
			if isDownscroll then
				bool = not bool
			end

			return bool
		end)

		for i = 1, #unsorted do
			spawn(noteAdded, unsorted[i], notest, not not isMine)
		end
	end

	cons[#cons + 1] = notes.ChildAdded:Connect(function(v)
		local downscroll = v.Position.Y.Scale < receptor.Position.Y.Scale + 0.5
		downscrollPropability = clamp((downscroll and power or -power) + downscrollPropability, -1, 1)
		isDownscroll = downscrollPropability > 0

		local found = find(notest, v)
		if found then
			remove(notest, found)
		end

		noteAdded(v, notest, not not isMine)
	end)

	local labels = lane:WaitForChild("Labels", 9e9)
	for i, v in labels:GetChildren() do
		spawn(labelAdded, laneNum, v, cons)
	end

	cons[#cons + 1] = labels.ChildAdded:Connect(function(v)
		spawn(labelAdded, laneNum, v, cons)
	end)

	spawn(refreshKbs, 0)
end

local offsets = {
	Sick = 0.05,
	Good = 0.1,
	Ok = 0.15,
	Bad = 0.2,
	Miss = 0.3
}

for i, v in offsets do
	if i ~= "Miss" then
		offsets[i] = v - 0.01
	end
end

local downKeys, keys = { }, { }
local ske = vim.SendKeyEvent

local KPS = 0
local kps = { }

local function press(key, isDown)
	ske(vim, isDown, key, false, game)
end

local function kpsP(key)
	kps[key] += 1
	KPS += 1
	settings.KPS += 1

	wait(1)

	kps[key] -= 1
	KPS -= 1
	settings.KPS -= 1
end

local function kpsCount(key)
	if maxkps > 0 and KPS > maxkps then return true end

	kps[key] = kps[key] or 0
	if maxkpspk > 0 and kps[key] > maxkpspk then return true end

	spawn(kpsP, key)
end

local function pressKey(key, duration)
	local kk = kk:FromName(key)
	if downKeys[key] then
		downKeys[key] = false
		press(kk, false)
	end

	if kpsCount(key) then return end

	local myId = (keys[key] or 0) + 1
	keys[key] = myId

	press(kk, true)

	if duration and duration > 0 then
		downKeys[key] = true
		wait(duration)
	end

	if keys[key] == myId then
		downKeys[key] = false
		press(kk, false)
	end
end

local function isBehind(x, y)
	local is = x.Y > y.Y
	if isDownscroll then
		is = not is
	end

	return is
end

local rolled = { }
local function roll(note)
	local n = rolled[note]
	if not n then
		n = rollChance()
		rolled[note] = n
	end

	return n
end

local speed = 4 -- = 1
local speedBuffer = { }

local function canHit(note, receptor)
	local x = UDimToVector2(receptor.Position) + v2(useX and 0.5 or 0, 0.5, 0)
	local y = UDimToVector2(note.Position)

	local dist = getDistance(x, y) / speed

	if isBehind(x, y) then
		return dist <= offsets.Bad, true, dist, false
	end

	local rolled = roll(note)
	return dist <= offsets[rolled], false, dist, rolled == "Sick"
end

local one = UDim2.fromScale(1, 1)
local lastOffset = 0

spawn(function()
	while true do
		lastOffset = (wait(0.1) - 0.1) / 2
	end
end)

local function hitNote(note, key, dist, sick)
	if sick and psick > 0 then
		local t = dist * psick - lastOffset
		if t > 0 then
			wait(t)
		end
	end

	if hit[note] then return end
	hit[note] = true

	local time = hd
	if hdr > 0 then
		time += (random() - 0.5) * 2 * hdr
	end

	for _, v in note:GetChildren() do
		if v and v.Size ~= one then
			time += abs(v.Size.Y.Scale / speed) + 0.1
			break
		end
	end

	spawn(pressKey, key, time > 0 and time)
end

local function hitLane(lane, laneIndex, receptor)
	if not receptor then return end

	local key = kbs[laneIndex]
	local meetYouAgain
	local maxIterations = #lane * 3
	local iterations = 0

	while #lane ~= 0 and key and iterations < maxIterations do
		iterations += 1

		local note = lane[1]
		if note == meetYouAgain then break end

		local can, far, dist, sick = canHit(note, receptor)
		if can then
			remove(lane, 1)
			spawn(hitNote, note, key, dist, sick)
		elseif not far then
			if meetYouAgain then
				local pos = find(lane, meetYouAgain)
				if pos then
					insert(lane, 1, remove(lane, pos))
				end
			end

			break
		elseif not meetYouAgain then
			meetYouAgain = note
			insert(lane, remove(lane, 1))
		end
	end
end

local notified = false
local ssMul = 1 / 6 * 100
local minSpeed = 0.25 / 6

local function calculateNotes(notes)
	local start
	for laneIndex, lane in notes do
		local receptor = receptors[laneIndex]

		if receptor then
			for _, note in lane do
				start = { UDimToVector2(note.Position), note, UDimToVector2(receptor.Position), receptor }
				break
			end
		end

		if start then
			break
		end
	end

	local delta = r()
	if not start then return end -- no notes
	
	local travel = UDimToVector2(start[4].Position) - start[3]
	if travel.Magnitude > 0.01 and not notified then
		notified = true
		message:Fire("Autoplayer might have issues with ModCharts!")
	end

	local gotSpeed = clamp(getDistance(start[1], UDimToVector2(start[2].Position) - travel) / delta, 0.4, 24)
	if gotSpeed < 25 and gotSpeed > 0.0375 then
		while #speedBuffer >= fps do
			remove(speedBuffer, 1)
		end

		insert(speedBuffer, gotSpeed)

		local avgSpeed = 0
		for i, v in speedBuffer do
			avgSpeed += v
		end

		speed = avgSpeed / #speedBuffer
		scrollSpeed = round(speed * ssMul) / 100
		
		settings.ScrollSpeed = scrollSpeed
	end

	for laneIndex, lane in notes do
		spawn(hitLane, lane, laneIndex, receptors[laneIndex])
	end
end

local function mainLoop(fields, window, dontStartAutoplay)
	local mySide = fields[side]:WaitForChild("Inner", 9e9)
	local enemySide = fields[side == "Left" and "Right" or "Left"]:WaitForChild("Inner", 9e9)

	local myNotes = { }
	local enemyNotes = { }

	local cons = { }

	for i, v in mySide:GetChildren() do
		spawn(laneAdded, v, mySide, myNotes, cons)
	end

	cons[#cons + 1] = mySide.ChildAdded:Connect(function(v)
		laneAdded(v, mySide, myNotes, cons)
	end)

	for i, v in enemySide:GetChildren() do
		spawn(laneAdded, v, false, enemyNotes, cons)
	end

	cons[#cons + 1] = enemySide.ChildAdded:Connect(function(v)
		laneAdded(v, false, enemyNotes, cons)
	end)

	if not dontStartAutoplay then
		spawn(refreshKbs, 0)
	end

	while true do
		if not window.Parent then break end

		if ap and not dontStartAutoplay then
			local iHaveNotes = false
			for _, v in myNotes do
				for _ in v do
					iHaveNotes = true
					break
				end

				if iHaveNotes then break end
			end

			calculateNotes(not iHaveNotes and cn and enemyNotes or myNotes)
		else
			r()
		end
	end

	for i, v in cons do
		v:Disconnect()
	end
end

local function statsAdded(stats, cons)
	if stats:FindFirstChild("Title") then return end

	local row = stats:WaitForChild("Combo", 9e9):Clone()
	local rows = { }
	local totalRows = 0

	local function addRow(name, isFirst)
		local safeName = name:gsub(" ", "")
		local row = row:Clone()
		row.Name = safeName
		row.LayoutOrder = isFirst and -999 or 999 + totalRows
		row.Parent = stats

		totalRows += 1

		local label = row.Label
		label.Text = name .. ": null"

		local fn = function(_, value, prefix)
			row.Visible = true
			if typeof(value) == "string" then
				label.Text = value
			elseif tonumber(value) then
				label.Text = name .. ": " .. (prefix or "") .. value
			else
				row.Visible = false
			end
		end

		rows[safeName] = fn
		return fn
	end

	addRow("Title", true)
	addRow("Total Notes")
	addRow("Rendered")
	addRow("Scroll Speed")
	addRow("Autoplay KPS")
	addRow("FPS")

	cons[#cons + 1] = rse:Connect(function()
		local hs = settings.MoreStats
		if hs then
			rows:Title(typeof(hs) == "string" and hs or false)
			rows:Rendered("Rendered: " .. actuallyVisible .. " (" .. rendered .. ")")
			rows:TotalNotes(total, "~")
			rows:AutoplayKPS(KPS)
			rows:ScrollSpeed(scrollSpeed, "~")
			rows:FPS("FPS: <font color=\"#" .. (estFps < 60 and c3(1):Lerp(c3(0, 1), estFps / 60) or estFps < 120 and c3(0, 1):Lerp(c3(1, 0, 1), (estFps - 60) / 60) or estFps < 240 and c3(1, 0, 1):Lerp(c3(0.33, 0, 1), (estFps - 120) / 120) or c3(0.6, 0.2, 1)):ToHex() .. "\">" .. ("%.1f"):format(estFps) .. "</font>")
		else
			for i, v in rows do
				rows[i](nil, false)
			end
		end
	end)
end

local function set3d(enabled)
	rs:Set3dRenderingEnabled(enabled)
end

local gui = Instance.new("ScreenGui", pgui)
gui.Name = "Black"
gui.DisplayOrder = -999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = false

local black = Instance.new("Frame", gui)
black.BackgroundColor3 = c3()
black.Size = UDim2.fromScale(2, 2)
black.Position = UDim2.fromScale(0.5, 0.5)
black.AnchorPoint = Vector2.new(0.5, 0.5)
black.ZIndex = -999

local function onWindow(window, dontStartAutoplay)
	if window.Name ~= "Window" then return end

	gameStarted:Fire()

	lanes = 0
	total = 0
	kbVals = { }

	settings.Playing = true

	local cons = { }
	local gameField = window:WaitForChild("Game", 9e9)
	local fields = gameField:WaitForChild("Fields", 9e9)
	fields = {
		Left = fields:WaitForChild("Left", 9e9),
		Right = fields:WaitForChild("Right", 9e9)
	}

	spawn(mainLoop, fields, window, dontStartAutoplay)

	local hud = gameField:WaitForChild("HUD", 9e9)
	if hud:FindFirstChild("Stats") then
		spawn(statsAdded, hud.Stats, cons)
	end

	cons[#cons + 1] = hud.ChildAdded:Connect(function(child)
		if child.Name == "Stats" then
			statsAdded(child, cons)
		end
	end)

	local mySide = fields[side]
	local enemySide = fields[side == "Left" and "Right" or "Left"]
	local accuracy = hud:WaitForChild("AccuracyGauge", 9e9):WaitForChild("Ticks", 9e9)

	local function perfc(setting, value)
		if setting ~= "Performance" then return end

		mySide.Visible = value <= 5
		enemySide.Visible = value <= 2
		accuracy.Visible = value <= 1
		gui.Enabled = value >= 3

		pcall(set3d, value <= 3)
	end

	cons[#cons + 1] = settingChanged:Connect(perfc)
	perfc("Performance", perf)

	repeat wait() until not window.Parent

	gameEnded:Fire()

	settings.Playing = false
	gui.Enabled = false
	pcall(set3d, true)

	for i, v in cons do
		v:Disconnect()
	end
end

smt(settings, { __index = function(self, key) return key == "Events" and events or events[key] end })
global[key] = settings

local hasWindow = pgui:FindFirstChild("Window")
if hasWindow then
	spawn(onWindow, hasWindow, true)
end

spawn(function()
	while fps == 0 do r() end
	r()

	message:Fire("Autoplayer loaded!")
	
	if hasWindow then
		message:Fire("Unable to start the autoplay:\nScript must be ran before the game starts")
	end
	
	local key = kk.RightAlt
	uis.InputBegan:Connect(function(kk)
		if kk == key then
			pressed = true
		end
	end)
	
	press(key, true)
	press(key, false)
    r(10)

    warn("Press check:", pressed)
end)

pgui.ChildAdded:Connect(onWindow)

for i, v in settings do
	settingChanged:Fire(i, v)
end

while fps == 0 do r() end
return settings

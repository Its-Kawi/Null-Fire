local global = getgenv and getgenv() or _G
local kp, kr = keypress, keyrelease
local key = "FFAutoplayLib"

if global[key] then
	return global[key]
end

local settings = {
	Version = "1.2", -- autoplayer version

	AutoPlay = false,
	PerfectSick = 1, -- 0 to 1, 0 = off, values above 1 can cause issues
	CopyEnemyNotes = false, -- I find this stupid

	Performance = 0, -- 0 - 5. More value = less lags

	MaxKPSPerKey = 0, -- 0 or less = inf
	MaxKPS = 0, -- same here; MaxKPS limits keys per second for ALL keys, while MaxKPSPerKey limits keys per second for each key

	HoldDuration = 0.075,
	HoldDurationRandom = 0.025, -- both positive and negative

	MoreStats = false, -- if true, stats will have autoplayer stats also, if string, it will act as its "true", but will contain that one string on top of the stats

	Side = "Left", -- read only
	Playing = false, -- read only
	FPS = 0, -- approximated fps value, read only
	NotesRendered = 0, -- how many notes there currently is, read only
	KPS = 0, -- read only
	NotesVisible = 0, -- how many notes are visible right now (this can be lower than rendered, because of performance option), read only
	ScrollSpeed = 0, -- is not game's scroll speed, is calculated scroll speed; usually that value 3-6 times bigger than game's scrollspeed value, read only
	DownScroll = false, -- on ModChart songs it sometimes can freak out, read only
	Lanes = 0, -- e.g. how much keys are in the song (4, 5, 6, 7, 8, 9), read only
	RenderDelta = 0, -- a literal (tick() - start) time between RenderStepped events, read only

	Chances = {
		Sick = 100,
		Good = 0,
		Ok = 0,
		Bad = 0, -- wont always hit the "Bad", very often it will hit the `Ok`
		Miss = 0 -- sometimes when `Miss` note and any other note are coming close, they both will be hit
	}
}

--[[ Extra readonly values:
Keybinds = { string }
Events = { [string] = Event } -- a table that stores next events:

NoteAdded = Event(instance, isMine: boolean)
NoteRemoved = Event(instance, isMine: boolean)

KeybindsChanged = Event({ string })

GameStarted = Event()
GameEnded = Event()

Message = Event(string)

SettingChanged = Event(string, any) -- settings from the settings table below, does not apply for readonly values
Changed = Event(string, any, isReadOnly: bool) -- same as previous one, but being fired ALSO for readonly values (e.g. normal values are being fired also)

----

print(settings.Keybinds[1]) -- will print the first keybind

----

Each Event has
	:Connect(func) -> Connection
	:Once(func) -> Connection
	:Wait() -> Any -- uses task.wait(), so its not instant

Each Connection has
	.Connected : bool
	.Enabled : bool
	.Callback : function
	:Disconnect() -> never
]]

local readonlyStats = { "Side", "Playing", "FPS", "NotesRendered", "KPS", "NotesVisible", "ScrollSpeed", "DownScroll", "Lanes", "RenderDelta" }

local fps, estFps, lastDelta = 0, 0, 0
local psick = false
local ap = false
local maxkpspk, maxkps = 0, 0
local hd, hdr = 0, 0
local scrollSpeed = 0
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

local function toN(n)
	return tonumber(n) or n
end

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
	end
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
local changed = newEvent()

local note = newEvent()
local noteRemoved = newEvent()
local gameStarted = newEvent()
local gameEnded = newEvent()
local message = newEvent()
local keybindsChanged = newEvent()

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
		hd = abs(value)
	elseif setting == "HoldDurationRandom" then
		hdr = abs(value)
	elseif setting == "Performance" then
		perf = value
	end
end)

local events = { -- not actually only events
	Message = message,

	NoteAdded = note,
	NoteRemoved = noteRemoved,

	KeybindsChanged = keybindsChanged,

	SettingChanged = settingChanged, -- (setting, value)
	Changed = changed, -- save as previous one, but applies also for readonly values

	GameStarted = gameStarted,
	GameEnded = gameEnded
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
local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

local function r(times)
	local dt = tick()

	for i = 1, tonumber(times) or 1 do
		rse:Wait()
	end

	return tick() - dt
end

local function getAverage(t)
	local avg = 0
	local l = #t

	for i = 1, l do
		avg += t[i]
	end

	avg = avg / l
	return avg ~= avg and 0 or avg
end

local function append(t, v, s)
	s = max(round(s), 1)
	local len = #t
	if len >= s then
		remove(t, 1, len - s + 1)
	end

	insert(t, v)
	return getAverage(t)
end

local fpsBuffer = { }
local readonlyLookup = { }
local oldChances = clone(settings.Chances)

for _, v in readonlyStats do
	readonlyLookup[v] = true
end

spawn(function()
	while true do
		lastDelta = r()
		fps = 1 / lastDelta
		psick = fps > 20 and settings.PerfectSick or 0

		append(fpsBuffer, fps, fps)
		estFps = round(append(fpsBuffer, fps, fps) * 10) / 10

		settings.FPS = estFps
		settings.RenderDelta = lastDelta

		local Changed = false
		local chancesChanged = false
		
		for i, v in settings do
			if oldSettings[i] ~= v then
				local isReadOnly = readonlyLookup[i]
				if not isReadOnly then
					settingChanged:Fire(i, v)
				end
				
				changed:Fire(i, v, isReadOnly)
				Changed = true
				chancesChanged = chancesChanged or i == "Chances"
				oldSettings[i] = v
			end
		end
		
		if not chancesChanged then
			local chances = settings.Chances
			Changed = false
			
			for i, v in chances do
				if oldChances[i] ~= v then
					Changed = true
                    oldChances[i] = v
				end
			end

            if Changed then
				settingChanged:Fire("Chances", chances)
				changed:Fire("Chances", chances, false)
            end
		end
	end
end)

local function getDistance(a, b)
	return (a - b).Magnitude
end

local function getClosest(toIterate)
	if not plr.Character then return end

	local c, d = nil, inf

	for _, v in toIterate:GetChildren() do
		local m = getDistance(v:GetPivot().Position, plr.Character:GetPivot().Position)
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
local lanes = 0
local isDownScroll = false
local downscrollPropability = 0
local power = 3 -- idc

local hit = { }

local useX = true
local function UDimToVector2(ud)
	return v2(useX and ud.X.Scale or 0, ud.Y.Scale, 0)
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

local function raceEvents(events, timeout)
	timeout = timeout or 1

	local last = tick()
	local cons = { }
	local winner

	for i, v in events do
		cons[#cons + 1] = v:Once(function()
			winner = i

			for idx, val in cons do
				val:Disconnect()
			end
		end)
	end

	repeat wait() until winner or tick() - last > timeout

	winner = winner or 0
	for idx, val in cons do
		val:Disconnect()
	end

	return winner
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
local badNotes = { }
local isModChart = false
local badNoteAssets = { "rbxassetid://116778203667435", "rbxassetid://116254476280414", "rbxassetid://91620137594170", "rbxassetid://84581380793886", "rbxassetid://74989444694115" }
local actuallyVisible = 0

local gpcsCache = { }
local function gpcs(v, n)
	local cache = gpcsCache[toN(v.Name)] or { }
	gpcsCache[v] = cache

	local got = cache[n] or v:GetPropertyChangedSignal(n)
	cache[n] = got

	return got
end

local dummy = { }
local function noteAdded(v, notest, mine, lane)
	note:Fire(v, mine, lane)

	local isGood = not find(badNoteAssets, v:WaitForChild("LayeredSprite", 9e9):WaitForChild("2", 9e9).Image)
	local toInsert
	if isGood then
		toInsert = notest
		rolled[v] = rollChance()
	elseif mine then
		toInsert = badNotes[lane] or { }
		badNotes[lane] = toInsert
	else
		toInsert = dummy
	end

	insert(toInsert, v)

	renderedOnLanes[lane] = renderedOnLanes[lane] or 0
	local visible = perf >= 4 and mine and renderedOnLanes[lane] <= 64 // scrollSpeed and (renderedOnLanes[lane] <= 16 // scrollSpeed or renderedOnLanes[lane] % (8 * scrollSpeed // 1) == 0) or perf < 4
	local val = visible and 1 or 0

	renderedOnLanes[lane] += val
	total += 1

	settings.NotesRendered += 1
	rendered += 1
	actuallyVisible += val
	settings.NotesVisible += val

	v.Visible = visible

	gpcs(v, "Parent"):Wait()

	noteRemoved:Fire(v, mine, lane)

	renderedOnLanes[lane] -= val
	settings.NotesRendered -= 1
	rendered -= 1	
	actuallyVisible -= val
	settings.NotesVisible += val

	local found = find(toInsert, v)
	if found then
		remove(toInsert, found)
	end
end

local function sortF(a, b)
	local cond = a.Position.Y.Scale > b.Position.Y.Scale
	if isDownScroll then
		cond = not cond
	end

	return cond
end

local function laneAdded(lane, isMine, notest, cons, receptors)
	local laneNum = tonumber(lane.Name:sub(5))
	if not laneNum then return end

	notest[laneNum] = { }
	notest = notest[laneNum]

	local receptor = lane:WaitForChild("Receptor", 9e9)

	receptors[laneNum] = receptor

	if isMine then
		lanes = max(lanes, laneNum)
		settings.Lanes = lanes
		
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

				isDownScroll = topOnes / n > 0.5
				downscrollPropability = isDownScroll and 1 or -1
				settings.DownScroll = isDownScroll
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

		sort(unsorted, sortF)
		for i = 1, #unsorted do
			spawn(noteAdded, unsorted[i], notest, not not isMine, laneNum)
		end
	end

	cons[#cons + 1] = notes.ChildAdded:Connect(function(v)
		local downscroll = v.Position.Y.Scale < receptor.Position.Y.Scale + 0.5
		downscrollPropability = clamp((downscroll and power or -power) + downscrollPropability, -1, 1)
		isDownScroll = downscrollPropability > 0
		settings.DownScroll = isDownScroll

		local found = find(notest, v)
		if found then
			remove(notest, found)
		end

		noteAdded(v, notest, not not isMine, laneNum)
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
		offsets[i] = v - 0.005
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
	if isDownScroll then
		is = not is
	end

	return is
end

local speed = 0
local canHit; canHit = function(note, receptor, isBadNote, laneIndex)
	local x = UDimToVector2(receptor.Position) + v2(useX and 0.5 or 0, 0.5, 0)
	local y = UDimToVector2(note.Position)

	local dist = getDistance(x, y) / speed
	if isBadNote then
		return dist, isBehind(x, y)
	else
		local bad = badNotes[laneIndex]
		local forceSick = false

		if bad then
			for i, v in bad do
				local d, b = canHit(v, note, true, laneIndex)
				forceSick = forceSick or b and 1
				if b and d < offsets.Miss or not b and d < dist then
					return false, false, dist, false, false
				end
			end
		end

		if isBehind(x, y) then
			return dist <= offsets.Bad, true, dist, false, false
		end

		local rolled = forceSick and "Sick" or rolled[note] or "Sick"
		return rolled ~= "Miss" and dist <= offsets[rolled], false, dist, rolled == "Sick", forceSick
	end
end

local one = UDim2.fromScale(1, 1)
local lastOffset = 0

spawn(function()
	while true do
		lastOffset = (wait(0.1) - 0.1) / 1.5
		side = getMySide() or side
		settings.Side = side
	end
end)

local function sortLane(lane)
	sort(lane, sortF)
end

local function hitNote(note, key, dist, sick, lane, force)
	local s = force or psick
	if sick and s > 0 then
		local t = dist * s - lastOffset
		if t > 0 then
			wait(t)
		end
	end

	if hit[note] then return end
	hit[note] = true

	local time = hd
	if hdr > 0 then
		time += (random() - 0.5) * 2 * abs(hdr)
	end

	local holdTime = 0
	for _, v in note:GetChildren() do
		if v and v.Size ~= one then
			holdTime = abs(v.Size.Y.Scale / speed) + 0.1
			break
		end
	end

	time += holdTime
	if holdTime ~= 0 then
		pressKey(key, time > 0 and time)
	else
		spawn(pressKey, key, time > 0 and time)
	end

	local winner = raceEvents({ gpcs(note, "Parent"), gpcs(note, "Position") }, 0)
	hit[note] = false

	if winner ~= 0 and note.Parent and not find(lane, note) then
		insert(lane, 1, note)
		spawn(sortLane, lane)
	end
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

		local can, far, dist, sick, force = canHit(note, receptor, false, laneIndex)
		if can then
			remove(lane, 1)
			spawn(hitNote, note, key, dist, sick, lane, force)
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

local function notif(text)
	while #message._Connections == 0 do wait() end
	message:Fire(text)
end

local function msg(text)
	spawn(notif, text)
end

local ssMul = 1 / 5 * 100

local function swap(val)
	val[1] = v2(-(val[1].X - 0.5) + 0.5, -(val[1].Y - 0.5) + 0.5, 0)
	val[3] = v2(-val[3].X, -val[3].Y, 0)
end

local function isDownS(notes, receptors)
	local topOnes = 0
	local allNotes = 0
	
	for laneIndex, lane in notes do
		local receptor = receptors[laneIndex]
		
		if receptor then
			allNotes += #lane
			
			for _, note in lane do
				if note.Position.Y.Scale < receptor.Position.Y.Scale + 0.5 then
					topOnes += 1
				end
			end
		end
	end

	return topOnes / allNotes > 0.5
end

local function calculateNotes(notes, receptors)
	local startPositions = { }

	for laneIndex, lane in notes do
		local receptor = receptors[laneIndex]

		if receptor then
			for _, note in lane do
				insert(startPositions, { UDimToVector2(note.Position), note, UDimToVector2(receptor.Position), receptor, lane, laneIndex })
				break
			end
		end
	end

	local delta = r()
	if #startPositions == 0 then return end -- no notes

	local gotSpeed = 0
	local dlt = min(delta, 0.1)
	
	if not isModChart and ap then
		for _, v in startPositions do
			if getDistance(UDimToVector2(v[4].Position), v[3]) / dlt > 0.1 then
				isModChart = true
				break
			end
		end
	end
	
	if isModChart and ap then
		local isDown = isDownS(notes, receptors)

		if isDownScroll ~= isDown then
			for i, v in startPositions do
				swap(v)
			end
		end
		
		isDownScroll = isDown
		settings.DownScroll = isDownScroll
	end

	for _, v in startPositions do
		gotSpeed += getDistance(UDimToVector2(v[2].Position) - (UDimToVector2(v[4].Position) - v[3]), v[1]) / delta
	end

	speed = gotSpeed / #startPositions
	scrollSpeed = round(speed * ssMul) / 100

	settings.ScrollSpeed = speed
	settings.IsModChart = isModChart

	for _, v in startPositions do
		spawn(hitLane, v[5], v[6], v[4])
	end
end

local function mainLoop(fields, window, dontStartAutoplay)
	local mySide = fields[side]:WaitForChild("Inner", 9e9)
	local enemySide = fields[side == "Left" and "Right" or "Left"]:WaitForChild("Inner", 9e9)

	local myNotes = { }
	local enemyNotes = { }
	local myReceptors = { }
	local enemyReceptors = { }

	local cons = { }

	for i, v in mySide:GetChildren() do
		spawn(laneAdded, v, mySide, myNotes, cons, myReceptors)
	end

	cons[#cons + 1] = mySide.ChildAdded:Connect(function(v)
		laneAdded(v, mySide, myNotes, cons, myReceptors)
	end)

	for i, v in enemySide:GetChildren() do
		spawn(laneAdded, v, false, enemyNotes, cons, enemyReceptors)
	end

	cons[#cons + 1] = enemySide.ChildAdded:Connect(function(v)
		laneAdded(v, false, enemyNotes, cons, enemyReceptors)
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

			local mine = iHaveNotes or cn
			calculateNotes(mine and myNotes or enemyNotes, mine and myReceptors or enemyReceptors)
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
	addRow("Autoplay KPS")
	addRow("FPS")

	cons[#cons + 1] = rse:Connect(function()
		local hs = settings.MoreStats
		if hs then
			rows:Title(typeof(hs) == "string" and hs or false)
			rows:Rendered("Rendered: " .. actuallyVisible .. " (" .. rendered .. ")")
			rows:TotalNotes(total, "~")
			rows:AutoplayKPS(KPS)
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
gui.ResetOnSpawn = false

local black = Instance.new("Frame", gui)
black.BackgroundColor3 = c3()
black.Size = UDim2.fromScale(2, 2)
black.Position = UDim2.fromScale(0.5, 0.5)
black.AnchorPoint = Vector2.new(0.5, 0.5)
black.ZIndex = -999
black.BackgroundTransparency = 1

local pressChecked = false
local function pressCheck()
	if pressChecked then return end
	pressChecked = true

	local key = kk.RightAlt
	local pressed = false

	local con = uis.InputBegan:Connect(function(kk)
		if kk.KeyCode == key then
			pressed = true
		end
	end)

	local function pressCheck()
		if pressed then return true end

		pcall(press, key, true)
		pcall(press, key, false)
		r(2)

		if pressed then
			con:Disconnect()
		end

		return pressed
	end

	local function WARN()
		msg("Autoplayer might don't work, because executor for some reason doesn't support key pressing, or rejects them")
	end

	if not pressCheck() then
		if kp and kr then
			local oldPress = press
			press = function(key, isDown)
				(isDown and kp or kr)(key.Name)
			end

			if not pressCheck() then
				press = function(key, isDown)
					(isDown and kp or kr)(key)
				end

				if not pressCheck() then
					press = oldPress
					WARN()
				end
			end
		else
			WARN()
		end
	end

	con:Disconnect()
end

local function onWindow(window, dontStartAutoplay)
	if window.Name ~= "Window" then return end

	gameStarted:Fire()

	lanes = 0
	total = 0
	kbVals = { }
	badNotes = { }
	speed = 0
	scrollSpeed = 0
	settings.ScrollSpeed = 0
	isModChart = false
	settings.IsModChart = false
	settings.Lanes = 0

	settings.Playing = true

	local cons = { }
	local gameField = window:WaitForChild("Game", 9e9)
	local fields = gameField:WaitForChild("Fields", 9e9)
	fields = {
		Left = fields:WaitForChild("Left", 9e9),
		Right = fields:WaitForChild("Right", 9e9)
	}

	if isMobile then
		spawn(pressCheck)
	end

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
		black.BackgroundTransparency = value >= 3 and 0 or 1

		pcall(set3d, value <= 3)
	end

	cons[#cons + 1] = settingChanged:Connect(perfc)
	perfc("Performance", perf)

	repeat wait() until not window.Parent

	gameEnded:Fire()

	settings.Playing = false
	black.BackgroundTransparency = 1
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

	if hasWindow then
		msg("Unable to start the autoplay:\nScript must be ran before the game starts")
	end

	if not isMobile then
		pressCheck()
	end
end)

pgui.ChildAdded:Connect(onWindow)

for i, v in settings do
	settingChanged:Fire(i, v)
end

while fps == 0 do r() end
return settings

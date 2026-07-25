-- Autoplayer API
-- Made with love
-- By Kawi

local settings = {
	Version = "2.0", -- autoplayer version
	
	Author = {
		DiscordServer = "https://discord.gg/4bexJD6WVT",
		Discord = "@its_kawi"
	},
	
	AutoPlay = true,
	CopyEnemyNotes = false, -- I find this stupid | When your lane has no arrows, it autoplays enemy's notes
	HitOffset = 0,
	
	Performance = {
		Notes = 0, -- 0 - 10. 0-8 decrease amount of notes that can be rendered, 9 hides opponent's side, 10 hides your's
		UI = 0, -- 0 - 3. 1 removes accuracy gauge, 2 removes indicators (sick, good, etc.), 3 hides the whole HUD 
		
		Disable3D = false
	},
	
	HoldDuration = {
		Value = 0.1, -- in seconds
		Random = 0.05 -- range: -25% to 100% | in seconds
	},
	
	MoreStats = true, -- if true, stats will have autoplayer stats also, if string, it will act as its "true", but will contain that one string on top of the stats
	
	TimeLeft = 0,
	TimePassed = 0,
	SongRealDuration = 0,
	SongDuration = 0,
	
	ScrollSpeed = 0,
	
	Display = {
		Lanes = {
			Me = {
				TotalNotes = 0,
				NotesRendered = 0,
				NotesVisible = 0
			},
			Enemy = {
				TotalNotes = 0,
				NotesRendered = 0,
				NotesVisible = 0
			}
		},
		
		TotalNotes = 0,
		NotesRendered = 0,
		NotesVisible = 0,
		
		FPS = 0,
		KPS = 0,
		
		IsModChart = false,
		IsSV = false,
		
		Rate = 1,
		SongDifficulty = "",
		SongNameColor = Color3.new(1, 1, 1),
		SongName = "",
		TimeLeft = 0,
		SongDuration = 0,
		SongRealDuration = 0,
		TimePassed = 0,
	},
	
	Chances = {
		Sick = 100,
		Good = 0,
		Ok = 0,
		Bad = 0,
		Miss = 0
	},
	
	Supported = { -- 3 = supported, 2 = kinda supported, 1 = poorly supported, 0 = not supported
		["SV"] = 2,
		["Mod Charts"] = 3,
		["Multi-Key"] = 3,
		["60 FPS+"] = 3,
		["Low FPS"] = 3,
		["Down & Up scroll"] = 3,
		["Start Auto Play mid-song"] = 3
	}
}

local global = getfenv().getgenv and getfenv().getgenv() or _G
local key = "FFAutoplayLib"

if global[key] then
	return global[key]
end

local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet("https://raw.githubusercontent.com/Null-Cherry/Utilities/refs/heads/main/Utility/Main.lua"))() end)()
if global[key] then
	return global[key]
end

local event = util:Event()
local message = event.new()
local songStarted = event.new()
local songStopped = event.new()
local songStopped = event.new()
local noteAdded = event.new()
local noteRemoved = event.new()

settings.Message = message

settings.Events = {
	SongStarted = songStarted, -- (<CORE>)
	SongStopped = songStopped, -- (<CORE>)
	Message = message, -- (text, title)
	NoteAdded = noteAdded, -- (<NOTE>)
	NoteRemoved = noteRemoved -- (<NOTE>)
}

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")

local tick = tick
local spawn = task.spawn
local _wait = task.wait
local pcall = pcall
local max = math.max
local min = math.min
local error = error
local tonumber = tonumber
local insert = table.insert
local remove = table.remove
local find = table.find
local c3n = Color3.new
local random = math.random
local sort = table.sort
local abs = math.abs
local v2 = vector.create
local round = math.round
local clamp = math.clamp

local lastOffset = 0
local function wait(t)
	t = max(tonumber(t) or 0, 0)
	local took = _wait(t)

	if t == 0 then
		lastOffset = took - t
	end

	return took
end

local globalScrollSpeedBuffer = { }
local globalScrollSpeed = 0

local rate = 1
local timePassed = 0

spawn(function()
	local unpack = unpack or table.unpack
	local c3r, c3h = Color3.fromRGB, Color3.fromHex
	
	local function decodeTime(time)
		local split = time:split(":")
		if #split == 1 then return tonumber(time) end

		while #split < 4 do
			insert(split, 1, 0)
		end

		return (split[1] * 86400) + (split[2] * 3600) + (split[3] * 60) + split[4]
	end

	local topLabel = pgui:WaitForChild("GameGui"):WaitForChild("Screen"):WaitForChild("TopLabel"):WaitForChild("Label")
	topLabel.Changed:Connect(function()
		local text = topLabel.Text
		local splitted = text:split("\n")

		if #splitted == 3 then
			local l1, l3 = splitted[1], splitted[3]
			if l1:sub(-2, -1) == "x)" then
				local endBracket = -3
				while true do
					if l1:sub(endBracket, endBracket) == "(" then
						rate = tonumber(l1:sub(endBracket + 1, -3))
						settings.Display.Rate = rate
						break
					end

					endBracket -= 1
					if -endBracket > #l1 then
						settings.Display.Rate = 1
						break
					end
				end
			else
				settings.Display.Rate = 1
			end

			local difficultyStart = l1:find("</font> (", 0, true)
			if difficultyStart then
				local difficultyEnd = l1:find(")", difficultyStart, true)
				settings.Display.SongDifficulty = l1:sub(difficultyStart + 9, difficultyEnd - 1)
			end

			local colorStart = l1:find("><font color='", 0, true)
			if colorStart then
				local colorEnd = l1:find("'>", colorStart, true) + 1
				local color = l1:sub(colorStart + 14, colorEnd - 2):gsub("\n\r\f\t\s\0 ", ""):lower()

				if color:sub(1, 3) == "rgb" then
					settings.Display.SongNameColor = c3r(unpack(color:sub(5, -2):split(",")))
				elseif color:sub(1, 1) == "#" then
					settings.Display.SongNameColor = c3h(color:sub(2, -1))
				end
			end

			settings.Display.SongName = l1:sub((l1:find(")'>", 0, true)) + 3, (l1:find("</f", 0, true)) - 1)

			local s, r = pcall(decodeTime, l3:sub(1, -10))
			settings.Display.TimeLeft = s and r or 0
			settings.TimeLeft = settings.Display.TimeLeft
			settings.Display.SongDuration = max(settings.Display.TimeLeft, settings.Display["Song" .. "Duration"], 0) -- suspend studio warning
			settings.Display.SongRealDuration = round(settings.Display.SongDuration * settings.Display.Rate)
			settings.SongRealDuration = settings.Display.SongRealDuration

			timePassed = round((settings.Display.SongDuration - settings.Display.TimeLeft) * settings.Display.Rate)
			settings.Display.TimePassed = timePassed
			settings.TimePassed = settings.Display.TimePassed
		end
	end)
end)

local inputs = { }
local vsrgConnection, vsrgConn2

local scr = Enum.InputBindingType.Scriptable
local inpFire

local function onInput(v)
	local input
	local laneNum = tonumber(v.Name:sub(5))
	
	while not input and vsrgConnection do
		input = v:WaitForChild("GamepadBinding", 1) or v:WaitForChild("KeyboardBinding", 1)
	end

	if not input then return end
	input.Type = scr

	inputs[laneNum] = input
	inpFire = input.Fire
end

local function hookInputs(vsrgContext)
	inputs = { }
	
	vsrgConnection = vsrgContext:GetPropertyChangedSignal("Parent"):Connect(function()
		if not vsrgContext.Parent then
			inputs = { }
			vsrgConnection:Disconnect()
			vsrgConn2:Disconnect()
			vsrgConnection = nil
		end
	end)
	
	for i, v in vsrgContext:GetChildren() do
		onInput(v)
	end
	
	vsrgConn2 = vsrgContext.ChildAdded:Connect(onInput)
end

local fireLane
function fireLane(laneIndex, state)
	local inp = inputs[laneIndex]
	if not inp then return end
	
	local s, e = pcall(inpFire, inp, state)
	if not s then
		input.Type = scr
		fireLane(laneIndex, state)
	end
end

local laneStates = { }
local laneHitIndexes = { }
local KPS = 0

local function appendKPS()
	KPS += 1
	settings.Display.KPS = KPS
	wait(1)
	KPS -= 1
	settings.Display.KPS = KPS
end

local function hitLane(laneIndex, duration)
	duration = duration or 0
	
	if laneStates[laneIndex] then
		fireLane(laneIndex, false)
		laneStates[laneIndex] = false
	end

	spawn(appendKPS)
	fireLane(laneIndex, true)
	laneStates[laneIndex] = true
	
	laneHitIndexes[laneIndex] = (laneHitIndexes[laneIndex] or -1) + 1
	local myIndex = laneHitIndexes[laneIndex]
	
	if duration > 0 then
		wait(duration)
	end
	
	if laneHitIndexes[laneIndex] == myIndex then
		fireLane(laneIndex, false)
		laneStates[laneIndex] = false
	end
end

local function waitForChildError(object, childName, timeout)
	timeout = timeout or 30
	
	local ret = object:WaitForChild(childName, timeout)
	if not ret then
		error("Failed to find child \"" .. childName .. "\" in " .. object:GetFullName() .. " in " .. timeout .. " seconds", 0)
	end
	
	return ret
end

local function getAverage(t)
	local avg = 0
	local l = #t

	for i = 1, l do
		avg += t[i]
	end

	avg /= l
	return avg ~= avg and 0 or avg
end

local function append(table, value, size)
	local size = round(max(tonumber(size) or 0, 1))

	while #table >= size do
		remove(table, #table)
	end

	insert(table, 1, value)
	return getAverage(table)
end

local badNoteAssets = { "rbxassetid://103483801062498", "rbxassetid://88530467220950", "rbxassetid://109130876544260", "rbxassetid://120222801097284", "rbxassetid://101951481332606" }
local black = c3n()

local function rollChance()
	local total = 0

	for _, weight in settings.Chances do
		total += weight
	end

	local r = random() * total
	local sum = 0

	for k, weight in settings.Chances do
		sum += weight
		if r <= sum then
			return k
		end
	end

	return "Sick"
end

local useX = true
local function UDimToVector2(ud)
	return v2(useX and ud.X.Scale or 0, ud.Y.Scale, 0)
end

local function isDownS(data)
	local topOnes = 0
	local allNotes = #data.Notes
	local receptor = data.Receptor

	for laneIndex, note in data.Notes do
		if note.Note.Position.Y.Scale < receptor.Position.Y.Scale + 0.5 then
			topOnes += 1
		end
	end

	return topOnes / allNotes > 0.75
end

local function sortLane(data)
	local function sortF(a, b)
		local cond = a.Note.Position.Y.Scale < b.Note.Position.Y.Scale
		if data.IsDownScroll then
			cond = not cond
		end

		return cond
	end

	sort(data.Notes, sortF)
	sort(data.BadNotes, sortF)
end

local boolIdx = {
	[true] = "Me",
	[false] = "Enemy"
}

local total = 0
local renderStack = {
	[boolIdx[true]] = { },
	[boolIdx[false]] = { }
}

local function flushRenderStackLevel(stack, category, isMine, perf)
	local shouldRender = round(perf <= 0 and 1 / 0 or (perf >= 9 and not isMine or perf >= 10 and isMine) and 0 or (1000 / globalScrollSpeed) / min(perf, 8))
	local rendered = 0
	
	category.NotesRendered = #stack
	category.NotesVisible = shouldRender
	
	for _, v in stack do
		local vis = rendered < shouldRender
		v.Visible = vis
		rendered += vis and 1 or 0
		
		if not vis then
			break
		end
	end
	
	return rendered
end

local function flushRenderStack()
	local display = settings.Display
	local i = 0
	for catName, stack in renderStack do
		i += flushRenderStackLevel(stack, display.Lanes[catName], catName == boolIdx[true], settings.Performance.Notes)
	end
	
	settings.Display.NotesVisible = i
end

noteAdded:Connect(function()
	if settings.Performance.Notes > 0 then
		flushRenderStack()
	end
end)

noteRemoved:Connect(function()
	if settings.Performance.Notes > 0 then
		flushRenderStack()
	end
end)

local function onNote(note, data, sharedData, isNew, isMine)
	local sprite = note:WaitForChild("LayeredSprite"):WaitForChild("1")
	local isGood = sprite.ImageColor3 ~= black and not find(badNoteAssets, sprite.Image)
	local toInsert
	if isGood then
		toInsert = data.Notes
	else
		toInsert = data.BadNotes
	end

	local display = settings.Display
	
	local catName = boolIdx[isMine]
	local cat = display.Lanes[catName]
	
	local noteData = {
		Note = note,
		Rolled = rollChance(),
		PSickAdjust = 0,
		IsBad = not isGood,
		IsNew = isNew,
		IsMine = isMine,
		Hit = false,
		Lane = data,
		LaneIndex = data.LaneIndex,
		Destroyed = false,
		Destroying = event.new(),
		DisplayCategory = cat,
		CategoryName = catName
	}

	total += 1
	cat.TotalNotes += 1
	cat.NotesRendered += 1
	display.TotalNotes += 1
	display.NotesRendered += 1
	
	local rstack = renderStack[catName]
	insert(rstack, note)
	note.Visible = settings.Performance.Notes <= 0
	
	noteAdded:Fire(noteData)
	
	insert(toInsert, noteData)
	if isNew then
		local isDownScrollSpawn = note.Position.Y.Scale < data.Receptor.Position.Y.Scale + 0.5
		if isDownScrollSpawn ~= data.IsDownScroll then
			data.IsDownScroll = isDownScrollSpawn
			sortLane(data)
		end
	end

	note:GetPropertyChangedSignal("Parent"):Wait()
	
	cat.NotesRendered -= 1
	display.NotesRendered -= 1
	
	noteRemoved:Fire(noteData)
	noteData.Destroying:Fire()
	noteData.Destroyed = true
	
	local found = find(toInsert, noteData)
	if found then
		remove(toInsert, found)
	end
	
	found = find(rstack, note)
	if found then
		remove(rstack, found)
	end
end

local function onLane(lane, data, sharedData, isMine)
	local laneNum = tonumber(lane.Name:sub(5))
	if not laneNum then return end
	
	data.LanesCount = max(data.LanesCount, laneNum)
	
	local Notes = { }
	local receptor = lane:WaitForChild("Receptor")
	
	local myData = {
		ScrollSpeed = 0,
		ScrollSpeedBuffer = { },
		LaneIndex = laneNum,
		Lane = lane,
		Notes = Notes,
		BadNotes = { },
		IsDownScroll = true,
		Receptor = receptor
	}
	
	data.Lanes[laneNum] = myData
	local notes = lane:WaitForChild("Notes")
	
	if not sharedData.Working then return end
	
	for i, v in notes:GetChildren() do
		spawn(onNote, v, myData, sharedData, false, isMine)
	end
	
	if #Notes > 0 then
		myData.IsDownScroll = isDownS(myData)
		sortLane(myData)
	end
	
	local noteAddedCon = notes.ChildAdded:Connect(function(v)
		onNote(v, myData, sharedData, true, isMine)
	end)
	
	sharedData.StoppedWorking:Wait()
	noteAddedCon:Disconnect()
end

local function onField(field, myData, sharedData, isMine)
	local lanes = field:WaitForChild("Inner")
	if not sharedData.Working then return end
	
	for i, v in lanes:GetChildren() do
		spawn(onLane, v, myData, sharedData, isMine)
	end
end

local offsets = {
	Sick = 0.05,
	Good = 0.1,
	Ok = 0.15,
	Bad = 0.2,
	Miss = 0.3
}

local function getDistance(a, b)
	return (a - b).Magnitude
end

local function getClosest(toIterate)
	if not plr.Character then return end

	local c, d = nil, 1 / 0

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
local renderDelta = 0
local fps = 0
local estFps = 0
local fpsBuffer = { }

local rs = game:GetService("RunService")
local re = rs.RenderStepped

local ticks = 0
local lastPerf = settings.Performance.Notes

spawn(function()
	while true do
		local start = tick()
		re:Wait()
		renderDelta = tick() - start
		
		ticks += 1
		
		side = getMySide() or side
		fps = 1 / renderDelta
		
		estFps = append(fpsBuffer, fps, fps)
		settings.FPS = estFps
		
		local currentPerf = settings.Performance.Notes
		if lastPerf ~= currentPerf or ticks % 30 == 0 and currentPerf > 0 then
			lastPerf = currentPerf
			flushRenderStack()
		end
	end
end)

local function isBehind(data, x, y)
	local is = x.Y > y.Y
	if data.IsDownScroll then
		is = not is
	end

	return is
end

local sickOffset  = offsets.Sick
local sickOffset2 = offsets.Sick / 1.35
local missOffset  = offsets.Miss
local missOffset2 = offsets.Miss * 2
local badOffset   = offsets.Bad
local goodOffset  = offsets.Good

local offsetOffset = 0.0075
for i, v in offsets do
	offsets[i] = v - offsetOffset
end

local canHit; canHit = function(note, data)
	local x = UDimToVector2(data.Receptor.Position) + v2(useX and 0.5 or 0, 0.5, 0)
	local y = UDimToVector2(note.Note.Position)

	local dist = getDistance(x, y) / data.ScrollSpeed
	local behind = isBehind(data, x, y)

	if behind then
		dist += settings.HitOffset
	else
		dist -= settings.HitOffset
	end

	if dist < 0 then
		dist = -dist
		behind = not behind
	end

	if note.IsBad then
		return dist, behind
	else
		local forceSick = false

		for i, v in data.BadNotes do
			local d, b = canHit(v, data)
			forceSick = forceSick or b and d <= missOffset
			
			if b and d < missOffset or not b and d < dist then
				return false, behind, dist, false, false
			end
		end

		if behind then
			return dist <= badOffset, true, dist, dist <= sickOffset, false
		end

		local rolled = not forceSick and note.Rolled or "Sick"
		local sick = rolled == "Sick"

		return rolled ~= "Miss" and dist <= offsets[rolled], false, dist, sick, forceSick
	end
end

local longNoteIndex
local function calc(v, data)
	return abs(v.Size.Y.Scale / data.ScrollSpeed) + 0.075
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

local one = UDim2.fromScale(1, 1)
local playLane

local function hitNote(note, data, dist, sick, force)
	local s = force
	local isBehind = note.Note.Position.Y.Scale < data.Receptor.Position.Y.Scale + 0.5
	if data.IsDownScroll then
		isBehind = not isBehind
	end
	
	if sick and s and s > 0 then
		local t = isBehind and (s <= 1 and 0 or (sickOffset - dist) * (s - 1) - (0.001 + (lastOffset * 2))) or (s <= 1 and (dist * s) - (lastOffset / 2) or (dist + (sickOffset * (s - 1)) - (0.001 + (lastOffset * 2))))
		if t > 0 then
			wait(t)
		end
	end

	if note.Hit then return end
	note.Hit = true

	local time = settings.HoldDuration.Value
	local hdr = settings.HoldDuration.Random
	
	if hdr > 0 then
		time = max(time + (((random() * 1.25) - 0.25) * hdr), 0)
	end
	
	local holdTime = 0
	local children = note.Note:GetChildren()
	if not longNoteIndex then
		for i, v in children do
			if v and v.Size ~= one then
				holdTime = calc(v, data)
				longNoteIndex = i
				break
			end
		end
	else
		local v = children[longNoteIndex]
		if v and v.Size ~= one then
			holdTime = calc(v, data)
		end
	end

	time += holdTime
	
	if holdTime ~= 0 then
		hitLane(data.LaneIndex, time)
	else
		spawn(hitLane, data.LaneIndex, time)
	end

	raceEvents({ note.Note:GetPropertyChangedSignal("Parent"), note.Note:GetPropertyChangedSignal("Position") }, 0)
	
	if note.Parent then
		note.Hit = false
		insert(data.Notes, 1, note)
		spawn(sortLane, data)
		spawn(playLane, data)
	end
end

function playLane(lane)
	local iterations = 0
	local maxIterations = clamp(3250 / estFps, 3, 50)
	
	while #lane.Notes ~= 0 and iterations < maxIterations do
		local note = lane.Notes[1]
		if not note then break end
		
		local hit, far, dist, sick, force = canHit(note, lane)
		if hit then
			remove(lane.Notes, 1)
			spawn(hitNote, note, lane, dist, sick, force)
		elseif far then
			sortLane(lane)
		end
		
		iterations += 1
	end
end

local finishes = 0
local fe = event.new()
local modChart = false
local modChartDetectBuffer = 0
local function mcdf()
	modChartDetectBuffer += 1
	wait(30)
	modChartDetectBuffer = max(modChartDetectBuffer - 1, 0)
end

local function processLane(lane, sharedData)
	local note = lane.Notes[1]
	if not note then
		re:Wait()
		finishes += 1
		fe:Fire()
		
		return
	end
	
	local receptor = lane.Receptor
	
	local noteStart, receptorStart = UDimToVector2(note.Note.Position), UDimToVector2(receptor.Position)
	local start = tick()
	
	re:Wait()
	
	local took = tick() - start
	local receptorEnd = UDimToVector2(receptor.Position)
	local receptorTravel = receptorEnd - receptorStart
	if not modChart and receptorTravel.Magnitude > 0.001 then
		spawn(mcdf)
		if modChartDetectBuffer > estFps * 10 then
			modChart = true
		end
	end
	
	if modChart then
		local isDown = isDownS(lane)
		if isDown ~= lane.IsDownScroll then
			lane.IsDownScroll = isDown
			noteStart, receptorStart = v2(-(noteStart.X - 0.5) + 0.5, -(noteStart.Y - 0.5) + 0.5, 0), v2(-receptorStart.X, -receptorStart.Y, 0)
			receptorTravel = receptorEnd - receptorStart
			
			sortLane(lane)
		end
	end
	
	local ss = append(lane.ScrollSpeedBuffer, getDistance(noteStart, UDimToVector2(note.Note.Position) - receptorTravel) / took, estFps * 3)
	lane.ScrollSpeed = ss
	
	globalScrollSpeed = append(globalScrollSpeedBuffer, ss, estFps * 3)
	
	playLane(lane)
	
	finishes += 1
	fe:Fire()
end

local function statsAdded(stats, cons)
	if stats:FindFirstChild("Title") then return end

	local row = stats:WaitForChild("Combo"):Clone()
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

	cons[#cons + 1] = re:Connect(function()
		local hs = settings.MoreStats
		if hs then
			rows:Title(typeof(hs) == "string" and hs or false)
			rows:Rendered(settings.Display.NotesRendered == settings.Display.NotesVisible and settings.Display.NotesRendered or "Rendered: " .. settings.Display.NotesVisible .. " (" .. settings.Display.NotesRendered .. ")")
			rows:TotalNotes(total)
			rows:AutoplayKPS(KPS)
			rows:FPS("FPS: <font color=\"#" .. (estFps < 60 and c3n(1):Lerp(c3n(0, 1), estFps / 60) or estFps < 120 and c3n(0, 1):Lerp(c3n(1, 0, 1), (estFps - 60) / 60) or estFps < 240 and c3n(1, 0, 1):Lerp(c3n(0.33, 0, 1), (estFps - 120) / 120) or c3n(0.6, 0.2, 1)):ToHex() .. "\">" .. ("%.1f"):format(estFps) .. "</font>")
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
black.BackgroundColor3 = c3n()
black.Size = UDim2.fromScale(2, 2)
black.Position = UDim2.fromScale(0.5, 0.5)
black.AnchorPoint = Vector2.new(0.5, 0.5)
black.ZIndex = -999
black.Visible = false

songStarted:Connect(function(sharedData)
	modChart = false
	modChartDetectBuffer = 0
	settings.Core = sharedData
	settings.Playing = true
	total = 0
	
	for _, lane in settings.Display.Lanes do
		for i in lane do
			lane[i] = 0
		end
	end

	settings.Display.TotalNotes = 0
	settings.Display.NotesRendered = 0
	settings.Display.NotesVisible = 0
	
	local cons = { }
	local hud = sharedData.Window.Game:WaitForChild("HUD")
	if hud:FindFirstChild("Stats") then
		spawn(statsAdded, hud.Stats, cons)
	end

	cons[#cons + 1] = hud.ChildAdded:Connect(function(child)
		if child.Name == "Stats" then
			statsAdded(child, cons)
		end
	end)
	
	local working = true
	songStopped:Once(function()
		working = false
		for i, v in cons do
			v:Disconnect()
		end
	end)
	
	local can3d = pcall(set3d, true)
	while wait() and working do
		if can3d then
			set3d(not settings.Performance.Disable3D)
			black.Visible = settings.Performance.Disable3D
		end
		
		hud.Visible = settings.Performance.UI < 3
		hud.AccuracyGauge.Visible = settings.Performance.UI < 1
		
		for i, v in hud:GetChildren() do
			if v.Name == "Indicator" then
				v.Visible = settings.Performance.UI < 2
			end
		end
	end
	
	set3d(true)
	black.Visible = false
end)

songStopped:Connect(function(sharedData)
	sharedData.Working = false
	settings.Core = nil
	settings.Playing = false
	modChartDetectBuffer = 0

	for _, lane in settings.Display.Lanes do
		for i in lane do
			lane[i] = 0
		end
	end

	settings.Display.TotalNotes = 0
	settings.Display.NotesRendered = 0
	settings.Display.NotesVisible = 0
	
	set3d(true)
	black.Visible = false
end)

local function onWindow(window)
	local fields = window.Game.Fields
	
	local sharedData = {
		Fields = {
			Left = {
				LanesCount = 0,
				Lanes = { },
			},
			Right = {
				LanesCount = 0,
				Lanes = { }
			},
		},
		Working = true,
		StoppedWorking = event.new(),
		Window = window
	}
	
	sharedData.StoppedWorking:Once(function()
		songStopped:Fire(sharedData)
	end)
	
	for i, v in sharedData.Fields do
		local s, obj = pcall(waitForChildError, fields, i)
		if not s then
			sharedData.StoppedWorking:Fire()
			return
		else
			spawn(onField, obj, sharedData.Fields[i], sharedData, i == side)
		end
	end
	
	songStarted:Fire(sharedData)
	
	while window.Parent do
		local myField = sharedData.Fields[side]
		local oppositeField = sharedData.Fields[side == "Left" and "Right" or "Left"]
		
		local mineHasNotes = false
		for _, lane in myField.Lanes do
			for _, note in lane.Notes do
				mineHasNotes = true
				break
			end
		end
		
		local targetField = (mineHasNotes or not settings.CopyEnemyNotes) and myField or oppositeField
		
		finishes = 0
		local need = 0
		
		for i, v in targetField.Lanes do
			need += 1
			spawn(processLane, v, sharedData)
		end
		
		while finishes ~= need do
			fe:Wait()
		end
	end
	
	sharedData.StoppedWorking:Fire()
end

local function vf(ch)
	if ch.ClassName == "InputContext" or ch.Name == "VSRGContext" then
		hookInputs(ch)
	elseif ch.Name == "Window" and ch:WaitForChild("Game", 1) and ch.Game:WaitForChild("Fields", 1) then
		onWindow(ch)
	end
end

pgui.ChildAdded:Connect(vf)
for i, v in pgui:GetChildren() do
	spawn(vf, v)
end

global[key] = settings
re:Wait()

return settings

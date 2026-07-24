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

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")

local tick = tick
local spawn = task.spawn
local _wait = task.wait
local pcall = pcall
local max = math.max
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

local lastOffset = 0
local function wait(t)
	t = max(tonumber(t) or 0, 0)
	local took = _wait(t)

	if t == 0 then
		lastOffset = took - t
	end

	return took
end

local inputs = { }
local vsrgConnection, vsrgConn2

local scr = Enum.InputBindingType.Scriptable
local inpFire

local function onInput(v)
	local input
	while not input and vsrgConnection do
		input = v:WaitForChild("GamepadBinding", 1) or v:WaitForChild("KeyboardBinding", 1)
	end

	if not input then return end
	input.Type = scr

	inputs[tonumber(v.Name:sub(5))] = input
	inpFire = input.Fire

	warn("HOOKED INPUT", input:GetFullName())
end

local function hookInputs(vsrgContext)
	warn("ATTEMPT HOOKING INPUTS")
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

local function hitLane(laneIndex, duration)
	duration = duration or 0
	
	if laneStates[laneIndex] then
		fireLane(laneIndex, false)
		laneStates[laneIndex] = false
	end
	
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

local badNoteAssets = { "rbxassetid://103483801062498", "rbxassetid://88530467220950", "rbxassetid://109130876544260", "rbxassetid://120222801097284", "rbxassetid://101951481332606" }
local black = c3n()

local chances = {
	Sick = 100,
	Good = 0,
	Ok = 0,
	Bad = 0,
	Miss = 0
}

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

local useX = true
local function UDimToVector2(ud)
	return v2(useX and ud.X.Scale or 0, ud.Y.Scale, 0)
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

local function onNote(note, data, sharedData, isNew)
	local sprite = note:WaitForChild("LayeredSprite"):WaitForChild("1")
	local isGood = sprite.ImageColor3 ~= black and not find(badNoteAssets, sprite.Image)
	local toInsert
	if isGood then
		toInsert = data.Notes
	else
		toInsert = data.BadNotes
	end

	local noteData = {
		Note = note,
		Rolled = rollChance(),
		PSickAdjust = 0,
		IsBad = not isGood,
		IsNew = isNew,
		Hit = false
	}
	
	insert(toInsert, noteData)
	if isNew then
		local isDownScrollSpawn = note.Position.Y.Scale < data.Receptor.Position.Y.Scale + 0.5
		if isDownScrollSpawn ~= data.IsDownScroll then
			data.IsDownScroll = isDownScrollSpawn
			sortLane(data)
		end
	end

	note:GetPropertyChangedSignal("Parent"):Wait()

	local found = find(toInsert, noteData)
	if found then
		remove(toInsert, found)
	end
end

local function onLane(lane, data, sharedData)
	local laneNum = tonumber(lane.Name:sub(5))
	if not laneNum then return end
	
	data.LanesCount = max(data.LanesCount, laneNum)
	
	local Notes = { }
	local receptor = lane:WaitForChild("Receptor")
	
	local myData = {
		ScrollSpeed = 0,
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
		spawn(onNote, v, myData, sharedData, false)
	end
	
	if #Notes > 0 then
		local totalNotes = #Notes
		local downScrollNotes = 0
		
		for i, v in Notes do
			if v.Note.Position.Y.Scale < receptor.Position.Y.Scale + 0.5 then
				downScrollNotes += 1
			end
		end
		
		local isDownScroll = downScrollNotes / totalNotes > 0.75
		myData.IsDownScroll = isDownScroll
		
		sortLane(myData)
	end
	
	local noteAddedCon = notes.ChildAdded:Connect(function(v)
		onNote(v, myData, sharedData, true)
	end)
	
	sharedData.StoppedWorking:Wait()
	noteAddedCon:Disconnect()
end

local function onField(field, myData, sharedData)
	local lanes = field:WaitForChild("Inner")
	if not sharedData.Working then return end
	
	for i, v in lanes:GetChildren() do
		spawn(onLane, v, myData, sharedData)
	end
end

local offsets = {
	Sick = 0.05,
	Good = 0.1,
	Ok = 0.15,
	Bad = 0.225,
	Miss = 0.4
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
local rs = game:GetService("RunService")
local re = rs.RenderStepped

spawn(function()
	while true do
		local start = tick()
		re:Wait()
		local renderDelta = tick() - start
		
		side = getMySide() or side
	end
end)

local function isBehind(data, x, y)
	local is = x.Y > y.Y
	if data.IsDownScroll then
		is = not is
	end

	return is
end

local hitOffset = 0
local sickOffset  = offsets.Sick
local sickOffset2 = offsets.Sick / 1.35
local missOffset  = offsets.Miss
local missOffset2 = offsets.Miss * 2
local badOffset   = offsets.Bad
local goodOffset  = offsets.Good

local canHit; canHit = function(note, data)
	local x = UDimToVector2(data.Receptor.Position) + v2(useX and 0.5 or 0, 0.5, 0)
	local y = UDimToVector2(note.Note.Position)

	local dist = getDistance(x, y) / data.ScrollSpeed
	local behind = isBehind(data, x, y)

	if behind then
		dist += hitOffset
	else
		dist -= hitOffset
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
	return abs(v.Size.Y.Scale / data.ScrollSpeed) + 0.25
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

	local time = 0.25
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
	spawn(hitLane, data.LaneIndex, time)

	local winner = raceEvents({ note.Note:GetPropertyChangedSignal("Parent"), note.Note:GetPropertyChangedSignal("Position") }, 0)
	note.Hit = false

	if winner ~= 0 and note.Parent and not find(data.Notes, note) then
		insert(data.Notes, 1, note)
		spawn(sortLane, data)
	end
end

local function playLane(lane)
	local iterations = 0
	local maxIterations = 10
	
	local cycle
	
	while #lane.Notes ~= 0 and iterations < maxIterations do
		local note = lane.Notes[1]
		if not note then break end
		
		if note == cycle then break end
		
		local hit, far, dist, sick, force = canHit(note, lane)
		if hit then
			remove(lane.Notes, 1)
			spawn(hitNote, note, lane, dist, sick, force)
			continue
		elseif not cycle then
			cycle = note
			insert(lane.Notes, remove(lane.Notes, 1))
			continue
		elseif not far then
			if cycle then
				local pos = find(lane.Notes, cycle)
				if pos then
					insert(lane.Notes, 1, remove(lane.Notes, pos))
				end
			end

			spawn(sortLane, lane)
			break
		end
		
		iterations += 1
	end
end

local finishes = 0
local fe = event.new()

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
	local noteEnd, receptorEnd = UDimToVector2(note.Note.Position), UDimToVector2(receptor.Position)
	local receptorTravel = receptorEnd - receptorStart
	noteEnd -= receptorTravel
	
	lane.ScrollSpeed = getDistance(noteStart, noteEnd) / took
	playLane(lane)
	
	finishes += 1
	fe:Fire()
end

warn("BEGIN")

local function onWindow(window)
	warn("ON WINDOW")
	
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
		StoppedWorking = event.new()
	}
	
	sharedData.StoppedWorking:Once(function()
		sharedData.Working = false
		warn("END")
		
		-- TODO: add logic here later
	end)
	
	for i, v in sharedData.Fields do
		warn("DOING", i)
		local s, obj = pcall(waitForChildError, fields, i)
		if not s then
			sharedData.StoppedWorking:Fire()
			warn("FAILRURE BREAK FOR", i)
			return
		else
			warn("DONE", i)
			spawn(onField, obj, sharedData.Fields[i], sharedData)
		end
	end
	
	warn("START")
	
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
		
		local targetField = -- mineHasNotes and myField or oppositeField
			myField
		
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

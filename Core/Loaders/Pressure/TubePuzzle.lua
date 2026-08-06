-- WARNING: The following code is shitcode by Kawi, it's purpose to work and not being readable. Read ts at your own risk

local global = getfenv().getgenv and getfenv().getgenv() or _G
local key = "PressureTubes"

if global[key] then
	return global[key]
end

local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 78, 117, 108, 108, 45, 67, 104, 101, 114, 114, 121, 47, 85, 116, 105, 108, 105, 116, 105, 101, 115, 47, 114, 101, 102, 115, 47, 104, 101, 97, 100, 115, 47, 109, 97, 105, 110, 47, 85, 116, 105, 108, 105, 116, 121, 47, 77, 97, 105, 110, 46, 108, 117, 97)))() end)()
local event = util:Event()
local fpp = util:Fire().fireproximityprompt

if global[key] then
	return global[key]
end

local container = game:GetService("RunService"):IsStudio() and game:GetService("StarterGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local v2 = Vector2.new
local name = "TubeGameDebugOutput"
if container:FindFirstChild(name) then
	container[name]:Destroy()
end

local lib
local rgb = Color3.fromRGB
local gui = Instance.new("ScreenGui", container)
gui.Name = name
gui.ResetOnSpawn = false

local holderFrame = Instance.new("Frame", gui)
holderFrame.AnchorPoint = v2(0.5, 0.5)
holderFrame.Position = UDim2.new(0.5, 0, 0.75, 0)
holderFrame.Size = UDim2.new(0, 0, 0, 0)
holderFrame.BackgroundTransparency = 1

local blankFrame = Instance.new("Frame")
blankFrame.Size = UDim2.new(0, 30, 0, 30)
blankFrame.BorderSizePixel = 0
blankFrame.BackgroundTransparency = 0.75

local tubeFrame = Instance.new("Frame")
tubeFrame.BorderSizePixel = 0
tubeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
tubeFrame.Size = UDim2.fromScale(1, 0.5)
tubeFrame.BackgroundColor3 = rgb(100, 100, 100)

local straightSprite = blankFrame:Clone()
local ssf1 = tubeFrame:Clone()
ssf1.Parent = straightSprite
ssf1.Position = UDim2.fromScale(0.5, 0.5)

local cornerSprite = blankFrame:Clone()
local csf1 = tubeFrame:Clone()
csf1.Parent = cornerSprite
csf1.Size = UDim2.fromScale(0.75, 0.5)
csf1.Position = UDim2.fromScale(0.375, 0.5)

local csf2 = tubeFrame:Clone()
csf2.Parent = cornerSprite
csf2.Size = UDim2.fromScale(0.5, 0.75)
csf2.Position = UDim2.fromScale(0.5, 0.375)

local tripleSprite = blankFrame:Clone()
local tsf1 = tubeFrame:Clone()
tsf1.Parent = tripleSprite
tsf1.Size = UDim2.fromScale(0.5, 0.5)
tsf1.Position = UDim2.fromScale(0.25, 0.5)

local tsf2 = tubeFrame:Clone()
tsf2.Parent = tripleSprite
tsf2.Size = UDim2.fromScale(0.5, 1)
tsf2.Position = UDim2.fromScale(0.5, 0.5)

local sprites = {
	Straight = straightSprite,
	Corner = cornerSprite,
	Triple = tripleSprite
}

local abs = math.abs
local round = math.round
local find = table.find
local wait, spawn = task.wait, task.spawn
local tonumber = tonumber
local setmetatable = setmetatable
local error = error
local clamp = math.clamp

local clone = function(tbl)
	local res = { }
	for i, v in tbl do
		res[i] = v
	end

	return res
end

local function count(t)
	local i = 0
	for _ in t do
		i += 1
	end

	return i
end

local cfr = CFrame.new()
local function getClosest(children, pos, name)
	local closest, d = nil, 1 / 0
	for _, v in children do
		local dist = (v:GetPivot().Position - pos).Magnitude
		if dist >= 0.1 and dist < d and (name and v.Name == name or not name) then
			closest, d = v, dist
		end
	end

	return closest, d
end

local function v2ts(v, e)
	return v.X .. "," .. v.Y .. (e and "," .. e or "")
end

local puzzleAdded = event.new()
local activePuzzles = { }

local tubeGameRoom, currentRoom, nextRoom
local function onDesc(v)
	if v.Name == "puzzle" then
		puzzleAdded:Fire(v.Parent)
		activePuzzles[#activePuzzles + 1] = v.Parent

		local room = v.Parent:FindFirstAncestorOfClass("Model")
		while true do
			if room.Parent.Name ~= "Rooms" then
				local anc = v:FindFirstAncestorOfClass("Model")
				if anc then
					room = anc
				else
					break
				end
			else
				break
			end
		end

		tubeGameRoom = room
	end
end

local green = rgb(0, 167, 97)
local remove = table.remove

puzzleAdded:Connect(function(puzzle)
	while wait() do
		if not puzzle:IsDescendantOf(workspace) or not puzzle:FindFirstChild("Ends") or #puzzle.Ends:GetChildren() == 0 then break end

		local allGreen = true
		for i, v in puzzle.Ends:GetChildren() do
			local light = v:FindFirstChild("LightPart")
			if light and light.Color ~= green then
				allGreen = false
				break
			end
		end

		if allGreen then break end
	end

	local found = find(activePuzzles, puzzle)
	if found then
		remove(activePuzzles, found)
	end
end)

workspace.DescendantAdded:Connect(onDesc)
for i, v in workspace:GetDescendants() do
	spawn(onDesc, v)
end

workspace.GameplayFolder.Rooms.ChildAdded:Connect(function(room)
	currentRoom = nextRoom
	nextRoom = room
end)

local rotationMap = {
	[v2ts(v2(-1, 0))] = 1,
	[v2ts(v2(0, -1))] = 2,
	[v2ts(v2(1, 0))] = 3,
	[v2ts(v2(0, 1))] = 4
}

local rotationMapOuts = {
	Straight = {
		{ v2(-1, 0), v2(1, 0) },
		{ v2(0, 1), v2(0, -1) },
		{ v2(-1, 0), v2(1, 0) },
		{ v2(0, 1), v2(0, -1) }
	},
	Corner = {
		{ v2(-1, 0), v2(0, -1) },
		{ v2(1, 0), v2(0, -1) },
		{ v2(1, 0), v2(0, 1) },
		{ v2(-1, 0), v2(0, 1) }
	},
	Triple = {
		{ v2(-1, 0), v2(0, -1), v2(0, 1) },
		{ v2(-1, 0), v2(1, 0), v2(0, -1) },
		{ v2(1, 0), v2(0, -1), v2(0, 1) },
		{ v2(-1, 0), v2(1, 0), v2(0, 1) }
	}
}

local function getTubeVariant(t)
	local part = t:FindFirstChild("Part")
	if not part then
		return "Straight"
	end

	local attachments = part:GetChildren()

	if #attachments == 3 then
		return "Triple"
	else
		return part.Atch1.SecondaryAxis.Y == 0 and "Straight" or "Corner"
	end
end

local function rotateFunc(self, repeats)
	for i = 1, repeats or 1 do
		self.Rotation = (self.Rotation % 4) + 1
	end

	return self
end

local function connectedTo(self, target)
	local loc = self.loc
	local h = false

	for i, v in target.Outs do
		if v.loc == loc then
			return true
		end
	end

	if h then
		loc = target.loc
		for i, v in self.Outs do
			if v.loc == loc then
				return true
			end
		end
	end

	return false
end

local cloneVirtualObject
local currentVirtualGrid
local virtualGrid

local function cloneVirtualGrid(grid) -- it does a DEEP copy
	local copy = { }
	for i, v in (grid or virtualGrid) do
		copy[i] = v.Copy
	end

	return copy
end

local hasRouteTo; hasRouteTo = function(tube, target, visited, grid)
	if tube.pos == target.pos then return true end

	visited = visited or { tube.pos }
	grid = grid or currentVirtualGrid
	currentVirtualGrid = grid

	for i, v in tube.Connections do
		if v.pos == target.pos then
			return true, visited
		end

		if not find(visited, v.pos) then
			visited[#visited + 1] = v.pos
			if hasRouteTo(v, target, visited, grid) then
				return true, visited
			end
		end
	end

	return false, visited
end

local neighbourVectors = { v2(-1, 0), v2(1, 0), v2(0, -1), v2(0, 1) }
local tubeMeta = {
	__index = function(self, name)
		if name == "Outs" then
			local outs = { }
			local myPosition = self.Position

			for i, vec in rotationMapOuts[self.Variant][self.Rotation] do
				local outVec = vec + myPosition
				if currentVirtualGrid[v2ts(outVec)] then
					outs[#outs + 1] = currentVirtualGrid[v2ts(outVec)]
				end
			end

			return outs
		elseif name == "Connections" then
			local connections = { }
			for i, v in self.Outs do
				if self:ConnectedTo(v) then
					connections[#connections + 1] = v
				end
			end

			return connections
		elseif name == "Neighbours" then
			local neighbours = { }
			for i, v in neighbourVectors do
				local neighbourPos = v + self.Position
				local neighbour = currentVirtualGrid[v2ts(neighbourPos)]

				if neighbour then
					neighbours[#neighbours + 1] = neighbour
				end
			end

			return neighbours
		elseif name == "Copy" then
			return cloneVirtualObject(self)
		elseif name == "ConnectedTo" then
			return connectedTo
		elseif name == "Rotate" then
			return rotateFunc
		elseif name == "loc" then
			return v2ts(self.Position, self.Rotation)
		elseif name == "pos" then
			return v2ts(self.Position)
		elseif name == "HasRoute" then
			return hasRouteTo
		end
	end
}

cloneVirtualObject = function(obj) -- deep copy
	return setmetatable(clone(obj), tubeMeta)
end

local function lerp(a, b, c)
	return a + (b - a) * c
end

local isBuzy = false
local solverId = 0

local function trySolvePuzzle(currentTubeGame)
	if isBuzy then return end
	
	isBuzy = true
	solverId += 1
	
	local currentSolverId = solverId
	local children = currentTubeGame.puzzle:GetChildren()

	local oldPos = currentTubeGame:GetPivot()
	currentTubeGame:PivotTo(cfr)

	local first = children[1]
	local closest, d = nil, 1 / 0
	for _, v in children do
		local dist = abs(v:GetPivot().Position.X - first:GetPivot().Position.X)
		if dist >= 0.1 and dist < d then
			closest, d = v, dist
		end
	end

	local cellSize = d

	local mostLeftPos, mostLeft = nil, nil
	local mostRightPos, mostRight = nil, nil
	local mostBottomPos, mostBottom = nil, nil
	local mostTopPos, mostTop = nil, nil

	local maxX, minX = 1000, -1000
	local minY, maxY = 1000, -1000

	for i, v in children do
		local pos = v:GetPivot().Position

		if pos.X < maxX then
			maxX = pos.X
			mostLeftPos = pos
			mostLeft = v
		end

		if pos.X > minX then
			minX = pos.X
			mostRightPos = pos
			mostRight = v
		end

		if pos.Y < minY then
			minY = pos.Y
			mostBottomPos = pos
			mostBottom = v
		end

		if pos.Y > maxY then
			maxY = pos.Y
			mostTopPos = pos
			mostTop = v
		end
	end

	maxX, mostLeftPos, mostLeft, minX, mostRightPos, mostRight = minX, mostRightPos, mostRight, maxX, mostLeftPos, mostLeft

	local fieldSize = v2(round((maxX - minX) / cellSize), round((maxY - minY) / cellSize))
	local grid = { }
	local gridReverse = { }

	local function getPositionInGrid(pos)
		return v2(fieldSize.X - round((pos.X - minX) / cellSize), fieldSize.Y - round((pos.Y - minY) / cellSize))
	end

	local function getTubeOuts(tubeObject)
		local part = tubeObject[1]:FindFirstChild("Part")
		local myPos = tubeObject[2]

		if not part then
			currentTubeGame:PivotTo(cfr)
			local pos = getPositionInGrid(getClosest(children, tubeObject[1]:GetPivot().Position, "End"):GetPivot().Position)
			currentTubeGame:PivotTo(oldPos)

			return { pos }, { v2(round(pos.X - myPos.X), round(pos.Y - myPos.Y)) }
		end

		local attachments = part:GetChildren()
		local outs = { }
		local relativeOuts = { }

		for i, v in attachments do
			local atch = tonumber(v.Name:sub(-1, -1))

			currentTubeGame:PivotTo(cfr)
			local pos = getPositionInGrid(v.WorldPosition + (v.WorldCFrame.YVector * cellSize))
			currentTubeGame:PivotTo(oldPos)

			outs[atch] = pos
			relativeOuts[atch] = v2(round(pos.X - myPos.X), round(pos.Y - myPos.Y))
		end

		return outs, relativeOuts
	end

	local function getTubeRotation(tubeObject)
		local tube, type = tubeObject[1], tubeObject[4]
		local _, rOuts = getTubeOuts(tubeObject)

		return rotationMap[v2ts(rOuts[1])] or 1
	end

	for i, v in children do
		local pos = getPositionInGrid(v:GetPivot().Position)
		local obj = { v, pos, "Tube", getTubeVariant(v) }

		grid[pos] = obj
		gridReverse[obj] = pos
	end

	for i, v in currentTubeGame.Ends:GetChildren() do
		local pos = getPositionInGrid(v:GetPivot().Position)
		local obj = { v, pos, "End", getTubeVariant(v) }

		grid[pos] = obj
		gridReverse[obj] = pos
	end
	
	local v = currentTubeGame.Power
	local pos = getPositionInGrid(v:GetPivot().Position)
	local obj = { v, pos, "Start", getTubeVariant(v) }

	grid[pos] = obj
	gridReverse[obj] = pos

	virtualGrid = { }

	local start
	local ends = { }

	for pos, obj in grid do
		local type = obj[3]
		local object = setmetatable({
			Position = pos,
			Type = type,
			Variant = obj[4],
			Rotation = getTubeRotation(obj),
			Fixed = type ~= "Tube",
			Start = type == "Start",
			End = type == "End",
			Instance = obj[1]
		}, tubeMeta)

		if object.Start then
			start = object
		elseif object.End then
			ends[#ends + 1] = object
		end

		virtualGrid[v2ts(pos)] = object
	end

	currentVirtualGrid = virtualGrid

	local originalVirtualGrid = cloneVirtualGrid(virtualGrid)

	local currentlyAt
	local highlighted
	local spritesGrid = { }
	
	local lastTick = tick()
	local allowedTime = 0.001
	local calcStartTick = lastTick

	spawn(function()
		for _, obj in originalVirtualGrid do
			local type, variant, pos = obj.Type, obj.Variant, obj.Position
			local sprite = sprites[variant]:Clone()

			sprite.Parent = holderFrame
			sprite.Position = UDim2.fromOffset((pos.X - (fieldSize.X / 2)) * 40, (pos.Y - (fieldSize.Y / 2)) * 40)
			sprite.Rotation = (obj.Rotation - 1) * 90
			sprite.BackgroundColor3 = type == "Start" and rgb(85, 255, 127) or type == "End" and rgb(255, 85, 127) or rgb()
			sprite.Name = pos.X .. " " .. pos.Y

			spritesGrid[obj.pos] = sprite
		end

		local ts = game:GetService("TweenService")
		local prevRotations = { }

		while gui:IsDescendantOf(game) and currentTubeGame:IsDescendantOf(workspace) and find(activePuzzles, currentTubeGame) and solverId == currentSolverId do
			local e = lib and lib.ShowDebugUI or false
			gui.Enabled = e
			allowedTime = lib and 1 / (lerp(lib.StartFPS, lib.EndFPS, clamp((tick() + lib.FPSDowngradeDuration - calcStartTick) / lib.FPSDowngradeDuration, 0, 1))) or 0.001

			if e then
				for _, obj in currentVirtualGrid do
					local sprite = spritesGrid[obj.pos]
					local type = obj.Type

					sprite.BackgroundColor3 = type == "Start" and rgb(85, 255, 127) or
						highlighted == obj.pos and rgb(170, 85, 255) or
						type == "End" and rgb(255, 85, 127) or
						currentlyAt == obj.pos and rgb(0, 170, 255) or
						hasRouteTo(obj, start) and rgb(85, 255, 127) or
						rgb()

					local rot = obj.Rotation
					local prevRot = prevRotations[obj.pos]
					if prevRot ~= rot then
						prevRotations[obj.pos] = rot
						
						if allowedTime > 0.04 then
							ts:Create(sprite, TweenInfo.new(0.1), { Rotation = (rot - 1) * 90 }):Play()
						else
							sprite.Rotation = (rot - 1) * 90
						end
					end
				end
			end

			wait()
		end

		for i, v in spritesGrid do
			v:Destroy()
		end
	end)

	local succeedCV

	local getPaths; getPaths = function(tube, previous, first, ignore, isFirst)
		local reachedStart = false
		local isFinalPath = false

		local cv = currentVirtualGrid
		ignore[previous.pos] = true

		currentlyAt = tube.pos

		local paths = { }
		for i = 1, tube.Fixed and 1 or tube.Variant == "Straight" and 2 or 4 do
			local copy = tube.Copy
			currentVirtualGrid = cloneVirtualGrid(cv)
			currentVirtualGrid[copy.pos] = copy
			copy.Rotation = copy.Fixed and copy.Rotation or i

			if copy:HasRoute(first) then
				local tbl
				for idx, val in copy.Neighbours do
					if (val.Start or val.End) and val:HasRoute(first) then
						reachedStart = val:HasRoute(start)

						local isf = true
						for _, End in ends do
							if not End:HasRoute(start) then
								isf = false
							end
						end

						if isf then
							isFinalPath = true
							succeedCV = succeedCV or cloneVirtualGrid(currentVirtualGrid)
						end
					end

					if copy.Start or copy.End then
						reachedStart = copy:HasRoute(start)

						local isf = true
						for _, End in ends do
							if not End:HasRoute(start) then
								isf = false
							end
						end

						if isf then
							isFinalPath = true
							succeedCV = succeedCV or cloneVirtualGrid(currentVirtualGrid)
						end
					end

					if ignore[val.pos] then continue end

					local ignore = clone(ignore)
					ignore[val.pos] = true

					local paths, rs, isFinal = getPaths(val, copy, first, ignore, false)
					isFinalPath = isFinalPath or isFinal
					tbl = { i, val.Position, paths }

					if isFinalPath then
						succeedCV = succeedCV or cloneVirtualGrid(currentVirtualGrid)
					end

					local t = tick()
					if t - lastTick > allowedTime then
						wait()
						lastTick = tick()
					end

					if isFinalPath then break end
				end

				if tbl then
					paths = tbl
				end
			end

			local t = tick()
			if t - lastTick > allowedTime then
				wait()
				lastTick = tick()
			end

			if isFinalPath then break end
		end

		if not reachedStart and not isFinalPath or count(paths) == 0 then
			paths = nil
		end

		currentVirtualGrid = cv
		return paths, reachedStart, isFinalPath
	end

	local cv = currentVirtualGrid
	local finalPath

	for i, End in ends do
		local cv = currentVirtualGrid

		highlighted = End.pos

		local path, _, isFinal = getPaths(End.Outs[1], End, End, { }, true)
		currentVirtualGrid = cv

		if isFinal then
			finalPath = path
			break
		end
	end
	
	local fakeGrid = { }
	for i, v in originalVirtualGrid do
		fakeGrid[v2ts(v.Position)] = v.Copy
	end

	local vRotMap
	if succeedCV then
		currentVirtualGrid = succeedCV

		local route = { }
		for i, v in ends do
			local _, endRoute = v:HasRoute(start)
			for idx, val in endRoute do
				if not find(route, val) then
					route[#route + 1] = val
				end
			end
		end

		local tempGrid = { }
		for i, v in currentVirtualGrid do
			tempGrid[v2ts(v.Position)] = v.Copy
		end
		
		local val = v2ts(start.Position)
		if not find(route, val) then
			route[#route + 1] = val
		end
		
		vRotMap = { }
		for i, v in route do
			local obj = tempGrid[v]
			vRotMap[obj.Position] = obj.Rotation
		end
	end

	isBuzy = false
	return vRotMap, fakeGrid
end

local function solvePuzzle(puzzle)
	local start = tick()
	local rotations, grid = trySolvePuzzle(puzzle)
	while not rotations do
		wait()
		rotations, grid = trySolvePuzzle(puzzle)
	end

	return rotations, grid, tick() - start
end

local plr = game:GetService("Players").LocalPlayer
lib = {
	StartFPS = 144, -- less fps = faster calculate
	EndFPS = 0.5,
	FPSDowngradeDuration = 10,
	
	ShowDebugUI = false,
	
	Solve = function(self, puzzle)
		local a, b = solvePuzzle(puzzle)
		return a, b
	end,
	SolveAndPlay = function(self, puzzle)
		local solution, grid = self:SolvePuzzle(puzzle)
		return self:PlaySolution(solution, grid)
	end,
	Play = function(self, rotations, grid)
		local start = tick()

		local puzzle
		for pos, obj in grid do
			puzzle = obj.Instance:FindFirstAncestorOfClass("Folder").Parent
			break
		end
		
		warn()
		
		local solution = { }
		for pos, targetRot in rotations do
			pos = v2ts(pos)
			local obj = grid[pos]
			
			local myRot = obj.Rotation
			local neededRotations = 0
			
			if obj.Variant == "Straight" then
				myRot = (myRot - 1) % 2 + 1
				targetRot = (targetRot - 1) % 2 + 1
				
				if myRot ~= targetRot then
					neededRotations = 1
				end
			elseif myRot ~= targetRot then
				neededRotations = targetRot > myRot and targetRot - myRot or 4 - (myRot - targetRot)
			end
			
			solution[pos] = neededRotations
			print(pos, neededRotations, myRot, targetRot)
		end

		if not find(activePuzzles, puzzle) then return 0 end

		local cons = { }
		local coodowns = { }
		local cons2 = { }

		local function rotate(pos)
			local obj = grid[pos].Instance:FindFirstChildWhichIsA("ProximityPrompt", true)
			if obj then
				local dist = (obj.Parent.Position - plr.Character:GetPivot().Position).Magnitude
				if dist < obj.MaxActivationDistance - 1 and (not coodowns[pos] or tick() - coodowns[pos] > 0.75 + (plr:GetNetworkPing() / 2)) and solution[pos] ~= 0 then
					coodowns[pos] = tick()
					spawn(fpp, obj)
					
					if not cons2[obj] then
						local sound = obj.Parent:FindFirstChildWhichIsA("Sound")
						local con; con = sound:GetPropertyChangedSignal("Playing"):Once(function()
							if sound.Playing then
								solution[pos] -= 1
								coodowns[pos] = tick()
								cons2[obj] = nil
								
								con:Disconnect()
							end
						end)
						
						cons[2] = con
					end
				end
			end
		end

		while true do
			if not gui.Parent then return 0 end

			local allZeros = true
			for i, v in solution do
				if v ~= 0 then
					allZeros = false
					break
				end
			end

			if allZeros then
				break
			end

			for i, v in rotations do
				rotate(v2ts(i))
			end

			wait()
		end

		for i, v in cons do
			v:Disconnect()
		end
		
		for i, v in cons2 do
			v:Disconnect()
		end

		wait(2 + plr:GetNetworkPing())
		if find(activePuzzles, puzzle) then
			local solution, grid = self:SolvePuzzle(puzzle)
			self:PlaySolution(solution, grid)
		end

		return tick() - start
	end,

	PuzzleAdded = puzzleAdded,
	ActivePuzzles = activePuzzles
}

global[key] = lib
return lib

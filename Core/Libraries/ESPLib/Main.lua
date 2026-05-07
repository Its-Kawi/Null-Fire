-- [[ GENERATED WITH InfernoHub/Scriptify STUDIO PLUGIN ]] --
-- Scriptify Version: 1.4

--

-- Create objects
local parent = nil;
local objects = {
    ["Instance0"] = Instance.new("ModuleScript");
    ["Instance1"] = Instance.new("BillboardGui");
    ["Instance2"] = Instance.new("Frame");
    ["Instance3"] = Instance.new("UICorner");
    ["Instance4"] = Instance.new("UIStroke");
    ["Instance5"] = Instance.new("UIGradient");
    ["Instance6"] = Instance.new("TextLabel");
    ["Instance7"] = Instance.new("UIStroke");
    ["Instance8"] = Instance.new("Highlight");
    ["Instance9"] = Instance.new("TextLabel");
    ["Instance10"] = Instance.new("UIStroke");
};

do -- Set properties
    objects["Instance0"]["Parent"] = parent;
    objects["Instance0"]["Name"] = "ESPLib";

    objects["Instance1"]["LightInfluence"] = 1;
    objects["Instance1"]["Name"] = "ESPObject";
    objects["Instance1"]["Active"] = true;
    objects["Instance1"]["Parent"] = objects["Instance0"];
    objects["Instance1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
    objects["Instance1"]["AlwaysOnTop"] = true;
    objects["Instance1"]["Size"] = UDim2.new(0, 20, 0, 20);

    objects["Instance2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
    objects["Instance2"]["BorderColor3"] = Color3.new(0, 0, 0);
    objects["Instance2"]["Name"] = "Circle";
    objects["Instance2"]["Position"] = UDim2.new(0.5, 0, 0.5, 2);
    objects["Instance2"]["Parent"] = objects["Instance1"];
    objects["Instance2"]["Size"] = UDim2.new(1, -8, 1, -8);
    objects["Instance2"]["BorderSizePixel"] = 0;
    objects["Instance2"]["BackgroundColor3"] = Color3.new(1, 1, 1);

    objects["Instance3"]["TopLeftRadius"] = UDim.new(1, 0);
    objects["Instance3"]["CornerRadius"] = UDim.new(1, 0);
    objects["Instance3"]["Parent"] = objects["Instance2"];
    objects["Instance3"]["BottomRightRadius"] = UDim.new(1, 0);
    objects["Instance3"]["TopRightRadius"] = UDim.new(1, 0);
    objects["Instance3"]["BottomLeftRadius"] = UDim.new(1, 0);

    objects["Instance4"]["Thickness"] = 2;
    objects["Instance4"]["Parent"] = objects["Instance2"];

    objects["Instance5"]["Rotation"] = 90;
    objects["Instance5"]["Parent"] = objects["Instance2"];
    objects["Instance5"]["Color"] = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    [2] = ColorSequenceKeypoint.new(1, Color3.new(0.686275, 0.686275, 0.686275))
});

    objects["Instance6"]["FontSize"] = Enum.FontSize.Size14;
    objects["Instance6"]["Parent"] = objects["Instance1"];
    objects["Instance6"]["AnchorPoint"] = Vector2.new(0.5, 0);
    objects["Instance6"]["BorderSizePixel"] = 0;
    objects["Instance6"]["Size"] = UDim2.new(0, 10000, 0, 10000);
    objects["Instance6"]["RichText"] = true;
    objects["Instance6"]["TextColor3"] = Color3.new(1, 1, 1);
    objects["Instance6"]["BorderColor3"] = Color3.new(0, 0, 0);
    objects["Instance6"]["Text"] = "Point zero";
    objects["Instance6"]["TextWrap"] = true;
    objects["Instance6"]["TextWrapped"] = true;
    objects["Instance6"]["BackgroundTransparency"] = 1;
    objects["Instance6"]["Position"] = UDim2.new(0.5, 0, 1, -1);
    objects["Instance6"]["TextSize"] = 14;
    objects["Instance6"]["TextYAlignment"] = Enum.TextYAlignment.Top;
    objects["Instance6"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal, true);
    objects["Instance6"]["BackgroundColor3"] = Color3.new(1, 1, 1);

    objects["Instance7"]["Thickness"] = 2;
    objects["Instance7"]["Parent"] = objects["Instance6"];

    objects["Instance8"]["Parent"] = objects["Instance1"];
    objects["Instance8"]["FillColor"] = Color3.new(1, 1, 1);
    objects["Instance8"]["FillTransparency"] = 0.75;
    objects["Instance8"]["Enabled"] = false;

    objects["Instance9"]["FontSize"] = Enum.FontSize.Size12;
    objects["Instance9"]["Parent"] = objects["Instance1"];
    objects["Instance9"]["AnchorPoint"] = Vector2.new(0.5, 1);
    objects["Instance9"]["BorderSizePixel"] = 0;
    objects["Instance9"]["Size"] = UDim2.new(0, 10000, 0, 10000);
    objects["Instance9"]["RichText"] = true;
    objects["Instance9"]["TextColor3"] = Color3.new(1, 1, 1);
    objects["Instance9"]["BorderColor3"] = Color3.new(0, 0, 0);
    objects["Instance9"]["Text"] = "<font transparency=\"0.25\">World's 0, 0, 0 point</font>";
    objects["Instance9"]["TextWrap"] = true;
    objects["Instance9"]["Name"] = "TopTextLabel";
    objects["Instance9"]["TextWrapped"] = true;
    objects["Instance9"]["BackgroundTransparency"] = 1;
    objects["Instance9"]["Position"] = UDim2.new(0.5, 0, 0, 2);
    objects["Instance9"]["TextSize"] = 12;
    objects["Instance9"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
    objects["Instance9"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal, true);
    objects["Instance9"]["BackgroundColor3"] = Color3.new(1, 1, 1);

    objects["Instance10"]["Thickness"] = 2;
    objects["Instance10"]["Parent"] = objects["Instance9"];
end;
local ___args = table.pack(...); local ___up = unpack;

-- Set modules
local o_require = require; local require; local cache = { };
local modules do
    modules = { };
    require = function(object)
        if modules[object] then
            local ret = cache[object] or modules[object](___up(___args));
            cache[object] = ret;
            return ret;
        end
        return o_require(object);
    end;

    getfenv().require = require;

    modules[objects["Instance0"]] = function(...)
        local script = objects["Instance0"];
local ESPObj = script.ESPObject
local getfenv = getfenv
local env = getfenv()
env = env.getgenv and env.getgenv() or env

local global = env.getgenv and env.getgenv() or _G
local n = "FESPLib"

local v = global[n]
if v then
    ESPObj:Destroy()
    script:Destroy()

    return v
end

script.Parent, ESPObj.Parent = nil, nil

local inew = Instance.new
local workspace, game = workspace, game

local holder = inew("Folder", game:GetService("CoreGui") or workspace)
holder.Name = "ESPLib"

local ESPs = { }

local rawset, rawget = rawset, rawget
local setmetatable = setmetatable
local tick = tick
local v2 = Vector2.new
local hsv = Color3.fromHSV
local typeof = typeof
local concat = table.concat
local pack, unpack = table.pack, table.unpack
local pcall = pcall
local u2 = UDim2.new
local v3 = Vector3.new

local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local drawing = env.Drawing or env.drawing
local fromPoint = v2(0, 0)
local maxX, maxY = 0, 0

local function memoize(fn)
    local cache = setmetatable({ }, { __mode = "k" })

    return function(...)
        local args = pack(...)
        local key = args.n ~= 0 and concat(args, "\0") or ""

        local result = cache[key]
        if result then
            return unpack(result, 1, result.n)
        end

        result = pack(fn(...))
        cache[key] = result

        return unpack(result, 1, result.n)
    end
end

local deg, atan2 = memoize(math.deg), memoize(math.atan2)

local dnew = --drawing and drawing.new or
    nil

local topb = inew("ScreenGui", holder.Parent == workspace and plr:WaitForChild("PlayerGui", 9e9) or holder.Parent)
topb.Name = "TopbarMeasurer"
topb.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets

local dh = not dnew and inew("ScreenGui", topb.Parent)
if dh then
    dh.DisplayOrder = 2147483647
    dh.ResetOnSpawn = false
    -- dh.IgnoreGuiInset = true
    dh.ClipToDeviceSafeArea = false
    dh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        dh.OnTopOfCoreBlur = true
    end)
end

local newLine = dnew and function()
    return dnew("Line")
end or function()
    local line = inew("Frame", dh)
    line.BorderSizePixel = 0
    line.Size = u2(0, 1, 0, 1)
    line.AnchorPoint = v2(0.5, 0.5)

    return line
end

local updateLine = dnew and function(line, visible, to, color)
    line.Visible = visible
    if not visible then return end

    line.From = fromPoint
    line.To = to
    line.Color = color
    line.Thickness = 2
end or function(line, visible, to, color)
    line.Visible = false
    if not visible then return end

    local direction = (to - fromPoint)
    local center = (to + fromPoint) / 2
    line.Position = u2(0, center.X, 0, center.Y)
    line.Rotation = deg(atan2(direction.Y, direction.X))
    line.Size =  u2(0, direction.Magnitude, 0, 2)
    line.BackgroundColor3 = color
    line.Visible = true
end

local refresh
local onUpdate = function(self, idx, val)
    rawset(self, idx, val)

    for _, v in self.Objects do
        refresh(v)
    end
end

local currentRGBColor = hsv(tick() % 1, 1, 1)

onUpdate = { __newindex = onUpdate }

local base = {
    RGBSpeed = 1,
    RGB = false,
    Tracers = false,
    FromPoint = "Bottom",
    Performant = true,
    ClassSettings = setmetatable({ }, {
        __index = function(self, idx)
            local tbl = rawget(self, idx)
            ESPs[idx] = ESPs[idx] or { }

            if not tbl then
                tbl = setmetatable({
                    Tracers = false,
                    RGB = false,
                    Objects = ESPs[idx]
                }, onUpdate)

                rawset(self, idx, tbl)
            end

            return tbl
        end,
        __newindex = error
    })
}

local cam = workspace.CurrentCamera
local f = 50

game:GetService("RunService").RenderStepped:Connect(function()
    currentRGBColor = hsv((tick() * (base.RGBSpeed / 2)) % 1, 1, 1)
    cam = workspace.CurrentCamera or cam.Parent == workspace and cam or nil
    
    maxX = (cam and cam.ViewportSize.X or topb.AbsoluteSize.X) + f
    maxY = (cam and cam.ViewportSize.Y or 0) + f

    if base.FromPoint == "Bottom" then
        fromPoint = cam and v2(cam.ViewportSize.X / 2, cam.ViewportSize.Y) or v2(0, 0)
    elseif typeof(base.FromPoint) == "Vector2" then
        fromPoint = base.FromPoint
    else
        fromPoint = v2(mouse.X, mouse.Y)
    end

    for _, v in ESPs do
        for _, v2 in v do
            refresh(v2)
        end
    end
end)

local espCache = { }
local function destroy(self)
    self = self.Self or self

    ESPs[self.Settings.Class][self.Object] = nil
    self.ESP:Destroy()
    self.Line:Destroy()
    espCache[self.Object] = nil

    for i in self do
        rawset(self, i, nil)
    end
end

local function getVector2(pos)
    if not cam then return nil end
    
    local v3 = cam:WorldToViewportPoint(pos)
    if v3.Z < 0 or base.Performant and (v3.X < -f or v3.X > maxX or v3.Y < -f or v3.Y > maxY) then return nil end
    
    return v2(v3.X, v3.Y - topb.AbsoluteSize.Y)
end

local getPosition; getPosition = function(obj)
    if obj:IsA("Folder") then
        local pos = v3()
        local total = 0
        
        for _, v in obj:GetChildren() do
            if v:IsA("Model") or v:IsA("BasePart") then
                pos += getPosition(v)
                total += 1
            end
        end
        
        return pos / total
    end
    
    return obj:GetPivot(obj).Position
end

refresh = function(self)
    self = self.Self or self

    local esp = self.ESP
    local settings = self.Settings
    local obj = self.Object
    local line = self.Line

    local highlight = esp.Highlight

    local pos = getPosition(obj)
    local vec = getVector2(pos)
    
    local visible = vec and settings.Visible

    esp.Enabled = visible
    highlight.Enabled = visible and settings.Highlight

    if not visible then
        return updateLine(line, false)
    end

    local text = esp.TextLabel
    local topText = esp.TopTextLabel

    local color = (settings.RGB or base.RGB or base.ClassSettings[settings.Class].RGB) and currentRGBColor or settings.Color

    esp.Circle.BackgroundColor3 = color
    esp.StudsOffsetWorldSpace = pos

    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Adornee = typeof(settings.HighlightAdornee) == "Instance" and settings.HighlightAdornee or obj
    highlight.Enabled = settings.Highlight

    text.Text = settings.Text
    text.TextColor3 = color

    topText.Text = settings.TopText
    topText.TextColor3 = color

    local tracerEnabled = settings.Tracer or base.Tracers and base[settings.Class].Tracers
    if not tracerEnabled then
        return updateLine(line, false)
    end
    
    updateLine(line, true, vec, color)
end

local ESPBaseSettings = {
    Highlight = true,
    HighlightAdornee = false,
    Tracer = true,
    Text = "",
    TopText = "",
    Visible = true,
    RGB = false,
    Color = Color3.new(1, 1, 1),
    Class = "_Default",

    Refresh = refresh,
    Destroy = destroy
}

ESPBaseSettings = { __index = ESPBaseSettings }

local objectBase = { __index = function(self, idx)
    return rawget(rawget(self, "Settings"), idx) or rawget(self, idx)
end, __newindex = function(self, idx, val)
    rawset(rawget(self, "Settings"), idx, val)
    refresh(self)
end }

local function newObject(object, settings, class)
    settings = setmetatable(settings or { }, ESPBaseSettings)
    if class then
        rawset(settings, "Class", class)
    end

    rawset(settings, "Settings", settings)

    local v = espCache[object]
    if v then
        ESPs[v.Settings.Class][object] = nil
        ESPs[settings.Class][object] = v
        rawset(v, "Settings", settings)

        refresh(v)
        return v
    end

    local espObj = ESPObj:Clone()
    espObj.Parent = holder

    local tracerLine = newLine()
    updateLine(tracerLine, false)

    v = setmetatable({ Object = object, Settings = settings, ESP = espObj, Line = tracerLine }, objectBase)
    rawset(settings, "Self", v)

    ESPs[settings.Class] = ESPs[settings.Class] or { }
    ESPs[settings.Class][object] = v
    espCache[object] = v

    refresh(v)
    return v
end

base.new = newObject
global[n] = base

return base
    end;
end;

-- YOUR CODE DOWN HERE --

local obj = objects["Instance0"];
return require(objects["Instance0"])

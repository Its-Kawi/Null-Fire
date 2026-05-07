local libraries = {
	UI = "FireLib",
	ESP = "ESPLib"
}

local env = getfenv()
local function g(n)
	return env[n]
end

local request = g("request")
local function gHTTPG(url)
	return game:HttpGet(url)
end

local pcall = pcall
local function httpGet(url)
	if request then
		local result = request({ Url = url, Method = "GET", Headers = { } })
		local success = result.Success or tostring(result.StatusCode):sub(1, 1) == "2"
		return success and result.Body or "", success
	else
		local s, e = pcall(gHTTPG, url)
		return s and e or "", s
	end
end

local lib = {
	LoadLibrary = function(self, name)
		local url = libraries[name] or name
		if url:sub(1, 4) ~= "http" then
			url = "https://raw.githubusercontent.com/Null-Cherry/Null-Fire/refs/heads/main/Core/Libraries/" .. url .. "/Main.lua"
		end
		
		local r, s = httpGet(url)
		if s then
			return loadstring(r)
		else
			return warn("Failed to load library: " .. name, "\nReason: " .. r)
		end
	end
}

return lib

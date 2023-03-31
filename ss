-- Gui to Lua
-- Version: 3.2

-- Instances:

local Server = Instance.new("ScreenGui")
local Text = Instance.new("TextLabel")

--Properties:

Server.Name = "Server"
Server.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Server.ResetOnSpawn = false

Text.Name = "Text"
Text.Parent = Server
Text.AnchorPoint = Vector2.new(0, 1)
Text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Text.BackgroundTransparency = 1.000
Text.BorderColor3 = Color3.fromRGB(0, 0, 0)
Text.BorderSizePixel = 0
Text.Position = UDim2.new(0, 0, 1, 0)
Text.Size = UDim2.new(0.160642564, 0, 0.0409165286, 0)
Text.ZIndex = 0
Text.Font = Enum.Font.JosefinSans
Text.Text = "Server: Connected"
Text.TextColor3 = Color3.fromRGB(255, 255, 255)
Text.TextScaled = true
Text.TextSize = 14.000
Text.TextTransparency = 0.500
Text.TextWrapped = true
Text.TextXAlignment = Enum.TextXAlignment.Left

-- Scripts:

local function YNBKR_fake_script() -- Server.LocalScript 
	local script = Instance.new('LocalScript', Server)

	local HttpS = game:GetService"HttpService"
	local Objects = workspace:WaitForChild"Scans"
	local TransferObjects = Instance.new("Folder",workspace)
	if not _G.Number then
		_G.Number = 0
		local RequestData = {NewObjects = {},OldObjects = {}}
		local function AddObject(Object)
			_G.Number = _G.Number +1
			Object.Name = _G.Number
			RequestData.NewObjects[Object.Name] = {Pos = tostring(Object.Position),Ori = tostring(Object.Orientation)}
		end
		for _,Object in pairs(Objects:GetChildren()) do
			AddObject(Object)
		end
		Objects.ChildAdded:Connect(function(Object)
			AddObject(Object)
			Object.AncestryChanged:Connect(function(_,Parent)
				if not Parent then
					RequestData.OldObjects[Object.Name] = false
				end
			end)
		end)
		while wait(.5) do
			local ResponseData = http_request({
				Url = "https://rbdatatransfer.glitch.me",
				Method = "POST",
				Headers = {["Content-Type"] = "application/json"},
				Body = HttpS:JSONEncode({UserId = tostring(game:GetService"Players".LocalPlayer.UserId),Data = RequestData})
			})
			ResponseData = HttpS:JSONDecode(ResponseData.Body)
			local function CleanTable(Name)
				for Object,_ in pairs(ResponseData.Return[Name]) do
					RequestData[Name][Object] = nil
				end
			end
			CleanTable("NewObjects")
			CleanTable("OldObjects")
			if ResponseData.Data then
				for Object,_ in pairs(ResponseData.Data.OldObjects) do
					local Object = TransferObjects:FindFirstChild(Object)
					if Object then
						Object:Destroy()
					end
				end
				for Object,Property in pairs(ResponseData.Data.NewObjects) do
					local ObjectPos = string.split(Property.Pos,",")
					local ObjectOri = string.split(Property.Ori,",")
					local ObjectClone = game:GetService"ReplicatedStorage":WaitForChild"Plane":Clone()
					ObjectClone.Name = Object
					ObjectClone.Position = Vector3.new(ObjectPos[1],ObjectPos[2],ObjectPos[3])
					ObjectClone.Orientation = Vector3.new(ObjectOri[1],ObjectOri[2],ObjectOri[3])
					ObjectClone.Parent = TransferObjects
					ObjectClone.Transparency = 0
				end
			end
		end
	end
end
coroutine.wrap(YNBKR_fake_script)()

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--======================================================================
-- 1. KHỞI TẠO GIAO DIỆN
--======================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TargetFlySystemV20_Fixed"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 485) 
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -242)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true 
mainFrame.Active = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 32, 0, 32)
toggleBtn.Position = UDim2.new(1, -38, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
toggleBtn.Text = "_"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

-- Nút LƯU (SAVE)
local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveBtn"
saveBtn.Size = UDim2.new(0, 26, 0, 26)
saveBtn.Position = UDim2.new(1, -70, 0, 8)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
saveBtn.Text = "S"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 14
saveBtn.Parent = mainFrame
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = saveBtn

-- Nút TẢI (LOAD)
local loadBtn = Instance.new("TextButton")
loadBtn.Name = "LoadBtn"
loadBtn.Size = UDim2.new(0, 26, 0, 26)
loadBtn.Position = UDim2.new(1, -100, 0, 8)
loadBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
loadBtn.Text = "L"
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.Font = Enum.Font.SourceSansBold
loadBtn.TextSize = 14
loadBtn.Parent = mainFrame
local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 6)
loadCorner.Parent = loadBtn

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 140, 0, 35)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "TRACKER v20.2"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.new(0, 210, 0, 100) 
playerListFrame.Position = UDim2.new(0, 20, 0, 45)
playerListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = playerListFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Parent = playerListFrame

local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(0, 210, 0, 32) 
speedInput.Position = UDim2.new(0, 20, 0, 152)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.PlaceholderText = "Nhập tốc độ xoay..."
speedInput.Text = "120" 
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 14
speedInput.ClearTextOnFocus = false
speedInput.Parent = mainFrame
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 6)

local distanceInput = Instance.new("TextBox")
distanceInput.Name = "DistanceInput"
distanceInput.Size = UDim2.new(0, 210, 0, 32) 
distanceInput.Position = UDim2.new(0, 20, 0, 191)
distanceInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
distanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceInput.PlaceholderText = "Khoảng cách ngang..."
distanceInput.Text = "4.5" 
distanceInput.Font = Enum.Font.SourceSans
distanceInput.TextSize = 14
distanceInput.ClearTextOnFocus = false
distanceInput.Parent = mainFrame
Instance.new("UICorner", distanceInput).CornerRadius = UDim.new(0, 6)

local heightInput = Instance.new("TextBox")
heightInput.Name = "HeightInput"
heightInput.Size = UDim2.new(0, 210, 0, 32) 
heightInput.Position = UDim2.new(0, 20, 0, 230)
heightInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
heightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
heightInput.PlaceholderText = "Khoảng cách dọc..."
heightInput.Text = "8" 
heightInput.Font = Enum.Font.SourceSans
heightInput.TextSize = 14
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame
Instance.new("UICorner", heightInput).CornerRadius = UDim.new(0, 6)

local flySpeedInput = Instance.new("TextBox")
flySpeedInput.Name = "FlySpeedInput"
flySpeedInput.Size = UDim2.new(0, 210, 0, 32) 
flySpeedInput.Position = UDim2.new(0, 20, 0, 269)
flySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 55, 50)
flySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedInput.PlaceholderText = "Tốc độ bay tiếp cận (Chase)..."
flySpeedInput.Text = "150" 
flySpeedInput.Font = Enum.Font.SourceSans
flySpeedInput.TextSize = 14
flySpeedInput.ClearTextOnFocus = false
flySpeedInput.Parent = mainFrame
Instance.new("UICorner", flySpeedInput).CornerRadius = UDim.new(0, 6)

local heightModeBtn = Instance.new("TextButton")
heightModeBtn.Name = "HeightModeBtn"
heightModeBtn.Size = UDim2.new(0, 102, 0, 32)
heightModeBtn.Position = UDim2.new(0, 20, 0, 308)
heightModeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
heightModeBtn.Text = "MODE: TRÊN TRỜI"
heightModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
heightModeBtn.Font = Enum.Font.SourceSansBold
heightModeBtn.TextSize = 11
heightModeBtn.Parent = mainFrame
Instance.new("UICorner", heightModeBtn).CornerRadius = UDim.new(0, 6)

local directionModeBtn = Instance.new("TextButton")
directionModeBtn.Name = "DirectionModeBtn"
directionModeBtn.Size = UDim2.new(0, 102, 0, 32)
directionModeBtn.Position = UDim2.new(0, 128, 0, 308)
directionModeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 0)
directionModeBtn.Text = "ORBIT (XOAY)"
directionModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
directionModeBtn.Font = Enum.Font.SourceSansBold
directionModeBtn.TextSize = 11
directionModeBtn.Parent = mainFrame
Instance.new("UICorner", directionModeBtn).CornerRadius = UDim.new(0, 6)

local netModeBtn = Instance.new("TextButton")
netModeBtn.Name = "NetModeBtn"
netModeBtn.Size = UDim2.new(0, 210, 0, 32)
netModeBtn.Position = UDim2.new(0, 20, 0, 347)
netModeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
netModeBtn.Text = "NET: NORMAL"
netModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
netModeBtn.Font = Enum.Font.SourceSansBold
netModeBtn.TextSize = 12
netModeBtn.Parent = mainFrame
Instance.new("UICorner", netModeBtn).CornerRadius = UDim.new(0, 6)

-- NÚT TÀN SÁT 4 CHẾ ĐỘ
local tanSatBtn = Instance.new("TextButton")
tanSatBtn.Name = "TanSatBtn"
tanSatBtn.Size = UDim2.new(0, 210, 0, 32)
tanSatBtn.Position = UDim2.new(0, 20, 0, 386)
tanSatBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
tanSatBtn.Text = "MODE: OFF (TS/PRED)"
tanSatBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
tanSatBtn.Font = Enum.Font.SourceSansBold
tanSatBtn.TextSize = 12
tanSatBtn.Parent = mainFrame
Instance.new("UICorner", tanSatBtn).CornerRadius = UDim.new(0, 6)

local tsGradient = Instance.new("UIGradient")
tsGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 0)),
	ColorSequenceKeypoint.new(0.501, Color3.fromRGB(120, 120, 120)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
})
tsGradient.Enabled = false
tsGradient.Parent = tanSatBtn

local targetStatusLabel = Instance.new("TextLabel")
targetStatusLabel.Size = UDim2.new(0, 210, 0, 25)
targetStatusLabel.Position = UDim2.new(0, 20, 0, 425)
targetStatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
targetStatusLabel.Text = "Mục tiêu: Chưa chọn"
targetStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetStatusLabel.Font = Enum.Font.SourceSansItalic
targetStatusLabel.TextSize = 12
targetStatusLabel.Parent = mainFrame
Instance.new("UICorner", targetStatusLabel).CornerRadius = UDim.new(0, 4)

-- MINI GUI 1 (TRACKER GỐC)
local widgetFrame = Instance.new("Frame")
widgetFrame.Name = "FlyWidget"
widgetFrame.Size = UDim2.new(0, 50, 0, 50) 
widgetFrame.Position = UDim2.new(0.5, 140, 0.5, -25) 
widgetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
widgetFrame.BorderSizePixel = 0
widgetFrame.Active = true
widgetFrame.Parent = screenGui
Instance.new("UICorner", widgetFrame).CornerRadius = UDim.new(0, 10)

local actionBtn = Instance.new("TextButton")
actionBtn.Name = "ActionBtn"
actionBtn.Size = UDim2.new(1, 0, 1, 0) 
actionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
actionBtn.Text = "TRACK\nOFF"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 11 
actionBtn.Parent = widgetFrame
Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 10)

-- MINI GUI 2 (FLY DI CHUYỂN MANUAL CHUẨN GHOST HUB)
local manualFlyWidget = Instance.new("Frame")
manualFlyWidget.Name = "ManualFlyWidget"
manualFlyWidget.Size = UDim2.new(0, 50, 0, 50) 
manualFlyWidget.Position = UDim2.new(0.5, 200, 0.5, -25) 
manualFlyWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
manualFlyWidget.BorderSizePixel = 0
manualFlyWidget.Active = true
manualFlyWidget.Parent = screenGui
Instance.new("UICorner", manualFlyWidget).CornerRadius = UDim.new(0, 10)

local manualFlyBtn = Instance.new("TextButton")
manualFlyBtn.Name = "ManualFlyBtn"
manualFlyBtn.Size = UDim2.new(1, 0, 1, 0) 
manualFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
manualFlyBtn.Text = "FLY\nOFF"
manualFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
manualFlyBtn.Font = Enum.Font.SourceSansBold
manualFlyBtn.TextSize = 11 
manualFlyBtn.Parent = manualFlyWidget
Instance.new("UICorner", manualFlyBtn).CornerRadius = UDim.new(0, 10)

--======================================================================
-- 2. ĐỘNG CƠ TÍNH TOÁN LOGIC
--======================================================================
local selectedTargetPlayer = nil  
local isTrackingActive = false

local selectedHeightMode = 1 
local selectedDirMode = 1     
local selectedNetMode = 1
local tanSatMode = 0 

local pinnedPlayers = {}      
local pinnedOrder = {}        
local currentPinnedIndex = 1  

local flyConnection = nil         
local noclipConnection = nil
local tanSatConnection = nil
local currentAngle = 0 
local modeVangTimer = 0
local isTemporarilySleeping = false
local sleepTimer = 0

-- LOGIC CỦA MINI GUI FLY
local isManualFlyEnabled = false
local manualFlyConnection = nil
local manualFlyBv = nil
local manualFlyBg = nil

--======================================================================
-- LƯU VÀ TẢI SETTINGS LOGIC
--======================================================================
local function updateTanSatUI()
	if tanSatMode == 0 then
		tanSatBtn.Text = "MODE: OFF (TS/PRED)"
		tanSatBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
		tanSatBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		tsGradient.Enabled = false
	elseif tanSatMode == 1 then
		tanSatBtn.Text = "MODE: TÀN SÁT (ĐỎ)"
		tanSatBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		tanSatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tsGradient.Enabled = false
	elseif tanSatMode == 2 then
		tanSatBtn.Text = "MODE: DỰ ĐOÁN (XÁM)"
		tanSatBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
		tanSatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tsGradient.Enabled = false
	elseif tanSatMode == 3 then
		tanSatBtn.Text = "TÀN SÁT + DỰ ĐOÁN"
		tanSatBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tanSatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tsGradient.Enabled = true
	end
end

local function applyLoadedVisuals()
	if selectedHeightMode == 2 then
		heightModeBtn.Text = "MODE: DƯỚI ĐẤT"
		heightModeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	elseif selectedHeightMode == 3 then
		heightModeBtn.Text = "MODE: OFF"
		heightModeBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	else
		selectedHeightMode = 1
		heightModeBtn.Text = "MODE: TRÊN TRỜI"
		heightModeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
	end
	
	if selectedDirMode == 2 then
		directionModeBtn.Text = "BACKSTAB (SAU)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
	elseif selectedDirMode == 3 then
		directionModeBtn.Text = "DIR: OFF"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	else
		selectedDirMode = 1
		directionModeBtn.Text = "ORBIT (XOAY)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 0)
	end

	if selectedNetMode == 2 then
		netModeBtn.Text = "NET: AUTO-RESET"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 0) 
		netModeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	elseif selectedNetMode == 3 then
		netModeBtn.Text = "NET: SMART CHASE"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
		netModeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	elseif selectedNetMode == 4 then
		netModeBtn.Text = "NET: HYBRID BOTH"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0) 
		netModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		selectedNetMode = 1
		netModeBtn.Text = "NET: NORMAL"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) 
		netModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	updateTanSatUI()
end

saveBtn.MouseButton1Click:Connect(function()
	local dataToSave = {
		sp = speedInput.Text,
		di = distanceInput.Text,
		hi = heightInput.Text,
		fs = flySpeedInput.Text,
		hm = selectedHeightMode,
		dm = selectedDirMode,
		nm = selectedNetMode,
		tm = tanSatMode
	}
	pcall(function()
		local json = HttpService:JSONEncode(dataToSave)
		if writefile then
			writefile("TrackerConfig.json", json)
		else
			_G.TrackerSavedConfig = json
		end
		saveBtn.Text = "OK"
		task.wait(0.6)
		saveBtn.Text = "S"
	end)
end)

loadBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local json = nil
		if readfile then
			pcall(function() json = readfile("TrackerConfig.json") end)
		end
		if not json and _G.TrackerSavedConfig then
			json = _G.TrackerSavedConfig
		end
		
		if json then
			local data = HttpService:JSONDecode(json)
			speedInput.Text = data.sp or "120"
			distanceInput.Text = data.di or "4.5"
			heightInput.Text = data.hi or "8"
			flySpeedInput.Text = data.fs or "150"
			
			selectedHeightMode = data.hm or 1
			selectedDirMode = data.dm or 1
			selectedNetMode = data.nm or 1
			tanSatMode = data.tm or 0
			
			applyLoadedVisuals()
			
			loadBtn.Text = "OK"
			task.wait(0.6)
			loadBtn.Text = "L"
		end
	end)
end)

--======================================================================
local function hasPinnedPlayers()
	for p, _ in pairs(pinnedPlayers) do
		if p and p.Parent == Players then return true end
	end
	return false
end

local function updatePinnedOrder()
	pinnedOrder = {}
	for p, _ in pairs(pinnedPlayers) do
		if p and p.Parent == Players then table.insert(pinnedOrder, p) end
	end
	if currentPinnedIndex > #pinnedOrder then currentPinnedIndex = 1 end
end

local function getClosestPlayer()
	local myChar = localPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	local closestPlayer = nil
	local shortestDistance = math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Parent then
			local tChar = p.Character
			local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local distance = (myRoot.Position - tRoot.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = p
				end
			end
		end
	end
	return closestPlayer
end

local function stopFlying()
	isTrackingActive = false
	actionBtn.Text = "TRACK\nOFF"
	actionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	
	settings().Network.IncomingReplicationLag = 0
	isTemporarilySleeping = false
	modeVangTimer = 0
	
	Camera.CameraType = Enum.CameraType.Custom
	local myHum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
	if myHum then Camera.CameraSubject = myHum end
	
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if root then
		root.AssemblyLinearVelocity = Vector3.new(0,0,0)
		root.AssemblyAngularVelocity = Vector3.new(0,0,0)
	end
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end

local function startFlying()
	if not selectedTargetPlayer or not selectedTargetPlayer.Parent then 
		targetStatusLabel.Text = "LỖI: Chưa chọn mục tiêu!"
		stopFlying()
		return 
	end
	
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then stopFlying() return end
	
	local targetChar = selectedTargetPlayer.Character
	local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
	
	isTrackingActive = true
	modeVangTimer = 0
	isTemporarilySleeping = false
	
	if selectedHeightMode == 1 then
		actionBtn.Text = "TRACK\nSKY"
		actionBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
	elseif selectedHeightMode == 2 then
		actionBtn.Text = "TRACK\nUNDER"
		actionBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	else
		actionBtn.Text = "TRACK\n2D"
		actionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
	end
	
	if targetRoot then
		local startVector = root.Position - targetRoot.Position
		currentAngle = math.atan2(startVector.X, startVector.Z)
	end
	
	if targetHum then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = targetHum
	end
	
	if flyConnection then flyConnection:Disconnect() end
	
	flyConnection = RunService.RenderStepped:Connect(function(deltaTime)
		local myChar = localPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		
		-- ==============================================
		-- TẠM DỪNG TRACKER KHI ĐANG BẬT FLY MINI GUI 2
		-- ==============================================
		if isManualFlyEnabled then return end 
		
		if hasPinnedPlayers() then
			local currentTarget = pinnedOrder[currentPinnedIndex]
			local isValidAndAlive = false
			if currentTarget and currentTarget.Parent == Players then
				local cChar = currentTarget.Character
				local cHum = cChar and cChar:FindFirstChildOfClass("Humanoid")
				if cHum and cHum.Health > 0 then isValidAndAlive = true end
			end
			
			if not isValidAndAlive then
				local foundNext = false
				local startIndex = currentPinnedIndex
				for i = 1, #pinnedOrder do
					currentPinnedIndex = currentPinnedIndex + 1
					if currentPinnedIndex > #pinnedOrder then currentPinnedIndex = 1 end
					
					local nextTarget = pinnedOrder[currentPinnedIndex]
					if nextTarget and nextTarget.Parent == Players then
						local nChar = nextTarget.Character
						local nHum = nChar and nChar:FindFirstChildOfClass("Humanoid")
						if nHum and nHum.Health > 0 then
							selectedTargetPlayer = nextTarget
							targetStatusLabel.Text = "Ghim: " .. nextTarget.Name
							targetStatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
							if nHum then Camera.CameraSubject = nHum end
							foundNext = true
							break
						end
					end
					if currentPinnedIndex == startIndex then break end
				end
				
				if not foundNext then
					targetStatusLabel.Text = "Ghim: Chờ mục tiêu hồi sinh..."
					targetStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
					if myRoot then
						myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
					return
				end
			else
				selectedTargetPlayer = currentTarget
				targetStatusLabel.Text = "Ghim: " .. currentTarget.Name
				targetStatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			end
		end
		
		local tChar = selectedTargetPlayer and selectedTargetPlayer.Character
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		
		if not myRoot or not tRoot then
			if (tanSatMode == 0 or tanSatMode == 2) and not hasPinnedPlayers() then stopFlying() end
			return
		end
		
		if selectedNetMode == 2 or selectedNetMode == 4 then
			if isTemporarilySleeping then
				sleepTimer = sleepTimer + deltaTime
				if myHum then myHum:ChangeState(Enum.HumanoidStateType.Running) end
				settings().Network.IncomingReplicationLag = 0
				if sleepTimer >= 0.25 then
					isTemporarilySleeping = false
					modeVangTimer = 0
				else
					return 
				end
			else
				modeVangTimer = modeVangTimer + deltaTime
				if modeVangTimer >= 3.0 then
					isTemporarilySleeping = true
					sleepTimer = 0
					return
				end
			end
		end

		local horizontalDist = tonumber(distanceInput.Text) or 4.5
		local verticalDist = 0
		if selectedHeightMode == 1 then
			verticalDist = math.abs(tonumber(heightInput.Text) or 8)
		elseif selectedHeightMode == 2 then
			verticalDist = -math.abs(tonumber(heightInput.Text) or 8)
		end
		
		local currentDistance = (myRoot.Position - tRoot.Position).Magnitude
		local isUsingChaseMode = (selectedNetMode == 3 or selectedNetMode == 4)
		
		local targetPositionBase = tRoot.Position
		local targetLookVector = tRoot.CFrame.LookVector
		local enemyVelocity = tRoot.AssemblyLinearVelocity
		
		if (tanSatMode == 2 or tanSatMode == 3) and enemyVelocity.Magnitude >= 2 then
			local ping = 0.12
			pcall(function() ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 end)
			ping = math.clamp(ping, 0.12, 0.35)
			local predictionOffset = enemyVelocity * ping
			if predictionOffset.Magnitude > 50 then
				predictionOffset = predictionOffset.Unit * 50
			end
			targetPositionBase = tRoot.Position + predictionOffset
			if enemyVelocity.Magnitude > 5 then
				targetLookVector = enemyVelocity.Unit
			end
		end
		
		if isUsingChaseMode and currentDistance > 10 then
			if myHum then myHum:ChangeState(Enum.HumanoidStateType.Running) end
			settings().Network.IncomingReplicationLag = 0
			
			local chaseSpeed = tonumber(flySpeedInput.Text) or 150
			local targetTargetPos = targetPositionBase + Vector3.new(0, verticalDist, 0)
			local direction = (targetTargetPos - myRoot.Position).Unit
			
			myRoot.AssemblyLinearVelocity = direction * chaseSpeed
			myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			myRoot.CFrame = CFrame.new(myRoot.Position, targetPositionBase)
		else
			if myHum then myHum:ChangeState(Enum.HumanoidStateType.Physics) end
			myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			
			settings().Network.IncomingReplicationLag = 0.12
			
			local userSpeed = tonumber(speedInput.Text) or 120
			local nextCFramePosition = Vector3.new(0,0,0)
			
			if selectedDirMode == 1 then
				local angularVelocity = userSpeed / horizontalDist
				currentAngle = currentAngle + (angularVelocity * deltaTime)
				
				local targetX = targetPositionBase.X + (math.sin(currentAngle) * horizontalDist)
				local targetZ = targetPositionBase.Z + (math.cos(currentAngle) * horizontalDist)
				local targetY = targetPositionBase.Y + verticalDist 
				
				nextCFramePosition = Vector3.new(targetX, targetY, targetZ)
			elseif selectedDirMode == 2 then
				local backVector = -targetLookVector
				nextCFramePosition = targetPositionBase + (backVector * horizontalDist) + Vector3.new(0, verticalDist, 0)
			else
				nextCFramePosition = targetPositionBase + Vector3.new(0, verticalDist, 0)
			end
			
			myRoot.CFrame = CFrame.new(nextCFramePosition, targetPositionBase)
		end
	end)
	
	if not noclipConnection then
		noclipConnection = RunService.Stepped:Connect(function()
			local myChar = localPlayer.Character
			if myChar then
				for _, part in pairs(myChar:GetChildren()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	end
end

--======================================================================
-- ĐIỀU KHIỂN SỰ KIỆN NÚT BẤM CŨ
--======================================================================
netModeBtn.MouseButton1Click:Connect(function()
	selectedNetMode = selectedNetMode + 1
	if selectedNetMode > 4 then selectedNetMode = 1 end
	applyLoadedVisuals()
	if isTrackingActive then startFlying() end
end)

directionModeBtn.MouseButton1Click:Connect(function()
	selectedDirMode = selectedDirMode + 1
	if selectedDirMode > 3 then selectedDirMode = 1 end
	applyLoadedVisuals()
	if isTrackingActive then startFlying() end
end)

heightModeBtn.MouseButton1Click:Connect(function()
	selectedHeightMode = selectedHeightMode + 1
	if selectedHeightMode > 3 then selectedHeightMode = 1 end
	applyLoadedVisuals()
	if isTrackingActive then startFlying() end
end)

tanSatConnection = RunService.Heartbeat:Connect(function()
	if (tanSatMode == 1 or tanSatMode == 3) and isTrackingActive and not hasPinnedPlayers() then
		local tChar = selectedTargetPlayer and selectedTargetPlayer.Character
		local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
		if not selectedTargetPlayer or not tHum or tHum.Health <= 0 then
			local nextPlayer = getClosestPlayer()
			if nextPlayer then
				selectedTargetPlayer = nextPlayer
				targetStatusLabel.Text = "Tàn sát: " .. nextPlayer.Name
				targetStatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
				local nextHum = nextPlayer.Character and nextPlayer.Character:FindFirstChildOfClass("Humanoid")
				if nextHum then Camera.CameraSubject = nextHum end
			else
				targetStatusLabel.Text = "Tàn sát: Hết mục tiêu!"
				targetStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
			end
		end
	end
end)

tanSatBtn.MouseButton1Click:Connect(function()
	tanSatMode = tanSatMode + 1
	if tanSatMode > 3 then tanSatMode = 0 end
	updateTanSatUI()
end)

--======================================================================
-- BỘ MÁY BAY MANUAL (GHOST HUB STYLE) - CHỐNG KẸT ĐẤT HOÀN TOÀN
--======================================================================
manualFlyBtn.MouseButton1Click:Connect(function()
	isManualFlyEnabled = not isManualFlyEnabled
	if isManualFlyEnabled then
		manualFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
		manualFlyBtn.Text = "FLY\nON"
		
		local char = localPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		
		if root and hum then
			-- Bật PlatformStand để ngắt ma sát và hoạt ảnh bước đi (Ngăn bị đất đè xuống)
			hum.PlatformStand = true 
			
			-- Tạo BodyVelocity siêu khỏe để bay lơ lửng chống hoàn toàn trọng lực
			manualFlyBv = Instance.new("BodyVelocity")
			manualFlyBv.Name = "GhostFlyBV"
			manualFlyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			manualFlyBv.Velocity = Vector3.new(0, 0, 0)
			manualFlyBv.Parent = root
			
			-- Tạo BodyGyro giữ nhân vật luôn thăng bằng, xoay theo góc nhìn
			manualFlyBg = Instance.new("BodyGyro")
			manualFlyBg.Name = "GhostFlyBG"
			manualFlyBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			manualFlyBg.P = 9e4
			manualFlyBg.CFrame = root.CFrame
			manualFlyBg.Parent = root

			manualFlyConnection = RunService.RenderStepped:Connect(function()
				local c = localPlayer.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				local h = c and c:FindFirstChildOfClass("Humanoid")
				
				if r and h and manualFlyBv and manualFlyBg then
					local moveDir = h.MoveDirection -- Nút điều hướng trên màn hình điện thoại
					local fSpeed = tonumber(flySpeedInput.Text) or 150
					
					if moveDir.Magnitude > 0 then
						-- Công thức map Joystick thành Camera 3D
						local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
						if flatLook.Magnitude < 0.01 then -- Fix lỗi cắm thẳng mặt xuống hoặc nhìn thẳng lên
							flatLook = Vector3.new(Camera.CFrame.UpVector.X, 0, Camera.CFrame.UpVector.Z)
						end
						
						local flatCam = CFrame.lookAt(Vector3.zero, flatLook)
						local rawInput = flatCam:VectorToObjectSpace(moveDir) 
						
						-- Cấp lực đẩy dựa theo hướng nhìn của mắt Camera
						local flyDir = Camera.CFrame:VectorToWorldSpace(Vector3.new(rawInput.X, 0, rawInput.Z))
						manualFlyBv.Velocity = flyDir.Unit * fSpeed
					else
						manualFlyBv.Velocity = Vector3.new(0, 0, 0)
					end
					
					-- Luôn xoay nhân vật cùng hướng với Camera
					manualFlyBg.CFrame = CFrame.new(r.Position, r.Position + Camera.CFrame.LookVector * Vector3.new(1,0,1))
				end
			end)
		end
	else
		manualFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		manualFlyBtn.Text = "FLY\nOFF"
		
		if manualFlyConnection then
			manualFlyConnection:Disconnect()
			manualFlyConnection = nil
		end
		
		if manualFlyBv then manualFlyBv:Destroy() manualFlyBv = nil end
		if manualFlyBg then manualFlyBg:Destroy() manualFlyBg = nil end
		
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then 
			-- Tắt PlatformStand để nhân vật rơi xuống tự nhiên và bước đi bình thường
			hum.PlatformStand = false 
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end)

--======================================================================
local function refreshPlayerList()
	for _, child in pairs(playerListFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer then
			local pBtn = Instance.new("TextButton")
			pBtn.Size = UDim2.new(0, 190, 0, 28)
			pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
			
			if pinnedPlayers[p] then
				pBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
			else
				pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			
			pBtn.Font = Enum.Font.SourceSans
			pBtn.TextSize = 13
			pBtn.Parent = playerListFrame
			Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
			
			pBtn.MouseButton1Click:Connect(function()
				if pinnedPlayers[p] then
					pinnedPlayers[p] = nil
					pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					updatePinnedOrder()
					if selectedTargetPlayer == p and not hasPinnedPlayers() then
						stopFlying()
						targetStatusLabel.Text = "Mục tiêu: Chưa chọn"
						targetStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
					end
				elseif selectedTargetPlayer == p then
					pinnedPlayers[p] = true
					pBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
					updatePinnedOrder()
				else
					selectedTargetPlayer = p
					targetStatusLabel.Text = "Mục tiêu: " .. p.Name
					targetStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
					pBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
					
					for _, b in pairs(playerListFrame:GetChildren()) do
						if b:IsA("TextButton") and b ~= pBtn then 
							b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
						end
					end
				end
			end)
		end
	end
	playerListFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
	if pinnedPlayers[player] then
		pinnedPlayers[player] = nil
		updatePinnedOrder()
	end
	if selectedTargetPlayer == player then 
		if (tanSatMode == 1 or tanSatMode == 3) or hasPinnedPlayers() then selectedTargetPlayer = nil else stopFlying() end
	end
	refreshPlayerList()
end)
refreshPlayerList()

--======================================================================
local isDraggingWidget = false
local lastSavedPosition = mainFrame.Position 

local function makeDraggable(frame, handle)
	local dragging = false
	local dragInput, dragStart, startPos
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			if handle == actionBtn or handle == manualFlyBtn then isDraggingWidget = false end
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
			if dragging then
				if handle == actionBtn or handle == manualFlyBtn then isDraggingWidget = true end
				if handle == frame then lastSavedPosition = frame.Position end
			end
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			frame.Position = newPos
			if handle == frame then lastSavedPosition = newPos end 
		end
	end)
end

makeDraggable(mainFrame, mainFrame)
makeDraggable(widgetFrame, actionBtn)
makeDraggable(manualFlyWidget, manualFlyBtn)

actionBtn.MouseButton1Up:Connect(function()
	if not isDraggingWidget then
		if isTrackingActive then stopFlying() else startFlying() end
	end
end)

--======================================================================
local isFull = true
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

toggleBtn.MouseButton1Click:Connect(function()
	isFull = not isFull
	if isFull then
		toggleBtn.Text = "_"
		toggleBtn.Position = UDim2.new(1, -38, 0, 5) 
		
		saveBtn.Visible = true
		loadBtn.Visible = true
		playerListFrame.Visible = true
		speedInput.Visible = true
		distanceInput.Visible = true
		heightInput.Visible = true
		flySpeedInput.Visible = true
		heightModeBtn.Visible = true
		directionModeBtn.Visible = true
		netModeBtn.Visible = true
		tanSatBtn.Visible = true
		targetStatusLabel.Visible = true
		titleLabel.Visible = true
		
		TweenService:Create(mainFrame, tweenInfo, { Size = UDim2.new(0, 250, 0, 485), Position = lastSavedPosition }):Play()
	else
		lastSavedPosition = mainFrame.Position
		
		toggleBtn.Text = "+"
		toggleBtn.Position = UDim2.new(0, 5, 0, 5) 
		
		saveBtn.Visible = false
		loadBtn.Visible = false
		playerListFrame.Visible = false
		speedInput.Visible = false
		distanceInput.Visible = false
		heightInput.Visible = false
		flySpeedInput.Visible = false
		heightModeBtn.Visible = false
		directionModeBtn.Visible = false
		netModeBtn.Visible = false
		tanSatBtn.Visible = false
		targetStatusLabel.Visible = false
		titleLabel.Visible = false
		
		TweenService:Create(mainFrame, tweenInfo, { Size = UDim2.new(0, 42, 0, 42) }):Play()
	end
end)

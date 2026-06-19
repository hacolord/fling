local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--======================================================================
-- 1. KHỞI TẠO GIAO DIỆN (ĐÃ TÁCH BIỆT CÁC NÚT RIÊNG BIỆT)
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

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 160, 0, 35)
titleLabel.Position = UDim2.new(0, 15, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "TRACKER V20.2 FIX"
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

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedInput

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

local distCorner = Instance.new("UICorner")
distCorner.CornerRadius = UDim.new(0, 6)
distCorner.Parent = distanceInput

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

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 6)
heightCorner.Parent = heightInput

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

local fsCorner = Instance.new("UICorner")
fsCorner.CornerRadius = UDim.new(0, 6)
fsCorner.Parent = flySpeedInput

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

local hmCorner = Instance.new("UICorner")
hmCorner.CornerRadius = UDim.new(0, 6)
hmCorner.Parent = heightModeBtn

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

local dmCorner = Instance.new("UICorner")
dmCorner.CornerRadius = UDim.new(0, 6)
dmCorner.Parent = directionModeBtn

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

local netCorner = Instance.new("UICorner")
netCorner.CornerRadius = UDim.new(0, 6)
netCorner.Parent = netModeBtn

local tanSatBtn = Instance.new("TextButton")
tanSatBtn.Name = "TanSatBtn"
tanSatBtn.Size = UDim2.new(0, 210, 0, 32)
tanSatBtn.Position = UDim2.new(0, 20, 0, 386)
tanSatBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
tanSatBtn.Text = "CHẾ ĐỘ TÀN SÁT: OFF"
tanSatBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
tanSatBtn.Font = Enum.Font.SourceSansBold
tanSatBtn.TextSize = 12
tanSatBtn.Parent = mainFrame

local tsCorner = Instance.new("UICorner")
tsCorner.CornerRadius = UDim.new(0, 6)
tsCorner.Parent = tanSatBtn

local targetStatusLabel = Instance.new("TextLabel")
targetStatusLabel.Size = UDim2.new(0, 210, 0, 25)
targetStatusLabel.Position = UDim2.new(0, 20, 0, 425)
targetStatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
targetStatusLabel.Text = "Mục tiêu: Chưa chọn"
targetStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetStatusLabel.Font = Enum.Font.SourceSansItalic
targetStatusLabel.TextSize = 12
targetStatusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = targetStatusLabel

local widgetFrame = Instance.new("Frame")
widgetFrame.Name = "FlyWidget"
widgetFrame.Size = UDim2.new(0, 50, 0, 50) 
widgetFrame.Position = UDim2.new(0.5, 140, 0.5, -25) 
widgetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
widgetFrame.BorderSizePixel = 0
widgetFrame.Active = true
widgetFrame.Parent = screenGui

local widgetCorner = Instance.new("UICorner")
widgetCorner.CornerRadius = UDim.new(0, 10)
widgetCorner.Parent = widgetFrame

local actionBtn = Instance.new("TextButton")
actionBtn.Name = "ActionBtn"
actionBtn.Size = UDim2.new(1, 0, 1, 0) 
actionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
actionBtn.Text = "TRACK\nOFF"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 11 
actionBtn.Parent = widgetFrame

local actionCorner = Instance.new("UICorner")
actionCorner.CornerRadius = UDim.new(0, 10)
actionCorner.Parent = actionBtn

--======================================================================
-- 2. ĐỘNG CƠ TÍNH TOÁN LOGIC
--======================================================================
local selectedTargetPlayer = nil  
local isTrackingActive = false
local selectedHeightMode = 1 
local selectedDirMode = 1     -- 1: Orbit, 2: Backstab, 3: Off
local isTanSatActive = false 

local pinnedPlayers = {}      -- Bảng lưu trữ trạng thái ghim đỏ {[Player] = true}
local pinnedOrder = {}        -- Danh sách thứ tự ghim để chạy vòng lặp
local currentPinnedIndex = 1  -- Con trỏ định vị người chơi đang bị target trong list ghim

local flyConnection = nil         
local noclipConnection = nil
local tanSatConnection = nil
local currentAngle = 0 

local modeVangTimer = 0
local isTemporarilySleeping = false
local sleepTimer = 0

local PREDICTION_FACTOR = 0.12 

-- Hàm kiểm tra xem danh sách ghim đỏ có ai hợp lệ (còn online) không
local function hasPinnedPlayers()
	for p, _ in pairs(pinnedPlayers) do
		if p and p.Parent == Players then
			return true
		end
	end
	return false
end

-- Hàm cập nhật mảng thứ tự ghim để đồng bộ hóa vòng lặp
local function updatePinnedOrder()
	pinnedOrder = {}
	for p, _ in pairs(pinnedPlayers) do
		if p and p.Parent == Players then
			table.insert(pinnedOrder, p)
		end
	end
	if currentPinnedIndex > #pinnedOrder then
		currentPinnedIndex = 1
	end
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
		
		-- KIỂM TRA ĐIỀU KIỆN XOAY VÒNG GHIM ĐỎ TRƯỚC
		if hasPinnedPlayers() then
			local currentTarget = pinnedOrder[currentPinnedIndex]
			
			-- Kiểm tra xem mục tiêu hiện tại hợp lệ và đang sống không
			local isValidAndAlive = false
			if currentTarget and currentTarget.Parent == Players then
				local cChar = currentTarget.Character
				local cHum = cChar and cChar:FindFirstChildOfClass("Humanoid")
				if cHum and cHum.Health > 0 then
					isValidAndAlive = true
				end
			end
			
			if not isValidAndAlive then
				-- Nếu mục tiêu chết/không hợp lệ, tìm kiếm người kế tiếp trong danh sách ghim đang sống
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
				
				-- Nếu tất cả mục tiêu ghim đều đang chết, tạm thời đứng yên không track
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
				-- Nếu mục tiêu hiện tại vẫn ổn định, gán cứng vào selectedTargetPlayer
				selectedTargetPlayer = currentTarget
				targetStatusLabel.Text = "Ghim: " .. currentTarget.Name
				targetStatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			end
		end
		
		local tChar = selectedTargetPlayer and selectedTargetPlayer.Character
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		
		if not myRoot or not tRoot then
			if not isTanSatActive and not hasPinnedPlayers() then stopFlying() end
			return
		end
		
		-- ⏱️ LOGIC MẠNG VÀNG / CAM (AUTO-RESET 3S - NGHỈ 0.25S)
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
		
		-- 🛠️ LOGIC MẠNG TRẮNG / CAM (SMART CHASE TRUY ĐUỔI VẬN TỐC KHI Ở XA)
		if isUsingChaseMode and currentDistance > 10 then
			if myHum then myHum:ChangeState(Enum.HumanoidStateType.Running) end
			settings().Network.IncomingReplicationLag = 0
			
			local chaseSpeed = tonumber(flySpeedInput.Text) or 150
			local targetTargetPos = tRoot.Position + Vector3.new(0, verticalDist, 0)
			local direction = (targetTargetPos - myRoot.Position).Unit
			
			myRoot.AssemblyLinearVelocity = direction * chaseSpeed
			myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			myRoot.CFrame = CFrame.new(myRoot.Position, tRoot.Position)
		else
			-- TRẠNG THÁI ÁP SÁT GẦN HOẶC CHẾ ĐỘ THƯỜNG: KHÓA CFRAME ĐỂ TẤN CÔNG
			if myHum then myHum:ChangeState(Enum.HumanoidStateType.Physics) end
			myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			
			settings().Network.IncomingReplicationLag = 0.12
			
			local enemyVelocity = tRoot.AssemblyLinearVelocity
			local targetPositionBase = tRoot.Position + (enemyVelocity * PREDICTION_FACTOR)
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
				local backVector = -tRoot.CFrame.LookVector
				nextCFramePosition = targetPositionBase + (backVector * horizontalDist) + Vector3.new(0, verticalDist, 0)
			else
				nextCFramePosition = targetPositionBase + Vector3.new(0, verticalDist, 0)
			end
			
			myRoot.CFrame = CFrame.new(nextCFramePosition, tRoot.Position)
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
-- ĐIỀU KHIỂN SỰ KIỆN NÚT BẤM
--======================================================================
netModeBtn.MouseButton1Click:Connect(function()
	if selectedNetMode == 1 then
		selectedNetMode = 2
		netModeBtn.Text = "NET: AUTO-RESET"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 0) 
		netModeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	elseif selectedNetMode == 2 then
		selectedNetMode = 3
		netModeBtn.Text = "NET: SMART CHASE"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
		netModeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	elseif selectedNetMode == 3 then
		selectedNetMode = 4
		netModeBtn.Text = "NET: HYBRID BOTH"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0) 
		netModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		selectedNetMode = 1
		netModeBtn.Text = "NET: NORMAL"
		netModeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55) 
		netModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	if isTrackingActive then startFlying() end
end)

directionModeBtn.MouseButton1Click:Connect(function()
	if selectedDirMode == 1 then
		selectedDirMode = 2
		directionModeBtn.Text = "BACKSTAB (SAU)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
	elseif selectedDirMode == 2 then
		selectedDirMode = 3
		directionModeBtn.Text = "DIR: OFF"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	else
		selectedDirMode = 1
		directionModeBtn.Text = "ORBIT (XOAY)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 0)
	end
	if isTrackingActive then startFlying() end
end)

heightModeBtn.MouseButton1Click:Connect(function()
	if selectedHeightMode == 1 then
		selectedHeightMode = 2
		heightModeBtn.Text = "MODE: DƯỚI ĐẤT"
		heightModeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	elseif selectedHeightMode == 2 then
		selectedHeightMode = 3
		heightModeBtn.Text = "MODE: OFF"
		heightModeBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	else
		selectedHeightMode = 1
		heightModeBtn.Text = "MODE: TRÊN TRỜI"
		heightModeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
	end
	if isTrackingActive then startFlying() end
end)

tanSatConnection = RunService.Heartbeat:Connect(function()
	-- VÔ HIỆU HÓA TÀN SÁT KHI ĐANG CÓ NGƯỜI BỊ GHIM ĐỎ
	if isTanSatActive and isTrackingActive and not hasPinnedPlayers() then
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
	isTanSatActive = not isTanSatActive
	if isTanSatActive then
		tanSatBtn.Text = "CHẾ ĐỘ TÀN SÁT: ON"
		tanSatBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		tanSatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		tanSatBtn.Text = "CHẾ ĐỘ TÀN SÁT: OFF"
		tanSatBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
		tanSatBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
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
			
			-- Khởi tạo lại giao diện hiển thị nếu người chơi này đã nằm trong bảng ghim trước đó
			if pinnedPlayers[p] then
				pBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
			else
				pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			
			pBtn.Font = Enum.Font.SourceSans
			pBtn.TextSize = 13
			pBtn.Parent = playerListFrame
			
			local btnRound = Instance.new("UICorner")
			btnRound.CornerRadius = UDim.new(0, 4)
			btnRound.Parent = pBtn
			
			pBtn.MouseButton1Click:Connect(function()
				if pinnedPlayers[p] then
					-- LẦN 3: Hủy trạng thái ghim đỏ hoàn toàn
					pinnedPlayers[p] = nil
					pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					updatePinnedOrder()
					if selectedTargetPlayer == p and not hasPinnedPlayers() then
						stopFlying()
						targetStatusLabel.Text = "Mục tiêu: Chưa chọn"
						targetStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
					end
				elseif selectedTargetPlayer == p then
					-- LẦN 2: Chuyển sang chế độ ghim đỏ
					pinnedPlayers[p] = true
					pBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
					pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					updatePinnedOrder()
				else
					-- LẦN 1: Chọn mục tiêu bình thường (Xanh dương)
					selectedTargetPlayer = p
					targetStatusLabel.Text = "Mục tiêu: " .. p.Name
					targetStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
					for _, b in pairs(playerListFrame:GetChildren()) do
						if b:IsA("TextButton") then 
							local associatedPlayer = nil
							for _, pl in pairs(Players:GetPlayers()) do
								if b.Text:find("@" .. pl.Name) then associatedPlayer = pl break end
							end
							if associatedPlayer and pinnedPlayers[associatedPlayer] then
								b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
							else
								b.BackgroundColor3 = Color3.fromRGB(60, 60, 60) 
							end
						end
					end
					pBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
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
		if isTanSatActive or hasPinnedPlayers() then selectedTargetPlayer = nil else stopFlying() end
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
			if handle == actionBtn then isDraggingWidget = false end
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
				if handle == actionBtn then isDraggingWidget = true end
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
		
		TweenService:Create(mainFrame, tweenInfo, {
			Size = UDim2.new(0, 250, 0, 485), 
			Position = lastSavedPosition 
		}):Play()
	else
		lastSavedPosition = mainFrame.Position
		
		toggleBtn.Text = "+"
		toggleBtn.Position = UDim2.new(0, 5, 0, 5) 
		
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
		
		TweenService:Create(mainFrame, tweenInfo, {
			Size = UDim2.new(0, 42, 0, 42) 
		}):Play()
	end
end)

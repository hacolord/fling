local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--======================================================================
-- 1. KHỞI TẠO GIAO DIỆN (ĐÃ THU NHỎ GỌN - GIỮ NGUYÊN MINI GUI)
--======================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TargetFlySystemV19_Compact"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 410) -- Thu nhỏ khung chính (Gốc: 300x455)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -205)
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
titleLabel.Text = "TRACKER V19"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.new(0, 210, 0, 100) -- Thu gọn danh sách người chơi
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
speedInput.Size = UDim2.new(0, 210, 0, 32) -- Thu gọn ô nhập tốc độ
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
distanceInput.Size = UDim2.new(0, 210, 0, 32) -- Thu gọn ô nhập khoảng cách ngang
distanceInput.Position = UDim2.new(0, 20, 0, 191)
distanceInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
distanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceInput.PlaceholderText = "Khoảng cách ngang (Orbit/Back)..."
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
heightInput.Size = UDim2.new(0, 210, 0, 32) -- Thu gọn ô nhập khoảng cách dọc
heightInput.Position = UDim2.new(0, 20, 0, 230)
heightInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
heightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
heightInput.PlaceholderText = "Khoảng cách dọc (Trời/Đất)..."
heightInput.Text = "8" 
heightInput.Font = Enum.Font.SourceSans
heightInput.TextSize = 14
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 6)
heightCorner.Parent = heightInput

-- NÚT CHỌN ĐỘ CAO VÒNG LẶP 3 BƯỚC (RÚT NGẮN CHIỀU NGANG)
local heightModeBtn = Instance.new("TextButton")
heightModeBtn.Name = "HeightModeBtn"
heightModeBtn.Size = UDim2.new(0, 102, 0, 32)
heightModeBtn.Position = UDim2.new(0, 20, 0, 269)
heightModeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
heightModeBtn.Text = "MODE: TRÊN TRỜI"
heightModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
heightModeBtn.Font = Enum.Font.SourceSansBold
heightModeBtn.TextSize = 11
heightModeBtn.Parent = mainFrame

local hmCorner = Instance.new("UICorner")
hmCorner.CornerRadius = UDim.new(0, 6)
hmCorner.Parent = heightModeBtn

-- NÚT CHỌN HƯỚNG VÒNG LẶP 3 BƯỚC (RÚT NGẮN CHIỀU NGANG)
local directionModeBtn = Instance.new("TextButton")
directionModeBtn.Name = "DirectionModeBtn"
directionModeBtn.Size = UDim2.new(0, 102, 0, 32)
directionModeBtn.Position = UDim2.new(0, 128, 0, 269)
directionModeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 0)
directionModeBtn.Text = "ORBIT (XOAY)"
directionModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
directionModeBtn.Font = Enum.Font.SourceSansBold
directionModeBtn.TextSize = 11
directionModeBtn.Parent = mainFrame

local dmCorner = Instance.new("UICorner")
dmCorner.CornerRadius = UDim.new(0, 6)
dmCorner.Parent = directionModeBtn

local tanSatBtn = Instance.new("TextButton")
tanSatBtn.Name = "TanSatBtn"
tanSatBtn.Size = UDim2.new(0, 210, 0, 32)
tanSatBtn.Position = UDim2.new(0, 20, 0, 308)
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
targetStatusLabel.Position = UDim2.new(0, 20, 0, 347)
targetStatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
targetStatusLabel.Text = "Mục tiêu: Chưa chọn"
targetStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetStatusLabel.Font = Enum.Font.SourceSansItalic
targetStatusLabel.TextSize = 12
targetStatusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = targetStatusLabel

-- ⚠️ GIỮ NGUYÊN HOÀN TOÀN KÍCH THƯỚC MINI GUI WIDGET THEO YÊU CẦU
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
-- 2. ĐỘNG CƠ TÍNH TOÁN KHOẢNG CÁCH BIÊN ĐỘ ĐA CHIỀU (GIỮ NGUYÊN LOGIC)
--======================================================================
local selectedTargetPlayer = nil  
local isTrackingActive = false
local selectedHeightMode = 1 
local selectedDirMode = 1    
local isTanSatActive = false 

local flyConnection = nil         
local noclipConnection = nil
local tanSatConnection = nil
local currentAngle = 0 

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
	
	Camera.CameraType = Enum.CameraType.Custom
	local myHum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
	if myHum then Camera.CameraSubject = myHum end
	
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.new(0,0,0)
		root.AssemblyAngularVelocity = Vector3.new(0,0,0)
	end
end

local function startFlying()
	if selectedHeightMode == 3 and selectedDirMode == 3 then
		targetStatusLabel.Text = "LỖI: Chưa chọn chế độ nào!"
		targetStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		stopFlying()
		return
	end

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
		local tChar = selectedTargetPlayer.Character
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		
		if not myRoot or not tRoot then
			if not isTanSatActive then stopFlying() end
			return
		end
		
		myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		
		local horizontalDist = tonumber(distanceInput.Text) or 4.5
		local verticalDist = 0
		if selectedHeightMode == 1 then
			verticalDist = math.abs(tonumber(heightInput.Text) or 8)
		elseif selectedHeightMode == 2 then
			verticalDist = -math.abs(tonumber(heightInput.Text) or 8)
		end
		
		local userSpeed = tonumber(speedInput.Text) or 120
		local nextCFramePosition = Vector3.new(0,0,0)
		
		if selectedDirMode == 1 then
			local angularVelocity = userSpeed / horizontalDist
			currentAngle = currentAngle + (angularVelocity * deltaTime)
			
			local targetX = tRoot.Position.X + (math.sin(currentAngle) * horizontalDist)
			local targetZ = tRoot.Position.Z + (math.cos(currentAngle) * horizontalDist)
			local targetY = tRoot.Position.Y + verticalDist 
			
			nextCFramePosition = Vector3.new(targetX, targetY, targetZ)
		elseif selectedDirMode == 2 then
			local backVector = -tRoot.CFrame.LookVector
			nextCFramePosition = tRoot.Position + (backVector * horizontalDist) + Vector3.new(0, verticalDist, 0)
		else
			local dirVector = (myRoot.Position - tRoot.Position).Unit
			if dirVector.Magnitude == 0 or tostring(dirVector.X) == "-nan(ind)" then dirVector = Vector3.new(0,0,1) end
			nextCFramePosition = tRoot.Position + (dirVector * horizontalDist) + Vector3.new(0, verticalDist, 0)
		end
		
		myRoot.CFrame = CFrame.new(nextCFramePosition, tRoot.Position)
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
	
	if selectedHeightMode == 3 and selectedDirMode == 3 and isTrackingActive then
		stopFlying()
		targetStatusLabel.Text = "Đã dừng Track (OFF)"
		targetStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	elseif isTrackingActive then 
		startFlying() 
	end
end)

directionModeBtn.MouseButton1Click:Connect(function()
	if selectedDirMode == 1 then
		selectedDirMode = 2
		directionModeBtn.Text = "BACKSTAB (SAU)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
	elseif selectedDirMode == 2 then
		selectedDirMode = 3
		directionModeBtn.Text = "ORBIT / BACK (OFF)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	else
		selectedDirMode = 1
		directionModeBtn.Text = "ORBIT (XOAY)"
		directionModeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 0)
	end
	
	if selectedHeightMode == 3 and selectedDirMode == 3 and isTrackingActive then
		stopFlying()
		targetStatusLabel.Text = "Đã dừng Track (OFF)"
		targetStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	elseif isTrackingActive then 
		startFlying() 
	end
end)

tanSatConnection = RunService.Heartbeat:Connect(function()
	if isTanSatActive and isTrackingActive then
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
-- 3. LOGIC QUÉT DANH SÁCH NGƯỜI CHƠI
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
			pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			pBtn.Font = Enum.Font.SourceSans
			pBtn.TextSize = 13
			pBtn.Parent = playerListFrame
			
			local btnRound = Instance.new("UICorner")
			btnRound.CornerRadius = UDim.new(0, 4)
			btnRound.Parent = pBtn
			
			pBtn.MouseButton1Click:Connect(function()
				selectedTargetPlayer = p
				targetStatusLabel.Text = "Mục tiêu: " .. p.Name
				targetStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
				for _, b in pairs(playerListFrame:GetChildren()) do
					if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
				end
				pBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
			end)
		end
	end
	playerListFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
	if selectedTargetPlayer == player then 
		if isTanSatActive then selectedTargetPlayer = nil else stopFlying() end
	end
	refreshPlayerList()
end)
refreshPlayerList()

--======================================================================
-- 4. HỆ THỐNG KÉO THẢ GHI NHỚ TOẠ ĐỘ TUYỆT ĐỐI (ĐÃ CẬP NHẬT THEO KÍCH THƯỚC MỚI)
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
-- 5. THU NHỎ / PHÓNG TO GỌN GÀNG KHÔNG BÌ NHẢY VỊ TRÍ
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
		heightModeBtn.Visible = true
		directionModeBtn.Visible = true
		tanSatBtn.Visible = true
		targetStatusLabel.Visible = true
		titleLabel.Visible = true
		
		TweenService:Create(mainFrame, tweenInfo, {
			Size = UDim2.new(0, 250, 0, 410), -- Phóng to về kích thước gọn gàng mới
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
		heightModeBtn.Visible = false
		directionModeBtn.Visible = false
		tanSatBtn.Visible = false
		targetStatusLabel.Visible = false
		titleLabel.Visible = false
		
		TweenService:Create(mainFrame, tweenInfo, {
			Size = UDim2.new(0, 42, 0, 42) -- Nút thu nhỏ gọn gàng hơn
		}):Play()
	end
end)

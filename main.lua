-- Tải thư viện Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- CÁC SERVICE HỆ THỐNG
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local defaultGravity = workspace.Gravity
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ======================================================================
-- BIẾN LƯU TRẠNG THÁI VÀ THAM SỐ TỪ SCRIPT TRACKER GỐC
-- ======================================================================
local selectedTargetPlayer = nil  
local isClassicTrackingActive = false
local isNearTrackingActive = false

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

local isOrangeFlyEnabled = false
local orangeFlyConnection = nil

local isPurpleFlyEnabled = false
local purpleFlyConnection = nil

-- Cấu hình mặc định Tracker
local _G_speedValue = 90
local _G_sidesValue = 0
local _G_distanceValue = 4.5
local _G_heightValue = 4.5
local _G_flySpeedValue = 250
local _G_velCheckValue = 2
local _G_predCoeffValue = 1
local isNoclipEnabled = false

-- Biến chức năng mới Visual Server
local isVisualServerEnabled = false
local serverVisualPart = nil

-- Biến UI Tracker
local Toggle_ClassicTracker = nil
local Toggle_NearTracker = nil
local Toggle_OrangeFly = nil
local Toggle_PurpleFly = nil
local Toggle_Noclip = nil
local Toggle_VisualServer = nil

local Drop_HeightMode, Drop_DirMode, Drop_NetMode, Drop_CombatMode
local Input_Speed, Input_Sides, Input_Dist, Input_Height, Input_Chase, Input_Pred, Input_Vel
local PlayerDropdown = nil
local PinnedDropdown = nil 

local currentHeightModeStr = "MODE: TRÊN TRỜI"
local currentDirModeStr = "ORBIT (XOAY)"
local currentNetModeStr = "NET: NORMAL"
local currentCombatModeStr = "MODE: OFF (TS/PRED)"

-- ======================================================================
-- BIẾN LƯU TRẠNG THÁI VÀ THAM SỐ TỪ SCRIPT ONE SHOT
-- ======================================================================
local fullSaveFileName = "FullGui_Save.json" 

local isAttached = false
local targetModeIndex = 3 
local mode1Name = "Hủy" 
local mode2Name = "Hủy" 
local studOffset = 0
local attachDuration = 0

local isMiniVoidVisible = true
local isMiniKBVisible = true

local trackedVoidY = workspace.FallenPartsDestroyHeight
local recordedVoidY = trackedVoidY
local lastSafeY = 0
local killBricksList = {}

-- Biến lưu trữ thực thực thế liên kết vật lý (Anchor Attach)
local originalCFrame = nil 
local attachTimerThread = nil
local currentAnchorPart = nil
local currentWeldConstraint = nil

-- ======================================================================
-- BIẾN LƯU TRẠNG THÁI CHO DỰ ÁN MỚI "KILL ALL"
-- ======================================================================
local killAllActive = false
local killAllOriginalCFrame = nil

local killAll_TeleportDistance = 1.5
local killAll_DirectionMode = "đằng sau"

-- Network Ownership Bypass gốc (Giữ nguyên cho hệ thống mô phỏng của game)
if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {},
		Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
	}
	Network.RetainPart = function(Part)
		if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
			table.insert(Network.BaseParts, Part)
			Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
			Part.CanCollide = false
		end
	end
	local function EnablePartControl()
		localPlayer.ReplicationFocus = workspace
		RunService.Heartbeat:Connect(function()
			sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
			sethiddenproperty(localPlayer, "MaxSimulationRadius", math.huge)
			for _, Part in pairs(Network.BaseParts) do
				if Part:IsDescendantOf(workspace) then
					Part.Velocity = Network.Velocity
				end
			end
		end)
	end
	EnablePartControl()
end

-- ======================================================================
-- KHAI BÁO CÁC HÀM TIỆN ÍCH LÊN ĐẦU ĐỂ TRÁNH LỖI GỌI NIL
-- ======================================================================
local function hasPinnedPlayers()
	for p, _ in pairs(pinnedPlayers) do if p and p.Parent == Players then return true end end
	return false
end

local function updatePinnedOrder()
	pinnedOrder = {}
	for p, _ in pairs(pinnedPlayers) do if p and p.Parent == Players then table.insert(pinnedOrder, p) end end
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

-- ======================================================================
-- 1. KHỞI TẠO CÁC CẤU TRÚC PHẦN TỬ MINI GUI
-- ======================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TargetFlyMiniGuiSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local classicWidget = Instance.new("Frame")
classicWidget.Name = "ClassicTrackerWidget"
classicWidget.Size = UDim2.new(0, 50, 0, 50) 
classicWidget.Position = UDim2.new(0.5, 80, 0.5, -25) 
classicWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
classicWidget.BorderSizePixel = 0
classicWidget.Active = true
classicWidget.Visible = false
classicWidget.Parent = screenGui
Instance.new("UICorner", classicWidget).CornerRadius = UDim.new(0, 10)

local classicActionBtn = Instance.new("TextButton")
classicActionBtn.Name = "ClassicActionBtn"
classicActionBtn.Size = UDim2.new(1, 0, 1, 0) 
classicActionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
classicActionBtn.Text = "CỔ ĐIỂN\nOFF"
classicActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
classicActionBtn.Font = Enum.Font.SourceSansBold
classicActionBtn.TextSize = 10 
classicActionBtn.Parent = classicWidget
Instance.new("UICorner", classicActionBtn).CornerRadius = UDim.new(0, 10)

local nearWidget = Instance.new("Frame")
nearWidget.Name = "NearTrackerWidget"
nearWidget.Size = UDim2.new(0, 50, 0, 50) 
nearWidget.Position = UDim2.new(0.5, 140, 0.5, -25) 
nearWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
nearWidget.BorderSizePixel = 0
nearWidget.Active = true
nearWidget.Visible = false
nearWidget.Parent = screenGui
Instance.new("UICorner", nearWidget).CornerRadius = UDim.new(0, 10)

local nearActionBtn = Instance.new("TextButton")
nearActionBtn.Name = "NearActionBtn"
nearActionBtn.Size = UDim2.new(1, 0, 1, 0) 
nearActionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
nearActionBtn.Text = "MỤC TIÊU\nGẦN OFF"
nearActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nearActionBtn.Font = Enum.Font.SourceSansBold
nearActionBtn.TextSize = 9
nearActionBtn.Parent = nearWidget
Instance.new("UICorner", nearActionBtn).CornerRadius = UDim.new(0, 10)

local orangeWidget = Instance.new("Frame")
orangeWidget.Name = "OrangeWidget"
orangeWidget.Size = UDim2.new(0, 50, 0, 50) 
orangeWidget.Position = UDim2.new(0.5, 200, 0.5, -25) 
orangeWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
orangeWidget.BorderSizePixel = 0
orangeWidget.Active = true
orangeWidget.Visible = false
orangeWidget.Parent = screenGui
Instance.new("UICorner", orangeWidget).CornerRadius = UDim.new(0, 10)

local orangeFlyBtn = Instance.new("TextButton")
orangeFlyBtn.Name = "OrangeFlyBtn"
orangeFlyBtn.Size = UDim2.new(1, 0, 1, 0) 
orangeFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
orangeFlyBtn.Text = "FLY CD\nOFF"
orangeFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
orangeFlyBtn.Font = Enum.Font.SourceSansBold
orangeFlyBtn.TextSize = 10 
orangeFlyBtn.Parent = orangeWidget
Instance.new("UICorner", orangeFlyBtn).CornerRadius = UDim.new(0, 10)

local purpleWidget = Instance.new("Frame")
purpleWidget.Name = "PurpleWidget"
purpleWidget.Size = UDim2.new(0, 50, 0, 50) 
purpleWidget.Position = UDim2.new(0.5, 260, 0.5, -25) 
purpleWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
purpleWidget.BorderSizePixel = 0
purpleWidget.Active = true
purpleWidget.Visible = false
purpleWidget.Parent = screenGui
Instance.new("UICorner", purpleWidget).CornerRadius = UDim.new(0, 10)

local purpleFlyBtn = Instance.new("TextButton")
purpleFlyBtn.Name = "purpleFlyBtn"
purpleFlyBtn.Size = UDim2.new(1, 0, 1, 0) 
purpleFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
purpleFlyBtn.Text = "CFRAM\nOFF"
purpleFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
purpleFlyBtn.Font = Enum.Font.SourceSansBold
purpleFlyBtn.TextSize = 10 
purpleFlyBtn.Parent = purpleWidget
Instance.new("UICorner", purpleFlyBtn).CornerRadius = UDim.new(0, 10)

local killAllWidget = Instance.new("Frame")
killAllWidget.Name = "KillAllWidget"
killAllWidget.Size = UDim2.new(0, 50, 0, 50)
killAllWidget.Position = UDim2.new(0.5, 320, 0.5, -25)
killAllWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
killAllWidget.BorderSizePixel = 0
killAllWidget.Active = true
killAllWidget.Visible = false
killAllWidget.Parent = screenGui
Instance.new("UICorner", killAllWidget).CornerRadius = UDim.new(0, 10)

local killAllActionBtn = Instance.new("TextButton")
killAllActionBtn.Name = "KillAllActionBtn"
killAllActionBtn.Size = UDim2.new(1, 0, 1, 0)
killAllActionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
killAllActionBtn.Text = "KILL ALL\nOFF"
killAllActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killAllActionBtn.Font = Enum.Font.SourceSansBold
killAllActionBtn.TextSize = 10
killAllActionBtn.Parent = killAllWidget
Instance.new("UICorner", killAllActionBtn).CornerRadius = UDim.new(0, 10)

local voidWidget = Instance.new("Frame")
voidWidget.Name = "VoidWidget"
voidWidget.Size = UDim2.new(0, 50, 0, 50) 
voidWidget.Position = UDim2.new(1, -70, 1, -140) 
voidWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
voidWidget.BorderSizePixel = 0
voidWidget.Active = true
voidWidget.Visible = isMiniVoidVisible
voidWidget.Parent = screenGui
Instance.new("UICorner", voidWidget).CornerRadius = UDim.new(0, 10)

local voidBtn = Instance.new("TextButton")
voidBtn.Name = "VoidBtn"
voidBtn.Size = UDim2.new(1, 0, 1, 0) 
voidBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
voidBtn.Text = "VOID\nOFF"
voidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
voidBtn.Font = Enum.Font.SourceSansBold
voidBtn.TextSize = 10 
voidBtn.Parent = voidWidget
Instance.new("UICorner", voidBtn).CornerRadius = UDim.new(0, 10)

local kbWidget = Instance.new("Frame")
kbWidget.Name = "KBWidget"
kbWidget.Size = UDim2.new(0, 50, 0, 50) 
kbWidget.Position = UDim2.new(1, -70, 1, -80) 
kbWidget.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
kbWidget.BorderSizePixel = 0
kbWidget.Active = true
kbWidget.Visible = isMiniKBVisible
kbWidget.Parent = screenGui
Instance.new("UICorner", kbWidget).CornerRadius = UDim.new(0, 10)

local kbBtn = Instance.new("TextButton")
kbBtn.Name = "KBBtn"
kbBtn.Size = UDim2.new(1, 0, 1, 0) 
kbBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
kbBtn.Text = "KB\nOFF"
kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kbBtn.Font = Enum.Font.SourceSansBold
kbBtn.TextSize = 10 
kbBtn.Parent = kbWidget
Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 10)

-- ======================================================================
-- HÀM LOGIC CỐT LÕI (TRACKER & ONE SHOT)
-- ======================================================================
local function SyncMiniGuiStates()
    if targetModeIndex == 1 and isAttached then
        voidBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        voidBtn.Text = "VOID\nON"
        kbBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        kbBtn.Text = "KB\nOFF"
    elseif targetModeIndex == 2 and isAttached then
        kbBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        kbBtn.Text = "KB\nON"
        voidBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        voidBtn.Text = "VOID\nOFF"
    else
        voidBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        voidBtn.Text = "VOID\nOFF"
        kbBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        kbBtn.Text = "KB\nOFF"
    end
end

local function getNearestKillBrick()
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local pos = char.HumanoidRootPart.Position
    local nearest, minDistance = nil, math.huge
    for _, kb in ipairs(killBricksList) do
        if kb and kb.Parent then
            local dist = (kb.Position - pos).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearest = kb
            end
        end
    end
    return nearest
end

local function getTargetRotation()
    local yaw, pitch = 0, 0
    if mode1Name == "Trước" then yaw = 0 
    elseif mode1Name == "Phải" then yaw = math.rad(-90) 
    elseif mode1Name == "Sau" then yaw = math.rad(180) 
    elseif mode1Name == "Trái" then yaw = math.rad(90) 
    end
    if mode2Name == "Dưới đất" then pitch = math.rad(-90) 
    elseif mode2Name == "Lên trời" then pitch = math.rad(90) 
    end
    return CFrame.Angles(pitch, yaw, 0)
end

local function updateAttachment()
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if attachTimerThread then
        task.cancel(attachTimerThread)
        attachTimerThread = nil
    end

    if isAttached and (targetModeIndex == 1 or targetModeIndex == 2) then
        if currentWeldConstraint then
            currentWeldConstraint:Destroy()
            currentWeldConstraint = nil
        end
        if currentAnchorPart then
            currentAnchorPart:Destroy()
            currentAnchorPart = nil
        end

        if not originalCFrame then
            originalCFrame = hrp.CFrame 
        end

        local targetPos = Vector3.new(0, 0, 0)
        local rotCFrame = getTargetRotation()

        if targetModeIndex == 1 then
            local pos = hrp.Position
            targetPos = Vector3.new(pos.X, recordedVoidY + studOffset, pos.Z)
        elseif targetModeIndex == 2 then
            local nearestKB = getNearestKillBrick()
            if nearestKB then
                targetPos = nearestKB.Position + Vector3.new(0, studOffset, 0)
            else
                targetPos = hrp.Position
            end
        end

        currentAnchorPart = Instance.new("Part")
        currentAnchorPart.Name = "OneShotPhysicalAnchor"
        currentAnchorPart.Size = Vector3.new(1, 1, 1)
        currentAnchorPart.Transparency = 1
        currentAnchorPart.CanCollide = false
        currentAnchorPart.Anchored = true
        currentAnchorPart.CFrame = CFrame.new(targetPos) * rotCFrame
        currentAnchorPart.Parent = workspace

        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = currentAnchorPart.CFrame
        hrp.Anchored = true

        currentWeldConstraint = Instance.new("WeldConstraint")
        currentWeldConstraint.Name = "OneShotPhysicalWeld"
        currentWeldConstraint.Part0 = currentAnchorPart
        currentWeldConstraint.Part1 = hrp
        currentWeldConstraint.Parent = currentAnchorPart

        if attachDuration > 0 then
            attachTimerThread = task.delay(attachDuration, function()
                if isAttached then
                    attachTimerThread = nil
                    isAttached = false
                    targetModeIndex = 3
                    updateAttachment()
                end
            end)
        end
    else
        if originalCFrame then
            hrp.CFrame = originalCFrame
            originalCFrame = nil
        end

        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.Anchored = false

        if currentWeldConstraint then
            currentWeldConstraint:Destroy()
            currentWeldConstraint = nil
        end
        if currentAnchorPart then
            currentAnchorPart:Destroy()
            currentAnchorPart = nil
        end
    end
    SyncMiniGuiStates()
end

local function restorePhysicsIfNeeded()
	if not isOrangeFlyEnabled and not isPurpleFlyEnabled then
		workspace.Gravity = defaultGravity
		if (isClassicTrackingActive or isNearTrackingActive) and selectedTargetPlayer and selectedTargetPlayer.Character then
			local tHum = selectedTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
			if tHum then Camera.CameraSubject = tHum end
		else
			local char = localPlayer.Character
			local myHum = char and char:FindFirstChildOfClass("Humanoid")
			if myHum then Camera.CameraSubject = myHum end
		end
		
		local char = localPlayer.Character
		local r = char and char:FindFirstChild("HumanoidRootPart")
		local h = char and char:FindFirstChildOfClass("Humanoid")
		if r then
			r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			r.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
		if h then
			h:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			h:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
			h:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
			h:ChangeState(Enum.HumanoidStateType.Running)
		end
	end
end

local function updateMiniGuiText()
    if isClassicTrackingActive then
        classicActionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
        if selectedHeightMode == 1 then classicActionBtn.Text = "CỔ ĐIỂN\nSKY"
        elseif selectedHeightMode == 2 then classicActionBtn.Text = "CỔ ĐIỂN\nUNDER"
        else classicActionBtn.Text = "CỔ ĐiỂN\n2D" end
    else
        classicActionBtn.Text = "CỔ ĐIỂN\nOFF"
        classicActionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end

    if isNearTrackingActive then
        nearActionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        if selectedHeightMode == 1 then nearActionBtn.Text = "GẦN\nSKY"
        elseif selectedHeightMode == 2 then nearActionBtn.Text = "GẦN\nUNDER"
        else nearActionBtn.Text = "GẦN\n2D" end
    else
        nearActionBtn.Text = "MỤC TIÊU\nGẦN OFF"
        nearActionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end

local function stopFlying()
	isClassicTrackingActive = false
	isNearTrackingActive = false
	updateMiniGuiText()
	
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	settings().Network.IncomingReplicationLag = 0
	isTemporarilySleeping = false
	modeVangTimer = 0
	restorePhysicsIfNeeded()
	selectedTargetPlayer = nil
end

local function getTargetInHorizontalRange()
	local myChar = localPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	
	local closestPlayer = nil
	local shortestDistance = math.huge
	
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Parent then
			local pChar = p.Character
			local tRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
			local tHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local currentDist = (myRoot.Position - tRoot.Position).Magnitude
				if (tanSatMode == 1 or tanSatMode == 3) or currentDist <= _G_distanceValue then
					if currentDist < shortestDistance then
						shortestDistance = currentDist
						closestPlayer = p
					end
				end
			end
		end
	end
	return closestPlayer
end

local function startFlying(modeType)
    if isAttached then
        isAttached = false
        targetModeIndex = 3
        updateAttachment()
    end

	if modeType == "Classic" then
		isClassicTrackingActive = true
		isNearTrackingActive = false
		
		if not selectedTargetPlayer or not selectedTargetPlayer.Parent then
            if hasPinnedPlayers() then
                selectedTargetPlayer = pinnedOrder[currentPinnedIndex]
            elseif (tanSatMode == 1 or tanSatMode == 3) then
                selectedTargetPlayer = getClosestPlayer()
            end
		end

		if not selectedTargetPlayer or not selectedTargetPlayer.Parent then 
			isClassicTrackingActive = false
			updateMiniGuiText()
			return 
		end
	elseif modeType == "Near" then
		isNearTrackingActive = true
		isClassicTrackingActive = false
		
		if not selectedTargetPlayer then
			local detected = getTargetInHorizontalRange()
			if detected then
				selectedTargetPlayer = detected
			end
		end
	end
	
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then stopFlying() return end
	
	modeVangTimer = 0
	isTemporarilySleeping = false
	updateMiniGuiText()
	
	if selectedTargetPlayer then
		local targetChar = selectedTargetPlayer.Character
		local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
		local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
		
		if targetRoot then
			local startVector = root.Position - targetRoot.Position
			currentAngle = math.atan2(startVector.X, startVector.Z)
		end
		
		if targetHum then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = targetHum
		end
	end
	
	if flyConnection then flyConnection:Disconnect() end
	
	flyConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if isAttached then return end

		local myChar = localPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		
		if isOrangeFlyEnabled or isPurpleFlyEnabled then return end 
		
		if isNearTrackingActive then
			if not selectedTargetPlayer then
				workspace.Gravity = 0
				if myRoot and myHum then
					myHum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
					myHum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
					myHum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
					myHum:ChangeState(Enum.HumanoidStateType.Freefall)
					
					local moveDir = myHum.MoveDirection
					local fSpeed = _G_flySpeedValue
					local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
					if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(Camera.CFrame.UpVector.X, 0, Camera.CFrame.UpVector.Z) end
					flatLook = flatLook.Unit
					
					if moveDir.Magnitude > 0 then
						local flatCam = CFrame.lookAt(Vector3.zero, flatLook)
						local rawInput = flatCam:VectorToObjectSpace(moveDir)
						local flyDir = Camera.CFrame:VectorToWorldSpace(Vector3.new(rawInput.X, 0, rawInput.Z))
						myRoot.AssemblyLinearVelocity = flyDir.Unit * fSpeed
					else
						myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					end
					myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + flatLook)
				end
				
				local detected = getTargetInHorizontalRange()
				if detected then
					selectedTargetPlayer = detected
					local targetChar = selectedTargetPlayer.Character
					local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
					if targetHum then Camera.CameraSubject = targetHum end
				end
				return 
			else
				local tChar = selectedTargetPlayer.Character
				local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
				
				if not tHum or tHum.Health <= 0 or not selectedTargetPlayer.Parent then
					selectedTargetPlayer = nil
					local charReset = localPlayer.Character
					local myHumReset = charReset and charReset:FindFirstChildOfClass("Humanoid")
					if myHumReset then Camera.CameraSubject = myHumReset end
					restorePhysicsIfNeeded()
					
					if tanSatMode == 1 or tanSatMode == 3 then
						local detected = getTargetInHorizontalRange()
						if detected then
							selectedTargetPlayer = detected
							local targetChar = selectedTargetPlayer.Character
							local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
							if targetHum then Camera.CameraSubject = targetHum end
						end
					end
					return
				end
			end
		end
		
		if isClassicTrackingActive then
            local isCurrentTargetValid = false
            if selectedTargetPlayer and selectedTargetPlayer.Parent == Players then
                local cChar = selectedTargetPlayer.Character
                local cHum = cChar and cChar:FindFirstChildOfClass("Humanoid")
                if cHum and cHum.Health > 0 then isCurrentTargetValid = true end
            end
            
            if not isCurrentTargetValid then
                if hasPinnedPlayers() then
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
                                if nHum then Camera.CameraSubject = nHum end
                                foundNext = true
                                break
                            end
                        end
                    end
                    
                    if not foundNext then
                        if myRoot then
                            myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end
                        return
                    end
                else
                    if not (tanSatMode == 1 or tanSatMode == 3) then
                        stopFlying()
                        return
                    end
                end
            end
		end
		
		local tChar = selectedTargetPlayer and selectedTargetPlayer.Character
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		
		if not myRoot or not tRoot then return end
		
		if selectedNetMode == 2 or selectedNetMode == 4 then
			if isTemporarilySleeping then
				sleepTimer = sleepTimer + deltaTime
				if myHum then 
					myHum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
					myHum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
					myHum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
					myHum:ChangeState(Enum.HumanoidStateType.Running) 
				end
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

		if not isTemporarilySleeping and myHum then
			myHum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			myHum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
			myHum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
			myHum:ChangeState(Enum.HumanoidStateType.Freefall)
		end

		local horizontalDist = _G_distanceValue
		local verticalDist = 0
		if selectedHeightMode == 1 then
			verticalDist = math.abs(_G_heightValue)
		elseif selectedHeightMode == 2 then
			verticalDist = -math.abs(_G_heightValue)
		end
		
		local currentDistance = (myRoot.Position - tRoot.Position).Magnitude
		local isUsingChaseMode = (selectedNetMode == 3 or selectedNetMode == 4)
		
		local targetPositionBase = tRoot.Position
		local targetLookVector = tRoot.CFrame.LookVector
		local enemyVelocity = tRoot.AssemblyLinearVelocity
		
		local eVelMag = enemyVelocity.Magnitude
		local velCheck = _G_velCheckValue
		local predCoeff = _G_predCoeffValue
		local predActive = false
		
		if velCheck >= 0 then
			if eVelMag >= velCheck then predActive = true end
		else
			if eVelMag < math.abs(velCheck) then predActive = true end
		end
		
		if (tanSatMode == 2 or tanSatMode == 3) and predActive then
			local ping = 0.12
			pcall(function() ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 end)
			ping = math.clamp(ping, 0.12, 0.35)
			
			local predictionOffset = enemyVelocity * ping * predCoeff
			targetPositionBase = tRoot.Position + predictionOffset
			
			if eVelMag > 5 then
				targetLookVector = enemyVelocity.Unit
			end
		end
		
		if isUsingChaseMode and currentDistance > 10 then
			settings().Network.IncomingReplicationLag = 0
			local chaseSpeed = _G_flySpeedValue
			local targetTargetPos = targetPositionBase + Vector3.new(0, verticalDist, 0)
			local direction = (targetTargetPos - myRoot.Position).Unit
			
			myRoot.AssemblyLinearVelocity = direction * chaseSpeed
			myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			myRoot.CFrame = CFrame.new(myRoot.Position, targetTargetPos)
		else
			local teleportSpeed = _G_speedValue
			local nextCFramePosition = Vector3.new(0,0,0)
			
			if selectedDirMode == 1 then
				settings().Network.IncomingReplicationLag = 0
				
				local sides = _G_sidesValue
				local targetX, targetZ
				
				if sides >= 3 then
					-- [FIX ĐỒNG BỘ GÓC CẠNH TỐC ĐỘ CAO]
					-- Ép bước nhảy góc tăng theo chu kỳ đếm đỉnh hình học thay vì biến đổi vô cấp theo deltaTime để server không bị loạn gói tin dữ liệu truyền tải.
					local sectorAngle = (math.pi * 2) / sides
					local angularVelocity = teleportSpeed / horizontalDist
					
					currentAngle = (currentAngle - (angularVelocity * deltaTime)) % (math.pi * 2)
					
					local currentSector = math.floor(currentAngle / sectorAngle)
					local exactAngle = currentSector * sectorAngle
					
					targetX = targetPositionBase.X + (math.sin(exactAngle) * horizontalDist)
					targetZ = targetPositionBase.Z + (math.cos(exactAngle) * horizontalDist)
				else
					local angularVelocity = teleportSpeed / horizontalDist
					currentAngle = (currentAngle - (angularVelocity * deltaTime)) % (math.pi * 2)
					
					targetX = targetPositionBase.X + (math.sin(currentAngle) * horizontalDist)
					targetZ = targetPositionBase.Z + (math.cos(currentAngle) * horizontalDist)
				end
				
				local targetY = targetPositionBase.Y + verticalDist 
				nextCFramePosition = Vector3.new(targetX, targetY, targetZ)
				
				myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				
				myRoot.CFrame = CFrame.new(nextCFramePosition, targetPositionBase)
			elseif selectedDirMode == 2 then
				local backVector = -targetLookVector
				nextCFramePosition = targetPositionBase + (backVector * horizontalDist) + Vector3.new(0, verticalDist, 0)
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
				myRoot.CFrame = CFrame.new(nextCFramePosition, targetPositionBase)
				settings().Network.IncomingReplicationLag = 0
			else
				nextCFramePosition = targetPositionBase + Vector3.new(0, verticalDist, 0)
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
				myRoot.CFrame = CFrame.new(nextCFramePosition, targetPositionBase)
				settings().Network.IncomingReplicationLag = 0
			end
		end
	end)
end

-- ======================================================================
-- VÒNG LẶP CHECK VISUAL SERVER-SIDE ĐỘC LẬP HOÀN TOÀN KHÔNG DÍNH BẢN THÂN
-- ======================================================================
RunService.Heartbeat:Connect(function()
    if isVisualServerEnabled then
        local char = localPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if myRoot then
            if not serverVisualPart or serverVisualPart.Parent ~= workspace then
                serverVisualPart = Instance.new("Part")
                serverVisualPart.Name = "ServerVisualPartHRP"
                serverVisualPart.Size = myRoot.Size
                serverVisualPart.Color = Color3.fromRGB(255, 0, 0)
                serverVisualPart.Material = Enum.Material.Neon
                serverVisualPart.CanCollide = false
                serverVisualPart.Anchored = true
                serverVisualPart.Transparency = 0.4
                serverVisualPart.Parent = workspace
            end
            
            local serverRootCFrame = myRoot.CFrame
            pcall(function()
                local currentPosition = myRoot.Position
                local lookVector = myRoot.CFrame.LookVector
                serverVisualPart.CFrame = CFrame.new(currentPosition, currentPosition + lookVector)
            end)
        end
    else
        if serverVisualPart then
            serverVisualPart:Destroy()
            serverVisualPart = nil
        end
    end
end)

RunService.Stepped:Connect(function()
    if not isNoclipEnabled then return end
    if isOrangeFlyEnabled or isPurpleFlyEnabled or isClassicTrackingActive or isNearTrackingActive or killAllActive then 
        local myChar = localPlayer.Character
        if myChar then
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ======================================================================
-- BIẾN LƯU TRẠNG THÁI VÀ LOGIC PHỤC VỤ TAB KILL ALL
-- ======================================================================
local killAll_Delay = 1
local killAll_FirstDeadCount = 0
local killAll_LowHealthCount = 0

local isTouchFlingEnabled = false
local touchFlingThread = nil
local isAntiFlingEnabled = false

local function getAllLivingTargets()
    local targets = {}
    local myChar = localPlayer.Character

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health > 0 then
                table.insert(targets, p.Character)
            end
        end
    end

    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            if child ~= myChar and not Players:GetPlayerFromCharacter(child) and child.Humanoid.Health > 0 then
                table.insert(targets, child)
            end
        end
    end

    local charactersFolder = workspace:FindFirstChild("Characters")
    if charactersFolder then
        for _, child in ipairs(charactersFolder:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
                if child ~= myChar and child.Humanoid.Health > 0 and not table.find(targets, child) then
                    table.insert(targets, child)
                end
            end
        end
    end

    return targets
end

local function getKillAllTargetCFrame(targetRoot)
    local distance = killAll_TeleportDistance
    local targetPos = targetRoot.Position
    local targetLook = targetRoot.CFrame.LookVector
    local targetRight = targetRoot.CFrame.RightVector
    
    local calculatedPos = targetPos
    
    if killAll_DirectionMode == "đằng sau" then
        calculatedPos = targetPos - (targetLook * distance)
    elseif killAll_DirectionMode == "đằng trước" then
        calculatedPos = targetPos + (targetLook * distance)
    elseif killAll_DirectionMode == "bên trái" then
        calculatedPos = targetPos - (targetRight * distance)
    elseif killAll_DirectionMode == "bên phait" then
        calculatedPos = targetPos + (targetRight * distance)
    elseif killAll_DirectionMode == "drowning/" then
        calculatedPos = targetPos + Vector3.new(0, distance, 0)
    end
    
    return CFrame.new(calculatedPos, targetPos)
end

local killAllLoopConnection = nil

local function runKillAllLoop()
    if killAll_LowHealthCount > 0 then
        while killAllActive do
            local allCurrentTargets = getAllLivingTargets()
            if #allCurrentTargets == 0 then break end
            
            table.sort(allCurrentTargets, function(a, b)
                return a.Humanoid.Health < b.Humanoid.Health
            end)
            
            local lowHealthTargets = {}
            for i = 1, math.min(killAll_LowHealthCount, #allCurrentTargets) do
                table.insert(lowHealthTargets, allCurrentTargets[i])
            end
            
            for _, target in ipairs(lowHealthTargets) do
                if not killAllActive then break end
                if target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 then
                    local myChar = localPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        myChar.HumanoidRootPart.CFrame = getKillAllTargetCFrame(target.HumanoidRootPart)
                    end
                    task.wait(killAll_Delay)
                end
            end
            
            if #getAllLivingTargets() == 0 then break end
        end
    end

    local priorityTargets = {}
    if killAll_FirstDeadCount > 0 and killAllActive then
        local allCurrentTargets = getAllLivingTargets()
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if myRoot then
            table.sort(allCurrentTargets, function(a, b)
                local distA = (a.HumanoidRootPart.Position - myRoot.Position).Magnitude
                local distB = (b.HumanoidRootPart.Position - myRoot.Position).Magnitude
                return distA < distB
            end)
        end
        
        for i = 1, math.min(killAll_FirstDeadCount, #allCurrentTargets) do
            table.insert(priorityTargets, allCurrentTargets[i])
        end
    end
    
    if #priorityTargets > 0 and killAllActive then
        while killAllActive do
            local hasAnyoneAlive = false
            for _, target in ipairs(priorityTargets) do
                if not killAllActive then break end
                if target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 then
                    hasAnyoneAlive = true
                    local myChar = localPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        myChar.HumanoidRootPart.CFrame = getKillAllTargetCFrame(target.HumanoidRootPart)
                    end
                    task.wait(killAll_Delay)
                end
            end
            if not hasAnyoneAlive then break end
        end
    end
    
    while killAllActive do
        local globalTargets = getAllLivingTargets()
        if #globalTargets == 0 then
            task.wait(0.5)
        end
        
        for _, target in ipairs(globalTargets) do
            if not killAllActive then break end
            if target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 then
                local myChar = localPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = getKillAllTargetCFrame(target.HumanoidRootPart)
                end
                task.wait(killAll_Delay)
            end
        end
    end
end

local function toggleKillAll(state)
	killAllActive = state
	if killAllActive then
		killAllActionBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		killAllActionBtn.Text = "KILL\nON"
		
		local myChar = localPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if myRoot then
			killAllOriginalCFrame = myRoot.CFrame
		end

		if killAllLoopConnection then task.cancel(killAllLoopConnection) end
		killAllLoopConnection = task.spawn(runKillAllLoop)
	else
		killAllActionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		killAllActionBtn.Text = "KILL\nOFF"
		
		if killAllLoopConnection then
			task.cancel(killAllLoopConnection)
			killAllLoopConnection = nil
		end

		if killAllOriginalCFrame then
			local myChar = localPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if myRoot then
				myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
				myRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
				myRoot.CFrame = killAllOriginalCFrame
			end
			killAllOriginalCFrame = nil
		end
	end
end

-- ======================================================================
-- 2. KHỞI TẠO MENU CHÍNH VỚI RAYFIELD GUI
-- ======================================================================
local Window = Rayfield:CreateWindow({
   Name = "HỆ THỐNG ĐIỀU KHIỂN SẮP XẾP MỚI",
   LoadingTitle = "Đang Đồng Bộ Giao Diện...",
   LoadingSubtitle = "Vui lòng chờ giây lát",
   ConfigurationSaving = {
      Enabled = false, 
      FolderName = "TrackerConfigSystem",
      FileName = "SavedSettings"
   },
   Discord = { Enabled = false }
})

-- ======================================================================
-- TAB 1: BẢNG CẤU HÌNH (TRACKER)
-- ======================================================================
local MainTab = Window:CreateTab("Bảng Cấu Hình", 4483362458)

MainTab:CreateSection("-tracker toggle")
Toggle_ClassicTracker = MainTab:CreateToggle({
   Name = "tracker cổ điển (bật/tắt)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then classicWidget.Visible = true else
           classicWidget.Visible = false
           if isClassicTrackingActive then stopFlying() end
       end
   end,
})

Toggle_NearTracker = MainTab:CreateToggle({
   Name = "tracker mục tiêu gần (bật/tắt)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then nearWidget.Visible = true else
           nearWidget.Visible = false
           if isNearTrackingActive then stopFlying() end
       end
   end,
})

MainTab:CreateSection("-fly toggle")
local function runOrangeFlyLogic(enabledStatus)
	isOrangeFlyEnabled = enabledStatus
	if isOrangeFlyEnabled then
		orangeFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
		orangeFlyBtn.Text = "FLY CD\nON"
		
		local char = localPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		
		if hum and not (isNearTrackingActive and not selectedTargetPlayer) then 
			Camera.CameraSubject = hum 
		end
		workspace.Gravity = 0
		
		if root and hum then
			hum.PlatformStand = false
			orangeFlyConnection = RunService.RenderStepped:Connect(function(deltaTime)
				local c = localPlayer.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				local h = c and c:FindFirstChildOfClass("Humanoid")
				if r and h then
					h:SetStateEnabled(Enum.HumanoidStateType.Running, false)
					h:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
					h:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
					h:ChangeState(Enum.HumanoidStateType.Freefall)
					
					local moveDir = h.MoveDirection
					local fSpeed = _G_flySpeedValue
					local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
					if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(Camera.CFrame.UpVector.X, 0, Camera.CFrame.UpVector.Z) end
					flatLook = flatLook.Unit
					
					if moveDir.Magnitude > 0 then
						local flatCam = CFrame.lookAt(Vector3.zero, flatLook)
						local rawInput = flatCam:VectorToObjectSpace(moveDir)
						local flyDir = Camera.CFrame:VectorToWorldSpace(Vector3.new(rawInput.X, 0, rawInput.Z))
						r.AssemblyLinearVelocity = flyDir.Unit * fSpeed
					else
						r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					end
					r.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					r.CFrame = CFrame.new(r.Position, r.Position + flatLook)
				end
			end)
		end
	else
		orangeFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		orangeFlyBtn.Text = "FLY CD\nOFF"
		if orangeFlyConnection then orangeFlyConnection:Disconnect() orangeFlyConnection = nil end
		restorePhysicsIfNeeded()
	end
end

Toggle_OrangeFly = MainTab:CreateToggle({
   Name = "fly cổ điển (bật/tắt)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then orangeWidget.Visible = true else
           orangeWidget.Visible = false
           if isOrangeFlyEnabled then runOrangeFlyLogic(false) end
       end
   end,
})

local function runPurpleFlyLogic(enabledStatus)
	isPurpleFlyEnabled = enabledStatus
	if isPurpleFlyEnabled then
		purpleFlyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
		purpleFlyBtn.Text = "CFRAM\nON"
		
		local char = localPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		
		if hum and not (isNearTrackingActive and not selectedTargetPlayer) then 
			Camera.CameraSubject = hum 
		end
		workspace.Gravity = 0
		
		if root and hum then
			hum.PlatformStand = false
			purpleFlyConnection = RunService.RenderStepped:Connect(function(deltaTime)
				local c = localPlayer.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				local h = c and c:FindFirstChildOfClass("Humanoid")
				if r and h then
					h:SetStateEnabled(Enum.HumanoidStateType.Running, false)
					h:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
					h:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
					h:ChangeState(Enum.HumanoidStateType.Freefall)
					
					r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					r.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					
					local moveDir = h.MoveDirection
					local fSpeed = _G_flySpeedValue
					local nextPos = r.Position
					local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
					if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(Camera.CFrame.UpVector.X, 0, Camera.CFrame.UpVector.Z) end
					flatLook = flatLook.Unit
					
					if moveDir.Magnitude > 0 then
						local flatCam = CFrame.lookAt(Vector3.zero, flatLook)
						local rawInput = flatCam:VectorToObjectSpace(moveDir)
						local flyDir = Camera.CFrame:VectorToWorldSpace(Vector3.new(rawInput.X, 0, rawInput.Z))
						nextPos = r.Position + (flyDir.Unit * fSpeed * deltaTime)
					end
					r.CFrame = CFrame.new(nextPos, nextPos + flatLook)
				end
			end)
		end
	else
		purpleFlyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		purpleFlyBtn.Text = "CFRAM\nOFF"
		if purpleFlyConnection then purpleFlyConnection:Disconnect() purpleFlyConnection = nil end
		restorePhysicsIfNeeded()
	end
end

Toggle_PurpleFly = MainTab:CreateToggle({
   Name = "fly cfram (bật/tắt)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then purpleWidget.Visible = true else
           purpleWidget.Visible = false
           if isPurpleFlyEnabled then runPurpleFlyLogic(false) end
       end
   end,
})

MainTab:CreateSection("-mode")
Drop_HeightMode = MainTab:CreateDropdown({
   Name = "Vị Trí Theo Dõi (Height Mode)",
   Options = {"MODE: TRÊN TRỜI", "MODE: DƯỚI ĐẤT", "MODE: OFF"},
   CurrentOption = {currentHeightModeStr},
   MultipleOptions = false,
   Callback = function(Option)
       local val = type(Option) == "table" and Option[1] or Option
       currentHeightModeStr = val
       if val == "MODE: TRÊN TRỜI" then selectedHeightMode = 1
       elseif val == "MODE: DƯỚI ĐẤT" then selectedHeightMode = 2
       else selectedHeightMode = 3 end
       if isClassicTrackingActive then startFlying("Classic")
       elseif isNearTrackingActive then startFlying("Near") end
   end,
})

Drop_DirMode = MainTab:CreateDropdown({
   Name = "Hướng Tiếp Cận (Direction Mode)",
   Options = {"ORBIT (XOAY)", "BACKSTAB (SAU)", "DIR: OFF"},
   CurrentOption = {currentDirModeStr},
   MultipleOptions = false,
   Callback = function(Option)
       local val = type(Option) == "table" and Option[1] or Option
       currentDirModeStr = val
       if val == "ORBIT (XOAY)" then selectedDirMode = 1
       elseif val == "BACKSTAB (SAU)" then selectedDirMode = 2
       else selectedDirMode = 3 end
       if isClassicTrackingActive then startFlying("Classic")
       elseif isNearTrackingActive then startFlying("Near") end
   end,
})

Drop_NetMode = MainTab:CreateDropdown({
   Name = "Bypass Anti-Cheat (Net Mode)",
   Options = {"NET: NORMAL", "NET: AUTO-RESET", "NET: SMART CHASE", "NET: HYBRID BOTH"},
   CurrentOption = {currentNetModeStr},
   MultipleOptions = false,
   Callback = function(Option)
       local val = type(Option) == "table" and Option[1] or Option
       currentNetModeStr = val
       if val == "NET: NORMAL" then selectedNetMode = 1
       elseif val == "NET: AUTO-RESET" then selectedNetMode = 2
       elseif val == "NET: SMART CHASE" then selectedNetMode = 3
       else slectedNetMode = 4 end
       if isClassicTrackingActive then startFlying("Classic")
       elseif isNearTrackingActive then startFlying("Near") end
   end,
})

Drop_CombatMode = MainTab:CreateDropdown({
   Name = "Chế Độ Tấn Công (Combat Mode)",
   Options = {"MODE: OFF (TS/PRED)", "MODE: TÀN SÁT (ĐỎ)", "MODE: DỰ ĐOÁN (XÁM)", "TÀN SÁT + DỰ ĐOÁN"},
   CurrentOption = {currentCombatModeStr},
   MultipleOptions = false,
   Callback = function(Option)
       local val = type(Option) == "table" and Option[1] or Option
       currentCombatModeStr = val
       if val == "MODE: OFF (TS/PRED)" then tanSatMode = 0
       elseif val == "MODE: TÀN SÁT (ĐỎ)" then tanSatMode = 1
       elseif val == "MODE: DỰ ĐOÁN (XÁM)" then tanSatMode = 2
       else tanSatMode = 3 end
   end,
})

MainTab:CreateSection("-điều chỉnh")
Toggle_Noclip = MainTab:CreateToggle({
   Name = "Bật Noclip (Chống kẹt tường)",
   CurrentValue = false,
   Callback = function(Value)
       isNoclipEnabled = Value
   end,
})

Input_Speed = MainTab:CreateInput({
   Name = "tốc độ xoay", PlaceholderText = "90", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_speedValue = tonumber(Text) or 90 end,
})

Input_Sides = MainTab:CreateInput({
   Name = "góc cạnh", PlaceholderText = "0", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_sidesValue = tonumber(Text) or 0 end,
})

Input_Dist = MainTab:CreateInput({
   Name = "khoảng cách xa gần ngang", PlaceholderText = "4.5", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_distanceValue = tonumber(Text) or 4.5 end,
})
Input_Height = MainTab:CreateInput({
   Name = "khoảng cách độ cao", PlaceholderText = "4.5", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_heightValue = tonumber(Text) or 4.5 end,
})
Input_Chase = MainTab:CreateInput({
   Name = "tốc độ bay truy sát", PlaceholderText = "250", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_flySpeedValue = tonumber(Text) or 250 end,
})
Input_Pred = MainTab:CreateInput({
   Name = "mức độ prediction", PlaceholderText = "1", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_predCoeffValue = tonumber(Text) or 1 end,
})
Input_Vel = MainTab:CreateInput({
   Name = "vận tốc prediction", PlaceholderText = "2", RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G_velCheckValue = tonumber(Text) or 2 end,
})

MainTab:CreateSection("-visual server side")
Toggle_VisualServer = MainTab:CreateToggle({
   Name = "Visual Server (HRP Đỏ)",
   CurrentValue = false,
   Callback = function(Value)
       isVisualServerEnabled = Value
   end,
})

-- ======================================================================
-- TAB: ONE SHOT
-- ======================================================================
local OneShotTab = Window:CreateTab("One Shot", 4483362458)
local ToggleVoidUI, ToggleKBUI, InputStudsUI, InputTimeUI, DropNgangUI, DropTrenUI

OneShotTab:CreateSection("Checkers")
OneShotTab:CreateButton({
    Name = "Check Void",
    Callback = function()
        recordedVoidY = trackedVoidY
    end,
})
OneShotTab:CreateButton({
    Name = "Check Kill Bricks",
    Callback = function()
        killBricksList = {}
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local name = string.lower(part.Name)
                local isKB = false
                if string.find(name, "kill") or string.find(name, "lava") or string.find(name, "damage") then isKB = true
                else
                    for _, child in ipairs(part:GetChildren()) do
                        if child:IsA("TouchTransmitter") or (child:IsA("Script") and string.find(string.lower(child.Name), "kill")) then
                            isKB = true; break
                        end
                    end
                end
                if isKB then
                    table.insert(killBricksList, part)
                end
            end
        end
    end,
})

InputStudsUI = OneShotTab:CreateInput({
    Name = "Khoảng cách Stud (Y Offset)",
    PlaceholderText = "Nhập số...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local val = tonumber(Text)
        if val then
            studOffset = val
            updateAttachment()
        end
    end,
})

InputTimeUI = OneShotTab:CreateInput({
    Name = "Thời gian Attach (giây, 0 = vĩnh viễn)",
    PlaceholderText = "Ví dụ: 1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local val = tonumber(Text)
        if val then
            attachDuration = val
        end
    end,
})

OneShotTab:CreateSection("-Phía")
DropNgangUI = OneShotTab:CreateDropdown({
    Name = "Vị trí Ngang",
    Options = {"Trước", "Phải", "Sau", "Trái", "Hủy"},
    CurrentOption = {mode1Name},
    MultipleOptions = false,
    Callback = function(Options)
        local val = type(Options) == "table" and Options[1] or Options
        mode1Name = val
        updateAttachment()
    end,
})
DropTrenUI = OneShotTab:CreateDropdown({
    Name = "Vị trí Trên",
    Options = {"Dưới đất", "Lên trời", "Hủy"},
    CurrentOption = {mode2Name},
    MultipleOptions = false,
    Callback = function(Options)
        local val = type(Options) == "table" and Options[1] or Options
        mode2Name = val
        updateAttachment()
    end,
})

OneShotTab:CreateSection("-Main")
ToggleVoidUI = OneShotTab:CreateToggle({
    Name = "Hiển thị Minigui Void",
    CurrentValue = isMiniVoidVisible,
    Callback = function(Value)
        isMiniVoidVisible = Value
        voidWidget.Visible = isMiniVoidVisible
    end,
})
ToggleKBUI = OneShotTab:CreateToggle({
    Name = "Hiển thị Minigui Kill Bricks",
    CurrentValue = isMiniKBVisible,
    Callback = function(Value)
        isMiniKBVisible = Value
        kbWidget.Visible = isMiniKBVisible
    end,
})

-- ======================================================================
-- TAB: KILL ALL
-- ======================================================================
local KillAllTab = Window:CreateTab("Kill All", 4483362458)
local Toggle_KillAllMiniVis

KillAllTab:CreateSection("-Main")

Toggle_KillAllMiniVis = KillAllTab:CreateToggle({
	Name = "MiniGui",
	CurrentValue = false,
	Callback = function(Value)
		killAllWidget.Visible = Value
	end,
})

KillAllTab:CreateToggle({
	Name = "Touch Fling",
	CurrentValue = false,
	Callback = function(Value)
		isTouchFlingEnabled = Value
		if isTouchFlingEnabled then
			touchFlingThread = coroutine.create(function()
				local lp = Players.LocalPlayer
				local c, hrp, vel, movel = nil, nil, nil, 0.1
				while isTouchFlingEnabled do
					RunService.Heartbeat:Wait()
					c = lp.Character
					hrp = c and c:FindFirstChild("HumanoidRootPart")
					if hrp then
                        local globalTargets = getAllLivingTargets()
                        if #globalTargets > 0 then
                            local currentTarget = globalTargets[1]
                            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                                hrp.CFrame = getKillAllTargetCFrame(currentTarget.HumanoidRootPart)
                            end
                        end
					
						vel = hrp.Velocity
						hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
						RunService.RenderStepped:Wait()
						hrp.Velocity = vel
						RunService.Stepped:Wait()
						hrp.Velocity = vel + Vector3.new(0, movel, 0)
						movel = -movel
						
						if killAll_Delay > 0 then
							task.wait(killAll_Delay)
						end
					end
				end
			end)
			coroutine.resume(touchFlingThread)
		else
			isTouchFlingEnabled = false
		end
	end,
})

KillAllTab:CreateToggle({
	Name = "Anti Fling",
	CurrentValue = false,
	Callback = function(Value)
		isAntiFlingEnabled = Value
	end,
})

KillAllTab:CreateSection("-mode")

KillAllTab:CreateInput({
	Name = "Delay",
	PlaceholderText = "Nhập Delay...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		killAll_Delay = tonumber(Text) or 1
	end,
})

KillAllTab:CreateInput({
	Name = "Số người chết đầu",
	PlaceholderText = "Nhập số...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		killAll_FirstDeadCount = tonumber(Text) or 0
	end,
})

KillAllTab:CreateInput({
	Name = "Số người ưu tiên yếu máu",
	PlaceholderText = "Nhập số...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		killAll_LowHealthCount = tonumber(Text) or 0
	end,
})

KillAllTab:CreateInput({
	Name = "Khoảng cách dịch chuyển",
	PlaceholderText = "Mặc định: 1.5",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		killAll_TeleportDistance = tonumber(Text) or 1.5
	end,
})

KillAllTab:CreateDropdown({
	Name = "Hướng",
	Options = {"drowning/", "đằng sau", "đằng trước", "bên trái", "bên phait"},
	CurrentOption = {killAll_DirectionMode},
	MultipleOptions = false,
	Callback = function(Options)
		local val = type(Options) == "table" and Options[1] or Options
		killAll_DirectionMode = val
	end,
})

-- ======================================================================
-- TAB 3: DANH SÁCH MỤC TIÊU
-- ======================================================================
local PlayerTab = Window:CreateTab("Danh Sách Mục Tiêu", 4483362458)

local playerNames = {}
local nameToPlayer = {} 

local function updatePlayers()
    playerNames = {}
    nameToPlayer = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= localPlayer then
            local displayNameStr = v.DisplayName .. " (" .. v.Name .. ")"
            table.insert(playerNames, displayNameStr)
            nameToPlayer[displayNameStr] = v
        end
    end
    
    if PlayerDropdown then
        PlayerDropdown:Refresh(playerNames, true)
    end
    if PinnedDropdown then
        PinnedDropdown:Refresh(playerNames, true)
    end
end

PlayerDropdown = PlayerTab:CreateDropdown({
   Name = "Chọn mục tiêu (Mục tiêu đơn)",
   Options = playerNames,
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
      local targetName = type(Option) == "table" and Option[1] or Option
      local p = nameToPlayer[targetName]
      if p then
         if isNearTrackingActive then return end
         selectedTargetPlayer = p
         if isClassicTrackingActive then startFlying("Classic") end
      end
   end,
})

PinnedDropdown = PlayerTab:CreateDropdown({
    Name = "Danh sách ghim (Ghim 1 ném 1, Ghim nhiều ném nhiều)",
    Options = playerNames,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        local selectedNames = type(Options) == "table" and Options or {Options}
        
        pinnedPlayers = {}
        for _, nameStr in ipairs(selectedNames) do
            local p = nameToPlayer[nameStr]
            if p then
                pinnedPlayers[p] = true
            end
        end
        updatePinnedOrder()
        
        if hasPinnedPlayers() then
            if isClassicTrackingActive then
                if not selectedTargetPlayer or not pinnedPlayers[selectedTargetPlayer] then
                    selectedTargetPlayer = pinnedOrder[currentPinnedIndex]
                end
            end
        end
    end,
})

updatePlayers()

PlayerTab:CreateButton({
   Name = "Làm mới danh sách (Refresh)",
   Callback = function()
      updatePlayers()
   end,
})

Players.PlayerRemoving:Connect(function(player)
	if pinnedPlayers[player] then 
        pinnedPlayers[player] = nil 
        updatePinnedOrder() 
        local currentPinnedNames = {}
        for _, p in ipairs(pinnedOrder) do table.insert(currentPinnedNames, p.DisplayName .. " (" .. p.Name .. ")") end
        if PinnedDropdown then PinnedDropdown:Refresh(currentPinnedNames, true) end
    end
    
	if selectedTargetPlayer == player then 
		if isClassicTrackingActive and ((tanSatMode == 1 or tanSatMode == 3) or hasPinnedPlayers()) then 
		else 
            stopFlying() 
        end
	end
    task.wait(0.5)
	updatePlayers()
end)

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    updatePlayers()
end)

-- ======================================================================
-- TAB 4: CÀI ĐẶT
-- ======================================================================
local SettingsTab = Window:CreateTab("Cài đặt", 4483362458)

SettingsTab:CreateSection("-cấu hình toàn bộ hệ thống")
SettingsTab:CreateButton({
   Name = "Lưu Toàn Bộ GUI (Save All)",
   Callback = function()
       local savedPinnedNames = {}
       if hasPinnedPlayers() then
           for _, p in ipairs(pinnedOrder) do table.insert(savedPinnedNames, p.DisplayName .. " (" .. p.Name .. ")") end
       end
       
       local config = {
           speed = _G_speedValue,
           sides = _G_sidesValue, 
           dist = _G_distanceValue,
           height = _G_heightValue,
           fSpeed = _G_flySpeedValue,
           pred = _G_predCoeffValue,
           vel = _G_velCheckValue,
           hModeStr = currentHeightModeStr, dModeStr = currentDirModeStr,
           nModeStr = currentNetModeStr, cModeStr = currentCombatModeStr,
           tC_Vis = classicWidget.Visible, tN_Vis = nearWidget.Visible,
           tO_Vis = orangeWidget.Visible, tP_Vis = purpleWidget.Visible,
           stud = studOffset, m1 = mode1Name, m2 = mode2Name,
           mV = isMiniVoidVisible, mKB = isMiniKBVisible,
           pinnedList = savedPinnedNames,
           noclip = isNoclipEnabled,
		   
		   killAllActive = killAllActive,
		   killAllMiniVis = killAllWidget.Visible,
		   killAllDist = killAll_TeleportDistance,
		   killAllDir = killAll_DirectionMode,

           -- Lưu vị trí (Position) của toàn bộ các Mini GUI trên màn hình
           widgetPositions = {
               classic = {classicWidget.Position.X.Scale, classicWidget.Position.X.Offset, classicWidget.Position.Y.Scale, classicWidget.Position.Y.Offset},
               near = {nearWidget.Position.X.Scale, nearWidget.Position.X.Offset, nearWidget.Position.Y.Scale, nearWidget.Position.Y.Offset},
               orange = {orangeWidget.Position.X.Scale, orangeWidget.Position.X.Offset, orangeWidget.Position.Y.Scale, orangeWidget.Position.Y.Offset},
               purple = {purpleWidget.Position.X.Scale, purpleWidget.Position.X.Offset, purpleWidget.Position.Y.Scale, purpleWidget.Position.Y.Offset},
               killAll = {killAllWidget.Position.X.Scale, killAllWidget.Position.X.Offset, killAllWidget.Position.Y.Scale, killAllWidget.Position.Y.Offset},
               void = {voidWidget.Position.X.Scale, voidWidget.Position.X.Offset, voidWidget.Position.Y.Scale, voidWidget.Position.Y.Offset},
               kb = {kbWidget.Position.X.Scale, kbWidget.Position.X.Offset, kbWidget.Position.Y.Scale, kbWidget.Position.Y.Offset}
           }
       }
       if writefile then
           pcall(function() writefile(fullSaveFileName, HttpService:JSONEncode(config)) end)
       end
   end,
})

SettingsTab:CreateButton({
    Name = "Tải Lại Toàn Bộ GUI (Load All)",
    Callback = function()
        if readfile and isfile then
            local isExist = false
            pcall(function() isExist = isfile(fullSaveFileName) end)
            if isExist then
                local success, parsed = pcall(function() return HttpService:JSONDecode(readfile(fullSaveFileName)) end)
                if success and type(parsed) == "table" then
                    if Input_Speed then Input_Speed:Set(tostring(parsed.speed or 90)) end
                    if Input_Sides then Input_Sides:Set(tostring(parsed.sides or 0)) end 
                    if Input_Dist then Input_Dist:Set(tostring(parsed.dist or 4.5)) end
                    if Input_Height then Input_Height:Set(tostring(parsed.height or 4.5)) end
                    if Input_Chase then Input_Chase:Set(tostring(parsed.fSpeed or 250)) end
                    if Input_Pred then Input_Pred:Set(tostring(parsed.pred or 1)) end
                    if Input_Vel then Input_Vel:Set(tostring(parsed.vel or 2)) end

                    if Drop_HeightMode then Drop_HeightMode:Set({parsed.hModeStr or "MODE: TRÊN TRỜI"}) end
                    if Drop_DirMode then Drop_DirMode:Set({parsed.dModeStr or "ORBIT (XOAY)"}) end
                    if Drop_NetMode then Drop_NetMode:Set({parsed.nModeStr or "NET: NORMAL"}) end
                    if Drop_CombatMode then Drop_CombatMode:Set({parsed.cModeStr or "MODE: OFF (TS/PRED)"}) end

                    if Toggle_ClassicTracker then Toggle_ClassicTracker:Set(parsed.tC_Vis == nil and false or parsed.tC_Vis) end
                    if Toggle_NearTracker then Toggle_NearTracker:Set(parsed.tN_Vis == nil and false or parsed.tN_Vis) end
                    if Toggle_OrangeFly then Toggle_OrangeFly:Set(parsed.tO_Vis == nil and false or parsed.tO_Vis) end
                    if Toggle_PurpleFly then Toggle_PurpleFly:Set(parsed.tP_Vis == nil and false or parsed.tP_Vis) end
                    if Toggle_Noclip then Toggle_Noclip:Set(parsed.noclip == nil and false or parsed.noclip) end

                    if InputStudsUI then InputStudsUI:Set(tostring(parsed.stud or 0)) end
                    if DropNgangUI then DropNgangUI:Set({parsed.m1 or "Hủy"}) end
                    if DropTrenUI then DropTrenUI:Set({parsed.m2 or "Hủy"}) end
                    if ToggleVoidUI then ToggleVoidUI:Set(parsed.mV == nil and true or parsed.mV) end
                    if ToggleKBUI then ToggleKBUI:Set(parsed.mKB == nil and true or parsed.mKB) end
                    
					killAllActive = parsed.killAllActive == nil and false or parsed.killAllActive
					killAllWidget.Visible = parsed.killAllMiniVis == nil and false or parsed.killAllMiniVis
					killAll_TeleportDistance = parsed.killAllDist or 1.5
					killAll_DirectionMode = parsed.killAllDir or "đằng sau"
					
					if Toggle_KillAllMiniVis then Toggle_KillAllMiniVis:Set(killAllWidget.Visible) end
					
                    if PinnedDropdown and parsed.pinnedList then
                        PinnedDropdown:Set(parsed.pinnedList)
                    end

                    -- Khôi phục vị trí (Position) của toàn bộ các Mini GUI đã lưu
                    if parsed.widgetPositions then
                        local wp = parsed.widgetPositions
                        if wp.classic then classicWidget.Position = UDim2.new(wp.classic[1], wp.classic[2], wp.classic[3], wp.classic[4]) end
                        if wp.near then nearWidget.Position = UDim2.new(wp.near[1], wp.near[2], wp.near[3], wp.near[4]) end
                        if wp.orange then orangeWidget.Position = UDim2.new(wp.orange[1], wp.orange[2], wp.orange[3], wp.orange[4]) end
                        if wp.purple then purpleWidget.Position = UDim2.new(wp.purple[1], wp.purple[2], wp.purple[3], wp.purple[4]) end
                        if wp.killAll then killAllWidget.Position = UDim2.new(wp.killAll[1], wp.killAll[2], wp.killAll[3], wp.killAll[4]) end
                        if wp.void then voidWidget.Position = UDim2.new(wp.void[1], wp.void[2], wp.void[3], wp.void[4]) end
                        if wp.kb then kbWidget.Position = UDim2.new(wp.kb[1], wp.kb[2], wp.kb[3], wp.kb[4]) end
                    end

                    isAttached = false
                    targetModeIndex = 3 
                    stopFlying()
                    updateAttachment()
                end
            end
        end
    end,
})

-- ======================================================================
-- CÁC HÀM SỰ KIỆN NỀN TẢNG
-- ======================================================================
tanSatConnection = RunService.Heartbeat:Connect(function()
	if isClassicTrackingActive and not hasPinnedPlayers() and (tanSatMode == 1 or tanSatMode == 3) then
		local tChar = selectedTargetPlayer and selectedTargetPlayer.Character
		local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
		if not selectedTargetPlayer or not tHum or tHum.Health <= 0 or not selectedTargetPlayer.Parent then
			local nextPlayer = getClosestPlayer()
			if nextPlayer then
				selectedTargetPlayer = nextPlayer
				local nextHum = nextPlayer.Character and nextPlayer.Character:FindFirstChildOfClass("Humanoid")
				if nextHum then Camera.CameraSubject = nextHum end
            else
                selectedTargetPlayer = nil
			end
		end
	end

	if isNearTrackingActive and (tanSatMode == 1 or tanSatMode == 3) then
		local tChar = selectedTargetPlayer and selectedTargetPlayer.Character
		local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
		if not selectedTargetPlayer or not tHum or tHum.Health <= 0 or not selectedTargetPlayer.Parent then
			local nextPlayer = getClosestPlayer()
			if nextPlayer then
                selectedTargetPlayer = nextPlayer
                local nextHum = nextPlayer.Character and nextPlayer.Character:FindFirstChildOfClass("Humanoid")
                if nextHum then Camera.CameraSubject = nextHum end
            else
                selectedTargetPlayer = nil
			end
		end
	end
end)

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local currentY = char.HumanoidRootPart.Position.Y
        if char.Humanoid.Health > 0 then
            lastSafeY = currentY
        else
            if lastSafeY < -20 then trackedVoidY = lastSafeY end
        end
    end
end)

localPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    if isAttached then updateAttachment() end
end)

-- ======================================================================
-- TÍNH NĂNG KÉO THẢ (DRAGGABLE) CHO CÁC MINI GUI
-- ======================================================================
local isDraggingWidget = false

local function makeDraggable(frame, handle)
	local dragging = false
	local dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; isDraggingWidget = false; dragStart = input.Position; startPos = frame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
			if dragging then 
				local delta = input.Position - dragStart
				if delta.Magnitude > 7 then
					isDraggingWidget = true 
				end
			end
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			frame.Position = newPos
		end
	end)
end

makeDraggable(classicWidget, classicActionBtn)
makeDraggable(nearWidget, nearActionBtn)
makeDraggable(orangeWidget, orangeFlyBtn)
makeDraggable(purpleWidget, purpleFlyBtn)
makeDraggable(killAllWidget, killAllActionBtn)
makeDraggable(voidWidget, voidBtn)
makeDraggable(kbWidget, kbBtn)

classicActionBtn.MouseButton1Up:Connect(function()
	if not isDraggingWidget then
		if isClassicTrackingActive then stopFlying() else startFlying("Classic") end
	end
end)
nearActionBtn.MouseButton1Up:Connect(function()
	if not isDraggingWidget then
		if isNearTrackingActive then stopFlying() else startFlying("Near") end
	end
end)
orangeFlyBtn.MouseButton1Click:Connect(function() if not isDraggingWidget then runOrangeFlyLogic(not isOrangeFlyEnabled) end end)
purpleFlyBtn.MouseButton1Click:Connect(function() if not isDraggingWidget then runPurpleFlyLogic(not isPurpleFlyEnabled) end end)

killAllActionBtn.MouseButton1Up:Connect(function()
	if not isDraggingWidget then
		local state = not killAllActive
		toggleKillAll(state)
	end
end)

voidBtn.MouseButton1Click:Connect(function()
    if not isDraggingWidget then
        if targetModeIndex == 1 and isAttached then 
            isAttached, targetModeIndex = false, 3
        else 
            isAttached, targetModeIndex = true, 1
            if isClassicTrackingActive or isNearTrackingActive then stopFlying() end
        end
        updateAttachment()
    end
end)
kbBtn.MouseButton1Click:Connect(function()
    if not isDraggingWidget then
        if targetModeIndex == 2 and isAttached then 
            isAttached, targetModeIndex = false, 3
        else 
            isAttached, targetModeIndex = true, 2 
            if isClassicTrackingActive or isNearTrackingActive then stopFlying() end
        end
        updateAttachment()
    end
end)

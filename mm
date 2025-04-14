-- Services
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local charHRP = character:WaitForChild("HumanoidRootPart")

-- UI สำหรับเปิด/ปิดระบบ
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoFarmUI"

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "เปิดระบบออโต้ฟาร์ม"
toggleButton.BorderSizePixel = 0

local enabled = false
toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		toggleButton.Text = "ปิดระบบออโต้ฟาร์ม"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	else
		toggleButton.Text = "เปิดระบบออโต้ฟาร์ม"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	end
end)

-- พิกัดเควส
local questPositions = {
	{levelMin = 1, levelMax = 9, pos = CFrame.new(1061.67, 16.51, 1544.52), quest = {"StartQuest", "BanditQuest1", 1}},
	{levelMin = 10, levelMax = 14, pos = CFrame.new(-1604.12, 36.85, 154.23), quest = {"StartQuest", "JungleQuest", 1}},
	{levelMin = 15, levelMax = 29, pos = CFrame.new(-1200.44, 8.02, -449.05), quest = {"StartQuest", "JungleQuest", 2}},
	{levelMin = 30, levelMax = 39, pos = CFrame.new(-1139.59, 4.75, 3825.16), quest = {"StartQuest", "PirateQuest1", 1}},
}

-- ฟังก์ชันบินไปหาเป้าหมาย
local function flyToTarget(targetPosition)
	local targetCFrame = CFrame.new(targetPosition + Vector3.new(0, 10, 0))
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(charHRP, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
end

-- ฟังก์ชันหา Enemy ตามเลเวล
local function findClosestEnemyByLevel(level)
	local closestEnemy = nil
	local minDistance = math.huge

	for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
		local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
		local enemyHumanoid = enemy:FindFirstChild("Humanoid")

		if enemyHRP and enemyHumanoid and enemyHumanoid.Health > 0 then
			if (level <= 9 and enemy.Name == "Bandit")
			or (level >= 10 and level <= 14 and enemy.Name == "Monkey")
			or (level >= 15 and level <= 29 and enemy.Name == "Gorilla")
			or (level >= 30 and level <= 39 and enemy.Name == "Pirate") then
				local distance = (charHRP.Position - enemyHRP.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					closestEnemy = enemy
				end
			end
		end
	end

	return closestEnemy
end

-- Fast Attack ระบบโจมตี
local FastAttack = true
local Net = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
local RegAttack = Net:WaitForChild("RE"):WaitForChild("RegisterAttack")
local RegHit = Net:WaitForChild("RE"):WaitForChild("RegisterHit")
local Enemies = workspace:WaitForChild("Enemies")

task.defer(function()
	while FastAttack do
		pcall(function()
			local Char = player.Character
			if not Char then return end

			local HR = Char:FindFirstChild("HumanoidRootPart")
			local Head = Char:FindFirstChild("Head") or HR
			if not HR then return end

			-- ยิงคำสั่งโจมตี
			RegAttack:FireServer(0)

			local HR_arg = {HR, {}}
			local Head_arg = {Head, {}}

			for _, enemy in pairs(Enemies:GetChildren()) do
				if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
					local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
					if enemyHRP then
						table.insert(HR_arg[2], {enemy, enemyHRP})
						table.insert(Head_arg[2], {enemy, enemyHRP})
					end
				end
			end

			RegHit:FireServer(unpack(HR_arg))
			RegHit:FireServer(unpack(Head_arg))
		end)
		task.wait() -- wait 1 frame เพื่อให้ Roblox engine ประมวลผลทัน
	end
end)

-- ทำงานอัตโนมัติ
task.spawn(function()
	while true do
		if enabled then
			local MyLevel = player:WaitForChild("Data"):WaitForChild("Level").Value
			local questGUI = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Quest")

			-- รับเควสอัตโนมัติ
			if questGUI.Visible == false then
				for _, data in pairs(questPositions) do
					if MyLevel >= data.levelMin and MyLevel <= data.levelMax then
						game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(data.quest))
						break
					end
				end
			end

			-- บินไปหา Enemy
			if questGUI.Visible == true then
				local enemy = findClosestEnemyByLevel(MyLevel)
				if enemy then
					local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
					if enemyHRP then
						flyToTarget(enemyHRP.Position)
					end
				end
			end
		end
		task.wait(0.5)
	end
end)
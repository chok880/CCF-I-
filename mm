getgenv().AutoFarm = true
_G.FastAttack = true

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = workspace:WaitForChild("Enemies")
local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local RegAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
local RegHit = ReplicatedStorage.Modules.Net["RE/RegisterHit"]

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function fastAttackLoop()
    task.spawn(function()
        while _G.FastAttack do
            local Char = getCharacter()
            local HR = Char:FindFirstChild("HumanoidRootPart")
            local Head = Char:FindFirstChild("Head") or HR
            if HR then
                pcall(function() RegAttack:FireServer(0) end)
                for _, enemy in pairs(Enemies:GetChildren()) do
                    local enemyHum = enemy:FindFirstChild("Humanoid")
                    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyHum and enemyHRP and enemyHum.Health > 0 then
                        pcall(function() RegHit:FireServer(HR, {{enemy, enemyHRP}}) end)
                        pcall(function() RegHit:FireServer(Head, {{enemy, enemyHRP}}) end)
                    end
                end
            end
            wait()
        end
    end)
end

local function autoFarmLoop()
    task.spawn(function()
        while getgenv().AutoFarm do
            local Char = getCharacter()
            local Hum = Char:WaitForChild("HumanoidRootPart")
            local Level = player.Data.Level.Value

            local MON, MONPOS, QUESTPOS, QUESTNAME, QUESTNUMBER
            
            if Level >= 1 and Level <= 9 then
            MON = "Bandit"; MONPOS = CFrame.new(1198.66,16.74,1618.34)
            QUESTPOS = CFrame.new(1057.98,17.70,1550.54); QUESTNAME="BanditQuest1"; QUESTNUMBER=1
        elseif Level >= 10 and Level <= 14 then
            MON = "Monkey"; MONPOS = CFrame.new(-1619.10,21.70,142.14)
            QUESTPOS = CFrame.new(-1598.08,35.55,153.37); QUESTNAME="JungleQuest"; QUESTNUMBER=1
        elseif Level >= 15 and Level <= 29 then
            MON = "Gorilla"; MONPOS = CFrame.new(-1135.46,40.71,-529.90)
            QUESTPOS = CFrame.new(-1598.08,35.55,153.37); QUESTNAME="JungleQuest"; QUESTNUMBER=2
        elseif Level >= 30 and Level <= 39 then
            MON = "Pirate"; MONPOS = CFrame.new(-1115.55,13.52,3937.50)
            QUESTPOS = CFrame.new(-1140.02,4.71,3829.60); QUESTNAME="BuggyQuest1"; QUESTNUMBER=1
        elseif Level >= 40 and Level <= 59 then
            MON = "Brute"; MONPOS = CFrame.new(-1137.80,14.86,4293.50)
            QUESTPOS = CFrame.new(-1140.02,4.71,3829.60); QUESTNAME="BuggyQuest1"; QUESTNUMBER=2
        elseif Level >= 60 and Level <= 74 then
            MON = "Desert Bandit"; MONPOS = CFrame.new(932.60,7.32,4486.49)
            QUESTPOS = CFrame.new(897.49,6.44,4388.54); QUESTNAME="DesertQuest"; QUESTNUMBER=1
        elseif Level >= 75 and Level <= 89 then
            MON = "Desert Officer"; MONPOS = CFrame.new(1572.10,10.39,4372.46)
            QUESTPOS = CFrame.new(897.49,6.44,4388.54); QUESTNAME="DesertQuest"; QUESTNUMBER=2
        elseif Level >= 90 and Level <= 99 then
            MON = "Snow Bandit"; MONPOS = CFrame.new(1353.78,105.22,-1462.11)
            QUESTPOS = CFrame.new(1389.91,87.27,-1297.12); QUESTNAME="SnowQuest"; QUESTNUMBER=1
        elseif Level >= 100 and Level <= 119 then
            MON = "Snowman"; MONPOS = CFrame.new(1189.68,105.42,-1410.17)
            QUESTPOS = CFrame.new(1389.91,87.27,-1297.12); QUESTNAME="SnowQuest"; QUESTNUMBER=2
        elseif Level >= 120 and Level <= 149 then
            MON = "Chief Petty Officer"; MONPOS = CFrame.new(-4855.77,22.67,4308.97)
            QUESTPOS = CFrame.new(-4881.28,22.65,4289.54); QUESTNAME="MarineQuest2"; QUESTNUMBER=1
        elseif Level >= 150 and Level <= 174 then
            MON = "Sky Bandit"; MONPOS = CFrame.new(-4981.47,278.58,-2837.20)
            QUESTPOS = CFrame.new(-4841.42,717.67,-2622.35); QUESTNAME="SkyQuest"; QUESTNUMBER=1
        elseif Level >= 175 and Level <= 189 then
            MON = "Dark Master"; MONPOS = CFrame.new(-5250.72,388.57,-2272.98)
            QUESTPOS = CFrame.new(-4841.42,717.67,-2622.35); QUESTNAME="SkyQuest"; QUESTNUMBER=2
        elseif Level >= 190 and Level <= 209 then
            MON = "Prisoner"; MONPOS = CFrame.new(4855.34,5.67,740.15)
            QUESTPOS = CFrame.new(5307.86,1.67,474.65); QUESTNAME="PrisonerQuest"; QUESTNUMBER=1
        elseif Level >= 210 and Level <= 249 then
            MON = "Dangerous Prisoner"; MONPOS = CFrame.new(5014.35,5.67,841.21)
            QUESTPOS = CFrame.new(5307.86,1.67,474.65); QUESTNAME="PrisonerQuest"; QUESTNUMBER=2
        elseif Level >= 250 and Level <= 299 then
            MON = "Toga Warrior"; MONPOS = CFrame.new(-1772.16,8.41,-2745.31)
        end


            if MON then
                local questGui = player.PlayerGui.Main.Quest
                local questTitle = questGui.Container.QuestTitle.Title:FindFirstChild("ContantText")

                if questTitle and not string.find(questTitle.Text, MON) then
                    pcall(function() CommF_:InvokeServer("AbandonQuest") end)
                end

                if QUESTPOS and (Hum.Position - QUESTPOS.Position).Magnitude < 5 then
                    player:LoadCharacter()
                wait(1)
                    Char = getCharacter()
                    Hum = Char:WaitForChild("HumanoidRootPart")
                end

                if not questGui.Visible then
                    Hum.CFrame = QUESTPOS
                    task.wait(0.5)
                    pcall(function() CommF_:InvokeServer("StartQuest", QUESTNAME, QUESTNUMBER) end)
                    task.wait(0.5)
                end

                local closestTarget = nil
                local minDist = math.huge
                for _, target in pairs(Enemies:GetChildren()) do
                    if target.Name == MON and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                        local targetHRP = target:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            local dist = (Hum.Position - targetHRP.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestTarget = targetHRP
                            end
                        end
                    end
                end

                if closestTarget then
                    Hum.CFrame = closestTarget.CFrame * CFrame.new(0, 15, 0)
                    task.wait()
                    pcall(function() RegHit:FireServer(closestTarget) end)
                else
                    Hum.CFrame = MONPOS
                end
            end

            task.wait()
        end
    end)
end

player.CharacterAdded:Connect(function(Char)
    Hum = Char:WaitForChild("HumanoidRootPart")
end)

fastAttackLoop()
autoFarmLoop()

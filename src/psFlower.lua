--[[
Custom proximityprompt by Sowd
Tween by Nahida
code is super cringe btw
]]

local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local Player = Players.LocalPlayer;
local chr = Player.Character
local root = chr.HumanoidRootPart

local TeleportSpeed = getgenv().speed or 250;
local NextFrame = RunService.Heartbeat;

local function fireproximityprompt(ProximityPrompt, Amount, Skip)
    assert(ProximityPrompt, "Argument #1 Missing or nil")
    assert(typeof(ProximityPrompt) == "Instance" and ProximityPrompt:IsA("ProximityPrompt"), "Attempted to fire a Value that is not a ProximityPrompt")

    local HoldDuration = ProximityPrompt.HoldDuration
    if Skip then
        ProximityPrompt.HoldDuration = 0
    end

    for i = 1, Amount or 1 do
        ProximityPrompt:InputHoldBegin()
        if Skip then
            local RunService = game:GetService("RunService")
            local Start = time()
            repeat
                RunService.Heartbeat:Wait(0.1)
            until time() - Start > HoldDuration
        end
        ProximityPrompt:InputHoldEnd()
    end
    ProximityPrompt.HoldDuration = HoldDuration
end

local function ImprovedTeleport(Target)
	if (typeof(Target) == "Instance" and Target:IsA("BasePart")) then
		Target = Target.Position;
	end;
	if (typeof(Target) == "CFrame") then
		Target = Target.p
	end;
	local HRP = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"));
	if (not HRP) then
		return;
	end;
	local StartingPosition = HRP.Position;
	local PositionDelta = (Target - StartingPosition);--Calculating the difference between the start and end positions.
	local StartTime = tick();
	local TotalDuration = (StartingPosition - Target).magnitude / TeleportSpeed;
	repeat
		NextFrame:Wait();
		local Delta = tick() - StartTime;
		local Progress = math.min(Delta / TotalDuration, 1);--Getting the percentage of completion of the teleport (between 0-1, not 0-100)
        --We also use math.min in order to maximize it at 1, in case the player gets an FPS drop, so it doesn't go past the target.
		local MappedPosition = StartingPosition + (PositionDelta * Progress);
		HRP.Velocity = Vector3.new();--Resetting the effect of gravity so it doesn't get too much and drag the player below the ground.
		HRP.CFrame = CFrame.new(MappedPosition);
	until (HRP.Position - Target).magnitude <= TeleportSpeed / 2;
	HRP.Anchored = false;
	HRP.CFrame = CFrame.new(Target);
end;


local flowers = game:GetService("Workspace").Demon_Flowers_Spawn
local function getFlower()
	local dist, flower = math.huge
	for i, v in next, flowers:GetChildren() do
		if v:IsA('Model') then
			local mag = (root.Position - v.WorldPivot.Position).magnitude
			if mag < dist then
				dist = mag
				flower = v
			end
		end
	end
	return flower
end


spawn(function()
	while task.wait() do
		pcall(function()
			if getgenv().enabled then
				repeat task.wait()
                    ImprovedTeleport(getFlower().WorldPivot.Position)
				    wait(getgenv().delay or 1)
				    for i,v in next, getFlower():GetDescendants() do
                        if v:IsA("ProximityPrompt") then
                            fireproximityprompt(v, 1, true)
                        end
                    end
                until not getFlower() or not TP
			end
		end)
	end
end)

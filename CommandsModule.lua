local module = {}
local Builds = script.Parent.Parent.Builds
local Remote = game.ReplicatedStorage.Catalyst_Remote
local Players = game.Players
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local DataStoreService = game.DataStoreService
local RankData = DataStoreService:GetDataStore("Catalyst_Ranks")
local RankValues = {
	["Owner"] = 10,
	["Head Admin"] = 4,
	["Admin"] = 3,
	["Mod"] = 2,
	["VIP"] = 1,
	["Non-Admin"] = 0
}

local function GetRankValue(Rank)
	for RankName, Value in pairs(RankValues) do
		if Rank:lower() == RankName:lower() then
			return Value
		end
	end
end

local function FindPlayerByName(Name)
	if Name and type(Name) == "string" then
		for _,Player in pairs(Players:GetPlayers()) do
			if string.match(Player.Name:lower(), Name:lower()) then
				return Player
			end
		end
	else
		warn("Cataylst Admin encountered an error: \n".."Script: "..script.Name.."\nFull Path: "..script:GetFullName().."\nError: No name provided for function FindPlayerByName or Name was not a string")
	end
end

local function GetPlayerRank(Player)
	for Rank,Admins in pairs(_G.HardCodedRanks) do
		for _,Admin in pairs(Admins) do
			if Player.Name:lower() == Admin:lower() then
				return Rank
			end
		end
	end

	for Admin,Rank in pairs(_G.TempRanks) do
		if Player.Name:lower() == Admin:lower() then
			return Rank
		end
	end
	
	local Rank = RankData:GetAsync(Player)
	
	if Rank then
		return Rank
	end

	return "Non-Admin"
end

local Commands = {
	["kick"] = {
		Name =  "Kick",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name, Reason)
			if Name and Reason then
				local Victim = FindPlayerByName(Name)
				
				if Victim then
					Victim:Kick(Reason)
				end
			elseif Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim then
					Victim:Kick()
				end
			end
		end,
	},
	["bring"] = {
		Name = "Bring",
		Description = "",
		Rank = "VIP",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Caller.Character then
					Victim.Character.HumanoidRootPart.CFrame = Caller.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
				end
			end
		end,
	},
	["kill"] = {
		Name = "Kill",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character then
					Victim.Character.Humanoid.Health = 0
				end
			end
		end,
	},
	["damage"] = {
		Name = "Damage",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name, Amount)
			if Name and Amount and tonumber(Amount) ~= nil then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character then
					Victim.Character.Humanoid.Health -= Amount
				end
			end
		end,
	},
	["to"] = {
		Name = "To",
		Description = "",
		Rank = "VIP",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Caller.Character and Victim.Character.HumanoidRootPart and Caller.Character.HumanoidRootPart then
					Caller.Character.HumanoidRootPart.CFrame = Victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
				end
			end
		end,
	},
	["join"] = {
		Name = "Join",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim then
					-- Player is in server handle this later when you've made notification module
				else
					local Reply = MessagingService:PublishAsync("follow", Name)
					
					local Options = Instance.new("TeleportOptions")
					Options.ServerInstanceId = Reply
					
					TeleportService:TeleportAsync(game.PlaceId, Caller, Options)
				end
			end
		end,
	},
	["temprank"] = {
		Name = "TempRank",
		Description = "",
		Rank = "Mod",
		Aliases = {"trank"},
		Callback = function(Caller, Name, Rank)
			if Name and Rank then
				local Victim = FindPlayerByName(Name)
				
				if Victim then
					_G.TempRanks[Victim.Name] = Rank
				end
			end
		end,
	},
	["respawn"] = {
		Name = "Respawn",
		Description = "",
		Rank = "VIP",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim then
					Victim:LoadCharacter()
				end
			end
		end,
	},
	["refresh"] = {
		Name = "Refresh",
		Description = "",
		Rank = "VIP",
		Aliases = {"re"},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Victim.Character.HumanoidRootPart then
					local OldCFrame = Victim.Character.HumanoidRootPart.CFrame
					Victim:LoadCharacter()
					Victim.Character.HumanoidRootPart.CFrame = OldCFrame
				end
			end
		end,
	},
	["speed"] = {
		Name = "Speed",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name, Value)
			if Name and Value and tonumber(Value) ~= nil then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Victim.Character.Humanoid.Health > 0 then
					Victim.Character.Humanoid.WalkSpeed = Value
				end
			end
		end,
	},
	["teleport"] = {
		Name = "Teleport",
		Description = "",
		Rank = "Mod",
		Aliases = {"tp"},
		Callback = function(Caller, Name, Name2)
			if Name and Name2 then
				local Victim1 = FindPlayerByName(Name)
				local Victim2 = FindPlayerByName(Name2)
				
				if Victim1 and Victim2 and Victim1.Character and Victim2.Character then
					Victim1.Character.HumanoidRootPart.CFrame = Victim2.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
				end
			end
		end,
	},
	["explode"] = {
		Name = "Explode",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Victim.Character.HumanoidRootPart then
					local Explosion =  Instance.new("Explosion")
					Explosion.Position = Victim.Character.HumanoidRootPart.Position
					Explosion.Parent = Victim.Character
				end
			end
		end,
	},
	["update"] = { -- broken rn
		Name = "Update",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function()
			require(14761113064):Update()
		end,
	},
	["jail"] = {
		Name = "Jail",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Victim.Character:FindFirstChild("HumanoidRootPart") then
					local Jail = Builds:FindFirstChild("Jail"):Clone()
					Jail.Name = Jail.Name.."_"..Victim.Name
					
					Jail:PivotTo(Victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2.5, 0))
					Jail.Parent = workspace
				end
			else
				if Caller and Caller.Character and Caller.Character:FindFirstChild("HumanoidRootPart") then
					local Jail = Builds:FindFirstChild("Jail"):Clone()
					Jail.Name = Jail.Name.."_"..Caller.Name

					Jail:PivotTo(Caller.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2.5, 0))
					Jail.Parent = workspace
				end
			end
		end,
	},
	["unjail"] = {
		Name = "UnJail",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim then
					if workspace:FindFirstChild("Jail_"..Victim.Name) then
						workspace:FindFirstChild("Jail_"..Victim.Name):Destroy()
					end
				end
			else
				if workspace:FindFirstChild("Jail_"..Caller.Name) then
					workspace:FindFirstChild("Jail_"..Caller.Name):Destroy()
				end
			end
		end,
	},
	["freeze"] = {
		Name = "Freeze",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Victim.Character:FindFirstChild("HumanoidRootPart") then
					Victim.Character.HumanoidRootPart.Anchored = true
				end
			end
		end,
	},
	["unfreeze"] = {
		Name = "UnFreeze",
		Description = "",
		Rank = "Mod",
		Aliases = {"thaw"},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)

				if Victim and Victim.Character and Victim.Character:FindFirstChild("HumanoidRootPart") then
					Victim.Character.HumanoidRootPart.Anchored = false
				end
			end
		end,
	},
	["lag"] = {
		Name = "Lag",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function(Caller, Name)
			if Name then
				local Victim = FindPlayerByName(Name)
				
				if Victim and Victim.Character and Victim.Character:FindFirstChild("HumanoidRootPart") then
					Victim.Character.HumanoidRootPart:SetNetworkOwner(nil)
				end
			end
		end,
	},
	["highlight"] = {
		Name = "Highlight",
		Description = "",
		Rank = "Mod",
		Aliases = {"hl"},
		Callback = function(Caller, Name)
			Remote:FireClient(Caller, "Highlight", Name)
		end,
	},
	["clear"] = {
		Name = "Clear",
		Description = "",
		Rank = "Mod",
		Aliases = {},
		Callback = function()
			for _,Build in pairs(Builds:GetChildren()) do
				for _,Child in pairs(workspace:GetChildren()) do
					if Child.Name:find(Build.Name) then
						Child:Destroy()
					end
				end
			end
		end,
	}
}

function module:GetCommand(Name)
	for CommandName, Command in pairs(Commands) do
		if Name:lower() == CommandName:lower() or table.find(Command.Aliases, Name) then
			return Command
		end
	end
end

return module
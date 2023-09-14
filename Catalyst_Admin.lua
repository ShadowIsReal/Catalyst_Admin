local Players = game.Players
script.Parent.Modules:WaitForChild("CommandsModule")

local CommandsModule = require(script.Parent.Modules.CommandsModule)
if not _G.HardCodedRanks then
	_G.HardCodedRanks = {
		["Owner"] = {"shadowmaster940"},
		["Head Admin"] = {},
		["Admin"] = {},
		["Mod"] = {},
		["VIP"] = {},
		["Non-Admin"] = {}
	}
end
local RankValues = {
	["Owner"] = 10,
	["Head Admin"] = 4,
	["Admin"] = 3,
	["Mod"] = 2,
	["VIP"] = 1,
	["Non-Admin"] = 0
}
_G.CatalystConnections = {}

local function GetRankValue(Rank)
	for RankName, Value in pairs(RankValues) do
		if Rank:lower() == RankName:lower() then
			return Value
		end
	end
end

local function SearchForKeywords(Argument)
	if Argument then
		if Argument:lower() == "all" then
			return "all"
		elseif Argument:lower() == "others" then
			return "others"
		elseif Argument:lower() == "random" then
			return "random"
		elseif Argument:lower() == "me" then
			return "me"
		end
	end

	return nil
end

local function RunCommandWithKeyword(Player, Command, Arguments, Keyword)
	if Player and Command and Arguments and Keyword then
		if Keyword == "all" then
			for _, Victim in pairs(Players:GetPlayers()) do
				Command.Callback(Player, Victim.Name, select(3, unpack(Arguments)))
			end
		elseif Keyword == "others" then
			for _, Victim in pairs(Players:GetPlayers()) do
				if Victim ~= Player then
					Command.Callback(Player, Victim.Name, select(3, unpack(Arguments)))
				end
			end
		elseif Keyword == "random" then
			Command.Callback(Player, Players:GetPlayers()[math.random(1, #Players:GetPlayers())].Name, select(3, unpack(Arguments)))
		elseif Keyword == "me" then
			Command.Callback(Player, Player.Name, select(3, unpack(Arguments)))
		end
	end
end

local function PlayerCanRunCommand(Player, Command)
	for Rank,Admins in pairs(_G.HardCodedRanks) do
		for _,Admin in pairs(Admins) do
			if Player.Name:lower() == Admin:lower() then
				if GetRankValue(Rank) >= GetRankValue(Command.Rank) then
					return true
				end
			end
		end
	end
	
	for Admin,Rank in pairs(_G.TempRanks) do
		if Player.Name:lower() == Admin:lower() then
			if GetRankValue(Rank) >= GetRankValue(Command.Rank) then
				return true
			end
		end
	end
	
	return false
end

local function OnMessage(Player, Message)
	local Arguments = string.split(Message, " ")
	if string.sub(Arguments[1], 1, 1) == "-" then
		local Command = CommandsModule:GetCommand(string.sub(Arguments[1], 2, #Arguments[1]))
		if Command and PlayerCanRunCommand(Player, Command) then
			local Keyword = SearchForKeywords(Arguments[2])
			if Keyword then
				RunCommandWithKeyword(Player, Command, Arguments, Keyword)
			else
				Command.Callback(Player, select(2, unpack(Arguments)))
			end
		end
	elseif Arguments[1] == "/e" and string.sub(Arguments[2], 1, 1) == "-" then
		for i=1, #Arguments do
			Arguments[i] = Arguments[i+1]
		end
		
		local Command = CommandsModule:GetCommand(string.sub(Arguments[1], 2, #Arguments[1]))
		if Command and PlayerCanRunCommand(Player, Command) then
			local Keyword = SearchForKeywords(Arguments[2])
			if Keyword then
				RunCommandWithKeyword(Player, Command, Arguments, Keyword)
			else
				Command.Callback(Player, select(2, unpack(Arguments)))
			end
		end
	end
end

local function OnPlayer(Player)
	table.insert(_G.CatalystConnections, Player.Chatted:Connect(function(Message)
		OnMessage(Player, Message)
	end))
end

table.insert(_G.CatalystConnections, Players.PlayerAdded:Connect(OnPlayer))
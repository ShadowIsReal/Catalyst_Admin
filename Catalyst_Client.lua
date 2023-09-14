local Players = game.Players
local Remote = game.ReplicatedStorage:WaitForChild("Catalyst_Remote")

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

local CommandCallbacks = {
	["Highlight"] = function(Name)
		if Name then
			local Victim = FindPlayerByName(Name)
			
			if Victim and Victim.Character then
				Instance.new("Highlight", Victim.Character)
			end
		end
	end,
}


local function OnEvent(Command, ...)
	if Command and CommandCallbacks[Command] then
		task.spawn(CommandCallbacks[Command], ...)
	end
end

Remote.OnClientEvent:Connect(OnEvent)
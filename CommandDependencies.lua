local Players = game.Players
local MessagingService = game:GetService("MessagingService")

if not _G.TempRanks then
	_G.TempRanks = {}
end

MessagingService:SubscribeAsync("follow", function(Name)
	for _,Player in pairs(Name) do
		if Player.Name == Name then
			return game.JobId
		end
	end
end)
RegisterNetEvent('JJz:newPlayer')
RegisterNetEvent('JJz:playerKilledUndead')
RegisterNetEvent('JJz:playerKilledByUndead')
RegisterNetEvent('JJz:playerKilledBySelf')
RegisterNetEvent('JJz:playerKilledByPvp')
RegisterNetEvent('JJz:playerKilled')
RegisterNetEvent('JJz:playerKilledInnocent')
RegisterNetEvent('JJz:townfolkKilledByUndead')
RegisterNetEvent('JJz:townfolkKilled')
local CurrentZone = (Config.DefaultZone and Config.Zones[Config.DefaultZone] or nil)

function GetIdentifier(id, kind)
	local identifiers = {}

	for _, identifier in ipairs(GetPlayerIdentifiers(id)) do
		local prefix = kind .. ':'
		local len = string.len(prefix)
		if string.sub(identifier, 1, len) == prefix then
			return string.sub(identifier, len + 1)
		end
	end

	return nil
end

local LogColors = {
	['name'] = '\x1B[31m',
	['default'] = '\x1B[0m',
	['error'] = '\x1B[31m',
	['success'] = '\x1B[32m'
}

function Log(label, message)
	local color = LogColors[label]

	if not color then
		color = LogColors.default
	end

	print(string.format('%s[Undead] %s[%s]%s %s', LogColors.name, color, label, LogColors.default, message))
end

function InitPlayer(player, name)
	local license = GetIdentifier(player, 'license')
	
	MySQL.Async.fetchScalar(
		'SELECT id FROM undead WHERE id = @id',
		{
			['id'] = license
		},
		function(id)
			if id then
				print("^4[JJzppmain] ^2["..name.."] Has Returned ^0")
				MySQL.Async.execute(
					'UPDATE undead SET name = @name WHERE id = @id',
					{
						['name'] = name,
						['id'] = license
					},
					function(affectedRows)
						if affectedRows < 1 then
							Log('error', 'failed to update ' .. license)
						end
					end)
			else
				print("^4[JJzppmain] ^2["..name.."] Has Joined ^0")
				MySQL.Async.execute(
					'INSERT INTO undead (id, name, killed) VALUES (@id, @name, 0)',
					{
						['id'] = license,
						['name'] = name
					},
					function(affectedRows)
						if affectedRows > 0 then
							Log('success', name .. ' ' .. license .. ' was created')
						else
							Log('error', 'failed to initialize ' .. name .. ' ' .. license)
						end
					end)
			end
		end)
end

AddEventHandler('JJz:newPlayer', function()
	TriggerClientEvent('JJz:setZone', source, CurrentZone)
end)

AddEventHandler('JJz:playerKilledByUndead', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET deaths = deaths + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update deaths count for ' .. license)
				end
			end)
	end)	
end)
AddEventHandler('JJz:townfolkKilledByUndead', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET lossed = lossed + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update deaths count for ' .. license)
				end
			end)
	end)	
end)
AddEventHandler('JJz:townfolkKilled', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET lossed = lossed + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update deaths count for ' .. license)
				end
			end)
	end)	
end)
AddEventHandler('JJz:playerKilledBySelf', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET deaths = deaths + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update deaths count for ' .. license)
				end
			end)
	end)
end)
AddEventHandler('JJz:playerKilledByPvp', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET pvpdeaths = pvpdeaths + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update kill count for ' .. license)
				end
			end)
	end)
end)
AddEventHandler('JJz:playerKilled', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET deaths = deaths + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update deaths count for ' .. license)
				end
			end)
	end)
end)
AddEventHandler('JJz:playerKilledUndead', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET killed = killed + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update kill count for ' .. license)
				end
			end)
	end)
end)
AddEventHandler('JJz:playerKilledInnocent', function()
	if not Config.EnableSql then
		return
	end

	local player = source
	local license = GetIdentifier(player, 'license')

	MySQL.ready(function()
		MySQL.Async.execute(
			'UPDATE undead SET murders = murders + 1 WHERE id = @id',
			{
				['id'] = license
			},
			function (affectedRows)
				if affectedRows < 1 then
					Log('error', 'failed to update murders count for ' .. license)
				end
			end)
	end)
end)
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	if not Config.EnableSql then
		return
	end

	local player = source
	MySQL.ready(function()
		InitPlayer(player, name)
	end)
end)

AddEventHandler('onResourceStart', function()
	if resource == GetCurrentResourceName() then
	if not Config.EnableSql then
		print("^4[JJzppmain] [SQL] not enabled - not saving stats ^0")
		return
	end
	print("^4[JJzppmain]-[Zombies]^2 loaded ^0")
	MySQL.ready(function()
		for _, playerId in ipairs(GetPlayers()) do
			InitPlayer(playerId, GetPlayerName(playerId))
		end
	end)
end
end)

function RandomZone()
	return Config.Zones[Config.ZoneRotation[math.random(#Config.ZoneRotation)]]
end

function SetZone(zone)
	if zone == 'random' then
		CurrentZone = RandomZone()
	elseif zone then
		CurrentZone = Config.Zones[zone]
	else
		CurrentZone = nil
	end

	TriggerClientEvent('JJz:setZone', -1, CurrentZone)
end

function CreateZone(name, x, y, z, radius)
	Config.Zones[name] = {
		name = name,
		x = x,
		y = y,
		z = z,
		radius = radius
	}
	SetZone(name)
end

RegisterCommand('JJzone', function(source, args, raw)
	if #args >= 5 then
		local name = args[1]
		local x = tonumber(args[2]) * 1.0
		local y = tonumber(args[3]) * 1.0
		local z = tonumber(args[4]) * 1.0
		local r = tonumber(args[5]) * 1.0
		CreateZone(name, x, y, z, r)
	else
		SetZone(args[1])
	end
end, true)

function UpdatePlayerStats()
	
	local player = source
	local license = GetIdentifier(player, 'license')
	MySQL.ready(function()
		MySQL.Async.fetchAll(
			'SELECT name, killed FROM undead WHERE id = @id',
			{
				['id'] = license
			},
			function(results)
				TriggerClientEvent('JJz:updatePlayerStats', -1, results)
				
			end)
		
end)
end
function UpdateScoreboards()
	MySQL.ready(function()
		MySQL.Async.fetchAll(
			"SELECT name, killed, murders, lossed FROM undead WHERE name <> '' AND killed <> 0 ORDER BY killed DESC LIMIT 10",
			{},
			function(results)
				TriggerClientEvent('JJz:updateScoreboard', -1, results)

			end)
			
		MySQL.Async.fetchScalar(
			"SELECT SUM(killed) FROM undead",
			{},
			function(total)
				TriggerClientEvent("JJz:updateTotalUndeadKilled", -1, total)
			end)
			
	end)
	MySQL.ready(function()
		MySQL.Async.fetchAll(
			'SELECT name, killed, murders, lossed FROM undead WHERE id = @id',
			{
				['id'] = license
			},
			function(results)
				TriggerClientEvent('JJz:updatePlayerStats', -1, results)

			end)
end)
end

if Config.ZoneTimeout then
	CreateThread(function()
			local elapsed = Config.ZoneTimeout

			while true do
				Wait(1000)

				if elapsed >= Config.ZoneTimeout then
					SetZone('random')
					elapsed = 0
				else
					elapsed = elapsed + 1
				end
			end
	end)
end

if Config.EnableSql then
	CreateThread(function()
		while true do
			Wait(1000)
			UpdateScoreboards()
		--	UpdatePlayerStats()
			
		end
	end)
end

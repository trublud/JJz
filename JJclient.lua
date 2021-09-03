local ZoneBlip = nil
local CurrentZone = nil
local Undead = {}
local Zs = {}
local PPeds = {}
local Disposal = {}

local prev_health = 100

RegisterNetEvent('JJz:setZone')
RegisterNetEvent('JJz:createGuard')
RegisterNetEvent('JJz:updateScoreboard')
RegisterNetEvent('JJz:updateTotalUndeadKilled')
RegisterNetEvent('JJz:messageerror')
RegisterNetEvent('JJz:message')
RegisterNetEvent('JJz:messagealert')

 
RegisterCommand('JJinfest', function(source, args, raw)
  
    for i, v in ipairs(Zs) do 
        if (v.pedid >0) then   DelEnt(v.pedid) end
    end
  
end, false)

AddEventHandler('JJz:createGuard', function(msg)
    createbody()
end)
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if ZoneBlip then RemoveBlip(ZoneBlip) end
        for ped in EnumeratePeds() do
           if  not IsPedAPlayer(ped) then  DelEnt(ped)  end
        end
        RemoveRelationshipGroup('undead')
    end
end)
AddEventHandler('JJz:messagealert', function(msg)
    messagealert(msg)
end)
AddEventHandler('JJz:message', function(msg)
    message(msg)
end)
 AddEventHandler('JJz:messageerror', function(msg)
    messageerror(msg)
end)
AddEventHandler('JJz:updateScoreboard', function(results)
    SendNUIMessage({type = 'updatehp', php =  GetEntityHealth(PlayerPedId())})
    SendNUIMessage({type = 'updatezkills', ps = results[1].killed})
     SendNUIMessage({type = 'updatemissed', ps = results[1].lossed})
     SendNUIMessage({type = 'updatemurders', ps = results[1].murders})
     SendNUIMessage({type = 'updateScoreboard', scores = json.encode(results)})
 
 end)
  AddEventHandler('JJz:updateTotalUndeadKilled', function(total)
     SendNUIMessage({type = 'updateTotalUndeadKilled', total = total})
 end)
 AddEventHandler('JJz:setZone', function(zone)
    if CurrentZone and zone and CurrentZone.name == zone.name then return end

    if ZoneBlip then RemoveBlip(ZoneBlip) end

    ClearPedsInZone(CurrentZone)
    ClearPedsInZone(zone)

    CurrentZone = zone

    if not zone then return end

    if zone.radius then
        ZoneBlip = BlipAddForRadius(Config.ZoneBlipSprite, zone.x, zone.y,
                                    zone.z, zone.radius)
        SetBlipNameFromPlayerString(ZoneBlip, CreateVarString(10,
                                                              'LITERAL_STRING',
                                                              'Undead Infestation'))
        -- exports.notifications:notify('An undead infestation has appeared in ' .. zone.name)
    end
end)









Citizen.CreateThread(function()
    for ped in EnumeratePeds() do
        if not IsPedAPlayer(ped)  then DelEnt(ped) end
    end
  --  SetRandomTrains(true)
    while (true) do
        Citizen.Wait(1)
        for veh in EnumerateVehicles() do
            Citizen.Wait(1)
          if  IsThisModelATrain( GetEntityModel(veh)) then
        local train = veh
        BlipAddForEntity2(4044460928,train, 0.1)
     --   local blip = BlipAddForCoord(4044460928, GetEntityCoords(train))
        SetBlipNameFromPlayerString(blip, "Train") -- Name of the Blip
       -- SetBlipScale(blip, 0.2) -- Scale of the Blip
        blip = RemoveBlip()
        Citizen.Wait(5)
          end
        end
    end  
end)



function updatecounts()
    SendNUIMessage({type = 'updatecount', ps = #PPeds, zs= #Zs, php=GetEntityHealth(PlayerPedId()) })
end
local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

function EnumerateEntities(firstFunc, nextFunc, endFunc)
    return coroutine.wrap(function()
        local iter, id = firstFunc()

        if not id or id == 0 then
            endFunc(iter)
            return
        end

        local enum = {handle = iter, destructor = endFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = nextFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        endFunc(iter)
    end)
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function CreatePed_2(modelHash, x, y, z, heading, isNetwork, thisScriptCheck,
                     p7, p8)
    return Citizen.InvokeNative(0xD49F9B0955C367DE, modelHash, x, y, z, heading,
                                isNetwork, thisScriptCheck, p7, p8)
end

function SetPedDefaultOutfit(ped, p1)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, p1)
end

function SetRandomOutfitVariation(ped, p1)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, p1)
end

function BlipAddForEntity2(blip, entity, scale)
    blippy = Citizen.InvokeNative(0x23f74c2fda6e7c61, blip, entity)
            SetBlipScale(blippy, scale) 
    
    return blippy
 --   return Citizen.InvokeNative(0x23f74c2fda6e7c61, blip, entity)
end

function BlipAddForRadius(blipHash, x, y, z, radius)
    return Citizen.InvokeNative(0x45F13B7E0A15C880, blipHash, x, y, z, radius)
end

function SetBlipNameFromPlayerString(blip, playerString)
    return Citizen.InvokeNative(0x9CB1A1623062F402, blip, playerString)
end

local function removefromTable(tab, val)
    local index = nil
    for i, v in ipairs(tab) do 
        if (v.pedid == val) then   index = i  end
    end
    if index == nil then  else  table.remove(tab, index)   end
end

function removeafter(ped,time)
    Citizen.CreateThread(function()
      if time < 1 then time = 15000 end
          Citizen.Wait(time)
          DelEnt(ped)

        
      end)
end
function DelEnt(entity)
     removefromTable(PPeds, entity)
     removefromTable(Zs, entity)
     removefromTable(Disposal, entity)
     removefromTable(Undead, entity)
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
    SetEntityAsNoLongerNeeded(entity)
   

end

function IsInZone(ped, zone)
    if not zone then return false end

    if not zone.radius then return true end

    local coords = GetEntityCoords(ped)

    return #(coords - vector3(zone.x, zone.y, coords.z)) <= zone.radius
end

function ClearPedsInZone(zone)
    for ped in EnumeratePeds() do
        if not IsPedAPlayer(ped) and IsInZone(ped, zone) then DelEnt(ped) end
    end
end

function IsUndead(ped)
    local model = GetEntityModel(ped)

    for _, undead in ipairs(UndeadPeds) do
        if model == GetHashKey(undead.model) then return true end
    end

    return false
end

function ShouldBecomeUndead(ped)
    if IsPedInGroup(ped) then return false end
    if GetPedRelationshipGroupHash(ped)== GetHashKey('notdead')   then return false end
    if not IsPedHuman(ped) then return false end
    local ped1Coords = GetEntityCoords(ped)
    if GetNearbyPeds(ped, ped1Coords.x, ped1Coords.y, ped1Coords.z, 4) > 2 then return false end
    if not IsInZone(ped, CurrentZone) then return false end

    return true
end

function ShouldCleanUp(ped1)
    local ped1Coords = GetEntityCoords(ped1)

    for _, player in ipairs(GetActivePlayers()) do
        local ped2 = GetPlayerPed(player)
        local ped2Coords = GetEntityCoords(ped2)

        if #(ped1Coords - ped2Coords) <= Config.DespawnDistance then
            return false
        end

        if HasEntityClearLosToEntity(ped2, ped1, 1) then return false end
    end
    removefromTable(PPeds, ped1)
    return true
end

function InRangeofPlayer(ped, distance)
    local ped1Coords = GetEntityCoords(ped)

    local ped2 = PlayerPedId()

    local ped2Coords = GetEntityCoords(ped2)

    if #(ped1Coords - ped2Coords) <= distance then return true end

    return false
end

function HasAnyPlayerLos(ped)
    for _, player in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(player)

        if HasEntityClearLosToEntity(playerPed, ped, 1) then return true end
    end

    return false
end


function GetNearbyPeds(target, X, Y, Z, Radius)
	local NearbyPeds = {}
	if tonumber(X) and tonumber(Y) and tonumber(Z) then
		if tonumber(Radius) then
            for Ped in EnumeratePeds() do
                if not IsPedAPlayer(target) and Ped ~= target then
				if DoesEntityExist(Ped) then
					local PedPosition = GetEntityCoords(Ped, false)
					if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
                    return Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z)
                        --	table.insert(NearbyPeds, Ped)
					end
                end
            end
            return 0
            end
            return 0
        else
            return 0
			
		end
    else
        return 0
		
	end
	return 0
end


function GiveRandomPistolWep (ped)
    hash = GetHashKey( WeaponsPISTOL[math.random(#WeaponsPISTOL)])
  GiveWeaponToPed_2(ped,tonumber(hash),1,true,true,1,false,0.5,1.0,false,0)
  for i, ammohash in ipairs(ammolist) do
      SetPedAmmoByType(ped,GetHashKey(ammohash),10000)    
  end
end
function GiveRandomRifleWep (ped)
    hash = GetHashKey( WeaponsRIFLE[math.random(#WeaponsRIFLE)])
  GiveWeaponToPed_2(ped,tonumber(hash),1,true,true,1,false,0.5,1.0,false,0)
  for i, ammohash in ipairs(ammolist) do
      SetPedAmmoByType(ped,GetHashKey(ammohash),10000)    
  end
end
function GiveRandomSniperWep (ped)
    hash = GetHashKey( WeaponsSNIPER[math.random(#WeaponsSNIPER)])
  GiveWeaponToPed_2(ped,tonumber(hash),1,true,true,1,false,0.5,1.0,false,0)
  for i, ammohash in ipairs(ammolist) do
      SetPedAmmoByType(ped,GetHashKey(ammohash),10000)    
  end
end
function GiveRandomThrowWep (ped)
    hash = GetHashKey( WeaponsTHROW[math.random(#WeaponsTHROW)])
  GiveWeaponToPed_2(ped,tonumber(hash),1,true,true,1,false,0.5,1.0,false,0)
  for i, ammohash in ipairs(ammolist) do
      SetPedAmmoByType(ped,GetHashKey(ammohash),10000)    
  end
end
function GiveRandomMeleeWep (ped)
  	hash = GetHashKey( WeaponsMELEE[math.random(#WeaponsMELEE)])
    GiveWeaponToPed_2(ped,tonumber(hash),1,true,true,1,false,0.5,1.0,false,0)
    for i, ammohash in ipairs(ammolist) do
        SetPedAmmoByType(ped,GetHashKey(ammohash),10000)    
    end
end

function messageerror(msg)
    exports.pNotify:SendNotification({
        text = msg,
        type = "error",
        timeout = math.random(1000, 4000),
        layout = "centerLeft",
        queue = "left"
    })
end
function message(msg)
    exports.pNotify:SendNotification({
        text = msg,
        type = "info",
        timeout = math.random(1000, 4000),
        layout = "topRight",
        queue = "left"
    })
end
function messagealert(msg)
    exports.pNotify:SendNotification({
        text = msg,
        type = "success",
        timeout = math.random(1000, 4000),
        layout = "centerRight",
        queue = "left"
    })
end

function CheckAi()
    for ped in EnumeratePeds() do if InRangeofPlayer(ped,Config.InRangeofPlayer ) then end end

end

local playerdead = false
function PlayerDead(ped)

    if not Disposal[ped] then
        local killer = GetPedSourceOfDeath(ped)
        local thisplayer = PlayerPedId()
        if ped == thisplayer then
            -- this playerdying
            if not playerdead then
                playerdead = true
                if killer == thisplayer then
                    TriggerServerEvent('JJz:playerKilledBySelf')
                    messageerror("Died by Suicide!")

                else -- not by suicide
                    TriggerServerEvent('JJz:playerKilled')
                    messageerror("Died!") -- player died
                end
            end
        end
        if ped ~= thisplayer then -- other player died
            if killer == thisplayer then

                TriggerServerEvent('JJz:playerKilledPvp')
                messageerror("Died by You!")
                Disposal[ped] = ped

            else -- other pelayer died not by you
                messageerror("Died by something else!") -- other player died
                    TriggerServerEvent('JJz:playerKilled')
            end
        end
    end
end

function PedDead(ped)
    local thisplayer = PlayerPedId()
    local killer = GetPedSourceOfDeath(ped)
    if killer == thisplayer then -- you killed innocent
        if not Disposal[ped] then
              TriggerServerEvent('JJz:playerKilledInnocent')
             
            messagealert("Murderer!!")
            removeafter(ped,30000)
            Disposal[ped] = ped
           -- Undead[ped] = true
        end

    else -- not by you

        -- ped died
        if Undead[killer] then
            if not Disposal[ped] then
                messagealert("Zombie Killed Townfolk!") -- Z died
                TriggerServerEvent('JJz:townfolkKilledByUndead')
                removeafter(ped,30000)
                Disposal[ped] = ped
               -- Undead[ped] = true
            end
        else
            if not Disposal[ped] then
                messagealert("Townfolk Died!") -- Z died
                TriggerServerEvent('JJz:townfolkKilled')
                removeafter(ped,30000)
                Disposal[ped] = ped
               -- Undead[ped] = true
            end

        end
    end

    if not Undead[ped] then Undead[ped] = true end
end

function ZDead(ped)
    local thisplayer = PlayerPedId()
    local killer = GetPedSourceOfDeath(ped)
    if killer == thisplayer then -- you killed Z      
        if not Disposal[ped] then
            TriggerServerEvent('JJz:playerKilledUndead')
            messagealert("Killed a  Z!!")
           

            removeafter(ped,30000)
            Disposal[ped] = ped
            Undead[ped] = false

        end

    else -- not by you

        if not PPeds[killer] then
            if not Disposal[ped] then
                message("Zombie Died!") -- Z died
                removeafter(ped,30000)
                Disposal[ped] = ped
                Undead[ped] = false
            end

        else
            if Disposal[ped] then
                       message("Townfolk killed a Zombie!") -- Z died
                       removeafter(ped,30000)
                       Disposal[ped] = ped
                       Undead[ped] = false
            end

        end

    end
  --  Undead[ped] = nil
    SetPedAsNoLongerNeeded(ped)

end

function CheckDead()

    if not IsPedDeadOrDying(PlayerPedId()) then
        playerdead = false
        if Disposal[ped] then Disposal[ped] = nil end
    end
    local thisplayer = PlayerPedId()
    for ped in EnumeratePeds() do
        if IsPedHuman(ped) then -- InRangeofPlayer(ped, 200 ) and 
            if not IsPedDeadOrDying(ped) and IsPedAPlayer(ped) then
                playerdead = false
                Disposal[ped] = nil
            end
            -- if Disposal[ped] then return end
            --   if not IsPedDeadOrDying(ped) then return end
            local pedisz = false
            if Zs[ped] or IsUndead(ped) then
                if not Zs[ped] then   Zs[ped] = ped end
                pedisz = true 
            end
            if IsPedDeadOrDying(ped) then
                --    message("2")
                if IsPedAPlayer(ped) then PlayerDead(ped) end
                if not IsPedAPlayer(ped) then
                    --   message("3")
                    if Undead[ped] or pedisz then -- is a Z 
                        ZDead(ped)
                    else -- is not a Z 
                        PedDead(ped)
                    end
                    -- PedDead(ped)
                end
            end
        end
    end
end

function UpdateUndead(ped)

    CheckDead()
    if IsPedDeadOrDying(ped) then
        if Undead[ped] then
            if GetPedSourceOfDeath(ped) == PlayerPedId() then
           --     TriggerServerEvent('JJz:playerKilledUndead')
            end

            Undead[ped] = nil
        end

        SetPedAsNoLongerNeeded(ped)
    elseif not Undead[ped] then

        Undead[ped] = true

    end
    if ShouldCleanUp(ped) then
        if Disposal[ped]==nil then Disposal[ped] = ped end
        DelEnt(ped)


    end
end

function AddUndeadSpawn(spawns, ped)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local h = GetEntityHeading(ped)
    local hasLos = HasAnyPlayerLos(ped)

    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local model = GetEntityModel(veh)

        if not IsThisModelATrain(model) and not IsThisModelABoat(model) then
            DelEnt(veh)
        end
    end

    if IsPedOnMount(ped) then DelEnt(GetMount(ped)) end

    Wait(0)

    table.insert(spawns,
                 {ped = ped, x = x, y = y, z = z, h = h, hasLos = hasLos})

    DelEnt(ped)
end
function CheckLives(ped)
    local thisplayer = PlayerPedId()
    if IsPedDeadOrDying(ped) then
        local killer = GetPedSourceOfDeath(ped)
        if ped == thisplayer then
            -- player dying
        else

            if PPeds[ped] then
                PPeds[ped].dead = true
                PPeds[ped].lasthp = 0
                PPeds[ped].lasthp = 0
                PPeds[ped].attacker = killer
            else
                -- HOW??
            end

            if killer == thisplayer then -- you killed something
                if PPeds[ped] ~= nil and PPeds[ped].type == "townfolk"  then

                    if not Disposal[ped] then
                        TriggerServerEvent('JJz:playerKilledInnocent')
                        messagealert("Killed a townfolk!!")
                        removeafter(ped, 30000)
                        Disposal[ped] = ped

                    end
                elseif PPeds[ped] ~= nil and PPeds[ped].type == "zombie" then

                    if not Disposal[ped] then
                        TriggerServerEvent('JJz:playerKilledUndead')
                        messagealert("Killed a  Z!!")
                        removeafter(ped, 30000)
                        Disposal[ped] = ped

                    end
                elseif IsPedAPlayer(ped) then
                    TriggerServerEvent('JJz:playerKilledPvp')
                    messagealert("Killed a Player!!!")

                end

            else -- not by you
                if PPeds[killer] ~= nil and PPeds[killer].type == "zombie" then
                    if PPeds[ped].type == "townfolk" then

                        if not Disposal[ped] then
                            --     TriggerServerEvent('JJz:playerKilledInnocent')
                            messagealert("Zombie a townfolk!!")
                            removeafter(ped, 30000)
                            Disposal[ped] = ped

                        end
                    elseif PPeds[ped].type == "zombie" then

                        if not Disposal[ped] then
                            --   TriggerServerEvent('JJz:playerKilledUndead')
                            messagealert("Z V Z!!")
                            removeafter(ped, 30000)
                            Disposal[ped] = ped

                        end
                    elseif isPlayerPed(ped) then
                        --  TriggerServerEvent('JJz:playerKilledPvp')
                        messagealert("Zombie Killed a Player!!!")

                    end
                elseif PPeds[killer] ~= nil and PPeds[killer].type == "townfolk" then
                    if PPeds[ped].type == "zombie" then
                        if not Disposal[ped] then
                            --     TriggerServerEvent('JJz:playerKilledInnocent')
                            messagealert("Townfolk a Zombie!!")
                            removeafter(ped, 30000)
                            Disposal[ped] = ped

                        end
                    elseif PPeds[ped] ~= nil and PPeds[ped].type == "townfolk" then

                        if not Disposal[ped] then
                            --   TriggerServerEvent('JJz:playerKilledUndead')
                            messagealert("Townfolk V Townfolk!!")
                            removeafter(ped, 30000)
                            Disposal[ped] = ped

                        end
                    elseif isPlayerPed(ped) then
                        --   TriggerServerEvent('JJz:playerKilledPvp')
                        messagealert("Townfolk Killed a Player!!!")

                    end

                end
            end
        end

        --  Undead[ped] = nil
        SetPedAsNoLongerNeeded(ped)

    else
        if PPeds[ped] ~= nil then
            if GetEntityHealth(ped) < PPeds[ped].lasthp or
                HasEntityBeenDamagedByAnyPed(ped) then
                -- PED DAMAGED!
                -- HasEntityBeenDamagedByEntity(ped,attacker)
                for k, v in pairs(PPeds) do
                    if k == "pedid" then
                        if HasEntityBeenDamagedByEntity(ped, v) and
                            not PPeds[ped].attacker == ped then
                            -- found attacker  v
                            PPeds[ped].attacker = ped
                            messagealert(v .. " attacked" .. ped)
                        end
                    end

                end
                PPeds[ped].lasthp = GetEntityHealth(ped)
            end
        end
    end
end

function CreateUndeadSpawns()
    local spawns = {}
 

    for ped in EnumeratePeds() do
        local pped = ped
  --      CheckLives(ped)


   
  
       if PPeds[pped] ~= nil then  messagealert(PPeds[pped]) end
  
   
        --    if Disposal[ped] then return end
        Wait(0)
        if not IsPedAPlayer(pped) then 

            if InRangeofPlayer(pped, Config.SpawnDistance) then
            if IsUndead(pped) then

                UpdateUndead(pped)

            elseif ShouldBecomeUndead(pped) then
               
                --  if #Zs > Config.MaxZombies or #PPeds < 25 then
                if not PPeds[pped] == pped or #PPeds < Config.MaxTownfolk  then
                 --   local cped = GetEntityCoords(ped)
                --    cani = GetNearbyPeds(ped, cped.x,cped.y,cped.z, 70 )
                  
              --  if cani > 15 then 
              RemoveAllPedWeapons(pped,true,true)
              
              local randit =  math.random(10) 
              if randit < 7 then GiveRandomMeleeWep(pped) end
              if randit == 7  then GiveRandomThrowWep(pped) end
              if randit == 8  then  GiveRandomPistolWep(pped) end
              if randit == 9  then GiveRandomRifleWep(pped) end
              if randit == 10  then GiveRandomSniperWep(pped) end
  
                    SetEntityMaxHealth(pped, tonumber(Config.TownfolkBaseHealth))
                    SetEntityHealth(pped,tonumber(Config.TownfolkBaseHealth),0)
                    --   SetPedCombatAttributes(pped, 46, 1)
                    --	SetPedCombatAttributes(pped, 5, 1)	
                    SetPedCombatMovement(pped, 3)
                    SetPedAsCop(pped, true)

                    SetAiMeleeWeaponDamageModifier(pped, Config.TownfolkDamage)
                    SetPedHearingRange(pped, Config.MaxAttackRangeTownfolk)
                    SetPedSeeingRange(pped, Config.MaxAttackRangeTownfolk)
                    SetPedRelationshipGroupDefaultHash(pped, 'notdead')
                  
                    SetPedRelationshipGroupHash(pped, 'notdead')

                    SetRelationshipBetweenGroups(6, 'undead', 'notdead')
                    SetRelationshipBetweenGroups(6, 'notdead', 'undead')
                    SetRelationshipBetweenGroups(6, 'undead', PLAYER)
                    SetRelationshipBetweenGroups(6, PLAYER, 'undead')
                    SetRelationshipBetweenGroups(0, 'notdead', PLAYER)
                    SetRelationshipBetweenGroups(0, PLAYER, 'notdead')
                    SetPedAccuracy(pped, SetTownfolkAccuracy)

                    SetBlockingOfNonTemporaryEvents(pped, true)
                    --  SetAmbientVoiceName(pped, "ALIENS")
                    DisablePedPainAudio(pped, true)
                    SetPedCanRagdoll(pped, true)
                    SetPedPathCanUseClimbovers(pped, false)
                    SetPedPathCanUseLadders(pped, false)
                    SetPedPathAvoidFire(pped, false)
                    table.insert(PPeds, {
                        ped = true,
                        pedid = pped,
                        target = 0,
                        attacker = 0,
                        boss = false,
                        busy = false,
                        type = "ped", 
                        inrange = false,
                        dead = false, 
                        lasthp = Config.TownfolkBaseHealth
                    })
                    --      SetPedIsDrunk(pped, true)
                    
                 --   if Config.ShowBlips then
                  --      BlipAddForEntity2(Config.TownfolkBlipSprite, pped, 0.01)
                        
                --    end
                --    messagealert(cani)
                   
               -- end
                else
                    if #Zs < Config.MaxZombies then
                        local cped = GetEntityCoords(pped)
                        cani = GetNearbyPeds(pped, cped.x, cped.y, cped.z, 90)
                    
                        if cani > 15 then
                            --   messagealert(cani)
                            AddUndeadSpawn(spawns, pped)
                        end
                      
                    end
                end
            end
        end
        end

    end

    return spawns
end

function SpawnUndead(spawns)
    for _, spawn in ipairs(spawns) do

        --     if Disposal[spawn.ped] then return end
        if not DoesEntityExist(spawn.ped) and not spawn.hasLos then

            local undead = UndeadPeds[math.random(#UndeadPeds)]
            local model = GetHashKey(undead.model)

            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end

            local ped = CreatePed_2(model, spawn.x, spawn.y, spawn.z, spawn.h,
                                    true, false, false, false)
            SetModelAsNoLongerNeeded(model)

            SetPedOutfitPreset(ped, undead.outfit)

            if Config.ShowBlips then
                BlipAddForEntity2(Config.UndeadBlipSprite, ped, 0.01)
            end

            local walkingStyle = Config.WalkingStyles[math.random(
                                     #Config.WalkingStyles)]
            Citizen.InvokeNative(0x923583741DC87BCE, ped, walkingStyle[1])
            Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, walkingStyle[2])

            Citizen.InvokeNative(0x923583741DC87BCE, ped, walkingStyle[1])

            SetEntityMaxHealth(ped, tonumber(Config.UndeadBaseHealth))
            SetEntityHealth(ped,tonumber(Config.UndeadBaseHealth),0)
            SetPedRelationshipGroupDefaultHash(ped, 'undead')
            SetPedRelationshipGroupHash(ped, 'undead')
            SetRelationshipBetweenGroups(6, 'undead', 'notdead')
            SetRelationshipBetweenGroups(6, 'notdead', 'undead')
            SetRelationshipBetweenGroups(6, 'undead', PLAYER)
            SetRelationshipBetweenGroups(6, PLAYER, 'undead')
            SetPedCombatAttributes(ped, 46, true)
            SetPedFleeAttributes(ped, 0, false)
            SetEntityCanBeDamaged(PlayerPedId(), true)
            SetEntityCanBeDamaged(ped, true)
            SetPedAccuracy(ped, SetZombieAccuracy)
            local randit =  math.random(10) 
            if randit < 7 then GiveRandomMeleeWep(ped) end
            if randit == 7  then GiveRandomThrowWep(ped) end
            if randit == 8  then  GiveRandomPistolWep(ped) end
            if randit == 9  then GiveRandomRifleWep(ped) end
            if randit == 10  then GiveRandomSniperWep(ped) end

                --	SetPedAmmo(ped, 0x63F46DE6, 20) -- springfield
            SetPedHearingRange(ped, Config.MaxAttackRangeZombies)
            SetPedSeeingRange(ped, Config.MaxAttackRangeZombies)
            TaskWanderStandard(ped, 10.0, 10)
            table.insert(Zs, {
                [ped] = ped,
                pedid = ped,
                target = 0,
                attacker = 0,
                boss = false,
                busy = false
            })

            Undead[ped] = true

        end
    end
end

function createbody() -- Function to create the ped

    local undead = UndeadPeds[math.random(#UndeadPeds)]
    local model = GetHashKey(undead.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(1) end

    ploc = GetEntityCoords(PlayerPedId())
    -- CREATE_PED
    local ped --[[ Ped ]] =
        CreatePed(model --[[ Hash ]] , ploc.x --[[ number ]] , ploc.y --[[ number ]] ,
                  ploc.z --[[ number ]] , 0 --[[ number ]] , true --[[ boolean ]] ,
                  false --[[ boolean ]] , false --[[ boolean ]] , false --[[ boolean ]] )

    SetPedOutfitPreset(ped, undead.outfit)

    if Config.ShowBlips then BlipAddForEntity2(0x19365607, ped, 0.01) end

    local walkingStyle =
        Config.WalkingStyles[math.random(#Config.WalkingStyles)]
    Citizen.InvokeNative(0x923583741DC87BCE, ped, walkingStyle[1])

    SetModelAsNoLongerNeeded(model)

    -- SHOTGUN

    GiveWeaponToPed_2(ped, 0x31B7B9FE, 1000, true, true, 1, false, 0.5, 1.0, 1.0,
                      true, 0, 0)
    SetPedAmmo(ped, 0x90083D3B, 2000)

    -- GiveWeaponToPed_2(ped, 0x1086D041, 10, true, true, 1, false, 0.5, 1.0, 1.0,  true, 0, 0) -- JAWBONE KNIFE

    --  GiveWeaponToPed_2(ped, 0x63F46DE6, 1, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)  -- springfield
    --	SetPedAmmo(ped, 0x63F46DE6, 20) -- springfield
    SetPedCombatMovement(ped, 3)
    SetPedAsCop(ped, true)
    SetPedHearingRange(ped, Config.MaxAttackRangeTownfolk)
    SetPedSeeingRange(ped, Config.MaxAttackRangeTownfolk)
    SetPedRelationshipGroupDefaultHash(ped, 'notdead')
    SetPedRelationshipGroupHash(ped, 'notdead')
    SetRelationshipBetweenGroups(6, 'undead', 'notdead')
    SetRelationshipBetweenGroups(6, 'notdead', 'undead')
    SetRelationshipBetweenGroups(6, 'undead', PLAYER)
    SetRelationshipBetweenGroups(6, PLAYER, 'undead')
    SetRelationshipBetweenGroups(1, 'notdead', PLAYER)
    SetRelationshipBetweenGroups(1, PLAYER, 'notdead')
    -- messagealert (GetPedRelationshipGroupHash(ped))
    Citizen.InvokeNative(0x489FFCCCE7392B55, ped, PlayerPedId()) -- Follow
  
end

function createPet() -- Function to create the ped

    local undead = UndeadPeds[math.random(#UndeadPeds)]
    local model = GetHashKey(undead.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(1) end

    entity = CreatePed(model, x, y, b, heading, 1, 1)

    SET_PED_DEFAULT_OUTFIT(model)
    --	SET_BLIP_TYPE( dogspawn[idOfThedog].model )

    -- | SET_ATTRIBUTE_POINTS | --
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 0, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 1, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 2, 1100)
    -- | ADD_ATTRIBUTE_POINTS | --
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 0, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 1, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 2, 1100)
    -- | SET_ATTRIBUTE_BASE_RANK | --
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 0, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 1, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 2, 10)
    -- | SET_ATTRIBUTE_BONUS_RANK | --
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 0, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 1, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 2, 10)
    -- | SET_ATTRIBUTE_OVERPOWER_AMOUNT | --
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 0, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 1, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 2, 5000.0, false)
    SET_PED_DEFAULT_OUTFIT(dogModel)
    SET_BLIP_TYPE(dogModel)

    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 143493179)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -2040077242)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1222652248)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1077299173)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -887307738)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1998572072)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -661858713)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1232372459)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1836932466)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1878159675)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1078461828)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1535431934)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1862763509)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1663301869)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1448293989)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1201903818)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -886193798)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1996978098)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 555364152)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -2020052692)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 707888648)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 378397108)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -350651841)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1538724068)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1030835986)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1919885972)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1976316465)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 841021282)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 889541022)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1329647920)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -319516747)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -767591988)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -989642646)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 1986610512)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(dogModel),
                                 -1683752762)
    Citizen.InvokeNative(0x489FFCCCE7392B55, dogModel, PlayerPedId()) -- Follow
    SetPedAsGroupMember(dogModel, GetPedGroupIndex(PlayerPedId()))

    TaskGoToEntity(idOfThedog, player, -1, 7.2, 2.0, 0, 0)

end






CreateThread(function()
    if IsControlPressed(0, 0xAC4BD4F1) then
        DisableControlAction(0, 0x9CC7A1A4, true)
        DisableControlAction(0, 0xD9D0E1C0, true)
        DisableControlAction(0, 0xD51B784F, true)
        end
    AddRelationshipGroup('undead')
    AddRelationshipGroup('notdead')
    SetPedRelationshipGroupDefaultHash(PlayerPedId(), 'notdead')
    SetPedRelationshipGroupHash(PlayerPedId(), 'notdead')

    SetRelationshipBetweenGroups(6, 'undead', 'notdead')
    SetRelationshipBetweenGroups(6, 'notdead', 'undead')
    SetRelationshipBetweenGroups(6, 'undead', PLAYER)
    SetRelationshipBetweenGroups(6, PLAYER, 'undead')
    SetRelationshipBetweenGroups(0, 'notdead', PLAYER)
    SetRelationshipBetweenGroups(0, PLAYER, 'notdead')


    ExecuteCommand("JJui")
    TriggerServerEvent('JJz:newPlayer')
   
    updatecounts()
        CheckDead()
        CheckAi()
        if CurrentZone then
            local spawns = CreateUndeadSpawns()
            SpawnUndead(spawns)
        end
    
end)

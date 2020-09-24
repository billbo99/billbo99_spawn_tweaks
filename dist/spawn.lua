local Gui = require("scripts.gui")
local Spawn = {}

-- helper function

local function split(source, delimiters)
    local elements = {}
    local pattern = "([^" .. delimiters .. "]+)"
    string.gsub(
        source,
        pattern,
        function(value)
            elements[#elements + 1] = value
        end
    )
    return elements
end

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

-- Flush the players ammo / gun inventory
function Spawn.ClearPlayerInventories(player)
    if player.get_inventory(defines.inventory.character_ammo) then
        player.get_inventory(defines.inventory.character_ammo).clear()
    end
    if player.get_inventory(defines.inventory.character_guns) then
        player.get_inventory(defines.inventory.character_guns).clear()
    end
end

-- On new player created setup some default gear
function Spawn.GiveGear(event)
    local player = game.get_player(event.player_index)

    Spawn.ClearPlayerInventories(player)

    if settings.get_player_settings(player)["billbo99-respawn-with-primary_gun"] and global.SpawnItems["primary_gun"] then
        player.insert {name = global.SpawnItems["primary_gun"], count = 1}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-primary_ammo"] and global.SpawnItems["primary_ammo"] then
        player.insert {name = global.SpawnItems["primary_ammo"], count = settings.global["billbo99-primary_ammo_starting_amount"].value}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-secondary_gun"] and global.SpawnItems["secondary_gun"] then
        player.insert {name = global.SpawnItems["secondary_gun"], count = 1}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-secondary_ammo"] and global.SpawnItems["secondary_ammo"] then
        player.insert {name = global.SpawnItems["secondary_ammo"], count = settings.global["billbo99-secondary_ammo_starting_amount"].value}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-capsule"] and global.SpawnItems["capsule"] then
        player.insert {name = global.SpawnItems["capsule"], count = settings.global["billbo99-capsule_starting_amount"].value}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-armor"] and global.SpawnItems["armor"] then
        player.insert {name = global.SpawnItems["armor"], count = 1}
    end
end

-- Once a minute check to see what has been made and change the default spawn gear
local function InitCheckList()
    local Checks = {primary_gun = {}, secondary_gun = {}, primary_ammo = {}, secondary_ammo = {}, armor = {}, capsule = {}}

    for i = 1, 100 do
        Checks.primary_gun[i] = {}
        Checks.primary_ammo[i] = {}
        Checks.secondary_gun[i] = {}
        Checks.secondary_ammo[i] = {}
        Checks.armor[i] = {}
        Checks.capsule[i] = {}
    end
    Checks.primary_gun[1] = {what_type = "primary_gun", what = "pistol", what_name = "Pistol", done = false}
    Checks.primary_gun[10] = {what_type = "primary_gun", what = "submachine-gun", what_name = "Submachine Gun", done = false}

    Checks.primary_ammo[1] = {what_type = "primary_ammo", what = "firearm-magazine", what_name = "Firearms rounds magazine", done = false}
    Checks.primary_ammo[10] = {what_type = "primary_ammo", what = "piercing-rounds-magazine", what_name = "Piercing rounds magazine", done = false}
    Checks.primary_ammo[20] = {what_type = "primary_ammo", what = "uranium-rounds-magazine", what_name = "Uranium rounds magazine", done = false}

    Checks.secondary_gun[1] = {what_type = "secondary_gun", what = "shotgun", what_name = "Shotgun", done = false}
    Checks.secondary_gun[10] = {what_type = "secondary_gun", what = "flamethrower", what_name = "Flame Thrower", done = false}
    Checks.secondary_gun[20] = {what_type = "secondary_gun", what = "combat-shotgun", what_name = "Combat Shotgun", done = false}
    Checks.secondary_gun[30] = {what_type = "secondary_gun", what = "rocket-launcher", what_name = "Rocket Launcher", done = false}

    Checks.secondary_ammo[1] = {what_type = "secondary_ammo", what = "shotgun-shell", what_name = "Shotgun shells", done = false}
    Checks.secondary_ammo[10] = {what_type = "secondary_ammo", what = "flamethrower-ammo", what_name = "Flame Thrower ammo", done = false}
    Checks.secondary_ammo[20] = {what_type = "secondary_ammo", what = "piercing-shotgun-shell", what_name = "Piercing Shotgun shells", done = false}
    Checks.secondary_ammo[30] = {what_type = "secondary_ammo", what = "rocket", what_name = "Rocket", done = false}
    Checks.secondary_ammo[40] = {what_type = "secondary_ammo", what = "explosive-rocket", what_name = "Explosive Rocket", done = false}

    Checks.capsule[1] = {what_type = "capsule", what = "grenade", what_name = "Grenade", done = false}
    Checks.capsule[10] = {what_type = "capsule", what = "defender-capsule", what_name = "Defender Capsule", done = false}
    Checks.capsule[20] = {what_type = "capsule", what = "poison-capsule", what_name = "Poison Capsule", done = false}
    Checks.capsule[30] = {what_type = "capsule", what = "slowdown-capsule", what_name = "Slowdown Capsule", done = false}
    Checks.capsule[40] = {what_type = "capsule", what = "distractor-capsule", what_name = "Distractor Capsule", done = false}
    Checks.capsule[50] = {what_type = "capsule", what = "cluster-grenade", what_name = "Cluster Grenade", done = false}
    Checks.capsule[60] = {what_type = "capsule", what = "destroyer-capsule", what_name = "Destroyer Capsule", done = false}

    Checks.armor[1] = {what_type = "armor", what = "light-armor", what_name = "Light Armor", done = false}
    Checks.armor[10] = {what_type = "armor", what = "heavy-armor", what_name = "Heavy Armor", done = false}
    Checks.armor[20] = {what_type = "armor", what = "modular-armor", what_name = "Modular Armor", done = false}

    if game and game.active_mods["akimbo-weapons"] then
        Checks.primary_gun[5] = {what_type = "primary_gun", what = "apistol", what_name = "Akimbo Pistol", done = false}
        Checks.primary_gun[15] = {what_type = "primary_gun", what = "asmg", what_name = "Akimbo Submachine Gun", done = false}

        Checks.secondary_gun[5] = {what_type = "secondary_gun", what = "ashotgun", what_name = "Akimbo Shotgun", done = false}
        Checks.secondary_gun[25] = {what_type = "secondary_gun", what = "acombat-shotgun", what_name = "Akimbo Combat Shotgun", done = false}
    end

    if game and game.active_mods["Krastorio2"] then
        Checks.primary_ammo[5] = {what_type = "primary_ammo", what = "rifle-magazine", what_name = "Rifle magazine", done = false}
        Checks.primary_ammo[15] = {what_type = "primary_ammo", what = "armor-piercing-rifle-magazine", what_name = "Armor piercing rifle magazine", done = false}
        Checks.primary_ammo[25] = {what_type = "primary_ammo", what = "uranium-rifle-magazine", what_name = "Uranium rifle magazine", done = false}

        Checks.secondary_gun[5] = {what_type = "secondary_gun", what = "anti-material-rifle", what_name = "Anti-material rifle", done = false}
        Checks.secondary_ammo[5] = {what_type = "secondary_ammo", what = "anti-material-rifle-magazine", what_name = "Anti-material rifle magazine", done = false}
        Checks.secondary_ammo[6] = {what_type = "secondary_ammo", what = "armor-piercing-anti-material-rifle-magazine", what_name = "Armor piercing anti-material rifle magazine", done = false}
    end

    return Checks
end

function Spawn.OnTickDoCheckForSpawnGear()
    global.SpawnItems.Checks = InitCheckList()

    global.SpawnItems.primary_gun_threshold = settings.global["billbo99-primary_gun_threshold"].value
    global.SpawnItems.secondary_gun_threshold = settings.global["billbo99-secondary_gun_threshold"].value
    global.SpawnItems.primary_ammo_threshold = settings.global["billbo99-primary_ammo_threshold"].value
    global.SpawnItems.secondary_ammo_threshold = settings.global["billbo99-secondary_ammo_threshold"].value
    global.SpawnItems.armor_threshold = settings.global["billbo99-armor_threshold"].value
    global.SpawnItems.capsule_threshold = settings.global["billbo99-capsule_threshold"].value

    local flag = false
    for k, force in pairs(game.forces) do
        local produced = force["item_production_statistics"].input_counts
        -- for each type do a check  (gun/ammo/armor)
        for k1, _ in pairs(global.SpawnItems.Checks) do
            -- for each item under that type see which one we should be using
            local old_what_type = global.SpawnItems[k1]
            for _, v2 in pairs(global.SpawnItems.Checks[k1]) do
                if produced[v2.what] and produced[v2.what] > global.SpawnItems[v2.what_type .. "_threshold"] then
                    global.SpawnItems[v2.what_type] = v2.what
                    global.SpawnItems[v2.what_type .. "_name"] = v2.what_name
                end
            end
            if old_what_type ~= global.SpawnItems[k1] then
                flag = true
            end
        end

        if settings.global["billbo99-get-starting-gear"].value then
            if not global.SpawnItems.primary_gun_name then
                global.SpawnItems["primary_gun"] = global.SpawnItems.Checks.primary_gun[1].what
                global.SpawnItems["primary_gun_name"] = global.SpawnItems.Checks.primary_gun[1].what_name
            end
            if not global.SpawnItems.primary_ammo_name then
                global.SpawnItems["primary_ammo"] = global.SpawnItems.Checks.primary_ammo[1].what
                global.SpawnItems["primary_ammo_name"] = global.SpawnItems.Checks.primary_ammo[1].what_name
            end
        end

        if flag then
            local list = {}
            if global.SpawnItems.armor_name then
                table.insert(list, global.SpawnItems.armor_name)
            end
            if global.SpawnItems.primary_gun_name then
                table.insert(list, global.SpawnItems.primary_gun_name)
            end
            if global.SpawnItems.primary_ammo_name then
                table.insert(list, global.SpawnItems.primary_ammo_name)
            end
            if global.SpawnItems.secondary_gun_name then
                table.insert(list, global.SpawnItems.secondary_gun_name)
            end
            if global.SpawnItems.secondary_ammo_name then
                table.insert(list, global.SpawnItems.secondary_ammo_name)
            end
            if global.SpawnItems.capsule_name then
                table.insert(list, global.SpawnItems.capsule_name)
            end
            force.print("Clones will now receive the following on respawn; " .. table.concat(list, ", "), global.print_colour)
        end
    end
end

function Spawn.OnConfigurationChanged(e)
    if e.mod_changes and e.mod_changes["billbo99_spawn_tweaks"] then
        Spawn.OnInit()
    end
end

-- Init the mod
function Spawn.OnInit()
    global.print_colour = {r = 255, g = 255, b = 0}
    global.SpawnTimer = global.SpawnTimer or {}
    global.SpawnItems = global.SpawnItems or {}
    global.queue = global.queue or {}
    global.surprise = global.surprise or {flag = false, chance = 10}

    -- global.SpawnItems.DeathCount = {}
    global.SpawnItems.Checks = InitCheckList()

    global.SpawnItems.primary_gun = global.SpawnItems.primary_gun or nil
    global.SpawnItems.primary_gun_name = global.SpawnItems.primary_gun_name or nil
    global.SpawnItems.primary_gun_priority = global.SpawnItems.primary_gun_priority or 0

    global.SpawnItems.primary_ammo = global.SpawnItems.primary_ammo or nil
    global.SpawnItems.primary_ammo_name = global.SpawnItems.primary_ammo_name or nil
    global.SpawnItems.primary_ammo_priority = global.SpawnItems.primary_ammo_priority or 0

    global.SpawnItems.secondary_gun = global.SpawnItems.secondary_gun or nil
    global.SpawnItems.secondary_gun_name = global.SpawnItems.secondary_gun_name or nil
    global.SpawnItems.secondary_gun_priority = global.SpawnItems.secondary_gun_priority or 0

    global.SpawnItems.secondary_ammo = global.SpawnItems.secondary_ammo or nil
    global.SpawnItems.secondary_ammo_name = global.SpawnItems.secondary_ammo_name or nil
    global.SpawnItems.secondary_ammo_priority = global.SpawnItems.secondary_ammo_priority or 0

    global.SpawnItems.capsule = global.SpawnItems.capsule or nil
    global.SpawnItems.capsule_name = global.SpawnItems.capsule_name or nil
    global.SpawnItems.capsule_priority = global.SpawnItems.capsule_priority or nil

    global.SpawnItems.armor = global.SpawnItems.armor or nil
    global.SpawnItems.armor_name = global.SpawnItems.armor_name or nil
    global.SpawnItems.armor_priority = global.SpawnItems.armor_priority or 0
end

-- Register default commands
function Spawn.OnLoad()
end

function Spawn.OnRuntimeModSettingChanged(event)
    local setting = event.setting

    if not starts_with(setting, "billbo99") then
        return
    end -- not a setting we care about presently

    -- lazy time
    global.SpawnItems.primary_gun_threshold = settings.global["billbo99-primary_gun_threshold"].value
    global.SpawnItems.secondary_gun_threshold = settings.global["billbo99-secondary_gun_threshold"].value
    global.SpawnItems.primary_ammo_threshold = settings.global["billbo99-primary_ammo_threshold"].value
    global.SpawnItems.secondary_ammo_threshold = settings.global["billbo99-secondary_ammo_threshold"].value
    global.SpawnItems.armor_threshold = settings.global["billbo99-armor_threshold"].value
end

function Spawn.Recalculate(event)
    local player = game.get_player(event.player_index)
    if not player.admin then
        player.print("Your not an admin")
        return
    end

    global.SpawnItems.Checks = InitCheckList()
    Spawn.OnTickDoCheckForSpawnGear()
end

function Spawn.Reprint(event)
    local player = game.get_player(event.player_index)

    local list = {}
    if global.SpawnItems.armor_name then
        table.insert(list, global.SpawnItems.armor_name)
    end
    if global.SpawnItems.primary_gun_name then
        table.insert(list, global.SpawnItems.primary_gun_name)
    end
    if global.SpawnItems.primary_ammo_name then
        table.insert(list, global.SpawnItems.primary_ammo_name)
    end
    if global.SpawnItems.secondary_gun_name then
        table.insert(list, global.SpawnItems.secondary_gun_name)
    end
    if global.SpawnItems.secondary_ammo_name then
        table.insert(list, global.SpawnItems.secondary_ammo_name)
    end
    player.print("Clones will now receive the following on respawn; " .. table.concat(list, ", "), global.print_colour)
end

function Spawn.RespawnTime(event)
    local player = game.get_player(event.player_index)
    local params = event.parameter

    -- If param sent assume we are given a player name to search for
    local target_player = player
    if params then
        for _, p in pairs(game.players) do
            if p.name == params then
                target_player = p
            end
        end
    end

    if global.SpawnTimer[target_player.name] then
        game.print(string.format("%s current respawn timers is set at %d seconds", target_player.name, math.ceil(global.SpawnTimer[target_player.name] / 60)))
    end
end

function Spawn.OnPlayerCreated(event)
    local player = game.get_player(event.player_index)
    Spawn.OnTickDoCheckForSpawnGear()
    Spawn.GiveGear(event)
    player.print(settings.global["billbo99-welcome"].value, global.print_colour)
end

function Spawn.OnPlayerRespawned(event)
    local player = game.get_player(event.player_index)
    global.SpawnItems.Checks = InitCheckList()
    Spawn.OnTickDoCheckForSpawnGear()

    Spawn.GiveGear(event)

    if settings.global["billbo99-extra-respawn-gear"].value then
        local items = split(settings.global["billbo99-extra-respawn-gear"].value, " +")
        for _, item in pairs(items) do
            local parts = split(item, ":")
            if game.item_prototypes[parts[1]] and type(tonumber(parts[2])) == "number" then
                player.insert {name = parts[1], count = tonumber(parts[2])}
            end
        end
    end

    player.print(settings.global["billbo99-respawn"].value, global.print_colour)
end

function Spawn.OnTickDoCoolDown()
    local default_respawn_time = 10 * 60

    local prototypes = game.get_filtered_entity_prototypes({{filter = "type", type = "character"}})
    for _, prototype in pairs(prototypes) do
        if prototype.name == "character" then
            default_respawn_time = prototype.respawn_time * 60
        end
    end

    for _, player in pairs(game.connected_players) do
        if global.SpawnTimer[player.name] and player.ticks_to_respawn == nil then
            global.SpawnTimer[player.name] = global.SpawnTimer[player.name] - settings.global["billbo99-respawn-cooldown"].value
            if global.SpawnTimer[player.name] < default_respawn_time then
                global.SpawnTimer[player.name] = default_respawn_time
            end
        end
    end
end

function Spawn.OnPlayerDied(event)
    -- event.name
    -- event.tick
    -- event.player_index
    -- event.cause
    local player = game.players[event.player_index]
    if global.SpawnTimer[player.name] then
        global.SpawnTimer[player.name] = global.SpawnTimer[player.name] * settings.global["billbo99-respawn-multiplyer"].value
    else
        global.SpawnTimer[player.name] = player.character.prototype.respawn_time * 60
    end

    -- game.print("OnPlayerDied " .. tostring(player.ticks_to_respawn))
    player.ticks_to_respawn = global.SpawnTimer[player.name]

    if global.SpawnTimer[player.name] then
        player.print(string.format("%s current respawn timers is set at %d seconds", player.name, math.ceil(global.SpawnTimer[player.name] / 60)), global.print_colour)
        if global.SpawnTimer[player.name] > 10 * 60 then
            player.print("A cooldown is in effect enter /RespawnTime on the console to see how much it has been reduced")
        end
    end

    if global.surprise.flag and math.random(100) <= global.surprise.chance then
        local future_tick = game.tick + player.ticks_to_respawn + 10
        Gui.ScheduleTash(future_tick, {name = "CreateGui", player = player.name})
    end
end

return Spawn

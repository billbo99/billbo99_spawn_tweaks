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
    local force = player.force
    local ref = global.SpawnForceItems[force.name]

    Spawn.ClearPlayerInventories(player)

    if settings.get_player_settings(player)["billbo99-respawn-with-primary_gun"] and ref["primary_gun"] then
        player.insert {name = ref["primary_gun"], count = 1}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-primary_ammo"] and ref["primary_ammo"] then
        player.insert {name = ref["primary_ammo"], count = settings.global["billbo99-primary_ammo_starting_amount"].value}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-secondary_gun"] and ref["secondary_gun"] then
        player.insert {name = ref["secondary_gun"], count = 1}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-secondary_ammo"] and ref["secondary_ammo"] then
        player.insert {name = ref["secondary_ammo"], count = settings.global["billbo99-secondary_ammo_starting_amount"].value}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-capsule"] and ref["capsule"] then
        player.insert {name = ref["capsule"], count = settings.global["billbo99-capsule_starting_amount"].value}
    end

    if settings.get_player_settings(player)["billbo99-respawn-with-armor"] and ref["armor"] then
        player.insert {name = ref["armor"], count = 1}
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

    if game and game.active_mods["SchmindustrialRevolution"] then
        Checks.primary_ammo[5] = {what_type = "primary_ammo", what = "copper-magazine", what_name = "Copper magazine", done = false}
        Checks.primary_ammo[15] = {what_type = "primary_ammo", what = "iron-magazine", what_name = "Iron magazine", done = false}
        Checks.primary_ammo[25] = {what_type = "primary_ammo", what = "steel-magazine", what_name = "Steel magazine", done = false}
        Checks.primary_ammo[35] = {what_type = "primary_ammo", what = "titanium-magazine", what_name = "Titanium magazine", done = false}
        Checks.primary_ammo[45] = {what_type = "primary_ammo", what = "uranium-magazine", what_name = "Depleted uranium magazine", done = false}

        Checks.secondary_ammo[5] = {what_type = "secondary_ammo", what = "copper-catridge", what_name = "Copper cartridge", done = false}
        Checks.secondary_ammo[15] = {what_type = "secondary_ammo", what = "iron-catridge", what_name = "Iron cartridge", done = false}
        Checks.secondary_ammo[15] = {what_type = "secondary_ammo", what = "steel-catridge", what_name = "Steel cartridge", done = false}
        Checks.secondary_ammo[15] = {what_type = "secondary_ammo", what = "titanium-catridge", what_name = "Titanium cartridge", done = false}
        Checks.secondary_ammo[15] = {what_type = "secondary_ammo", what = "uranium -catridge", what_name = "Depleted uranium cartridge", done = false}
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
    for _, force in pairs(game.forces) do
        local ref = global.SpawnForceItems[force.name]

        ref.Checks = InitCheckList()

        ref.primary_gun_threshold = settings.global["billbo99-primary_gun_threshold"].value
        ref.secondary_gun_threshold = settings.global["billbo99-secondary_gun_threshold"].value
        ref.primary_ammo_threshold = settings.global["billbo99-primary_ammo_threshold"].value
        ref.secondary_ammo_threshold = settings.global["billbo99-secondary_ammo_threshold"].value
        ref.armor_threshold = settings.global["billbo99-armor_threshold"].value
        ref.capsule_threshold = settings.global["billbo99-capsule_threshold"].value

        local flag = false
        local produced = force["item_production_statistics"].input_counts
        -- for each type do a check  (gun/ammo/armor)
        for k1, _ in pairs(ref.Checks) do
            -- for each item under that type see which one we should be using
            local old_what_type = ref[k1]
            for _, v2 in pairs(ref.Checks[k1]) do
                if produced[v2.what] and produced[v2.what] > ref[v2.what_type .. "_threshold"] then
                    ref[v2.what_type] = v2.what
                    ref[v2.what_type .. "_name"] = v2.what_name
                end
            end
            if old_what_type ~= ref[k1] then
                flag = true
            end
        end

        if settings.global["billbo99-get-starting-gear"].value then
            if not ref.primary_gun_name then
                ref["primary_gun"] = ref.Checks.primary_gun[1].what
                ref["primary_gun_name"] = ref.Checks.primary_gun[1].what_name
            end
            if not ref.primary_ammo_name then
                ref["primary_ammo"] = ref.Checks.primary_ammo[1].what
                ref["primary_ammo_name"] = ref.Checks.primary_ammo[1].what_name
            end
        end

        if flag then
            local list = {}
            if ref.armor_name then
                table.insert(list, ref.armor_name)
            end
            if ref.primary_gun_name then
                table.insert(list, ref.primary_gun_name)
            end
            if ref.primary_ammo_name then
                table.insert(list, ref.primary_ammo_name)
            end
            if ref.secondary_gun_name then
                table.insert(list, ref.secondary_gun_name)
            end
            if ref.secondary_ammo_name then
                table.insert(list, ref.secondary_ammo_name)
            end
            if ref.capsule_name then
                table.insert(list, ref.capsule_name)
            end

            local msg = "Clones will now receive the following on respawn; "
            if force.name ~= "player" then
                msg = "Clones from the force (" .. force.name .. ") will now receive the following on respawn; "
            end
            force.print(msg .. table.concat(list, ", "), global.print_colour)
        end
    end
    log("Spawn.OnTickDoCheckForSpawnGear Completed")
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
    global.SpawnForceItems = global.SpawnForceItems or {}
    global.surprise = global.surprise or {flag = false, chance = 10}

    for _, force in pairs(game.forces) do
        if global.SpawnForceItems[force.name] == nil then
            global.SpawnForceItems[force.name] = {}
        end

        local ref = global.SpawnForceItems[force.name]
        ref.Checks = InitCheckList()

        ref.primary_gun = ref.primary_gun or nil
        ref.primary_gun_name = ref.primary_gun_name or nil
        ref.primary_gun_priority = ref.primary_gun_priority or 0

        ref.primary_ammo = ref.primary_ammo or nil
        ref.primary_ammo_name = ref.primary_ammo_name or nil
        ref.primary_ammo_priority = ref.primary_ammo_priority or 0

        ref.secondary_gun = ref.secondary_gun or nil
        ref.secondary_gun_name = ref.secondary_gun_name or nil
        ref.secondary_gun_priority = ref.secondary_gun_priority or 0

        ref.secondary_ammo = ref.secondary_ammo or nil
        ref.secondary_ammo_name = ref.secondary_ammo_name or nil
        ref.secondary_ammo_priority = ref.secondary_ammo_priority or 0

        ref.capsule = ref.capsule or nil
        ref.capsule_name = ref.capsule_name or nil
        ref.capsule_priority = ref.capsule_priority or nil

        ref.armor = ref.armor or nil
        ref.armor_name = ref.armor_name or nil
        ref.armor_priority = ref.armor_priority or 0
    end
    log("Spawn.OnInit Complete")
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
    for _, force in pairs(game.forces) do
        local ref = global.SpawnForceItems[force.name]
        ref.primary_gun_threshold = settings.global["billbo99-primary_gun_threshold"].value
        ref.secondary_gun_threshold = settings.global["billbo99-secondary_gun_threshold"].value
        ref.primary_ammo_threshold = settings.global["billbo99-primary_ammo_threshold"].value
        ref.secondary_ammo_threshold = settings.global["billbo99-secondary_ammo_threshold"].value
        ref.armor_threshold = settings.global["billbo99-armor_threshold"].value
    end
end

function Spawn.Recalculate(event)
    local player = game.get_player(event.player_index)
    local force = player.force
    if not player.admin then
        player.print("Your not an admin")
        return
    end

    global.SpawnForceItems[force.name].Checks = InitCheckList()
    Spawn.OnTickDoCheckForSpawnGear()
end

function Spawn.Reprint(event)
    local player = game.get_player(event.player_index)
    local force = player.force
    local ref = global.SpawnForceItems[force.name]

    local list = {}
    if ref.armor_name then
        table.insert(list, ref.armor_name)
    end
    if ref.primary_gun_name then
        table.insert(list, ref.primary_gun_name)
    end
    if ref.primary_ammo_name then
        table.insert(list, ref.primary_ammo_name)
    end
    if ref.secondary_gun_name then
        table.insert(list, ref.secondary_gun_name)
    end
    if ref.secondary_ammo_name then
        table.insert(list, ref.secondary_ammo_name)
    end
    player.print(force.name)
    local msg = "Clones will now receive the following on respawn; "
    if force.name ~= "player" then
        msg = "Clones from the force (" .. force.name .. ") will now receive the following on respawn; "
    end
    player.print(msg .. table.concat(list, ", "), global.print_colour)
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
    local force = player.force
    global.SpawnForceItems[force.name].Checks = InitCheckList()
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
end

return Spawn

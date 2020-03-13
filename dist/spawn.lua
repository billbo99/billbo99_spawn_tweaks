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

local function getKeysSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(
        keys,
        function(a, b)
            return sortFunction(tbl[a], tbl[b])
        end
    )
    return keys
end

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function DeathCountSummary(PlayerName)
    local total = 0
    for _, count in pairs(global.SpawnItems.DeathCount[PlayerName] or {}) do
        total = total + count
    end
    return total
end

-- Flush the players ammo / gun inventory
function Spawn.ClearPlayerInventories(player)
    player.get_inventory(defines.inventory.character_ammo).clear()
    player.get_inventory(defines.inventory.character_guns).clear()
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

    if settings.get_player_settings(player)["billbo99-respawn-with-armor"] and global.SpawnItems["armor"] then
        player.insert {name = global.SpawnItems["armor"], count = 1}
    end
end

-- Once a minute check to see what has been made and change the default spawn gear
local function InitCheckList()
    local Checks = {primary_gun = {}, secondary_gun = {}, primary_ammo = {}, secondary_ammo = {}, armor = {}}

    for i = 1, 100 do
        Checks.primary_gun[i] = {}
        Checks.primary_ammo[i] = {}
        Checks.secondary_gun[i] = {}
        Checks.secondary_ammo[i] = {}
        Checks.armor[i] = {}
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

    Checks.armor[1] = {what_type = "armor", what = "light-armor", what_name = "Light Armor", done = false}
    Checks.armor[10] = {what_type = "armor", what = "heavy-armor", what_name = "Heavy Armor", done = false}
    Checks.armor[20] = {what_type = "armor", what = "modular-armor", what_name = "Modular Armor", done = false}

    if game and game.active_mods["akimbo-weapons"] then
        Checks.primary_gun[5] = {what_type = "primary_gun", what = "apistol", what_name = "Akimbo Pistol", done = false}
        Checks.primary_gun[15] = {what_type = "primary_gun", what = "asmg", what_name = "Akimbo Submachine Gun", done = false}

        Checks.secondary_gun[5] = {what_type = "secondary_gun", what = "ashotgun", what_name = "Akimbo Shotgun", done = false}
        Checks.secondary_gun[25] = {what_type = "secondary_gun", what = "acombat-shotgun", what_name = "Akimbo Combat Shotgun", done = false}
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
            force.print("Clones will now receive the following on respawn; " .. table.concat(list, ", "), global.print_colour)
        end
    end
end

-- Init the mod
function Spawn.OnInit()
    log("Spawn.OnInit")

    global.print_colour = {r = 255, g = 255, b = 0}
    global.SpawnItems = global.SpawnItems or {}

    global.SpawnItems.DeathCount = {}
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

    global.SpawnItems.armor = global.SpawnItems.armor or nil
    global.SpawnItems.armor_name = global.SpawnItems.armor_name or nil
    global.SpawnItems.armor_priority = global.SpawnItems.armor_priority or 0

    Spawn.OnLoad()
end

-- Register default commands
function Spawn.OnLoad()
    log("Spawn.OnLoad")
    -- global.SpawnItems.Checks = InitCheckList()
end

function Spawn.OnRuntimeModSettingChanged(event)
    -- local player = game.get_player(event.player_index)
    local setting = event.setting

    -- local setting_type = event.setting_type
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

function Spawn.OnPlayerDied(event)
    local PlayerName = game.get_player(event.player_index).name

    local cause = "reasons unknown"
    if event.cause then
        cause = event.cause.name
    end

    if cause == "character" then
        if event.cause.player and event.cause.player.name then
            if event.cause.player.name == PlayerName then
                cause = "suicide"
            else
                cause = "player/" .. event.cause.player.name
            end
        end
    end

    if not global.SpawnItems.DeathCount[PlayerName] then
        global.SpawnItems.DeathCount[PlayerName] = {}
    end
    if not global.SpawnItems.DeathCount[PlayerName][cause] then
        global.SpawnItems.DeathCount[PlayerName][cause] = 0
    end
    global.SpawnItems.DeathCount[PlayerName][cause] = global.SpawnItems.DeathCount[PlayerName][cause] + 1
end

function Spawn.DeathCountStats(event)
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

    local PlayerName = target_player.name
    local sortedKeys =
        getKeysSortedByValue(
        global.SpawnItems.DeathCount[PlayerName] or {},
        function(a, b)
            return a > b
        end
    )

    game.print(string.format("Player %s has died %d time(s) to the following causes", PlayerName, DeathCountSummary(PlayerName)))
    for _, key in ipairs(sortedKeys) do
        local msg
        if key == "suicide" then
            msg = string.format("[img=entity.character] (suicide) -- %d", global.SpawnItems.DeathCount[PlayerName][key])
        elseif key == "reasons unknown" then
            msg = string.format("reasons unknown -- %d", global.SpawnItems.DeathCount[PlayerName][key])
        elseif starts_with(key, "player") then
            msg = string.format("[img=entity.character] (%s) -- %d", split(key, "/")[2], global.SpawnItems.DeathCount[PlayerName][key])
        else
            msg = string.format("[img=entity.%s] -- %d", key, global.SpawnItems.DeathCount[PlayerName][key])
        end

        game.print(msg)
    end
end

function Spawn.OnPlayerCreated(event)
    local player = game.get_player(event.player_index)
    Spawn.GiveGear(event)
    player.print(settings.global["billbo99-welcome"].value, global.print_colour)
end

function Spawn.OnPlayerRespawned(event)
    local player = game.get_player(event.player_index)
    global.SpawnItems.Checks = InitCheckList()
    Spawn.OnTickDoCheckForSpawnGear()

    Spawn.GiveGear(event)
    player.print(settings.global["billbo99-respawn"].value, global.print_colour)
    player.print(string.format("You have died .. %d .. time(s) .. /DeathCountStats .. for some fun stats", DeathCountSummary(player.name)))
end

return Spawn
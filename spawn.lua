local Spawn = {}
local Checks = {primary_gun = {}, secondary_gun = {}, primary_ammo = {}, secondary_ammo = {}, armor = {}}

-- helper function
local function starts_with(str, start)
    return str:sub(1, #start) == start
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

function Spawn.OnPlayerCreated(event)
    local player = game.get_player(event.player_index)
    Spawn.GiveGear(event)
    player.print({"messages.billbo99-welcome"}, global.print_colour)
end

function Spawn.OnPlayerRespawned(event)
    local player = game.get_player(event.player_index)
    Spawn.GiveGear(event)
    player.print({"messages.billbo99-respawn"}, global.print_colour)
end

-- Once a minute check to see what has been made and change the default spawn gear
local function InitCheckList()
    if not Checks then
        Checks = {primary_gun = {}, secondary_gun = {}, primary_ammo = {}, secondary_ammo = {}, armor = {}}
    end

    for i = 1, 1000 do
        Checks.primary_gun[i] = {}
        Checks.primary_ammo[i] = {}
        Checks.secondary_gun[i] = {}
        Checks.secondary_ammo[i] = {}
        Checks.armor[i] = {}
    end

    Checks.primary_gun[001] = {what_type = "primary_gun", what = "pistol", what_name = "Pistol", done = false}
    Checks.primary_gun[100] = {what_type = "primary_gun", what = "submachine-gun", what_name = "Submachine Gun", done = false}

    Checks.primary_ammo[001] = {what_type = "primary_ammo", what = "firearm-magazine", what_name = "Firearms rounds magazine", done = false}
    Checks.primary_ammo[100] = {what_type = "primary_ammo", what = "piercing-rounds-magazine", what_name = "Piercing rounds magazine", done = false}
    Checks.primary_ammo[200] = {what_type = "primary_ammo", what = "uranium-rounds-magazine", what_name = "Uranium rounds magazine", done = false}

    Checks.secondary_gun[001] = {what_type = "secondary_gun", what = "shotgun", what_name = "Shotgun", done = false}
    Checks.secondary_gun[100] = {what_type = "secondary_gun", what = "flamethrower", what_name = "Flame Thrower", done = false}
    Checks.secondary_gun[200] = {what_type = "secondary_gun", what = "combat-shotgun", what_name = "Combat Shotgun", done = false}
    Checks.secondary_gun[300] = {what_type = "secondary_gun", what = "rocket-launcher", what_name = "Rocket Launcher", done = false}

    Checks.secondary_ammo[001] = {what_type = "secondary_ammo", what = "shotgun-shell", what_name = "Shotgun shells", done = false}
    Checks.secondary_ammo[100] = {what_type = "secondary_ammo", what = "flamethrower-ammo", what_name = "Flame Thrower ammo", done = false}
    Checks.secondary_ammo[200] = {what_type = "secondary_ammo", what = "piercing-shotgun-shell", what_name = "Piercing Shotgun shells", done = false}
    Checks.secondary_ammo[300] = {what_type = "secondary_ammo", what = "rocket", what_name = "Rocket", done = false}
    Checks.secondary_ammo[400] = {what_type = "secondary_ammo", what = "explosive-rocket", what_name = "Explosive Rocket", done = false}
    -- Checks.secondary_ammo[500] = {what_type = "secondary_ammo", what = "atomic-rocket", what_name = "Atomic Rocket", done = false}

    Checks.armor[001] = {what_type = "armor", what = "light-armor", what_name = "Light Armor", done = false}
    Checks.armor[100] = {what_type = "armor", what = "heavy-armor", what_name = "Heavy Armor", done = false}
    Checks.armor[200] = {what_type = "armor", what = "modular-armor", what_name = "Modular Armor", done = false}
    -- Checks.armor[300] = {what_type = "armor", what = "power-armor", what_name = "Power Armor", done = false}
    -- Checks.armor[400] = {what_type = "armor", what = "power-armor-mk2", what_name = "Power Armor MK2", done = false}

    if game and game.active_mods["akimbo-weapons"] then
        Checks.primary_gun[050] = {what_type = "primary_gun", what = "apistol", what_name = "Akimbo Pistol", done = false}
        Checks.primary_gun[150] = {what_type = "primary_gun", what = "asmg", what_name = "Akimbo Submachine Gun", done = false}

        Checks.secondary_gun[050] = {what_type = "secondary_gun", what = "ashotgun", what_name = "Akimbo Shotgun", done = false}
        Checks.secondary_gun[250] = {what_type = "secondary_gun", what = "acombat-shotgun", what_name = "Akimbo Combat Shotgun", done = false}
    end

    return Checks
end

function Spawn.OnTickDoCheckForSpawnGear()
    if not Checks then
        Checks = InitCheckList()
    end

    global.SpawnItems.primary_gun_threshold = settings.global["billbo99-primary_gun_threshold"].value
    global.SpawnItems.secondary_gun_threshold = settings.global["billbo99-secondary_gun_threshold"].value
    global.SpawnItems.primary_ammo_threshold = settings.global["billbo99-primary_ammo_threshold"].value
    global.SpawnItems.secondary_ammo_threshold = settings.global["billbo99-secondary_ammo_threshold"].value
    global.SpawnItems.armor_threshold = settings.global["billbo99-armor_threshold"].value

    local flag = false
    for k, force in pairs(game.forces) do
        local produced = force["item_production_statistics"].input_counts
        for k1, _ in pairs(Checks) do
            for k2, v2 in pairs(Checks[k1]) do
                if produced[v2.what] and produced[v2.what] > global.SpawnItems[v2.what_type .. "_threshold"] then
                    if global.SpawnItems[v2.what_type] ~= v2.what then
                        global.SpawnItems[v2.what_type] = v2.what
                        global.SpawnItems[v2.what_type .. "_name"] = v2.what_name
                        Checks[k1][k2] = nil
                        flag = true
                    end
                end
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
    Checks = global.SpawnItems.Checks or InitCheckList()
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

return Spawn

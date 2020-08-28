data:extend(
    {
        -- runtime-per-user
        {name = "billbo99-respawn-with-primary_gun", type = "bool-setting", default_value = "true", setting_type = "runtime-per-user", order = "0100"},
        {name = "billbo99-respawn-with-primary_ammo", type = "bool-setting", default_value = "true", setting_type = "runtime-per-user", order = "0110"},
        {name = "billbo99-respawn-with-secondary_gun", type = "bool-setting", default_value = "true", setting_type = "runtime-per-user", order = "0200"},
        {name = "billbo99-respawn-with-secondary_ammo", type = "bool-setting", default_value = "true", setting_type = "runtime-per-user", order = "0210"},
        {name = "billbo99-respawn-with-armor", type = "bool-setting", default_value = "true", setting_type = "runtime-per-user", order = "0300"},
        {name = "billbo99-respawn-with-capsule", type = "bool-setting", default_value = "true", setting_type = "runtime-per-user", order = "0400"},
        -- runtime-global
        {name = "billbo99-get-starting-gear", type = "bool-setting", default_value = "true", setting_type = "runtime-global", order = "0010"},
        {name = "billbo99-extra-respawn-gear", type = "string-setting", default_value = "", allow_blank = true, setting_type = "runtime-global", order = "0020"},
        {name = "billbo99-primary_gun_threshold", type = "int-setting", default_value = 15, setting_type = "runtime-global", order = "0100"},
        {name = "billbo99-primary_ammo_threshold", type = "int-setting", default_value = 50, setting_type = "runtime-global", order = "0150"},
        {name = "billbo99-primary_ammo_starting_amount", type = "int-setting", default_value = 20, setting_type = "runtime-global", order = "0160"},
        {name = "billbo99-secondary_gun_threshold", type = "int-setting", default_value = 15, setting_type = "runtime-global", order = "0200"},
        {name = "billbo99-secondary_ammo_threshold", type = "int-setting", default_value = 50, setting_type = "runtime-global", order = "0250"},
        {name = "billbo99-secondary_ammo_starting_amount", type = "int-setting", default_value = 20, setting_type = "runtime-global", order = "0260"},
        {name = "billbo99-armor_threshold", type = "int-setting", default_value = 15, setting_type = "runtime-global", order = "0300"},
        {name = "billbo99-capsule_threshold", type = "int-setting", default_value = 50, setting_type = "runtime-global", order = "0400"},
        {name = "billbo99-capsule_starting_amount", type = "int-setting", default_value = 5, setting_type = "runtime-global", order = "0410"},
        {name = "billbo99-welcome", type = "string-setting", default_value = "Welcome to the map", setting_type = "runtime-global", order = "0900"},
        {name = "billbo99-respawn", type = "string-setting", default_value = "Cloning complete ... have a nice day", setting_type = "runtime-global", order = "0901"},
        {name = "billbo99-respawn-multiplyer", type = "double-setting", default_value = 2, minimum_value = 1, setting_type = "runtime-global", order = "0902"},
        {name = "billbo99-respawn-cooldown", type = "int-setting", default_value = 10, setting_type = "runtime-global", order = "0903"},
        -- startup
        {name = "billbo99-player_corpse_life", type = "int-setting", default_value = 15, setting_type = "startup", order = "0100"},
        {name = "billbo99-biter_corpse_life", type = "int-setting", default_value = 5, setting_type = "startup", order = "0200"},
        {name = "billbo99-healing_per_tick", type = "double-setting", default_value = 0.15, minimum_value = 0, setting_type = "startup", order = "0300"}, -- 9hp per second
        {name = "billbo99-ticks_to_stay_in_combat", type = "int-setting", default_value = 600, minimum_value = 0, setting_type = "startup", order = "0400"}, -- 10 seconds default
        {name = "billbo99-damage_hit_tint_r", type = "int-setting", default_value = -1, minimum_value = -1, maximum_value = 255, setting_type = "startup", order = "0500"}, -- default 1
        {name = "billbo99-damage_hit_tint_g", type = "int-setting", default_value = -1, minimum_value = -1, maximum_value = 255, setting_type = "startup", order = "0501"}, -- default 0
        {name = "billbo99-damage_hit_tint_b", type = "int-setting", default_value = -1, minimum_value = -1, maximum_value = 255, setting_type = "startup", order = "0502"}, -- default 0
        {name = "billbo99-damage_hit_tint_a", type = "int-setting", default_value = -1, minimum_value = -1, maximum_value = 255, setting_type = "startup", order = "0503"} -- default 0
    }
)

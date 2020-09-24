require "prototypes.style"
require "prototypes.sounds"

local biter_corpse_time = settings.startup["billbo99-biter_corpse_life"].value * 60 * 60
local player_corpse_time = settings.startup["billbo99-player_corpse_life"].value * 60 * 60

for _, corpse in pairs(data.raw["corpse"]) do
    if corpse.time_before_removed == 54000 and corpse.subgroup == "corpses" then
        corpse.time_before_removed = biter_corpse_time
    end
end

data.raw["character-corpse"]["character-corpse"].time_to_live = player_corpse_time

local character = data.raw["character"]["character"]
if character["healing_per_tick"] then
    character["healing_per_tick"] = settings.startup["billbo99-healing_per_tick"].value
end
if character["ticks_to_stay_in_combat"] then
    character["ticks_to_stay_in_combat"] = settings.startup["billbo99-ticks_to_stay_in_combat"].value
end

local color = character["damage_hit_tint"]
if settings.startup["billbo99-damage_hit_tint_r"].value >= 0 then
    color.r = settings.startup["billbo99-damage_hit_tint_r"].value
end
if settings.startup["billbo99-damage_hit_tint_g"].value >= 0 then
    color.g = settings.startup["billbo99-damage_hit_tint_g"].value
end
if settings.startup["billbo99-damage_hit_tint_b"].value >= 0 then
    color.b = settings.startup["billbo99-damage_hit_tint_b"].value
end
if settings.startup["billbo99-damage_hit_tint_a"].value >= 0 then
    color.a = settings.startup["billbo99-damage_hit_tint_a"].value
end

if character["damage_hit_tint"] then
    character["damage_hit_tint"] = color
end

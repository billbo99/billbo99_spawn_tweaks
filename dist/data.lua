local biter_corpse_time = settings.startup["billbo99-biter_corpse_life"].value * 60 * 60
local player_corpse_time = settings.startup["billbo99-player_corpse_life"].value * 60 * 60

for _, corpse in pairs(data.raw["corpse"]) do
    if corpse.time_before_removed == 54000 and corpse.subgroup == "corpses" then
        corpse.time_before_removed = biter_corpse_time
    end
end

data.raw["character-corpse"]["character-corpse"].time_to_live = player_corpse_time

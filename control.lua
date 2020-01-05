local Spawn = require("spawn")

script.on_init(Spawn.OnInit)
script.on_load(Spawn.OnLoad)

script.on_nth_tick(1800, Spawn.OnTickDoCheckForSpawnGear)

script.on_event(defines.events.on_player_created, Spawn.OnPlayerCreated)
script.on_event(defines.events.on_player_respawned, Spawn.OnPlayerRespawned)
script.on_event(defines.events.on_runtime_mod_setting_changed, Spawn.OnRuntimeModSettingChanged)

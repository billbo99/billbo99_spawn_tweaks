local Spawn = require("spawn")

local function RegisterCommands()
    commands.remove_command("spawn_recalculate")
    commands.add_command("spawn_recalculate", "Recalculate spawn gear", Spawn.Recalculate)

    commands.remove_command("spawn_reprint_message")
    commands.add_command("spawn_reprint_message", "Reprint spawn gear", Spawn.Reprint)

    commands.remove_command("RespawnTime")
    commands.add_command("RespawnTime", "RespawnTime [player_name]", Spawn.RespawnTime)
end

local function OnStartup()
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_skip_intro", true)

    Spawn.OnInit()
    RegisterCommands()
end

local function OnLoad()
    Spawn.OnLoad()
    RegisterCommands()
end

local function OnConfigurationChanged(e)
    Spawn.OnConfigurationChanged(e)
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_nth_tick(1800, Spawn.OnTickDoCheckForSpawnGear)
script.on_nth_tick(60, Spawn.OnTickDoCoolDown)
script.on_configuration_changed(OnConfigurationChanged)

script.on_event(defines.events.on_player_died, Spawn.OnPlayerDied)
script.on_event(defines.events.on_player_created, Spawn.OnPlayerCreated)
script.on_event(defines.events.on_player_respawned, Spawn.OnPlayerRespawned)
script.on_event(defines.events.on_runtime_mod_setting_changed, Spawn.OnRuntimeModSettingChanged)

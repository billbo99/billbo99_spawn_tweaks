local Gui = require("scripts.gui")
local Spawn = require("spawn")

local function ParseQueue(e)
    if e.tick > 60 then
        for idx, jobs in pairs(global.queue) do
            if idx < game.tick then
                for _, job in pairs(jobs) do
                    if job.name == "DestroyGui" then
                        Gui.DestroyGui(game.get_player(job.player))
                    end
                    if job.name == "CreateGui" then
                        Gui.CreateGui(game.get_player(job.player))
                    end
                end
                global.queue[idx] = nil
            end
        end
    end
end

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

local function On60thTick(e)
    Spawn.OnTickDoCoolDown(e)
    ParseQueue(e)
end

script.on_event(
    defines.events.on_player_joined_game,
    function(e)
        Gui.DestroyGui(game.players[e.player_index])
    end
)

commands.add_command(
    "surprise",
    "surprise [player]",
    function(event)
        local player = game.players[event.player_index]
        if player.admin then
            if event.parameter then
                player = game.get_player(event.parameter)
                if player then
                    Gui.CreateGui(game.get_player(event.parameter))
                else
                    if event.parameter == "auto" then
                        global.surprise.flag = not global.surprise.flag
                    elseif tonumber(event.parameter) > 0 and tonumber(event.parameter) <= 100 then
                        global.surprise.chance = tonumber(event.parameter)
                    end
                end
            else
                Gui.CreateGui(game.get_player(player.name))
            end
        else
            player.print("Only admins can run this command")
        end
    end
)

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_nth_tick(1800, Spawn.OnTickDoCheckForSpawnGear)
script.on_nth_tick(60, On60thTick)
script.on_configuration_changed(OnConfigurationChanged)

script.on_event(defines.events.on_cutscene_cancelled, OnStartup)
script.on_event(defines.events.on_player_died, Spawn.OnPlayerDied)
script.on_event(defines.events.on_player_created, Spawn.OnPlayerCreated)
script.on_event(defines.events.on_player_respawned, Spawn.OnPlayerRespawned)
script.on_event(defines.events.on_runtime_mod_setting_changed, Spawn.OnRuntimeModSettingChanged)

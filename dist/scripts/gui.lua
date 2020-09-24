local Gui = {}

function Gui.ScheduleTash(tick, data)
    if global.queue[tick] == nil then
        global.queue[tick] = {}
    end
    table.insert(global.queue[tick], data)
end

function Gui.DestroyGui(player)
    local gui_top = player.gui.screen["JumpScare"]

    if gui_top ~= nil then
        gui_top.destroy()
    end
end

function Gui.CreateGui(player)
    if player then
        Gui.DestroyGui(player)
        local main_frame =
            player.gui.screen.add(
            {
                type = "frame",
                name = "JumpScare",
                caption = "",
                direction = "vertical",
                style = "JumpScareFrameStyle"
            }
        )
        main_frame.force_auto_center()
        main_frame.style.left_padding = 0
        main_frame.style.right_padding = 0
        main_frame.style.top_padding = 0
        main_frame.style.bottom_padding = 0
        main_frame.add {type = "sprite", style = "JumpScareImageStyle", sprite = "JumpScareSprite"}

        player.surface.play_sound {path = "scream", position = player.position}

        Gui.ScheduleTash(game.tick + (4 * 60), {name = "DestroyGui", player = player.name})
    end
end

return Gui

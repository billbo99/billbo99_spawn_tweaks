-- local function make_image(unique_name, filename, width, height)
--     data.raw["gui-style"]["default"][unique_name] = {
--         width = width,
--         height = height,
--         type = "button_style",
--         horizontal_align = "center",
--         vertical_align = "center",
--         stretch_image_to_widget_size = true,
--         clicked_graphical_set = {filename = filename, scale = 1, width = width, height = height},
--         default_graphical_set = {filename = filename, scale = 1, width = width, height = height},
--         disabled_graphical_set = {filename = filename, scale = 1, width = width, height = height},
--         hovered_graphical_set = {filename = filename, scale = 1, width = width, height = height}
--     }
-- end

-- make_image("surprise", "__billbo99_spawn_tweaks__/graphics/unnamed.png", 1024, 500)
-- make_image("surprise2", "__billbo99_spawn_tweaks__/graphics/unnamed_1440p.png", 2560, 1440)

data:extend(
    {
        {
            type = "sprite",
            name = "JumpScareSprite",
            filename = "__billbo99_spawn_tweaks__/graphics/unnamed.png",
            width = 1024,
            height = 500
        }
    }
)

data.raw["gui-style"]["default"]["JumpScareFrameStyle"] = {
    type = "frame_style",
    horizontal_align = "center",
    vertical_align = "center",
    horizontally_stretchable = "on",
    vertically_stretchable = "on",
    horizontally_squashable = "on",
    vertically_squashable = "on"
}

data.raw["gui-style"]["default"]["JumpScareImageStyle"] = {
    type = "image_style",
    top_padding = -4,
    bottom_padding = -4,
    right_padding = -4,
    left_padding = -4,
    horizontal_align = "center",
    vertical_align = "center",
    horizontally_stretchable = "on",
    vertically_stretchable = "on",
    horizontally_squashable = "on",
    vertically_squashable = "on",
    filename = "__billbo99_spawn_tweaks__/graphics/unnamed.png",
    width = 2048,
    height = 1100,
    scalable = true,
    stretch_image_to_widget_size = true
}

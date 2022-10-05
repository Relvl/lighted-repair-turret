local mod_gui = require("mod-gui")

script.on_init(function()
    for _, player in pairs(game.players) do
        JeiMainButton(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    JeiMainButton(game.players[event.player_index])
end)

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.valid and event.element.name == "jei_main_button" then
        local player = game.players[event.player_index]
        player.print("JEI main button!")
    end
end)

function JeiMainButton(player)
    local buttonflow = mod_gui.get_button_flow(player)
    local button = buttonflow.jei_main_button or
        buttonflow.add {
            type = "sprite-button",
            name = "jei_main_button",
            sprite = "virtual-signal/jei_main_button",
            tooltip = "test tooltip!",
            visible = true
        }
    return button
end

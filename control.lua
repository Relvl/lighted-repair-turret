-- Отношение турели к столбу. См data-updates.lua
local turret_to_pole_map = {}
turret_to_pole_map["repair-turret-pole"] = "lighted-big-electric-pole-lrt"
turret_to_pole_map["repair-turret-substation"] = "lighted-substation-lrt"

script.on_event(
    { defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive },
    function(event)
        local entity = event.created_entity or event.entity
        if entity then
            for turret, _ in pairs(turret_to_pole_map) do
                if entity.name == turret then
                    local player = game.players[event.player_index]
                    local pole = entity.surface.create_entity {
                        name = turret_to_pole_map[entity.name],
                        position = entity.position,
                        force = entity.force,
                        player = player,
                        raise_built = true
                    }
                    pole.destructible = false
                    pole.minable = false
                end
            end
        end
    end)

script.on_event(
    { defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.on_entity_died,
        defines.events.script_raised_destroy },
    function(event)
        for turret, pole in pairs(turret_to_pole_map) do
            if event.entity.name == turret then
                local center = event.entity.position
                local nearbyPoles = event.entity.surface.find_entities_filtered {
                    position = event.entity.position,
                    radius = 1,
                    name = pole
                }
                for _, entity in pairs(nearbyPoles) do
                    entity.destroy { raise_destroy = true }
                end
            end
        end
    end
)

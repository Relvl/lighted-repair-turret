-- Отношение турели к столбу, чтобы не искать долго. См data-updates.lua
local turret_to_pole_map = {}
turret_to_pole_map["repair-turret-pole"] = "lighted-big-electric-pole-lrt"
turret_to_pole_map["repair-turret-substation"] = "lighted-substation-lrt"
-- Отношение столба к турели, чтобы не искать долго. См data-updates.lua
local pole_to_turret_map = {}
for turret, pole in pairs(turret_to_pole_map) do pole_to_turret_map[pole] = turret end

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

-- todo! Так как основная энтити у нас - это столб, а турель маскируется под столб, то при открытии столба - открываем турель, и наоборот.
--[[ local requested_open_gui = nil
script.on_event({ defines.events.on_gui_opened }, function(event)
    if requested_open_gui then
        requested_open_gui = nil
        return
    end
    local player = game.players[event.player_index]
    local entity = event.entity
    if player and entity and event.gui_type == 1 then
        local counterpart_name = turret_to_pole_map[entity.name] or pole_to_turret_map[entity.name]
        if counterpart_name then
            local counterparts = entity.surface.find_entities_filtered { position = entity.position, radius = 1,
                name = counterpart_name, limit = 1 }
            if counterparts and counterparts[1] then
                requested_open_gui = counterparts[1].name
                player.opened = counterparts[1]
            end
        end
    end
end)
]]

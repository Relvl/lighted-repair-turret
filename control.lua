local const = require("util.const")

-- Отношение турели к столбу, чтобы не искать долго. См data-updates.lua
local turret_to_pole_map = {}
-- Отношение столба к турели, чтобы не искать долго. См data-updates.lua
local pole_to_turret_map = {}
for _, variant in pairs(const.variants) do
    turret_to_pole_map["repair-turret-" .. variant] = "lighted-" .. variant .. "-lrt"
    pole_to_turret_map["lighted-" .. variant .. "-lrt"] = "repair-turret-" .. variant
end

script.on_event(
    { defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive },
    function(event)
        local entity = event.created_entity or event.entity
        if not entity then return end

        local to_build = pole_to_turret_map[entity.name]
        if not to_build then return end

        local player = event.player_index and game.players[event.player_index] or nil
        entity.surface.create_entity {
            name = to_build,
            position = entity.position,
            force = entity.force,
            player = player,
            raise_built = true
        }
    end)

script.on_event(
    { defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.on_entity_died,
        defines.events.script_raised_destroy },
    function(event)
        local entity = event.entity
        if not entity then return end

        -- При удалении турели из скрипта - ничего не удаляем
        if event.name == defines.events.script_raised_destroy and turret_to_pole_map[entity.name] then return end

        local to_remove = turret_to_pole_map[entity.name] or pole_to_turret_map[entity.name]
        if not to_remove then return end

        local nearbyPoles = event.entity.surface.find_entities_filtered {
            position = event.entity.position,
            radius = 1,
            name = to_remove
        }
        for _, nearby in pairs(nearbyPoles) do
            nearby.destroy { raise_destroy = true }
        end
    end
)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    -- todo понять как проверить, что _берет_ игрок, и если это столбы - то брать турель.
    -- Тогда можно будет и за центр поднимать.
end)

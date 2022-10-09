local const = require("util.const")

-- Отношение турели к столбу, чтобы не искать долго. См data-updates.lua
local turret_to_pole_map = {}
-- Отношение столба к турели, чтобы не искать долго. См data-updates.lua
local pole_to_turret_map = {}
for _, variant in pairs(const.variants) do
    if const.rt_remote_present then
        turret_to_pole_map["repair-turret-" .. variant] = "lighted-" .. variant .. "-lrt"
        pole_to_turret_map["lighted-" .. variant .. "-lrt"] = "repair-turret-" .. variant
    else
        turret_to_pole_map["repair-turret" .. variant] = "lighted-" .. variant .. "-lrt"
        pole_to_turret_map["lighted-" .. variant .. "-lrt"] = "repair-turret"
    end
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
        if event.name == defines.events.script_raised_destroy and
            (turret_to_pole_map[entity.name] or entity.name == const.rt) then return end

        local to_remove = turret_to_pole_map[entity.name] or pole_to_turret_map[entity.name]

        -- Если Klonan еще не выкатил правку, добавляющую интерфейс - удаляем все столбы ниже обычной турели
        if entity.name == const.rt and not const.rt_remote_present then
            to_remove = {}
            for key, _ in pairs(pole_to_turret_map) do
                table.insert(to_remove, key)
            end
        end

        if not to_remove then return end

        local nearbyPoles = event.entity.surface.find_entities_filtered {
            position = event.entity.position,
            radius = 1,
            name = to_remove
        }

        if nearbyPoles[1] and event.player_index and not const.rt_remote_present then
            event.buffer.clear()
            for _, e in pairs(nearbyPoles) do
                for _, product in pairs(e.prototype.mineable_properties.products) do
                    event.buffer.insert({ name = product.name, count = product.amount or 1 --[[@as uint]] })
                end
            end
        end

        for _, nearby in pairs(nearbyPoles) do
            nearby.destroy { raise_destroy = true }
        end
    end
)

script.on_init(function()
end)
script.on_load(function()
    const.rt_remote_call()
end)

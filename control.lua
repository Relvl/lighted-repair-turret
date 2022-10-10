local const = require("util.const")
local flib_migration = require("__flib__.migration")

-- Отношение турели к столбу, чтобы не искать долго. См data-updates.lua
local turret_to_pole_map = {}
-- Отношение столба к турели, чтобы не искать долго. См data-updates.lua
local pole_to_turret_map = {}

local pole_to_item_map = {}

local pole_names = {}

for _, variant in pairs(const.variants) do
    local pole_name = "lighted-" .. variant .. "-lrt"
    if const.rt_remote_present then
        turret_to_pole_map["repair-turret-" .. variant] = pole_name
        pole_to_turret_map[pole_name] = "repair-turret-" .. variant
    else
        turret_to_pole_map["repair-turret" .. variant] = pole_name
        pole_to_turret_map[pole_name] = "repair-turret"
    end
    pole_to_item_map[pole_name] = "repair-turret-" .. variant
    table.insert(pole_names, pole_name)
end

script.on_event(
    { defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive },
    function(event)
        local entity = event.created_entity or event.entity
        if not entity then return end

        -- При размещении призраков, если размещены одновременно столб и турель - турель сносим. Порция костылей из-за лени @Klonan
        if entity.name == "entity-ghost" then
            if pole_to_turret_map[entity.ghost_name] then
                local nearest_turret_ghost = entity.surface.find_entities_filtered {
                    name = "entity-ghost",
                    ghost_name = const.rt,
                    position = entity.position,
                    radius = 1
                }
                for _, nearest in pairs(nearest_turret_ghost) do
                    nearest.destroy()
                end
                return
            end
        end

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

        if not const.rt_remote_present and nearbyPoles[1] and nearbyPoles[1].name ~= const.rt then
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

script.on_event(defines.events.on_player_pipette, function(event)
    if event.item then
        local counterpart = pole_to_item_map[event.item.name]
        if counterpart then
            local player = game.players[event.player_index]
            local inventory = player.get_main_inventory()
            if player and inventory then
                if not player.is_cursor_empty() then
                    -- Удаляем неразрешенные предметы, либо очищаем курсор в инвентарь
                    if pole_to_turret_map[player.cursor_stack.name] then
                        player.cursor_stack.clear()
                    else
                        player.clear_cursor()
                    end
                end
                local counter_stack = inventory.find_item_stack(counterpart)
                if counter_stack then
                    player.cursor_stack.transfer_stack(counter_stack)
                end
            end
        end
    end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
    if not event.entity then return end
    if not const.rt_remote_present and event.entity.name == const.rt then
        local nearest_poles = event.entity.surface.find_entities_filtered {
            name = pole_names,
            position = event.entity.position,
            radius = 1
        }
        if nearest_poles[1].name then
            for _, player in pairs(game.players) do
                event.entity.cancel_deconstruction(player.force)
            end
        end
    end
end)

script.on_load(function()
    const.rt_remote_call()
end)

require("migration")

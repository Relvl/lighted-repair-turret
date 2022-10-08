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
        local pole_name = turret_to_pole_map[entity.name]
        if not pole_name then return end
        local player = event.player_index and game.players[event.player_index] or nil
        entity.surface.create_entity {
            name = pole_name,
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
        -- При удалении столба из скрипта - ничего не удаляем
        if event.name == defines.events.script_raised_destroy and pole_to_turret_map[entity.name] then return end
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

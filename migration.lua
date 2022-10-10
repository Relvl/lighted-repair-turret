local event = require("__flib__.event")
local migration = require("__flib__.migration")
local const = require("util.const")

local migrations = {
    -- each function will be run when upgrading from a version older than it
    ["0.1.0"] = function()
        log("LRT: migration from 0.1.0 started...")
        local poles_fixed = 0
        for surf_name, surface in pairs(game.surfaces) do
            for _, variant in pairs(const.variants) do
                local all_mod_poles = surface.find_entities_filtered { name = "lighted-" .. variant .. "-lrt" }
                for _, pole_entity in pairs(all_mod_poles) do
                    local nearest_turret = surface.find_entities_filtered {
                        type = "roboport",
                        position = pole_entity.position,
                        radius = 1
                    }

                    if not nearest_turret[1] then
                        log("LRT: Adding missing turret @ " ..
                            surf_name .. "-> [" .. pole_entity.position.x .. "," .. pole_entity.position.y .. "]")

                        local player = pole_entity.force.players[1]
                        surface.create_entity {
                            name = const.rt,
                            position = pole_entity.position,
                            force = pole_entity.force,
                            player = player,
                            raise_built = true
                        }
                        poles_fixed = poles_fixed + 1
                    end
                end
            end
        end
        if poles_fixed > 0 then
            for _, player in pairs(game.players) do
                player.print("Lighted Repair Turret: Migration to 0.1.0 finished, fixed " ..
                    poles_fixed .. " missing turrets.")
            end
        end
    end,
}

event.on_configuration_changed(function(e)
    migration.on_config_changed(e--[[@as ConfigurationChangedData]] , migrations)
end)

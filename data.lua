local flib = require('__flib__.data-util')
local const = require("util.const")
local find_variant_technology_info = require("util.find_variant_technology_info")

local function make_variant_prototypes(variant)
    local name = "repair-turret-" .. variant
    -- Проверяем, что вариант имеет предмет и он столб
    if not data.raw.item[variant] or not data.raw["electric-pole"][variant] then return end

    -- Копии прототипов столбов. LPP+ сдалает из них освещенные столбы, которые будут создаваться при установке ремонтных турелей. Затем эти прототипы удалятся в data-updates.lua
    local tempPoleItem = flib.copy_prototype(data.raw.item[variant], variant .. "-lrt", false)
    local tempPole = flib.copy_prototype(data.raw["electric-pole"][variant], variant .. "-lrt", false)
    tempPoleItem.place_result = tempPole.name
    tempPoleItem.flags = { "hidden" }
    local c = tempPole.collision_box[2][1] / 2
    tempPole.selection_box = { { -c, -c }, { c, c } }
    tempPole.collision_mask = { "resource-layer" }
    tempPole.working_sound = nil
    tempPole.selection_priority = 60
    tempPole.minable = { result = tempPoleItem.name, mining_time = data.raw.roboport[const.rt].minable.mining_time }
    tempPole.maximum_wire_distance = settings.startup.repair_turret_range.value + 1
    tempPole.flags = { "not-blueprintable", "not-deconstructable", "no-copy-paste", "placeable-neutral", "not-upgradable" }

    local itemTurret = flib.copy_prototype(data.raw.item[const.rt], name, false)
    itemTurret.icons = flib.create_icons(itemTurret, { const.lighted_icon })
    itemTurret.order = "b[turret]-az[repair-turret]-az[" .. name .. "]"
    itemTurret.localised_name = { name }

    local entityTurret = flib.copy_prototype(data.raw.roboport[const.rt], name, false)

    local tech_unit, prerequisites, cable_count = find_variant_technology_info(variant, "repair-turret-lightning")

    local technology = {
        type = "technology",
        name = name,
        localised_name = { name },
        icon_size = 182,
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        effects = { { type = "unlock-recipe", recipe = name } },
        prerequisites = prerequisites,
        unit = tech_unit,
        order = "c-k-a",
    }

    local recipe = {
        type = "recipe",
        name = name,
        localised_name = { name },
        enabled = false,
        energy_required = 20,
        ingredients = {
            { const.rt, 1 },
            { "copper-cable", cable_count },
            { "lighted-" .. variant, 1 }
        },
        result = name,
    }

    return tempPoleItem, tempPole, itemTurret, entityTurret, technology, recipe
end

local tech_unit, prerequisites = find_variant_technology_info("small-lamp", const.rt)
data:extend({
    -- Базовая технология - ничего не открывает. Чисто для усложнения.
    { type = "technology",
        name = "repair-turret-lightning",
        localised_name = { "repair-turret-lightning" },
        icon_size = 182,
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        prerequisites = prerequisites,
        unit = tech_unit,
        order = "c-k-a" }
})

local dataTable = {}
for _, variant in pairs(const.variants) do
    for _, prototype in pairs({ make_variant_prototypes(variant) }) do
        table.insert(dataTable, prototype)
    end
end

data:extend(dataTable)

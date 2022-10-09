local flib = require('__flib__.data-util')
local const = require("util.const")
local find_variant_technology_info = require("util.find_variant_technology_info")

local function make_variant_prototypes(variant)
    local name = "repair-turret-" .. variant
    -- Проверяем, что вариант имеет предмет и он столб
    if not data.raw.item[variant] or not data.raw["electric-pole"][variant] then return end

    -- Основная энтити - это столб. Так что создаем предмет и энтити настоящего столба,
    -- LPP+ создаст для них версии с лампой, потом удалим и предмет и энтитю.
    -- Использовать будем именно LPP+ варианты.
    -- Турель теперь будет либо не видна, либо только анимацию оставлю, "шоп красиво".
    -- Провода всё-таки должны быть оставлены "как было" - на непрямых поворотах это жопа. Да и в чанки плохо вписывается.

    -- Временные заготовки для "лампофикации"
    local tempPoleItem = flib.copy_prototype(data.raw.item[variant], variant .. "-lrt", false)
    local tempPoleEntity = flib.copy_prototype(data.raw["electric-pole"][variant], variant .. "-lrt", false)
    tempPoleItem.place_result = tempPoleEntity.name
    tempPoleItem.flags = { "hidden" }

    local c = tempPoleEntity.collision_box[2][1] / 2
    tempPoleEntity.minable = { result = tempPoleItem.name, mining_time = data.raw.roboport[const.rt].minable.mining_time }

    -- Основной предмет
    local itemTurret = flib.copy_prototype(data.raw.item[const.rt], name, false)
    itemTurret.icons = flib.create_icons(itemTurret, { const.lighted_icon })
    itemTurret.order = "b[turret]-az[" .. const.rt .. "]-az[" .. name .. "]"
    itemTurret.localised_name = { const.rt .. "-" .. variant }
    itemTurret.place_result = "lighted-" .. tempPoleEntity.name

    -- Невидимая турель
    local entityTurret = flib.copy_prototype(data.raw.roboport[const.rt], name, false)
    entityTurret.name = itemTurret.name
    entityTurret.localised_name = { "rlt-turret-access-point" }
    entityTurret.flags = { "not-blueprintable", "not-deconstructable", "no-copy-paste", "placeable-neutral",
        "not-upgradable" }
    entityTurret.selection_box = { { -c, -c }, { c, c } }
    entityTurret.collision_mask = { "resource-layer" }
    entityTurret.selection_priority = 60
    entityTurret.base.layers[1].filename = const.mod_id .. "/graphics/repair_turret_crop.png"
    entityTurret.base.layers[2].filename = const.mod_id .. "/graphics/repair_turret_shadow_crop.png"
    entityTurret.base_animation.layers[1].filename = const.mod_id .. "/graphics/hr-roboport-base-animation_crop.png"

    --
    local tech_unit, prerequisites, cable_count = find_variant_technology_info(variant, const.rt .. "-lightning")

    local technology = {
        type = "technology",
        name = name,
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
        enabled = false,
        energy_required = 20,
        ingredients = {
            { const.rt, 1 },
            { "copper-cable", cable_count },
            { "lighted-" .. variant, 1 }
        },
        result = name,
    }

    return tempPoleItem, tempPoleEntity, itemTurret, entityTurret, technology, recipe
end

local tech_unit, prerequisites = find_variant_technology_info("small-lamp", const.rt)
data:extend({
    -- Базовая технология - ничего не открывает. Чисто для усложнения.
    { type = "technology",
        name = const.rt .. "-lightning",
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

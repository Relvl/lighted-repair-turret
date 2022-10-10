local flib = require('__flib__.data-util')
local flib_table = require('__flib__.table')
local const = require("util.const")
local find_variant_technology_info = require("util.find_variant_technology_info")
local img = const.mod_id .. "/graphics/entity/"

--[[ todo! Klonan не предусмотрел возможности копировать прото турели... 
    Ждем его одобрения на PR, или когда сам сделает.
    Пока что просто создаем обычную турель, если нет интерфейса.
    ------------------------------------------------------------------------
    Создаем копию турели, назначаем ей новые тайлы, и вообще настраиваем её.
    Эта турель будет создаваться автоматически при установке нового столба.
]]
local function make_repair_turret_proto(variant, tempPoleEntity)
    if const.rt_remote_present then
        local name = "repair-turret-" .. variant
        local entityTurret = flib.copy_prototype(data.raw.roboport[const.rt], name, false)
        entityTurret.localised_name = { "rlt-turret-access-point" }
        entityTurret.flags = {
            "not-blueprintable",
            "not-deconstructable",
            "no-copy-paste",
            "placeable-neutral",
            "not-upgradable"
        }
        local c = tempPoleEntity.collision_box[2][1] / 2
        entityTurret.selection_box = { { -c, -c }, { c, c } }
        entityTurret.collision_mask = { "resource-layer" }
        entityTurret.selection_priority = 60

        entityTurret.base.layers[1].filename = img .. "repair_turret_slim.png"
        entityTurret.base.layers[2].filename = img .. "repair_turret_shadow_slim.png"

        entityTurret.base_animation.layers[1].filename = img .. "hr-roboport-base-animation_crop.png"

        data:extend({ entityTurret })
    end
end

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

    tempPoleEntity.minable = { result = tempPoleItem.name, mining_time = data.raw.roboport[const.rt].minable.mining_time }
    tempPoleEntity.pictures.layers[1] = flib_table.deep_merge({
        tempPoleEntity.pictures.layers[1].hr_version, {
            filename = img .. "hr-" .. variant .. ".png"
        }
    })

    if not const.rt_remote_present then
        tempPoleEntity.flags = {
            "placeable-neutral",
            "not-upgradable",
            "player-creation"
        }
        local c = tempPoleEntity.collision_box[2][1] / 1.07
        tempPoleEntity.selection_box = { { -c, -c }, { c, c } }
        tempPoleEntity.selection_priority = 60
    end

    -- Основной предмет
    local itemTurret = flib.copy_prototype(data.raw.item[const.rt], name, false)
    itemTurret.icons = flib.create_icons(itemTurret, { const.lighted_icon })
    itemTurret.order = "b[turret]-az[" .. const.rt .. "]-az[" .. name .. "]"
    itemTurret.localised_name = { const.rt .. "-" .. variant }
    itemTurret.place_result = "lighted-" .. tempPoleEntity.name

    make_repair_turret_proto(variant, tempPoleEntity)

    local tech_unit, prerequisites, cable_count = find_variant_technology_info(variant, const.rt .. "-lightning")

    local technology = {
        type = "technology",
        name = name,
        icon_size = 182,
        icon = const.mod_id .. "/graphics/technology/repair_turret_icon.png",
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

    return tempPoleItem, tempPoleEntity, itemTurret, technology, recipe
end

local tech_unit, prerequisites = find_variant_technology_info("small-lamp", const.rt)
data:extend({
    -- Базовая технология - ничего не открывает. Чисто для усложнения.
    { type = "technology",
        name = const.rt .. "-lightning",
        icon_size = 182,
        icon = const.mod_id .. "/graphics/technology/repair_turret_icon.png",
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

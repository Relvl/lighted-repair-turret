local flib = require('__flib__.data-util')
local mod_id = "__lighted-repair-turret__"
require(mod_id .. ".data.technologies")

-- Основная концепция в том, что мы создаем столб по внешнему виду неотличимый от ремонтной турели.
-- LPP+ для такого столба создаст "ламповую" версию, и затем мы удаляем оригинальный столб. В итоге при постройке LPP+ будет спавнить свою лампу в него.
-- Далее мы создаем невидимую копию турели, которую так же спавним при установке этого столба.
-- В итоге мы сможем ставить турели как столбы, протягиванием. К тому же будут видны тени проводов перед установкой. Шикарно.

-- Переменная локальная в LPP+, копипастим...
local lighted_icon = { icon = "__LightedPolesPlus__/graphics/icons/lighted.png",
    icon_size = 32,
    tint = { r = 1, g = 1, b = 1, a = 0.85 }
}

-- Копии прототипов столбов. LightedPolesPlus сдалает из них освещенные столбы, которые будут создаваться при установке ремонтных турелей.
-- Затем эти прототипы удалятся в data-updates.lua
local function make_temporary_pole(oldName)
    local tempItem = flib.copy_prototype(data.raw.item[oldName], oldName .. "-lrt", false)
    local tempPole = flib.copy_prototype(data.raw["electric-pole"][oldName], oldName .. "-lrt", false)
    local c = tempPole.collision_box[2][1] / 2
    tempItem.place_result = tempPole.name
    tempPole.minable.result = tempItem.name
    tempPole.selection_box = { { -c, -c }, { c, c } }
    tempPole.collision_mask = { "resource-layer" }
    tempPole.working_sound = nil
    tempPole.selection_priority = 60
    return { tempItem, tempPole }
end

data:extend(make_temporary_pole("big-electric-pole"))
data:extend(make_temporary_pole("substation"))

local entityTurretPole = flib.copy_prototype(data.raw.roboport["repair-turret"], "repair-turret-pole", false)

local itemTurretPole = flib.copy_prototype(data.raw.item["repair-turret"], "repair-turret-pole", false)
itemTurretPole.icons = flib.create_icons(itemTurretPole, { lighted_icon })
itemTurretPole.order = "b[turret]-az[repair-turret]-az[repair-turret-pole]"

-- Турель с лампой и большим столбом
data:extend({
    entityTurretPole,
    itemTurretPole,
    {
        type = "recipe",
        name = "repair-turret-pole",
        localised_name = { "repair-turret-pole" },
        enabled = false,
        energy_required = 20,
        ingredients = {
            { "repair-turret", 1 },
            { "copper-cable", 20 },
            { "lighted-big-electric-pole", 1 }
        },
        result = "repair-turret-pole",
    },

})

local entityTurretSubstation = flib.copy_prototype(data.raw.roboport["repair-turret"], "repair-turret-substation", false)

local itemTurretSubstation = flib.copy_prototype(data.raw.item["repair-turret"], "repair-turret-substation", false)
itemTurretSubstation.icons = flib.create_icons(itemTurretSubstation, { lighted_icon })
itemTurretSubstation.order = "b[turret]-az[repair-turret]-az[repair-turret-substation]"

-- Турель с лампой и подстанцией
data:extend({
    entityTurretSubstation,
    itemTurretSubstation,
    {
        type = "recipe",
        name = itemTurretSubstation.name,
        localised_name = { itemTurretSubstation.name },
        enabled = false,
        energy_required = 20,
        ingredients = {
            { "repair-turret", 1 },
            { "copper-cable", 100 },
            { "lighted-substation", 1 }
        },
        result = itemTurretSubstation.name,
    }
})

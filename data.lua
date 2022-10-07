local flib = require('__flib__.data-util')

--- Считает потребляемые бутылки для зависимостей технологии. Фактически, суммирует время, количество, и типы всех зависимостей
local function calc_tech_units(reqs)
    local result = { count = 0, ingredients = {}, time = 0 }
    for _, tech_name in pairs(reqs) do
        local tech = data.raw.technology[tech_name]
        if tech then
            result.count = result.count + tech.unit.count
            result.time = result.time + tech.unit.time
            -- Проверяем, есть ли в результатах все типы бутылок от зависимости
            if tech.unit.ingredients then
                for _, ingredient in pairs(tech.unit.ingredients) do
                    local ing_found = false
                    for _, res_ing in pairs(result.ingredients) do
                        if res_ing[1] == ingredient[1] then
                            ing_found = true
                            break
                        end
                    end
                    -- Добавляем тип бутылки, если не добавляли ранее
                    if not ing_found then
                        table.insert(result.ingredients, ingredient)
                    end
                end
            end
        end
    end
    return result
end

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

-- Базовая технология - ничего не открывает.
data:extend({
    {
        type = "technology",
        name = "lighted-rep-turret",
        localised_name = { "lighted-rep-turret" },
        icon_size = 182,
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        prerequisites = { "optics", "repair-turret" },
        unit = calc_tech_units({ "optics", "repair-turret" }),
        order = "c-k-a",
    },
})

-- Турель с лампой и большим столбом
data:extend({
    -- Копия repair-turret, которая при установке спавнит столб
    flib.copy_prototype(data.raw.roboport["repair-turret"], "repair-turret-pole", false),
    {
        type = "item",
        name = "repair-turret-pole",
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        icon_size = 182,
        --- flags = {"goes-to-quickbar"},
        subgroup = "defensive-structure",
        order = "b[turret]-az[repair-turret]-az[rep-turret-light]",
        place_result = "repair-turret-pole",
        stack_size = 10
    },
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
    {
        type = "technology",
        name = "repair-turret-pole",
        localised_name = { "repair-turret-pole" },
        icon_size = 182,
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        effects = { { type = "unlock-recipe", recipe = "repair-turret-pole" } },
        prerequisites = { "electric-energy-distribution-1", "lighted-rep-turret" },
        unit = calc_tech_units({ "electric-energy-distribution-1", "lighted-rep-turret" }),
        order = "c-k-a",
    }
})


-- Турель с лампой и подстанцией
data:extend({
    -- Копия repair-turret, которая при установке спавнит подстанцию
    flib.copy_prototype(data.raw.roboport["repair-turret"], "repair-turret-substation", false),
    {
        type = "item",
        name = "repair-turret-substation",
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        icon_size = 182,
        --- flags = {"goes-to-quickbar"},
        subgroup = "defensive-structure",
        order = "b[turret]-az[repair-turret]-az[rep-turret-light]",
        place_result = "repair-turret-substation",
        stack_size = 10
    },
    {
        type = "recipe",
        name = "repair-turret-substation",
        localised_name = { "repair-turret-substation" },
        enabled = false,
        energy_required = 20,
        ingredients = {
            { "repair-turret", 1 },
            { "copper-cable", 100 },
            { "lighted-substation", 1 }
        },
        result = "repair-turret-substation",
    },
    {
        type = "technology",
        name = "repair-turret-substation",
        localised_name = { "repair-turret-substation" },
        icon_size = 182,
        icon = "__lighted-repair-turret__/graphics/technology/repair_turret_icon.png",
        effects = { { type = "unlock-recipe", recipe = "repair-turret-substation" } },
        prerequisites = { "electric-energy-distribution-2", "repair-turret-pole" },
        unit = calc_tech_units({ "electric-energy-distribution-2", "repair-turret-pole" }),
        order = "c-k-a",
    }
})

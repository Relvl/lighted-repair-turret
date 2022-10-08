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

data:extend({
    -- Базовая технология - ничего не открывает. Чисто для усложнения?
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
    --
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
    },
    --
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

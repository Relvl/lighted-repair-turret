local flib_table = require('__flib__.table')

return function(variant, additional_tech)
    local found_recipes = {}
    for rec_name, recipe in pairs(data.raw.recipe) do
        if recipe.result == variant or
            (recipe.normal and recipe.normal.result == variant) or
            (recipe.expensive and recipe.expensive.result == variant)
        then
            found_recipes[rec_name] = recipe
        end
        -- todo! recipe.results
    end

    local variant_technology = {}
    for tech_name, tech in pairs(data.raw.technology) do
        if tech.effects then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" and found_recipes[effect.recipe] then
                    variant_technology[tech_name] = tech
                end
            end
        end
    end

    if additional_tech then
        variant_technology[additional_tech] = data.raw.technology[additional_tech]
    end

    -- Берем все требемые технологии (плюс технологию самой турели), суммируем их стоимость, время
    local prerequisites = {}
    local tech_unit = { count = 0, ingredients = {}, time = 0 }
    for tech_name, tech in pairs(variant_technology) do
        tech_unit.count = tech_unit.count + tech.unit.count
        tech_unit.time = tech_unit.time + tech.unit.time
        tech_unit.ingredients = flib_table.deep_merge({ tech_unit.ingredients, tech.unit.ingredients })
        table.insert(prerequisites, tech_name)
    end

    -- Считаем количество кабеля, необходимого для крафта варианта
    local cable_count = 10
    for _, recipe in pairs(found_recipes) do
        for _, ing in pairs(recipe.ingredients) do
            cable_count = cable_count + ing[2]
        end
    end

    return tech_unit, prerequisites, cable_count * 1.5
end

local const = require("util.const")

-- Нужно удалить весь мусор за собой и за LPP+
for _, variant in pairs(const.variants) do
    local name = variant .. "-lrt"
    local lighed_name = "lighted-" .. name
    data.raw.item[name] = nil
    data.raw["electric-pole"][name] = nil
    data.raw.recipe[lighed_name] = nil

    -- Производить фейковые столбы мы не планируем.
    -- Ищем по всем рецептам и удаляем.
    -- Черт знает, куда автор LPP+ может записать рецепты... Сейчас это optics
    for _, recipe in pairs(data.raw.technology) do
        local effects_copy = recipe.effects or {}
        for eff_idx, effect in pairs(effects_copy) do
            if effect.type == "unlock-recipe" and effect.recipe == lighed_name then
                table.remove(data.raw.technology.optics.effects, eff_idx)
            end
        end
    end

    if const.rt_remote_present then
        data.raw.item[lighed_name].place_result = "repair-turret-" .. variant
        data.raw["roboport"]["repair-turret-" .. variant].minable.result = "repair-turret-" .. variant
    else
        data.raw["electric-pole"][lighed_name].localised_name = { "entity-name.rlt-turret-power-point" }
    end

    data.raw["electric-pole"][lighed_name].minable.result = "repair-turret-" .. variant
    data.raw.item[lighed_name].place_result = nil
end

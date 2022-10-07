local flib = require('__flib__.data-util')

local function remove_temporary_protos(names)
    for _, name in pairs(names) do
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
    end
end

-- Нужно удалить весь мусор за собой и за LPP+
remove_temporary_protos({
    "big-electric-pole-lrt",
    "substation-lrt"
})
